#!/usr/bin/env python3
"""MERG production/state drift checker.

The checker is intentionally production-first:
- public runtime checks are always performed;
- authenticated GitHub/Vercel/Supabase checks run only when credentials exist;
- missing credentials are reported as UNVERIFIED, never as success;
- known documented defects do not create repeat alerts unless reality changes.
"""

from __future__ import annotations

import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
REPORT_JSON = ROOT / "state_drift_report.json"
REPORT_MD = ROOT / "state_drift_report.md"

POWERLUX_URL = "https://powerlux-luxembourg.vercel.app"
POWERLUX_SPORTS_URL = (
    "https://powerlux-luxembourg.vercel.app/api/sports"
    "?lat=49.6116&lng=6.1319&radius=10"
)
POWERTV_URL = "https://powertv-network.lucienne-ruppert.chatgpt.site"
POWERTV_LOGO_URL = "https://powertv-network.lucienne-ruppert.chatgpt.site/powertv-logo.jpg"
COGNI_URL = "https://cogni-release.vercel.app"


@dataclass
class Check:
    name: str
    state: str  # OK | ALIGNED | UNVERIFIED | DRIFT
    severity: str  # info | warning | critical
    detail: str
    evidence: str = ""


checks: list[Check] = []


def add(name: str, state: str, severity: str, detail: str, evidence: str = "") -> None:
    checks.append(Check(name=name, state=state, severity=severity, detail=detail, evidence=evidence))


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        return ""


def http_get(url: str, headers: dict[str, str] | None = None, timeout: int = 20) -> tuple[int, str, str]:
    request_headers = {
        "User-Agent": "MERG-State-Drift-Watch/1.0",
        "Accept": "text/html,application/json;q=0.9,*/*;q=0.8",
    }
    if headers:
        request_headers.update(headers)
    req = urllib.request.Request(url, headers=request_headers)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            body = resp.read(1_000_000).decode("utf-8", errors="replace")
            return int(resp.status), resp.geturl(), body
    except urllib.error.HTTPError as exc:
        body = exc.read(1_000_000).decode("utf-8", errors="replace")
        return int(exc.code), exc.geturl(), body
    except Exception as exc:  # network/DNS/TLS failure
        return 0, url, f"{type(exc).__name__}: {exc}"


def api_json(url: str, token: str, *, bearer: bool = True) -> tuple[int, Any]:
    auth_value = f"Bearer {token}" if bearer else f"token {token}"
    status, _, body = http_get(
        url,
        headers={
            "Authorization": auth_value,
            "Accept": "application/json",
        },
    )
    try:
        return status, json.loads(body)
    except json.JSONDecodeError:
        return status, {"raw": body[:1000]}


def login_redirect(final_url: str) -> bool:
    lowered = final_url.lower()
    return "vercel.com/login" in lowered or "/sso-api" in lowered


def require_docs() -> tuple[str, str, str]:
    required = [
        ROOT / "AGENTS.md",
        ROOT / "merg_os" / "CURRENT_STATE.md",
        ROOT / "merg_os" / "PROJECT_REGISTRY.md",
        ROOT / "merg_os" / "PRODUCTION_GATES.md",
        ROOT / "powerlux_os" / "CURRENT_STATE.md",
    ]
    for path in required:
        if path.exists():
            add("canonical-doc", "OK", "info", f"Present: {path.relative_to(ROOT)}")
        else:
            add("canonical-doc", "DRIFT", "critical", f"Required source-of-truth file missing: {path.relative_to(ROOT)}")
    return (
        read_text(ROOT / "merg_os" / "CURRENT_STATE.md"),
        read_text(ROOT / "merg_os" / "PROJECT_REGISTRY.md"),
        read_text(ROOT / "powerlux_os" / "CURRENT_STATE.md"),
    )


def check_mockup_guard(merg_state: str, registry: str) -> None:
    wrong_powertv = ROOT / "powertv" / "index.html"
    if wrong_powertv.exists():
        add(
            "powertv-source-guard",
            "DRIFT",
            "critical",
            "A local powertv/index.html exists while PowerTV canonical source is still documented as unverified. This can become another replacement/mockup path.",
            str(wrong_powertv.relative_to(ROOT)),
        )
    else:
        add("powertv-source-guard", "OK", "info", "No replacement powertv/index.html is present.")

    source_unverified = (
        "No canonical PowerTV GitHub repository is currently verified" in merg_state
        or "No canonical Git source verified yet" in registry
    )
    if source_unverified:
        add("powertv-canonicality", "ALIGNED", "info", "PowerTV remains explicitly source-unverified; replacement builds are blocked.")
    else:
        add(
            "powertv-canonicality",
            "DRIFT",
            "warning",
            "PowerTV no longer appears explicitly source-unverified. Verify that the ORIGINAL ChatGPT Sites source was actually recovered before treating any Git/Vercel project as canonical.",
        )


