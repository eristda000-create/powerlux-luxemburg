# MERG State Drift Watch

This is a real GitHub Actions production/state checker, not a ChatGPT Task and not a mock monitoring screen.

## Runtime
Workflow: `.github/workflows/merg-state-drift.yml`
Checker: `scripts/merg_state_drift.py`

It runs:
- hourly at minute 17;
- manually via GitHub Actions `workflow_dispatch`;
- on relevant `main` changes to MERG/PowerLux state, guard code or the workflow itself.

## Always-on public checks
No secret is required for these checks:
- original PowerTV ChatGPT Sites runtime is publicly reachable;
- original PowerTV identity markers remain present;
- rejected replacement/mockup markers are not present on original PowerTV;
- no local `powertv/index.html` replacement reappears while canonical PowerTV source is unverified;
- PowerLux production root is publicly reachable and identifiable;
- PowerLux `/api/sports` behavior is compared with the documented known-defect state, so a known 404 does not create a new alert every hour;
- Cogni canonical public host is reachable and identifiable;
- mandatory MERG source-of-truth documents exist;
- MERG cross-project state age is checked.

## Optional authenticated checks
The workflow supports deeper checks when repository secrets are configured:

- `MERG_GITHUB_TOKEN`: read access to the private `eristda000-create/cogni` repo for cross-repo verification.
- `VERCEL_TOKEN` + `VERCEL_TEAM_ID`: authenticated Vercel project inventory verification.
- `SUPABASE_ACCESS_TOKEN`: Supabase management project health verification.

If one of these credentials is absent, the check is reported as `UNVERIFIED`. It is never silently converted to `OK`.

## Alert behavior
Critical drift makes the workflow fail and opens or updates one GitHub Issue titled `MERG State Drift Alert`.

When a later critical check succeeds, the workflow closes the active drift issue. Reports are uploaded as a GitHub Actions artifact for 14 days.

Warning drift is recorded in the report but does not generate a critical alert by itself. Known documented defects that still match reality are `ALIGNED`, not new incidents.

## Production-first principle
The watcher detects divergence; it does not automatically rewrite production, fabricate a replacement, deploy a mockup, or claim a missing external check is healthy.
