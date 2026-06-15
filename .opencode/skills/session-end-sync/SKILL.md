---
name: session-end-sync
description: Check GitHub updates after 5 or more assistant turns, and before ending or wrapping up; notifies non-technical users when updates are available and waits for confirmation before pulling.
---

# Session End Sync

Use this skill after 5 or more assistant turns in any git repository with an upstream. Repeat about every 5 assistant turns after that during longer sessions.

Also use this skill before ending or wrapping up a session, especially when the user says any of these phrases:

- `done`
- `wrap up`
- `finish`
- `end session`
- `final status`
- `before we stop`

## Purpose

Help non-technical teammates notice GitHub updates early, while avoiding accidental pulls over local edits.

## Safety rules

- Never run `git pull` without explicit user confirmation.
- Never discard, reset, clean, or overwrite local changes.
- Never force-push.
- If the working tree has local changes and upstream is ahead, recommend reviewing, committing, or stashing before pulling.
- If the branch has diverged, stop and ask for a merge/rebase decision.

## Workflow

1. Confirm the current directory is a git repository:
   - `git rev-parse --is-inside-work-tree`
2. Confirm the current branch has an upstream:
   - `git rev-parse --abbrev-ref --symbolic-full-name @{upstream}`
3. Run the simplest quiet sync check:
   - `git fetch --prune --quiet && git status --short --branch`
4. If deeper ahead/behind counts are needed, run:
   - `git status --short --branch`
5. Check ahead/behind counts:
   - `git rev-list --left-right --count HEAD...@{upstream}`
   - Output is `<ahead> <behind>`.
6. Interpret results:
   - `behind = 0`: report no upstream updates.
   - `behind > 0` and clean working tree: notify the user with simple wording: `GitHub updates are available. Reply yes to update.`
   - `behind > 0` and local changes exist: do not pull; offer safe choices.
   - `ahead > 0` and `behind > 0`: report divergence; ask whether to inspect, merge, or rebase.
7. If user confirms pull and working tree is clean:
   - Prefer `git pull --ff-only`.
   - If fast-forward fails, stop and report the reason.

## Response shape

Use concise status text:

```text
GitHub updates are available. Reply yes to update.
```

or:

```text
Repo sync check: remote has 2 new commits, but local changes exist. No pull run. Choices: inspect incoming commits, commit local work, stash local work, or skip.
```

or:

```text
Repo sync check: already current.
```
