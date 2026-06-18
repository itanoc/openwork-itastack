---
name: endpoint-sync
description: Use for quiet regular OpenWork configuration update checks and agent-mediated endpoint-safe sync from the ITAStack MCP config service.
---

# Endpoint Sync

Use this skill after the first meaningful workspace-specific work in an OpenWork configuration workspace. Repeat about every 5 assistant turns during longer sessions and before wrapping up meaningful work.

Also use this skill when OpenWork configuration sync guidance says to run the endpoint-safe sync procedure.

## Purpose

Keep centrally maintained OpenWork configuration current on endpoints without requiring GitHub access, repository pull/merge, installed sync scripts, OS schedulers, LaunchAgents, systemd timers, Windows Scheduled Tasks, or background daemons.

Routine sync is agent-mediated. The agent checks the ITAStack MCP config service during normal OpenWork sessions, downloads a short-lived bundle only when needed, verifies paths and hashes, applies allowlisted files, writes workspace-local state, and reports safe scalar telemetry.

## Tools

Use the ITAStack MCP OpenWork config tools:

- `itastack_openwork_config_get_status`
- `itastack_openwork_config_get_bundle_url`
- `itastack_openwork_config_report_result`

Use ephemeral local shell/Python commands only when needed for binary-safe bundle download, tar extraction, SHA256 calculation, or file copying. Do not install persistent helper scripts.

## Definitions

- Apply root: currently opened OpenWork workspace root, not the user's global OpenCode/OpenWork config directory.
- Bundle paths are applied into the workspace, for example `<workspace>/.opencode/skills/**` and `<workspace>/AGENTS.md`.
- State file: `.openwork/state/itastack-config-installed.json` under the apply root.
- Local drift: after state exists, a current allowed file hash differs from the file hash recorded in the state file for the installed version.
- Routine sync: add/update files from the server manifest only; do not delete local files absent from the new manifest.

Allowed update paths are only:

- `AGENTS.md`
- `.opencode/skills/**`
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
- Do not auto-merge local drift.
- Do not overwrite drifted files during routine sync.
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

### 1. Validate status response

From the status response, require:

- `latest_version`
- `manifest`
- `bundle_sha256`
- manifest `files[]` with `path`, `sha256`, `size`, and `mode` where provided

For every manifest path:

1. Normalize as a POSIX relative path.
2. Reject if absolute, empty, contains `..`, contains backslashes, or resolves outside the apply root.
3. Reject if it matches any private/local excluded path, except exact scaffold paths allowed above.
4. Reject if it is not under the allowed update paths.
5. Reject if mode is anything other than a normal file mode such as `0644` or `0755`.
6. Reject if the SHA256 is not a lowercase 64-character hex string.

If validation fails, stop and call `itastack_openwork_config_report_result` with:

- `result: "failed"`
- `error_class`: safe short class such as `manifest_path_invalid`
- `message`: safe scalar summary only, no local paths beyond allowed relative config paths

### 2. Detect local drift when state exists

If `.openwork/state/itastack-config-installed.json` exists and contains a `file_hashes` map:

1. For each file path present in both state `file_hashes` and the new manifest, hash the current local file if it exists.
2. If the current local hash differs from the hash recorded in state, mark that path as drifted.
3. If any drifted paths exist, stop before download/apply.
4. Report: `OpenWork configuration update needs maintainer review because local config drift was detected.` Include drifted relative paths only.
5. Call `itastack_openwork_config_report_result` with `result: "blocked"`, `error_class: "local_drift"`, and a short safe message.

If the state file is missing, treat this as first install. No drift baseline exists; continue only after manifest path validation passes.

### 3. Get bundle URL and download to temp

1. Call `itastack_openwork_config_get_bundle_url` with:
   - `version: latest_version`
   - `channel: "stable"`
2. Confirm the returned `bundle_sha256` matches the status response `bundle_sha256` when both are present.
3. Download the bundle URL to a temporary directory outside the workspace when possible.
4. Do not store the bundle permanently.
5. Hash the downloaded bundle and require exact match with `bundle_sha256`.

If download or bundle hash verification fails, stop and report `failed` telemetry with safe scalar error details.

### 4. Extract and verify bundle safely

Extract only into a temporary directory.

For each tar entry:

1. Reject if path validation fails.
2. Reject if entry is not a regular file.
3. Reject symlinks, hardlinks, device files, FIFOs, and special files.
4. Reject if entry path is absent from the manifest.
5. Write into the temp extraction directory only.
6. Hash extracted file and require exact match with manifest file SHA256.

After extraction:

- Require every manifest file to exist in the extracted temp tree.
- Reject extra bundle entries not present in the manifest.

### 5. Apply add/update only

Before copying each file into the apply root:

1. Re-check target path remains within the apply root and allowed paths.
2. If target exists, reject symlink, hardlink, directory, or non-regular target.
3. Create parent directories only under allowed paths.
4. Copy verified extracted file over the target.
5. Set file mode from manifest when provided, limited to regular file modes such as `0644` or `0755`.

Do not delete files absent from the manifest.

### 6. Write state

After all files are applied successfully, write `.openwork/state/itastack-config-installed.json` atomically with:

- `channel`
- `version`
- `bundle_sha256`
- `manifest_sha256` when available
- `installed_at` as an ISO 8601 timestamp
- `verification: "mcp-authenticated-sha256"`
- `file_hashes`: map of applied relative path to manifest SHA256

Never include secrets, bearer tokens, absolute private filesystem paths, local usernames, or raw MCP headers in state.

### 7. Report result

On success, call `itastack_openwork_config_report_result` with:

- `version: latest_version`
- `channel: "stable"`
- `result: "success"`
- `message`: short safe scalar such as `applied`

On blocked local drift, report `blocked`.

On failure, report `failed`.

## User-facing reports

Use only concise reports unless troubleshooting details are needed:

- No update: stay silent.
- Updated cleanly: `OpenWork configuration has been updated.`
- Local drift: `OpenWork configuration update needs maintainer review because local config drift was detected.`
- Failure: `OpenWork configuration could not be updated automatically. Ask workspace maintainer to refresh this setup.`

Avoid Git/GitHub wording in user-facing sync reports unless troubleshooting a separate repository task requires it.
