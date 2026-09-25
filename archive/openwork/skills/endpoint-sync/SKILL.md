---
name: endpoint-sync
description: Use for quiet regular OpenWork configuration update checks and agent-mediated endpoint-safe sync from the ITAStack MCP config service.
metadata:
  route_default: daily
  route_max: medium
  route_class: endpoint_sync
---

<<<ROUTE default=daily max=medium class=endpoint_sync>>>

# Endpoint Sync

## DO THIS FIRST (quick path)

Actually RUN the steps below using your tools — do not describe them, and do not
emit any "sync failed" / "check your network" / "contact support" message. There
is NO canned failure response. The only way you may report a failure is to first
run a tool or command and quote the actual error it returned. If you have not yet
called `itastack_openwork_config_get_status` and run the helper, you have no
basis to claim failure — run them.

Run these steps in order. Do not stop to ask the user for anything. Do not hand
this to another agent. Do not save bundle output into the chat.

1. Read the installed version (or use `null` if the file is missing):
   ```
   cat .openwork/state/itastack-config-installed.json
   ```
   Use its `version` value as `current_version`.

2. Call `itastack_openwork_config_get_status`:
   ```json
   {"current_version": "<version-or-null>", "channel": "stable"}
   ```
   If `update_available` is `false`: stay silent and STOP. You are done.
   Otherwise note three scalar values from the response: `latest_version`,
   `manifest.bundle_sha256` (a 64-hex string), and the channel (`stable`).
   You do NOT need the big `manifest.files` list — ignore it.

3. Get the bundle URL. Call `itastack_openwork_config_get_bundle_url` with
   `{"version": "<latest_version>", "channel": "stable"}` and read `download_url`
   (and confirm its `bundle_sha256` matches the one from step 2).

4. Run the bundled helper in `--from-bundle` mode. It downloads the bundle,
   verifies it against `--bundle-sha256`, derives and re-checks every file from
   the verified bundle, and applies — so you never write a manifest file:
   ```
   python3 .agents/skills/endpoint-sync/scripts/apply_endpoint_sync.py \
     --from-bundle \
     --version "<latest_version>" \
     --channel stable \
     --bundle-sha256 "<bundle_sha256 from step 2/3>" \
     --bundle-url "<download_url>" \
     --apply-root <current-workspace-root>
   ```
   Pass these scalars exactly as received. Do NOT create or pass a `--manifest`
   JSON file (that path is error-prone for large manifests; `--from-bundle` is
   the normal path).

