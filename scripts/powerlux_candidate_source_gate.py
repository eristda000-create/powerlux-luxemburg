#!/usr/bin/env python3
"""Source-level acceptance gate for the PowerLux canonical recovery PR.

Unlike the external preview probe, this checks the source currently checked out by
GitHub Actions. It is intentionally narrow: it protects the known P0/privacy/UX
contracts without trying to certify the entire application.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path


def read(path: str) -> str:
    p = Path(path)
    if not p.is_file():
        return ""
    return p.read_text(encoding="utf-8", errors="replace")


def result(name: str, ok: bool, **details):
    row = {"check": name, "status": "PASS" if ok else "FAIL", **details}
    print(json.dumps(row, ensure_ascii=False))
    return ok, row


def main() -> int:
    index = read("index.html")
    runtime = read("powerlux-runtime.js")
    radar = read("plx-radar-v3.js")
    vercel = read("vercel.json")
    compact_radar = "".join(radar.split())

    checks = []

    checks.append(result(
        "canonical_source_present",
        bool(index) and "PowerLux" in index and "MY PLX" in index,
        index_chars=len(index),
    ))

    recovery_markers = [m for m in ("plxRecovery", "PowerLux recovery layer") if m in index]
    checks.append(result(
        "no_recovery_loader_shell",
        bool(index) and not recovery_markers,
        recovery_markers=recovery_markers,
    ))

    checks.append(result(
        "supported_runtime_endpoints",
        "powerlux-discovery" in runtime and "powerlux-revenue-intake" in runtime,
        discovery="powerlux-discovery" in runtime,
        revenue="powerlux-revenue-intake" in runtime,
    ))

    places_contract = "Array.isArray(j.places)" in radar or "Array.isArray(j?.places)" in radar
    explicit_error = "j.error" in radar or "j?.error" in radar or "discovery_temporarily_unavailable" in radar
    checks.append(result(
        "discovery_degraded_state_is_explicit",
        bool(radar) and places_contract and explicit_error,
        places_contract=places_contract,
        explicit_error_handling=explicit_error,
    ))

    startup_geo = (
        "constfirstPosition=navigator.geolocation" in compact_radar
        and "navigator.geolocation.getCurrentPosition(" in compact_radar
        and "firstPosition.then(" in compact_radar
    )
    permissions_api = "navigator.permissions" in radar
    checks.append(result(
        "no_unconditional_startup_geolocation",
        bool(radar) and not startup_geo and permissions_api,
        startup_geolocation_pattern=startup_geo,
        permissions_api=permissions_api,
    ))

    legacy_mail_copy = "E-Mail vorbereiten" in index
    server_submit_copy = any(x in index for x in ("Anfrage senden", "Kontakt senden", "Partneranfrage senden"))
    checks.append(result(
        "contact_copy_matches_server_submission",
        bool(index) and not legacy_mail_copy and server_submit_copy,
        legacy_mail_copy=legacy_mail_copy,
        server_submit_copy=server_submit_copy,
    ))

    # Current production has a real POST-only /api/track contract. The recovered
    # candidate must preserve or deliberately replace it before dependent PR #8 can
    # ship its powertv_open tracking. A route/rewrite string alone is not enough to
    # certify server behavior, but absence is a definite blocker.
    tracking_sources = [
        Path("api/track.js"), Path("api/track.ts"), Path("api/track.mjs"),
        Path("api/track/index.js"), Path("api/track/index.ts"),
        Path("api/track/index.mjs"),
    ]
    tracking_file = next((str(p) for p in tracking_sources if p.is_file()), None)
    tracking_route_declared = "/api/track" in vercel
    checks.append(result(
        "tracking_contract_source_present",
        bool(tracking_file),
        tracking_file=tracking_file,
        vercel_route_reference=tracking_route_declared,
        note="A verified server implementation is required; current production GET contract is 405 Allow: POST.",
    ))

    report = {
        "checks": [row for _ok, row in checks],
        "failures": [row["check"] for ok, row in checks if not ok],
        "source_ready": all(ok for ok, _row in checks),
    }
    Path("powerlux_candidate_source_gate_report.json").write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    return 0 if report["source_ready"] else 1


if __name__ == "__main__":
    sys.exit(main())