def check_powertv_runtime() -> None:
    status, final_url, body = http_get(POWERTV_URL)
    if status != 200 or login_redirect(final_url):
        add(
            "powertv-runtime",
            "DRIFT",
            "critical",
            f"Original PowerTV runtime is not publicly reachable as expected (HTTP {status}, final={final_url}).",
            POWERTV_URL,
        )
        return

    forbidden_markers = ["Strength has a screen", "INTERNAL RELEASE", "PowerTV Internal Release"]
    bad = [marker for marker in forbidden_markers if marker.lower() in body.lower()]
    if bad:
        add(
            "powertv-runtime-identity",
            "DRIFT",
            "critical",
            "PowerTV runtime contains markers from the previously rejected replacement/mockup: " + ", ".join(bad),
            POWERTV_URL,
        )
        return

    # ChatGPT Sites is a dynamic client application. The raw HTTP shell does not
    # reliably contain rendered labels such as MY PLX. Do not create a false
    # critical alert merely because client-rendered text is absent. Instead,
    # combine public root reachability, known original asset reachability and
    # explicit rejection-marker checks.
    identity_markers = ["PowerTV", "MY PLX", "Dein Sport wird geladen", "powertv-logo.jpg"]
    hits = [marker for marker in identity_markers if marker.lower() in body.lower()]
    logo_status, logo_final, _ = http_get(POWERTV_LOGO_URL)

    if logo_status == 200 and not login_redirect(logo_final):
        if hits:
            detail = "Original PowerTV public shell/asset verification passed; raw shell markers: " + ", ".join(hits)
        else:
            detail = "Original PowerTV root and canonical logo asset are publicly reachable. Rendered identity text is client-side and therefore not required in raw HTML."
        add("powertv-runtime-identity", "OK", "info", detail, POWERTV_URL)
    elif hits:
        add(
            "powertv-runtime-identity",
            "ALIGNED",
            "info",
            "PowerTV root contains original identity markers, but the canonical logo asset could not be independently confirmed in this run.",
            POWERTV_URL,
        )
    else:
        add(
            "powertv-runtime-identity",
            "DRIFT",
            "critical",
            f"PowerTV root is reachable but neither original raw-shell markers nor the canonical logo asset could be verified (logo HTTP {logo_status}).",
            POWERTV_URL,
        )


def check_powerlux_runtime(powerlux_state: str) -> None:
    status, final_url, body = http_get(POWERLUX_URL)
    if status != 200 or login_redirect(final_url):
        add(
            "powerlux-runtime",
            "DRIFT",
            "critical",
            f"PowerLux production root is not publicly reachable as expected (HTTP {status}, final={final_url}).",
            POWERLUX_URL,
        )
    elif "powerlux" not in body.lower():
        add(
            "powerlux-runtime-identity",
            "DRIFT",
            "warning",
            "PowerLux root returned HTTP 200 but the response did not contain a recognizable PowerLux identity marker.",
            POWERLUX_URL,
        )
    else:
        add("powerlux-runtime", "OK", "info", "PowerLux production root returns HTTP 200 with PowerLux identity.", POWERLUX_URL)

    documented_broken = bool(
        re.search(r"Production `/api/sports` currently returns 404", powerlux_state, re.IGNORECASE)
        or re.search(r"/api/sports.*404", powerlux_state, re.IGNORECASE | re.DOTALL)
    )
    api_status, api_final, _ = http_get(POWERLUX_SPORTS_URL)

    if documented_broken and api_status == 404:
        add(
            "powerlux-sports-api",
            "ALIGNED",
            "info",
            "Known /api/sports P0 defect still reproduces as documented (HTTP 404); not treated as a new alert.",
            POWERLUX_SPORTS_URL,
        )
    elif documented_broken and api_status != 404:
        add(
            "powerlux-sports-api",
            "DRIFT",
            "warning",
            f"Documented /api/sports 404 no longer matches runtime (now HTTP {api_status}). Verify whether the defect was fixed and update CURRENT_STATE.",
            POWERLUX_SPORTS_URL,
        )
    elif not documented_broken and api_status == 404:
        add(
            "powerlux-sports-api",
            "DRIFT",
            "critical",
            "/api/sports returns 404 but the current state no longer documents that as an open known defect.",
            POWERLUX_SPORTS_URL,
        )
    elif api_status == 0 or login_redirect(api_final):
        add(
            "powerlux-sports-api",
            "DRIFT",
            "critical",
            f"Could not verify PowerLux sports endpoint (HTTP {api_status}, final={api_final}).",
            POWERLUX_SPORTS_URL,
        )
    else:
        add("powerlux-sports-api", "OK", "info", f"PowerLux sports endpoint responds HTTP {api_status}.", POWERLUX_SPORTS_URL)


