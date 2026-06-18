---
name: personal-memory
description: Use when capturing, checking, promoting, pruning, or using local personal OpenWork memory under memory/. Triggers include remember this, capture this preference, promote memory candidate, run memory check, email preferences, voice preferences, and important docs to remember.
---

# Personal Memory

Use this skill to operate the local `memory/` workspace memory system. This memory is for non-code OpenWork preferences and durable personal context, not application source knowledge.

## Scope

Memory lives in `memory/` at the workspace root.

Committed scaffold files define the contract. Populated memory files are personal state and should be ignored by git.

## Safety Rules

- Never store secrets, tokens, passwords, API keys, bearer strings, OAuth credentials, or credential-like config.
- Never store raw private content by default.
- Store short summaries, not full emails, screenshots, client documents, or private transcripts.
- Use `memory/raw/` only when the user explicitly asks to keep raw material.
- Redact sensitive identifiers before writing memory.
- If capture would include third-party or client-sensitive content, ask before writing and prefer a redacted summary.

## Data Classes

- `shareable-scaffold`: committed rules, templates, and empty folder placeholders only.
- `personal-summary`: ignored summaries of preferences, docs, workflows, or communication style.
- `raw-private`: ignored raw snippets or attachments. Use only with explicit approval.

## Directory Contract

```text
memory/
├── README.md
├── TEMPLATES.md
├── index.md              # ignored personal state
├── log.md                # ignored personal state
├── candidates/           # ignored personal state
├── preferences/          # ignored personal state
├── docs/                 # ignored personal state
├── voice/                # ignored personal state
├── email/                # ignored personal state
├── workflows/            # ignored personal state
└── raw/                  # ignored personal state; explicit approval only
```

## Memory Read Policy

Use tiered reads:

1. At session start or first workspace-specific task, read `memory/index.md` if it exists.
2. Read only promoted files relevant to the task.
3. Before writing email, voice scripts, Slack messages, reports, or user-facing communication, check relevant promoted memory under `memory/email/`, `memory/voice/`, or `memory/preferences/`.
4. Before final response, run the memory check.
5. Do not read all candidates unless recurrence, promotion, or cleanup requires it.

If `memory/index.md` does not exist, proceed normally and create it only when writing the first candidate or promoted memory item.

## Setup Workflow

Use when setting up this memory system in a workspace.

1. Create directories:
   - `memory/candidates/`
   - `memory/preferences/`
   - `memory/docs/`
   - `memory/voice/`
   - `memory/email/`
   - `memory/workflows/`
   - `memory/raw/`
2. Create committed scaffold files if missing:
   - `memory/README.md`
   - `memory/TEMPLATES.md`
   - `.gitkeep` in each memory subdirectory.
3. Add or update `.gitignore` so populated personal memory is ignored while scaffold files and `.gitkeep` files remain trackable.
4. Add or update `AGENTS.md` with the Personal OpenWork memory rules.
5. Do not create populated `memory/index.md` or `memory/log.md` until the first capture or promotion.
6. Verify paths exist and report changed files.

## Naming Conventions

Use lowercase hyphenated slugs. Prefix candidate filenames by type:

- `memory/candidates/preference-<slug>.md`
- `memory/candidates/doc-<slug>.md`
- `memory/candidates/email-<slug>.md`
- `memory/candidates/voice-<slug>.md`
- `memory/candidates/workflow-<slug>.md`
- `memory/candidates/context-<slug>.md`

Default promoted topic files:

- `memory/preferences/assistant-style.md`
- `memory/email/tone-and-format.md`
- `memory/voice/voice-mode.md`
- `memory/docs/important-docs.md`
- `memory/workflows/session-end.md`
- `memory/workflows/approval-style.md`

## Capture Triggers

Capture memory when the session contains a clear durable signal:

- Preference: “I prefer X”, “do not do Y”, “use this style”.
- Repeated correction: the user corrects agent behavior in a way likely to apply again.
- Important doc/link/path: the user says something should matter later.
- Communication style: email, voice, meeting, report, summary, or response preferences.
- Workflow habit: preferred sequence, tool choice, approval style, or final-answer format.
- Personal work context: role, responsibilities, recurring clients/projects, only when useful for future work.
- Explicit remember request: “remember this”, “remember next time”, “keep this in memory”.
- Stable decision: “from now on”, “default to”, “always”, “never”.

Do not capture one-off task details, temporary instructions, guesses about personality, or private facts not needed for future work.

## Explicit Remember Workflow

When the user explicitly asks to remember something, treat that request as approval to promote durable memory. Do not create only a candidate and ask the user to promote it again.

Promote directly unless promotion is blocked by one of these conditions:

- The memory would include secrets, credentials, raw private content, client-sensitive content, or third-party-sensitive content.
- The memory conflicts with existing promoted memory.
- The memory target is unclear enough that writing it would likely store the wrong rule.
- The user asks to remember raw material rather than a redacted summary.

