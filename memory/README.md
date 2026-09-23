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
- Redacted reusable Ticket Guides for future Halo ticket research.
- Workflow habits and approval preferences.
- Repeated corrections that should become future defaults.
- Decisions deliberately finalized by decision-capture workflows.

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
├── glossary.md    # ignored — entity directory (shorthand -> identity)
├── preferences/
├── docs/
├── voice/
├── email/
├── guides/
├── workflows/
├── decisions/
└── raw/
```

## Capture Gate

There are no candidates. When a capture trigger fires (a correction, a stated rule/preference, a described workflow/boundary, a settled decision, or a reusable fact discovered while working), the agent ASKS in chat and writes to memory only after the user confirms. Nothing is written on inference alone.

Workflows that finalize durable knowledge with the user in the loop, such as `talk-it-through`, treat the in-session confirmation as the approval and promote settled items directly to their proper topic file at wrap-up.

## Naming

Use lowercase hyphenated slugs. Default promoted topic files:

- `memory/preferences/assistant-style.md`
- `memory/email/tone-and-format.md`
- `memory/voice/voice-mode.md`
- `memory/docs/important-docs.md`
- `memory/workflows/session-end.md`
- `memory/workflows/approval-style.md`

Decision-capture workflows may create promoted decision files under `memory/decisions/` using `decision-<slug>.md`.

Ticket Guides use flat, searchable filenames under `memory/guides/`, for example `m365-shared-mailbox-send-as-failure.md`.

The entity directory is a single root file `memory/glossary.md` (sections Clients / People / Acronyms / Codenames) — shorthand -> full identity. It is distinct from `CONTEXT.md`: glossary answers "who/what is this?", CONTEXT.md answers "which meaning?". Contested/overloaded terms go to `CONTEXT.md`; plain label expansions go to the glossary.

## Session-End Check

Before finishing a meaningful session, agents should check whether anything should be captured, promoted, merged, or discarded.

If nothing qualifies, say: `Memory check: nothing worth capturing.`

## Cross-linking

- Memory topics may link to each other with standard markdown links using workspace-relative paths that start with `memory/`, for example `[email tone](memory/email/tone-and-format.md)` — the same base `memory/index.md` uses.
- A link expresses a relationship; the relationship kind lives in the prose, not the link.
- Backlinks ("Cited by") are not stored; compute them at read time by reversing the link graph when useful.

## Tolerant Reads

Consume memory permissively. Never refuse to use a memory file because of missing optional frontmatter fields, an unknown `type`, extra unrecognized keys, a missing `index.md`, or a broken cross-link. Do best-effort consumption; a broken link may just be not-yet-written memory.

## Maintenance

- Recreate missing ignored `memory/index.md` or `memory/log.md` when first needed.
- Before writing confirmed memory, check existing topic files for a match and update in place instead of duplicating.
- If a confirmed item conflicts with existing promoted memory, keep the promoted rule active and ask which wins before changing it.
- If a promoted memory item is relevant and older than 90 days, ask whether it is still current.
