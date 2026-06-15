---
name: session-end-sync
description: Use when ending or wrapping up an OpenWork session in this shared GitHub workspace; checks whether upstream has updates and offers safe pull options without overwriting local work.
---

# Session End Sync

Use this skill before ending a meaningful session in this shared GitHub-backed workspace, especially when the user says any of these phrases:

- `done`
- `wrap up`
- `finish`
- `end session`
- `final status`
- `before we stop`

## Purpose

Keep teammates' local OpenWork workspace configuration current with the shared GitHub repository, while avoiding accidental pulls over local edits.

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
3. Refresh remote refs:
   - `git fetch --prune`
4. Check status:
   - `git status --short --branch`
5. Check ahead/behind counts:
   - `git rev-list --left-right --count HEAD...@{upstream}`
   - Output is `<ahead> <behind>`.
6. Interpret results:
   - `behind = 0`: report no upstream updates.
   - `behind > 0` and clean working tree: offer to pull.
   - `behind > 0` and local changes exist: do not pull; offer safe choices.
   - `ahead > 0` and `behind > 0`: report divergence; ask whether to inspect, merge, or rebase.
7. If user confirms pull and working tree is clean:
   - Prefer `git pull --ff-only`.
   - If fast-forward fails, stop and report the reason.

## Response shape

Use concise status text:

```text
Repo sync check: remote has 2 new commits. Working tree clean. Pull now? I will use `git pull --ff-only`.
```

or:

```text
Repo sync check: remote has 2 new commits, but local changes exist. No pull run. Choices: inspect incoming commits, commit local work, stash local work, or skip.
```

or:

```text
Repo sync check: already current.
```
