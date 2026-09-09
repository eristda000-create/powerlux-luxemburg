#!/usr/bin/env python3
"""Read-only QA gate for the current PowerLux canonical-source recovery preview.

This does not promote or mutate production. It validates that the recovered preview
behaves like an auditable source-controlled candidate and checks known blockers
before PR #6 can be considered promotion-ready.
"""

from __future__ import annotations

import json
import os
import sys
import time
import urllib.error
import urllib.request
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

BASE = os.environ.get(
    "POWERLUX_CANDIDATE_URL",
    "https://powerlux-luxembourg-p0b1w7ine-eristda000-2732s-projects.vercel.app",
).rstrip("/")
TIMEOUT = float(os.environ.get("POWERLUX_CANDIDATE_TIMEOUT", "20"))
UA = "PowerLux-Canonical-Candidate-Probe/1.1"


@dataclass
class Check:
    name: str
    status: str
    details: dict[str, Any]


def fetch(path: str) -> tuple[int | None, str, dict[str, str], str | None, int]:
    url = BASE + path
    started = time.monotonic()
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "*/*"})
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as response:
            data = response.read().decode("utf-8", errors="replace")
            headers = {k.lower(): v for k, v in response.headers.items()}
            return response.status, data, headers, None, int((time.monotonic() - started) * 1000)
    except urllib.error.HTTPError as exc:
        data = exc.read().decode("utf-8", errors="replace") if exc.fp else ""
        headers = {k.lower(): v for k, v in exc.headers.items()} if exc.headers else {}
        return exc.code, data, headers, str(exc), int((time.monotonic() - started) * 1000)
    except Exception as exc:  # noqa: BLE001
        return None, "", {}, f"{type(exc).__name__}: {exc}", int((time.monotonic() - started) * 1000)


def endpoint_check(path: str, name: str) -> Check:
    status, body, headers, error, latency = fetch(path)
    return Check(
        name=name,
        status="PASS" if status == 200 else "FAIL",
        details={
            "path": path,
            "http_status": status,
            "latency_ms": latency,
            "error": error,
            "content_type": headers.get("content-type"),
            "x_robots_tag": headers.get("x-robots-tag"),
            "body_chars": len(body),
        },
    )


def root_check() -> tuple[Check, str, dict[str, str]]:
    status, body, headers, error, latency = fetch("/")
    recovery_markers = [
        marker
        for marker in ("plxRecovery", "PowerLux recovery layer", "powerlux-release.js")
        if marker in body
    ]
    candidate_markers = [
        marker for marker in ("PowerLux", "MY PLX", "PowerMap") if marker in body
    ]
    noindex = "noindex" in (headers.get("x-robots-tag") or "").lower()
    ok = status == 200 and not recovery_markers and len(candidate_markers) >= 2 and noindex
    return (
        Check(
            name="candidate_root",
            status="PASS" if ok else "FAIL",
            details={
                "http_status": status,
                "latency_ms": latency,
                "error": error,
                "recovery_loader_markers": recovery_markers,
                "candidate_markers": candidate_markers,
                "preview_noindex": noindex,
            },
        ),
        body,
        headers,
    )


def runtime_contract_check() -> Check:
    status, body, _headers, error, latency = fetch("/powerlux-runtime.js")
    discovery = "powerlux-discovery" in body
    revenue = "powerlux-revenue-intake" in body
    ok = status == 200 and discovery and revenue
    return Check(
        name="runtime_contract",
        status="PASS" if ok else "FAIL",
        details={
            "http_status": status,
            "latency_ms": latency,
            "error": error,
            "discovery_endpoint_present": discovery,
            "revenue_intake_present": revenue,
        },
    )


