---
name: endpoint-sync
description: Use for quiet regular OpenWork configuration update checks and automatic endpoint-safe sync that backs up Git-visible working-tree drift while preserving ignored local-only data.
---

# Endpoint Sync

Use this skill after 5 or more assistant turns in this OpenWork configuration workspace. Repeat about every 5 assistant turns during longer sessions and before wrapping up meaningful work.

Also use this skill when repository sync guidance says to run the endpoint-safe sync procedure.

## Purpose

Keep centrally maintained OpenWork configuration current on endpoints without asking non-technical users to choose Git strategies.

Central OpenWork configuration wins for tracked/shared files during sync, but recoverable Git-visible working-tree drift must be backed up before tracked central updates are applied.

Endpoint sync is not a workspace cleanup routine. It runs only when upstream central OpenWork configuration updates are available. Its job is to apply tracked central configuration updates safely, not to remove user-created local files or make `git status` clean.

## Definitions

- Git-visible working-tree drift: tracked working-tree or index changes, deleted tracked files, staged locally added files, and untracked non-ignored files.
- Ignored local-only data: files ignored by `.gitignore` or local exclude rules, including personal memory, artifacts, local config, logs, prototypes, and other endpoint-only data.
- Backup root: `artifacts/git-sync-backups/YYYY-MM-DD-HHMM/` using local time.

## Hard safety rules

- Preserve ignored local-only data in place.
- Never use `git clean -fdx`.
- Do not commit, push, branch, create PRs, merge, rebase, or stash during endpoint sync handling.
- Do not ask non-technical users to choose between commit, stash, merge, rebase, or skip.
- If a command fails or repository setup is missing, stop and report the failure plainly.
- Keep clean/no-action checks silent when possible.
- Do not create backups when no upstream central updates are available.
- Do not remove untracked files as cleanup. Preserve untracked files in place unless a central tracked path cannot be applied because that exact untracked path obstructs it.
- Never include `artifacts/git-sync-backups/` in drift lists, verification failures, or cleanup decisions.

## Quiet update check

1. Refresh remote refs: `git fetch --prune --quiet`.
2. Inspect current state: `git status --short --branch`.
3. Get ahead/behind counts: `git rev-list --left-right --count HEAD...@{upstream}`.
4. Interpret output as `<ahead> <behind>`.
5. If `behind = 0`, no action is needed; create no backup and stay silent unless the user explicitly asked for status.
6. If `behind > 0`, run the endpoint-safe sync procedure below, even when `ahead > 0`. Local ahead commits are not backed up as patches or bundles during routine endpoint sync.

## Endpoint-safe sync procedure

### 1. Confirm repository and upstream

Run these checks:

- `git rev-parse --is-inside-work-tree`
- `git rev-parse --show-toplevel`
- `git rev-parse --abbrev-ref --symbolic-full-name @{upstream}`

If any check fails, stop. User-facing wording: `OpenWork configuration could not be updated automatically. Ask James to refresh this setup.`

### 2. Capture status before changing anything

Capture these values for the manifest:

- Current timestamp in local time as `YYYY-MM-DD-HHMM`.
- Repository root from `git rev-parse --show-toplevel`.
- Current branch from `git branch --show-current`.
- Current `HEAD` from `git rev-parse HEAD`.
- Upstream name from `git rev-parse --abbrev-ref --symbolic-full-name @{upstream}`.
- Upstream commit from `git rev-parse @{upstream}` after fetch.
- Ahead/behind from `git rev-list --left-right --count HEAD...@{upstream}`.
- Full short status from `git status --short --branch`.

### 3. Build the drift list

Use `git status --porcelain=v1 -z` to identify every Git-visible working-tree drift path. Use NUL-safe parsing so paths with spaces, quotes, renames, copies, or unusual characters are handled safely.

- Tracked drift: every tracked porcelain entry other than `??`, including modified, deleted, renamed, copied, type-changed, mode-changed, staged, and locally added paths.
- Deleted tracked files: tracked drift where the working-tree path is deleted.
- Locally added tracked files: tracked/index-added paths that are not present in pre-sync `HEAD`.
- Untracked non-ignored files: `??` entries.
- Rename/copy entries: handle as two-path records and preserve the relevant current working-tree path when present.

