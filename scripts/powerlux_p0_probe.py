#!/usr/bin/env python3
"""PowerLux production/discovery P0 probe.

Purpose:
- verify the public PowerLux root separately from the PowerMap discovery route;
- verify the supported Supabase discovery upstream independently;
- emit machine-readable and human-readable evidence;
- fail closed when the production discovery contract is broken.

This script performs read-only HTTP checks. It does not deploy, mutate production,
or treat a recovery/preview path as canonical source.
"""

from __future__ import annotations

import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

PRODUCTION_ROOT = os.environ.get(
    "POWERLUX_PRODUCTION_ROOT", "https://powerlux-luxembourg.vercel.app"
).rstrip("/")
DISCOVERY_UPSTREAM = os.environ.get(
    "POWERLUX_DISCOVERY_UPSTREAM",
    "https://fgkowgpauqexcwwtrxyd.supabase.co/functions/v1/powerlux-discovery",
)
LAT = float(os.environ.get("POWERLUX_PROBE_LAT", "49.6116"))
LNG = float(os.environ.get("POWERLUX_PROBE_LNG", "6.1319"))
RADIUS = float(os.environ.get("POWERLUX_PROBE_RADIUS", "10"))
TIMEOUT = float(os.environ.get("POWERLUX_PROBE_TIMEOUT", "25"))
USER_AGENT = "PowerLux-P0-Probe/1.0"


@dataclass
class Check:
    name: str
    url: str
    status: str
    http_status: int | None
    latency_ms: int
    details: dict[str, Any]


def fetch(url: str) -> tuple[int | None, bytes, dict[str, str], str | None, int]:
    started = time.monotonic()
    req = urllib.request.Request(
        url,
        headers={"User-Agent": USER_AGENT, "Accept": "application/json,text/html;q=0.9,*/*;q=0.8"},
    )
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as response:
            body = response.read()
            headers = {k.lower(): v for k, v in response.headers.items()}
            return response.status, body, headers, None, int((time.monotonic() - started) * 1000)
    except urllib.error.HTTPError as exc:
        body = exc.read() if exc.fp else b""
        headers = {k.lower(): v for k, v in exc.headers.items()} if exc.headers else {}
        return exc.code, body, headers, str(exc), int((time.monotonic() - started) * 1000)
    except Exception as exc:  # noqa: BLE001 - report exact probe failure
        return None, b"", {}, f"{type(exc).__name__}: {exc}", int((time.monotonic() - started) * 1000)


def parse_json(body: bytes) -> Any | None:
    try:
        return json.loads(body.decode("utf-8"))
    except Exception:
        return None


def root_check() -> Check:
    status, body, headers, error, latency = fetch(PRODUCTION_ROOT + "/")
    text = body.decode("utf-8", errors="replace")[:20000]
    recovery_markers = [
        "plxRecovery",
        "PowerLux recovery layer",
        "powerlux-release.js",
    ]
    detected = [marker for marker in recovery_markers if marker in text]
    ok = status == 200
    return Check(
        name="production_root",
        url=PRODUCTION_ROOT + "/",
        status="PASS" if ok else "FAIL",
        http_status=status,
        latency_ms=latency,
        details={
            "error": error,
            "content_type": headers.get("content-type"),
            "recovery_loader_markers": detected,
            "note": (
                "HTTP 200 does not establish canonical source lineage; recovery markers are evidence only."
            ),
        },
    )


def sports_route_check() -> Check:
    query = urllib.parse.urlencode({"lat": LAT, "lng": LNG, "radius": RADIUS})
    url = f"{PRODUCTION_ROOT}/api/sports?{query}"
    status, body, headers, error, latency = fetch(url)
    payload = parse_json(body)
    valid_contract = (
        status == 200
        and isinstance(payload, dict)
        and isinstance(payload.get("places"), list)
    )
    return Check(
        name="production_api_sports",
        url=url,
        status="PASS" if valid_contract else "FAIL",
        http_status=status,
        latency_ms=latency,
        details={
            "error": error,
            "content_type": headers.get("content-type"),
            "json_object": isinstance(payload, dict),
            "places_array": isinstance(payload, dict) and isinstance(payload.get("places"), list),
            "places_count": len(payload.get("places", [])) if isinstance(payload, dict) and isinstance(payload.get("places"), list) else None,
            "version": payload.get("version") if isinstance(payload, dict) else None,
            "critical": not valid_contract,
        },
    )


def upstream_check() -> Check:
    query = urllib.parse.urlencode({"lat": LAT, "lng": LNG, "radius": RADIUS})
    url = f"{DISCOVERY_UPSTREAM}?{query}"
    status, body, headers, error, latency = fetch(url)
    payload = parse_json(body)
    valid_contract = (
        status == 200
        and isinstance(payload, dict)
        and isinstance(payload.get("places"), list)
    )
    return Check(
        name="discovery_upstream",
        url=url,
        status="PASS" if valid_contract else "FAIL",
        http_status=status,
        latency_ms=latency,
        details={
            "error": error,
            "content_type": headers.get("content-type"),
            "json_object": isinstance(payload, dict),
            "places_array": isinstance(payload, dict) and isinstance(payload.get("places"), list),
            "places_count": len(payload.get("places", [])) if isinstance(payload, dict) and isinstance(payload.get("places"), list) else None,
            "version": payload.get("version") if isinstance(payload, dict) else None,
            "sources": payload.get("sources") if isinstance(payload, dict) else None,
            "error_field": payload.get("error") if isinstance(payload, dict) else None,
        },
    )


def write_reports(checks: list[Check]) -> None:
    now = datetime.now(timezone.utc).isoformat()
    report = {
        "generated_at": now,
        "production_root": PRODUCTION_ROOT,
        "discovery_upstream": DISCOVERY_UPSTREAM,
        "probe": {"lat": LAT, "lng": LNG, "radius_km": RADIUS},
        "checks": [asdict(check) for check in checks],
        "critical_failures": [check.name for check in checks if check.status == "FAIL"],
    }
    Path("powerlux_p0_probe_report.json").write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )

    lines = [
        "# PowerLux P0 Discovery Probe",
        "",
        f"Generated: `{now}`",
        "",
        "| Check | Result | HTTP | Latency |",
        "|---|---:|---:|---:|",
    ]
    for check in checks:
        lines.append(
            f"| `{check.name}` | **{check.status}** | {check.http_status if check.http_status is not None else 'n/a'} | {check.latency_ms} ms |"
        )
    lines += ["", "## Evidence", ""]
    for check in checks:
        lines.append(f"### {check.name}")
        lines.append("")
        lines.append(f"- URL: `{check.url}`")
        for key, value in check.details.items():
            lines.append(f"- `{key}`: `{json.dumps(value, ensure_ascii=False)}`")
        lines.append("")
    Path("powerlux_p0_probe_report.md").write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    checks = [root_check(), sports_route_check(), upstream_check()]
    write_reports(checks)

    for check in checks:
        print(
            json.dumps(
                {
                    "check": check.name,
                    "status": check.status,
                    "http_status": check.http_status,
                    "latency_ms": check.latency_ms,
                    "details": check.details,
                },
                ensure_ascii=False,
            )
        )

    # The release gate is deliberately strict: all three contracts must be healthy.
    return 0 if all(check.status == "PASS" for check in checks) else 1


if __name__ == "__main__":
    sys.exit(main())