5. Report the helper's outcome to `itastack_openwork_config_report_result`
   (`result: "success"` + short `message: "applied"` on success; `result: "failed"`
   with the helper's `error_class`/`message` on failure).

Only STOP early in two cases: `update_available` is false (step 2), or the
helper exits non-zero (step 4). Local drift on allowlisted files is NOT a stop
condition — the verified server bundle wins; keep going silently. Everything
below is reference detail for these same five steps.

The helper also runs any one-time maintenance operations after a successful
apply — you do not do anything extra; it is part of step 4. See "Maintenance
operations" below.

Use this skill after the first meaningful workspace-specific work in an OpenWork configuration workspace. Repeat on every turn and before wrapping up meaningful work.

Also use this skill when OpenWork configuration sync guidance says to run the endpoint-safe sync procedure.

## Maintenance operations (one-time cleanups, moves, migrations)

Routine sync is add/update-only: it never deletes files that drop out of the
manifest. To remove or relocate files fleet-wide (e.g. a skill that moved to
local-only, a renamed path), use the bundle-shipped maintenance list. This is
how a maintainer triggers cleanups/migrations on every endpoint.

- File: `.agents/skills/endpoint-sync/maintenance.json` (ships in the bundle;
  read by the helper from the **verified** bundle, so it is integrity-anchored
  by `bundle_sha256`).
- Shape:
  ```json
  {
  "operations": [
      {"id": "2026-06-29-remove-skill-audit", "op": "delete",
       "path": ".agents/skills/skill-audit/SKILL.md", "note": "why"},
      {"id": "2026-07-01-move-foo", "op": "move",
       "from": ".agents/skills/foo/SKILL.md", "to": ".agents/skills/bar/SKILL.md"},
      {"id": "2026-07-31-archive-old-skills", "op": "archive_unshipped_skills"}
    ]
  }
  ```
- Each op has a stable `id`. The helper runs an op only if its `id` is not
  already in the state file's `maintenance_done`, then records it — so every op
  fires **exactly once per endpoint** and is safe to leave in place.
- Ops are gated by the same safety rules as sync: paths must be allowlisted
  config paths (no private/local data, no traversal, no symlinks/dirs). A `move`
  refuses to overwrite an existing destination. Missing source/target is treated
  as already-done (idempotent).
- **Never fails the sync.** Maintenance runs *after* the config files are applied
  and the sync state is saved, and it asks nothing. Any malformed, unsafe, or
  conflicting op is silently skipped and reported in `maintenance_skipped`; the
  config update is never blocked. This matters for unattended office endpoints —
  a bad op can never break a user's config sync or prompt them.
- **Do not delete/move a path the same bundle still ships.** The helper skips any
  `delete` (or `move` source) whose path is in the current manifest, because sync
  would just re-add it. To remove a file fleet-wide: first stop shipping it (it
  leaves the bundle), then add the `delete` op — the helper applies it once the
  path is no longer in the manifest.
- The helper reports applied ops in `maintenance_ran` and skipped ops (with a
  safe reason) in `maintenance_skipped`.
- `archive_unshipped_skills` is a one-time cleanup: it moves regular files under
  `.agents/skills/` that are absent from the verified bundle into
  `.openwork/state/archives/<version>-<UTC>/`, preserving their relative paths.
  It never follows symlinks and leaves empty directories in place.

Maintainer workflow: add an op (new unique `id`) to `maintenance.json`, publish a
new bundle. Endpoints apply it on their next sync; re-running sync is a no-op.
Leave applied entries in the file — they are skipped by id. To confirm rollout,
check `maintenance_ran` in an endpoint's sync output or `maintenance_done` in its
`.openwork/state/itastack-config-installed.json`. This `maintenance.json` is
itself published config; do not put secrets or per-endpoint data in it.

## Purpose

Keep centrally maintained OpenWork configuration current on endpoints without requiring GitHub access, repository pull/merge, installed sync scripts, OS schedulers, LaunchAgents, systemd timers, Windows Scheduled Tasks, or background daemons.

Routine sync is agent-mediated. The agent checks the ITAStack MCP config service during normal OpenWork sessions, downloads a short-lived bundle only when needed, verifies paths and hashes, applies allowlisted files, writes workspace-local state, and reports safe scalar telemetry.

## Tools

Use the ITAStack MCP OpenWork config tools:

- `itastack_openwork_config_get_status`
- `itastack_openwork_config_get_bundle_url`
- `itastack_openwork_config_report_result`

Use the bundled helper script for the local apply step:

- `scripts/apply_endpoint_sync.py` (in this skill folder)

The helper performs the safety-critical local work — bundle download (or verify an already-downloaded bundle), SHA256 verification, safe tar extraction, path/allowlist enforcement, add/update-only apply, atomic state write — and prints a compact JSON changed-path summary. Prefer it over generating inline Python each run. Only fall back to ephemeral inline shell/Python during first-install bootstrapping (see below) when the bundled script is not yet present locally. Do not install persistent schedulers or daemons.

## Definitions

- Apply root: currently opened OpenWork workspace root, not the user's global OpenCode/OpenWork config directory.
- Bundle paths are applied into the workspace, for example `<workspace>/.agents/skills/**` and `<workspace>/AGENTS.md`.
- State file: `.openwork/state/itastack-config-installed.json` under the apply root.
- Local drift: after state exists, a current allowed file hash differs from the file hash recorded in the state file for the installed version. Drift is informational only for allowed configuration files; the verified server bundle wins during routine sync.
- Routine sync: add/update files from the server manifest only, overwriting allowlisted configuration files with the verified server version. Do not delete local files absent from the new manifest.

Allowed update paths are only:

- `AGENTS.md`
- `.agents/skills/**`
- `.opencode/agents/**`
- `.opencode/plugins/**`
- `.opencode/workflows/**`
- `.opencode/commands/**`
- `memory/README.md`
- `memory/TEMPLATES.md`
- `memory/*/.gitkeep`

Private/local excluded paths that must never be applied, deleted, overwritten, or used as sync state input:

- `opencode.json`
- `opencode.jsonc`
- `.env*`
- `.openwork/state/**`
- `memory/**`
- `artifacts/**`
- `.handoff/**`
- `.onboarding/**`
- `.issues/**`
- `youtube/**`
- `prototypes/**`
- `teaching/**`

Exception: the allowlisted memory scaffold paths `memory/README.md`, `memory/TEMPLATES.md`, and `memory/*/.gitkeep` may be applied. No populated personal memory files may be applied.

## Hard safety rules

- Use ITAStack MCP config tools, not GitHub or repository pull/merge, for routine endpoint configuration sync.
- Apply only to the currently opened OpenWork workspace root. Do not apply to `~/.config/opencode`, `%USERPROFILE%\.config\opencode`, or another global user config directory unless that directory is explicitly the opened workspace.
- Do not upload local files during routine pull/sync.
- Do not offer to push, publish, upload, or sync local configuration back to the server as part of routine endpoint sync. This skill is pull-only.
- Do not install scripts, schedulers, LaunchAgents, systemd timers, Scheduled Tasks, or daemons as part of routine sync.
- Reject any manifest or bundle path outside the allowlist.
- Reject `opencode.json`, `opencode.jsonc`, absolute paths, path traversal with `..`, backslashes, symlinks, hardlinks, device files, directories as file entries, and non-regular files.
- Preserve ignored local-only data in place.
- Server-published configuration wins over local drift for allowlisted update paths after manifest, bundle, and per-file hash verification passes.
- Overwrite drifted allowlisted configuration files during routine sync. Do not stop for drift unless the drift involves a rejected/private path or an unsafe target type.
- Do not automatically delete local files that are absent from the new manifest.
- Keep no-update checks silent when possible.
- If MCP status, download, hash verification, path validation, extraction, or apply fails, stop and report failure with safe scalar details only.

## Quiet update check

1. Confirm the apply root is the currently opened OpenWork workspace root. If the resolved apply root is `~/.config/opencode`, `%USERPROFILE%\.config\opencode`, or another global user config directory, stop unless that directory is explicitly the opened workspace.
2. Read `.openwork/state/itastack-config-installed.json` from the workspace root if it exists.
3. Set `current_version` to the state's `version`; use `null` if the state file is missing or unreadable.
4. Call `itastack_openwork_config_get_status` with:
   - `current_version`
   - `channel: "stable"`
   - `endpoint_id`: a safe endpoint/workspace identifier when available
   - `openwork_version`: `null` unless known
5. If `update_available` is false:
   - Optionally call `itastack_openwork_config_report_result` with `result: "no_update"` when useful for fleet visibility.
   - Stay silent unless the user explicitly asked for status.
6. If `update_available` is true, run the endpoint-safe sync procedure below.

## Endpoint-safe sync procedure

This is a compact one-shot path. The bundled helper `scripts/apply_endpoint_sync.py` performs manifest validation, bundle download/verification, safe extraction, allowlist enforcement, add/update-only apply, and the atomic state write. The agent only orchestrates MCP calls and reports the result.

### 1. Save the status response

Write the full `itastack_openwork_config_get_status` response (or at least its `manifest` object plus `bundle_sha256`) to a temporary JSON file outside the workspace. The helper accepts either the full status response or the inner manifest object.

### 2. Get the bundle URL

Call `itastack_openwork_config_get_bundle_url` with:

- `version: latest_version`
- `channel: "stable"`

Confirm the returned `bundle_sha256` matches the status response `bundle_sha256` when both are present.

### 3. Run the helper

Run the bundled helper, passing the saved manifest, the bundle source, and the apply root (the currently opened workspace root):

```
python3 .agents/skills/endpoint-sync/scripts/apply_endpoint_sync.py \
  --manifest <temp-status.json> \
  --bundle-url "<download_url>" \
  --apply-root <workspace-root>
```

Use `--bundle-path <file>` instead of `--bundle-url` if you have already downloaded the bundle. Add `--dry-run` to verify and preview the changed-path summary without writing.

The helper prints a single compact JSON object to stdout. On success:

- `result: "success"`, `version`, `channel`, `bundle_sha256`
- `added[]`, `updated[]`, `unchanged_count`, `applied_count`
- `state_path` (relative)
- `backup_path` (relative dir under `.openwork/state/backups/`, or `null` if nothing was backed up), `backup_count`, and `backup_errors[]`

On failure it prints `{"result":"failed","error_class":"...","message":"..."}` and exits non-zero. Both fields are safe scalars suitable for telemetry.

Use the `added`/`updated` lists as the changed-path summary. Do not paste the full manifest into the chat.

### 4. Report result

Forward the helper's outcome to `itastack_openwork_config_report_result`:

- On success: `version: latest_version`, `channel: "stable"`, `result: "success"`, `message`: short safe scalar such as `applied`.
- On failure: `result: "failed"` with the helper's `error_class` and `message`.

### Safety contract enforced by the helper

The helper enforces every gate below; do not relax or bypass them. If the helper is unavailable, any inline fallback must enforce the same:

- Require `latest_version`/`config_version`, `manifest.files[]`, and `bundle_sha256`.
- Per path: normalize as POSIX relative; reject absolute, empty, `..` traversal, or backslashes; reject private/local excluded paths (except the exact memory scaffold paths); reject paths outside the allowlist; reject modes other than `0644`/`0755`; reject SHA256 that is not lowercase 64-hex.
- Verify the downloaded bundle SHA256 against `bundle_sha256` before extraction.
- Extract only into a temp dir; reject non-regular entries, symlinks, hardlinks, device/special files, entries absent from the manifest, and any extra/missing entries; verify each extracted file's SHA256.
- Apply add/update only into the apply root: re-check the target stays within the apply root and allowed paths; reject symlink/hardlink/directory/non-regular targets; overwrite drifted allowlisted files with the verified server version; never delete files absent from the manifest.
- Before overwriting an updated file or deleting/moving one via a maintenance op, copy the current content into a run-scoped backup dir `.openwork/state/backups/<version>-<UTC-timestamp>/` (original relative paths preserved). New files (adds) have no prior content and are not backed up. Backups are best-effort: a backup that cannot be written is recorded in `backup_errors[]` but never blocks or fails the sync, and the backup dir is created only if at least one file needs saving (dry runs and no-op syncs leave none). Backups live under the excluded `.openwork/state/` prefix, so they are never re-ingested as sync input. To revert an apply, copy files from the reported `backup_path` back over the workspace and roll the state file's `version`/`bundle_sha256`/`file_hashes` back; drop the run's ids from `maintenance_done` if you want its maintenance ops to re-run.
- Write `.openwork/state/itastack-config-installed.json` atomically with `channel`, `version`, `bundle_sha256`, `manifest_sha256` when available, ISO 8601 `installed_at`, `verification: "mcp-authenticated-sha256"`, and a `file_hashes` map. Never include secrets, tokens, absolute private paths, usernames, or raw MCP headers.

Ordinary local drift on allowlisted files is informational only; the verified server bundle wins. Stay silent about drift and do not send `blocked` telemetry for it. Stop only on an unsafe target or another verification failure, reporting `failed` with a safe error class such as `unsafe_target`.

### First-install bootstrapping

On a brand-new endpoint the bundled helper may not exist locally yet (it ships in the same bundle). For that first sync only, you may download and run an equivalent ephemeral inline script that enforces the full safety contract above. After the first successful apply, the bundled `scripts/apply_endpoint_sync.py` is present and every subsequent routine sync uses it.

## User-facing reports

Use only concise reports unless troubleshooting details are needed:

- No update: stay silent.
- Updated cleanly: `OpenWork configuration has been updated.`
- Local drift on allowed config files: stay silent while applying the verified server version.
- Failure: `OpenWork configuration could not be updated automatically. Ask workspace maintainer to refresh this setup.`

Avoid Git/GitHub wording in user-facing sync reports unless troubleshooting a separate repository task requires it.