def check_cogni_runtime() -> None:
    status, final_url, body = http_get(COGNI_URL)
    if status != 200 or login_redirect(final_url):
        add(
            "cogni-runtime",
            "DRIFT",
            "critical",
            f"Cogni canonical public host is not publicly reachable as expected (HTTP {status}, final={final_url}).",
            COGNI_URL,
        )
    elif "cogni" not in body.lower():
        add(
            "cogni-runtime-identity",
            "DRIFT",
            "warning",
            "Cogni host returned HTTP 200 but no recognizable Cogni identity marker was found.",
            COGNI_URL,
        )
    else:
        add("cogni-runtime", "OK", "info", "Cogni public host returns HTTP 200 with Cogni identity.", COGNI_URL)


def check_cross_repo_github() -> None:
    token = os.getenv("MERG_GITHUB_TOKEN", "").strip()
    if not token:
        add(
            "github-cogni-cross-repo",
            "UNVERIFIED",
            "warning",
            "MERG_GITHUB_TOKEN is not configured; private Cogni cross-repo verification is skipped rather than assumed healthy.",
        )
        return

    headers = {"Authorization": f"Bearer {token}", "Accept": "application/vnd.github+json"}
    status, _, repo_body = http_get("https://api.github.com/repos/eristda000-create/cogni", headers=headers)
    agents_status, _, _ = http_get("https://api.github.com/repos/eristda000-create/cogni/contents/AGENTS.md", headers=headers)
    readme_status, _, readme_body = http_get("https://api.github.com/repos/eristda000-create/cogni/contents/README.md", headers=headers)

    if status != 200 or agents_status != 200 or readme_status != 200:
        add(
            "github-cogni-cross-repo",
            "DRIFT",
            "critical",
            f"Private Cogni source verification failed (repo={status}, AGENTS.md={agents_status}, README.md={readme_status}).",
        )
        return

    if "Canonical source repository" not in readme_body:
        # GitHub contents API returns base64/JSON, so this check is informational only.
        add("github-cogni-cross-repo", "OK", "info", "Cogni repo and required source-control files are reachable with authenticated GitHub access.")
    else:
        add("github-cogni-cross-repo", "OK", "info", "Cogni canonical repo and AI operating rules are reachable.")


def check_vercel_management() -> None:
    token = os.getenv("VERCEL_TOKEN", "").strip()
    team_id = os.getenv("VERCEL_TEAM_ID", "").strip()
    if not token or not team_id:
        add(
            "vercel-management",
            "UNVERIFIED",
            "warning",
            "VERCEL_TOKEN and/or VERCEL_TEAM_ID is not configured; authenticated Vercel project drift is not claimed as verified.",
        )
        return

    url = "https://api.vercel.com/v9/projects?" + urllib.parse.urlencode({"teamId": team_id, "limit": 100})
    status, payload = api_json(url, token)
    if status != 200 or not isinstance(payload, dict):
        add("vercel-management", "DRIFT", "critical", f"Vercel project inventory request failed with HTTP {status}.")
        return

    projects = payload.get("projects", []) or []
    names = {str(p.get("name", "")) for p in projects}
    if "powerlux-luxembourg" not in names:
        add(
            "vercel-powerlux-project",
            "DRIFT",
            "critical",
            "Expected Vercel project powerlux-luxembourg is missing from the authenticated team inventory.",
        )
    else:
        add("vercel-powerlux-project", "OK", "info", "Authenticated Vercel inventory contains powerlux-luxembourg.")

    powertv_projects = sorted(name for name in names if name.startswith("powertv"))
    if powertv_projects:
        add(
            "vercel-powertv-noncanonical",
            "ALIGNED",
            "info",
            "PowerTV-named Vercel projects exist but remain non-canonical until original source recovery: " + ", ".join(powertv_projects),
        )


