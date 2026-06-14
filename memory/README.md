# Personal OpenWork Memory

This directory is a local, personal memory area for OpenWork sessions in this workspace.

The scaffold files in this directory can be shared with the team. Populated memory files are personal state and should stay ignored by git.

## For Teammates

Copy or clone this scaffold, then populate only your local ignored memory files. Commit changes to `README.md`, `TEMPLATES.md`, `AGENTS.md`, `.gitignore`, and empty `.gitkeep` placeholders only when improving the shared memory system itself.

## Purpose

Use `memory/` to preserve durable non-code preferences and useful working context, including:

- Assistant response preferences.
- Email and voice communication preferences.
- Important docs, links, or paths to remember.
- Workflow habits and approval preferences.
- Repeated corrections that should become future defaults.

## Safety

- Do not store secrets, tokens, passwords, API keys, bearer strings, OAuth credentials, or credential-like config.
- Prefer summaries over raw private content.
- Store raw snippets only when explicitly approved.
- Redact sensitive third-party or client information.
- Keep personal memory local and uncommitted.

## Data Classes

- `shareable-scaffold`: committed templates, rules, and empty placeholders.
- `personal-summary`: ignored summaries of preferences, docs, workflows, and communication style.
- `raw-private`: ignored raw snippets saved only with explicit approval.

## Directory Layout

```text
memory/
├── README.md
├── TEMPLATES.md
├── index.md
├── log.md
├── candidates/
├── preferences/
├── docs/
├── voice/
├── email/
├── workflows/
└── raw/
```

## Candidate Gate

New inferred or auto-captured memory starts in `memory/candidates/`.

Promote only after user approval. When a candidate is promoted, merge it into the relevant topic file and delete obsolete candidate files.

## Naming

Candidate files use lowercase hyphenated names with a type prefix:

- `preference-<slug>.md`
- `doc-<slug>.md`
- `email-<slug>.md`
- `voice-<slug>.md`
- `workflow-<slug>.md`
- `context-<slug>.md`

Default promoted topic files:

- `memory/preferences/assistant-style.md`
- `memory/email/tone-and-format.md`
- `memory/voice/voice-mode.md`
- `memory/docs/important-docs.md`
- `memory/workflows/session-end.md`
- `memory/workflows/approval-style.md`

## Session-End Check

Before finishing a meaningful session, agents should check whether anything should be captured, promoted, merged, or discarded.

If nothing qualifies, say: `Memory check: nothing worth capturing.`

## Maintenance

- Recreate missing ignored `memory/index.md` or `memory/log.md` when first needed.
- Before creating a candidate, check existing candidates for duplicates and update similar candidates instead of creating buildup.
- If promoted memory conflicts with a new candidate, keep the promoted rule active until the user approves a change.
- If a promoted memory item is relevant and older than 90 days, ask whether it is still current.