If blocked, ask one focused question before writing. Prefer a redacted summary over raw content.

Direct promotion steps:

1. Read `memory/index.md` if it exists.
2. Read only promoted topic files needed to detect conflicts or merge into the right category.
3. Write or update the appropriate promoted topic file under:
   - `memory/preferences/`
   - `memory/docs/`
   - `memory/voice/`
   - `memory/email/`
   - `memory/workflows/`
4. Update frontmatter to `status: promoted` where relevant.
5. Create or update `memory/index.md` with the promoted row.
6. Create or update `memory/log.md` with a promotion entry.
7. Delete or archive obsolete candidates that are fully superseded by the promoted memory.
8. Remove stale candidate rows from `memory/index.md`.
9. In the final response, mention the promoted memory path changed.

## Candidate Workflow

Use candidates only for inferred durable signals, repeated corrections, weak preferences, or possible future usefulness that the user did not explicitly ask to remember.

When an inferred capture trigger is clear:

1. Read `memory/index.md` if it exists.
2. Check candidate filenames and index rows for similar unresolved candidates.
3. If a similar candidate exists, update that candidate instead of creating a duplicate.
4. If no similar candidate exists, write a concise candidate file under `memory/candidates/<type>-<slug>.md` using `memory/TEMPLATES.md`.
5. Create or update `memory/index.md` with the candidate row.
6. Create or update `memory/log.md` with a capture entry.
7. In the final response, mention the candidate path and ask whether to promote it.

Candidates are non-authoritative. Do not silently act on candidates as settled preferences.

Do not use candidates for explicit “remember this” requests unless direct promotion is unsafe, sensitive, conflicting, or unclear.

## Recurrence Check

At the end of each session:

1. Review current session for capture triggers.
2. Check `memory/candidates/` for similar unresolved candidates.
3. If a candidate repeats or is confirmed, recommend promotion.
4. If similar candidates conflict, ask which rule wins.
5. If nothing qualifies, say: `Memory check: nothing worth capturing.`

## Promotion Workflow

Ask before promotion only for candidates or conflict resolution. When the user approves candidate promotion:

1. Merge relevant candidate content into the right promoted topic file:
   - `memory/preferences/`
   - `memory/docs/`
   - `memory/voice/`
   - `memory/email/`
   - `memory/workflows/`
2. Update frontmatter to `status: promoted` where relevant.
3. Update `memory/index.md` promoted sections.
4. Delete or archive all candidate files made obsolete by the promotion.
5. Remove stale candidate rows from `memory/index.md`.
6. Append promotion and cleanup entries to `memory/log.md`.

Promoted memory is reliable for future sessions unless superseded.

## Conflict Resolution

- Promoted memory remains active until the user approves a change.
- If a new candidate conflicts with promoted memory, label it with `conflicts-with` in the candidate notes and ask which rule wins.
- After approval, update the promoted topic file and record the prior rule in notes as superseded.
- If two candidates conflict, keep both until the user chooses one, then delete or merge the obsolete candidate.

## Discard Workflow

When a candidate is wrong, stale, or not useful:

1. Read the candidate and find its `memory/index.md` row.
2. Remove the index row.
3. Delete the candidate file.
4. Append a discard entry to `memory/log.md`.
5. Report removed paths.

## Recovery Workflow

Ignored personal files may not exist in a fresh clone or teammate workspace.

- If `memory/index.md` is missing, recreate it from `memory/TEMPLATES.md` before writing a candidate or promoted memory.
- If `memory/log.md` is missing, recreate it from `memory/TEMPLATES.md` before appending.
- Missing ignored files are normal, not an error.

## Lint Workflow

Use when asked to review memory health or before broad cleanup.

Check for:

- Candidate files missing from `memory/index.md`.
- Index rows pointing to missing files.
- Promoted files missing from `memory/index.md`.
- Candidates older than the project threshold.
- Empty promoted topic files.
- Conflicting active promoted rules.

Report findings before making broad changes. Safe deterministic fixes include removing stale candidate rows and adding missing index rows for existing files.

## Review Cadence

If promoted memory is relevant and older than 90 days, ask whether it is still current. Do not ask repeatedly when unrelated.

## Prune and Supersede

- When a promoted preference changes, update the promoted topic file and record prior rule in notes as superseded.
- Delete obsolete candidates after promotion to prevent buildup.
- If a candidate is wrong or no longer useful, delete it and remove index references.

## Output Rules

- Report exact memory paths changed.
- For explicit remember requests, report the promoted memory path changed and do not ask for promotion again.
- For inferred captures, ask one focused promotion question when a candidate is worth promoting.
- Keep memory notes short and operational.
- Do not expose sensitive source text in chat when reporting capture.