def radar_guard_check() -> Check:
    status, body, _headers, error, latency = fetch("/plx-radar-v3.js")
    compact = "".join(body.split())

    # Known unsafe candidate behavior: accepting a places array without honoring the
    # upstream error field can turn a degraded backend into a false zero-result scan.
    references_error = (
        "j.error" in body
        or "j?.error" in body
        or (".error" in body and "discovery_temporarily_unavailable" in body)
    )
    accepts_places = "Array.isArray(j.places)" in body or "Array.isArray(j?.places)" in body

    # Do not let whitespace/minification make the startup geolocation regression pass.
    # PR #6 currently defines firstPosition directly from navigator.geolocation and
    # resolves it during init; that can prompt before a deliberate Scan action.
    known_unconditional_geo = (
        "constfirstPosition=navigator.geolocation" in compact
        and "navigator.geolocation.getCurrentPosition(" in compact
        and "firstPosition.then(" in compact
    )
    permissions_api = "navigator.permissions" in body

    degraded_ok = status == 200 and accepts_places and references_error
    geo_ok = status == 200 and not known_unconditional_geo and permissions_api
    return Check(
        name="radar_degraded_and_geolocation_guard",
        status="PASS" if degraded_ok and geo_ok else "FAIL",
        details={
            "http_status": status,
            "latency_ms": latency,
            "error": error,
            "places_contract_seen": accepts_places,
            "explicit_upstream_error_handling_seen": references_error,
            "known_unconditional_startup_geolocation_seen": known_unconditional_geo,
            "permissions_api_seen": permissions_api,
            "degraded_state_gate": "PASS" if degraded_ok else "FAIL",
            "geolocation_gate": "PASS" if geo_ok else "FAIL",
        },
    )


def contact_copy_check(root_body: str) -> Check:
    old_label = "E-Mail vorbereiten" in root_body
    revenue_copy = any(
        needle in root_body
        for needle in ("Anfrage senden", "Kontakt senden", "Partneranfrage senden")
    )
    ok = not old_label and revenue_copy
    return Check(
        name="contact_copy_matches_server_submission",
        status="PASS" if ok else "FAIL",
        details={
            "legacy_mail_label_present": old_label,
            "server_submission_label_seen": revenue_copy,
        },
    )


def tracking_route_check() -> Check:
    status, _body, headers, error, latency = fetch("/api/track")
    # Canonical recovery should preserve the existing POST-only production contract.
    ok = status == 405 and "POST" in (headers.get("allow") or "").upper()
    return Check(
        name="tracking_route_recovered",
        status="PASS" if ok else "FAIL",
        details={
            "http_status": status,
            "latency_ms": latency,
            "error": error,
            "allow": headers.get("allow"),
            "expected": "GET should return 405 with Allow: POST, matching current production contract",
        },
    )


def main() -> int:
    checks: list[Check] = []
    root, root_body, _ = root_check()
    checks.append(root)
    for path, name in (
        ("/robots.txt", "robots"),
        ("/sitemap.xml", "sitemap"),
        ("/privacy", "privacy"),
        ("/powerlux-runtime.js", "runtime_asset"),
        ("/plx-radar-v3.js", "radar_asset"),
    ):
        checks.append(endpoint_check(path, name))
    checks.append(runtime_contract_check())
    checks.append(radar_guard_check())
    checks.append(contact_copy_check(root_body))
    checks.append(tracking_route_check())

    generated = datetime.now(timezone.utc).isoformat()
    report = {
        "generated_at": generated,
        "candidate_url": BASE,
        "checks": [asdict(c) for c in checks],
        "failures": [c.name for c in checks if c.status == "FAIL"],
        "promotion_ready": all(c.status == "PASS" for c in checks),
    }
    Path("powerlux_candidate_probe_report.json").write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )

    lines = [
        "# PowerLux Canonical Recovery Candidate Gate",
        "",
        f"Candidate: `{BASE}`",
        f"Generated: `{generated}`",
        "",
        "| Check | Result |",
        "|---|---:|",
    ]
    lines += [f"| `{c.name}` | **{c.status}** |" for c in checks]
    lines += ["", "## Details", ""]
    for c in checks:
        lines.append(f"### {c.name}")
        for key, value in c.details.items():
            lines.append(f"- `{key}`: `{json.dumps(value, ensure_ascii=False)}`")
        lines.append("")
    Path("powerlux_candidate_probe_report.md").write_text("\n".join(lines), encoding="utf-8")

    for c in checks:
        print(json.dumps({"check": c.name, "status": c.status, **c.details}, ensure_ascii=False))

    return 0 if report["promotion_ready"] else 1


if __name__ == "__main__":
    sys.exit(main())