def check_supabase_management() -> None:
    token = os.getenv("SUPABASE_ACCESS_TOKEN", "").strip()
    if not token:
        add(
            "supabase-management",
            "UNVERIFIED",
            "warning",
            "SUPABASE_ACCESS_TOKEN is not configured; management-level project health is skipped rather than assumed healthy.",
        )
        return

    status, payload = api_json("https://api.supabase.com/v1/projects", token)
    if status != 200 or not isinstance(payload, list):
        add("supabase-management", "DRIFT", "critical", f"Supabase management project inventory failed with HTTP {status}.")
        return

    cogni = [p for p in payload if str(p.get("name", "")).strip().lower() == "cogni"]
    if not cogni:
        add("supabase-cogni", "DRIFT", "critical", "Cogni Supabase project is missing from authenticated project inventory.")
        return

    cogni_status = str(cogni[0].get("status", "UNKNOWN"))
    if cogni_status != "ACTIVE_HEALTHY":
        add("supabase-cogni", "DRIFT", "critical", f"Cogni Supabase project health is {cogni_status}, expected ACTIVE_HEALTHY.")
    else:
        add("supabase-cogni", "OK", "info", "Cogni Supabase project reports ACTIVE_HEALTHY.")


def check_state_age(merg_state: str) -> None:
    match = re.search(r"\*\*As-of date:\*\*\s*(\d{4}-\d{2}-\d{2})", merg_state)
    if not match:
        add("state-age", "DRIFT", "warning", "MERG CURRENT_STATE has no parseable As-of date.")
        return
    try:
        as_of = datetime.strptime(match.group(1), "%Y-%m-%d").replace(tzinfo=timezone.utc)
        days = (datetime.now(timezone.utc) - as_of).days
    except ValueError:
        add("state-age", "DRIFT", "warning", "MERG CURRENT_STATE As-of date is malformed.")
        return
    if days > 14:
        add("state-age", "DRIFT", "warning", f"MERG CURRENT_STATE is {days} days old; review material cross-project facts.")
    else:
        add("state-age", "OK", "info", f"MERG CURRENT_STATE age is {days} day(s).")


def write_reports() -> None:
    now = datetime.now(timezone.utc).isoformat()
    critical = [c for c in checks if c.state == "DRIFT" and c.severity == "critical"]
    warnings = [c for c in checks if c.state == "DRIFT" and c.severity == "warning"]
    unverified = [c for c in checks if c.state == "UNVERIFIED"]

    payload = {
        "generated_at": now,
        "summary": {
            "critical_drift": len(critical),
            "warning_drift": len(warnings),
            "unverified": len(unverified),
            "total_checks": len(checks),
        },
        "checks": [asdict(c) for c in checks],
    }
    REPORT_JSON.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    lines = [
        "# MERG State Drift Report",
        "",
        f"Generated: `{now}`",
        "",
        f"- Critical drift: **{len(critical)}**",
        f"- Warning drift: **{len(warnings)}**",
        f"- Unverified external checks: **{len(unverified)}**",
        f"- Total checks: **{len(checks)}**",
        "",
    ]
    for c in checks:
        icon = {"OK": "✅", "ALIGNED": "✅", "UNVERIFIED": "⚪", "DRIFT": "🚨"}.get(c.state, "•")
        lines.extend(
            [
                f"## {icon} {c.name} — {c.state}/{c.severity}",
                "",
                c.detail,
                "",
            ]
        )
        if c.evidence:
            lines.extend([f"Evidence: `{c.evidence}`", ""])

    REPORT_MD.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    merg_state, registry, powerlux_state = require_docs()
    check_mockup_guard(merg_state, registry)
    check_state_age(merg_state)
    check_powertv_runtime()
    check_powerlux_runtime(powerlux_state)
    check_cogni_runtime()
    check_cross_repo_github()
    check_vercel_management()
    check_supabase_management()
    write_reports()

    critical = [c for c in checks if c.state == "DRIFT" and c.severity == "critical"]
    warnings = [c for c in checks if c.state == "DRIFT" and c.severity == "warning"]
    unverified = [c for c in checks if c.state == "UNVERIFIED"]
    print(f"MERG drift watch: critical={len(critical)} warning={len(warnings)} unverified={len(unverified)}")
    for item in critical + warnings:
        print(f"[{item.severity.upper()}] {item.name}: {item.detail}")
    if unverified:
        print("Unverified checks are recorded in the report and are never counted as healthy.")
    return 2 if critical else 0


if __name__ == "__main__":
    sys.exit(main())