Do not include ignored files. Do not include `artifacts/git-sync-backups/`. Do not use commands that remove ignored files.

### 4. Create backup folder if drift exists

If there is any Git-visible working-tree drift, create `artifacts/git-sync-backups/YYYY-MM-DD-HHMM/`.

Inside the backup folder:

- Preserve relative paths for every backed-up file.
- Create `manifest.md` with the captured repository state and a table of backed-up paths.
- For tracked drift paths that exist in the working tree, copy the working-tree file into the same relative path under the backup folder. If a path is both modified and staged, preserve the working-tree file content, not the index blob.
- For deleted tracked files present in pre-sync `HEAD`, restore the pre-sync `HEAD` version into the same relative path under the backup folder and mark the path as `locally deleted tracked` in `manifest.md`.
- For locally added tracked files not present in pre-sync `HEAD` but present in the working tree, copy the working-tree file and mark it as `locally added tracked`.
- If a locally added tracked file exists only in the index and not in the working tree, stop before applying the central update.
- For untracked non-ignored files or directories, copy the file or directory into the same relative path under the backup folder and mark it as `untracked preserved`. Leave the original in place by default.

If a path cannot be backed up, stop before applying the central update. User-facing wording: `OpenWork configuration could not be updated automatically. Ask James to refresh this setup.`

Immediately before applying the central update, run `git status --porcelain=v1 -z` again. If the Git-visible working-tree drift list changed, update the backup and manifest before continuing. If backup update fails, stop before applying the central update.

### 5. Apply tracked central configuration

After successful backup and pre-reset recheck, align tracked files with upstream while preserving ignored local-only data and non-conflicting untracked files.

Allowed internal actions after backup:

- Reset tracked files to the upstream commit.
- If reset fails because an untracked file or directory path obstructs an upstream tracked file, use the reset/checkout error output to identify the exact obstructing path. If and only if that exact path was already backed up, update `manifest.md` to mark it as `untracked overwritten by central path`, remove only that exact obstruction, and retry reset once.

Never remove ignored files or directories. Never remove unrelated untracked files. Never use `git clean -fdx`.

The simplest safe shape is:

1. Use `git reset --hard @{upstream}` to align tracked files with upstream.
2. If reset succeeds, leave untracked files in place.
3. If reset fails because of an untracked obstruction, update `manifest.md`, remove only the exact backed-up obstructing file or directory path, and retry reset once.

If the reset or one-time obstruction retry fails, stop and report failure. Do not keep trying destructive alternatives.

### 6. Verify result

Run:

- `git status --short --branch`
- `git status --porcelain=v1 -z`
- `git rev-list --left-right --count HEAD...@{upstream}`

Success criteria:

- Ahead and behind counts are `0 0` after an applied update.
- No tracked or index porcelain entries remain in `git status --porcelain=v1 -z`; all remaining entries, if any, must be `??` untracked entries.
- `??` untracked entries may remain; a successful endpoint sync does not require a clean working tree.
- Any untracked path removed because it obstructed an upstream tracked path was included in the backup and marked as `untracked overwritten by central path` in the manifest.
- Ignored local-only data remains untouched.

## User-facing reports

Use only these concise reports unless troubleshooting details are needed:

- No action needed: stay silent.
- Updated without backups: `OpenWork configuration has been updated.`
- Updated with backups: `OpenWork configuration has been updated. Backups of local changes are located here: artifacts/git-sync-backups/YYYY-MM-DD-HHMM/`
- Failure: `OpenWork configuration could not be updated automatically. Ask James to refresh this setup.`

Avoid Git/GitHub wording in user-facing sync reports unless troubleshooting requires it.

## Manifest requirements

Write `manifest.md` in plain Markdown. Include:

- Timestamp.
- Repository root.
- Branch.
- Local `HEAD` before sync.
- Upstream name and commit.
- Ahead/behind counts before sync.
- Original `git status --short --branch` output.
- Backup table with columns: `Path`, `Status`, `Backup note`.
- Use these statuses where applicable: `modified tracked`, `locally deleted tracked`, `locally added tracked`, `untracked preserved`, `untracked overwritten by central path`.
- A note that ignored local-only data was intentionally not copied or removed.
- A note that preserved untracked files may remain in the workspace after successful sync.

Do not auto-prune backup folders.
