---
name: endpoint-sync
description: Use for quiet regular OpenWork configuration update checks and automatic endpoint-safe sync that merges shared updates while preserving endpoint-local OpenWork configuration changes.
---

# Endpoint Sync

Use this skill after 5 or more assistant turns in this OpenWork configuration workspace. Repeat about every 5 assistant turns during longer sessions and before wrapping up meaningful work.

Also use this skill when repository sync guidance says to run the endpoint-safe sync procedure.

## Purpose

Keep centrally maintained OpenWork configuration current on endpoints without asking non-technical users to choose Git strategies.

Shared OpenWork configuration updates are merged with endpoint-local OpenWork configuration changes. Routine endpoint sync must not overwrite endpoint-local work.

Endpoint sync is not a workspace cleanup routine. It runs only when upstream shared OpenWork configuration updates are available. Its job is to apply shared updates safely, not to remove user-created local files or make `git status` clean.

## Definitions

- Endpoint-local OpenWork configuration changes: uncommitted changes under the allowlisted OpenWork configuration paths below.
- Local commits: commits on the endpoint branch that are ahead of the configured upstream.
- Ignored local-only data: files ignored by `.gitignore` or local exclude rules, including personal memory, artifacts, local config, logs, prototypes, and other endpoint-only data.
- Allowlisted OpenWork configuration paths for endpoint auto-save:
  - `AGENTS.md`
  - `.opencode/skills/**`
  - `.opencode/agents/**`
  - `.opencode/plugins/**`
  - `.opencode/workflows/**`
  - `.opencode/commands/**`
- Private/local excluded paths that must never be staged or committed by endpoint sync:
  - `opencode.jsonc`
  - `.env*`
  - `memory/**`
  - `artifacts/**`
  - `.handoff/**`
  - `.onboarding/**`
  - `.issues/**`
  - `youtube/**`
  - `prototypes/**`
  - `teaching/**`

## Hard safety rules

- Preserve ignored local-only data in place.
- Never use `git clean -fdx`.
- Never push, branch, create PRs, rebase, stash, reset hard, or clean during endpoint sync handling.
- Never use broad staging such as `git add .`.
- Never stage or commit ignored/private files, secrets, logs, client data, or generated artifacts.
- Do not ask non-technical users to choose between commit, stash, merge, rebase, reset, or skip.
- If a command fails or repository setup is missing, stop and report the failure plainly.
- Keep clean/no-action checks silent when possible.
- Do not create local commits when no upstream shared updates are available.
- Do not remove untracked files as cleanup. Preserve untracked files in place.
- If local and shared changes conflict, stop and report that maintainer review is needed. Do not auto-resolve conflicts.

## Quiet update check

1. Refresh remote refs: `git fetch --prune --quiet`.
2. Inspect current state: `git status --short --branch`.
3. Get ahead/behind counts: `git rev-list --left-right --count HEAD...@{upstream}`.
4. Interpret output as `<ahead> <behind>`.
5. If `behind = 0`, no action is needed; create no local commit and stay silent unless the user explicitly asked for status.
6. If `behind > 0`, run the endpoint-safe sync procedure below, even when `ahead > 0`.

## Endpoint-safe sync procedure

### 1. Confirm repository and upstream

Run these checks:

- `git rev-parse --is-inside-work-tree`
- `git rev-parse --show-toplevel`
- `git rev-parse --abbrev-ref --symbolic-full-name @{upstream}`

If any check fails, stop. User-facing wording: `OpenWork configuration could not be updated automatically. Ask workspace maintainer to refresh this setup.`

### 2. Capture status before changing anything

Capture these values for troubleshooting if sync fails:

- Current timestamp in local time as `YYYY-MM-DD-HHMM`.
- Repository root from `git rev-parse --show-toplevel`.
- Current branch from `git branch --show-current`.
- Current `HEAD` from `git rev-parse HEAD`.
- Upstream name from `git rev-parse --abbrev-ref --symbolic-full-name @{upstream}`.
- Upstream commit from `git rev-parse @{upstream}` after fetch.
- Ahead/behind from `git rev-list --left-right --count HEAD...@{upstream}`.
- Full short status from `git status --short --branch`.

### 3. Inspect uncommitted changes

Use `git status --porcelain=v1 -z` to identify uncommitted tracked/index changes. Use NUL-safe parsing so paths with spaces, quotes, renames, copies, or unusual characters are handled safely.

Classify changed paths:

- Allowed OpenWork config changes: tracked or index changes where every affected path is in the allowlisted OpenWork configuration paths and not in an excluded path.
- Excluded/private changes: any changed path under excluded/private paths, any ignored file, any secret-like path, logs, client data, or generated artifacts.
- Other changes: any changed path outside both lists.
- Untracked files: leave in place. Do not stage them unless they are under an allowlisted OpenWork configuration path and clearly part of a user-created OpenWork config item.

If no uncommitted changes exist, continue to pull.

If uncommitted changes exist only in allowed OpenWork config paths, save them before pull:

1. Stage only the allowed paths explicitly. Do not use `git add .`.
2. Commit with message: `Local endpoint OpenWork changes`.

If excluded/private changes or other changes exist:

1. Do not stage or commit them.
2. Continue only if they do not prevent pull.
3. If the pull refuses to proceed because of those local changes, stop and report maintainer review is needed.

If the working tree changes while inspecting or staging, re-read `git status --porcelain=v1 -z` before committing. If classification is no longer clear, stop before pulling.

### 4. Pull shared updates

Recalculate ahead/behind after any local auto-save commit:

- `git rev-list --left-right --count HEAD...@{upstream}`

If behind is now `0`, no shared update remains; stop silently unless the user explicitly asked for status.

If behind is greater than `0` and ahead is `0`, use:

- `git pull --ff-only`

If behind is greater than `0` and ahead is greater than `0`, use:

- `git pull --no-rebase`

If pull fails because of local changes, conflicts, unrelated histories, authentication, or repository setup, stop. Do not retry with reset, rebase, stash, clean, or force options.

If merge conflicts occur, stop and report: `OpenWork configuration update needs maintainer review because local and shared changes conflict.`

### 5. Verify result

Run:

- `git status --short --branch`
- `git status --porcelain=v1 -z`
- `git rev-list --left-right --count HEAD...@{upstream}`

Success criteria:

- Behind count is `0` after an applied update.
- Ahead count may be `0` or greater depending on endpoint-local commits and merge commits.
- No merge-conflict porcelain entries remain.
- No excluded/private paths were staged or committed by endpoint sync.
- Untracked and ignored local-only data remain untouched.
- A successful endpoint sync does not require a clean working tree if unrelated local files remain.
- Ignored local-only data remains untouched.

## User-facing reports

Use only these concise reports unless troubleshooting details are needed:

- No action needed: stay silent.
- Updated cleanly: `OpenWork configuration has been updated.`
- Updated with preserved local changes: `OpenWork configuration has been updated. Local endpoint changes were preserved.`
- Conflict or unsafe local state: `OpenWork configuration update needs maintainer review because local and shared changes conflict.`
- Failure: `OpenWork configuration could not be updated automatically. Ask workspace maintainer to refresh this setup.`

Avoid Git/GitHub wording in user-facing sync reports unless troubleshooting requires it.
