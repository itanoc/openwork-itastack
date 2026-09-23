---
name: personal-memory
description: Use when capturing, promoting, pruning, or using local personal OpenWork memory under memory/. Triggers include remember this, capture this preference, run memory check, email preferences, voice preferences, glossary or entity shorthand, and important docs to remember.
metadata:
  route_default: daily
  route_max: daily
  route_class: personal_memory
---

<<<ROUTE default=daily max=daily class=personal_memory>>>

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
├── glossary.md           # ignored — entity directory (shorthand -> identity)
├── preferences/          # ignored personal state
├── docs/                 # ignored personal state
├── voice/                # ignored personal state
├── email/                # ignored personal state
├── guides/               # ignored personal redacted Ticket Guides
├── workflows/            # ignored personal state
├── decisions/            # ignored personal state
└── raw/                  # ignored personal state; explicit approval only
```

## Memory Read Policy

Use tiered reads:

1. At session start or first workspace-specific task, read `memory/index.md` if it exists.
2. Consult `memory/glossary.md` before acting on any request containing shorthand entities (client short names, nicknames, acronyms, project/engagement codenames) — it maps shorthand to full identity.
3. Read promoted memory files relevant to the task before choosing tools, applying workflow rules, drafting user-facing communication, or acting on workspace-specific behavior.
4. Before writing email, voice scripts, Slack messages, reports, or user-facing communication, check relevant promoted memory under `memory/email/`, `memory/voice/`, or `memory/preferences/`.
5. Before researching Halo tickets, check relevant redacted Ticket Guides under `memory/guides/` after fetching the ticket and before web research.
6. Before wrapping up, run the end-of-session aggregation (see Global Capture).

If `memory/index.md` does not exist, proceed normally and create it only when writing the first promoted memory item.

Read tolerantly. Never refuse to use a memory file because of missing optional frontmatter fields, an unknown `type`, extra unrecognized keys, a missing `index.md`, or a broken cross-link. Do best-effort consumption; a broken link may just be not-yet-written memory.

## Cross-linking

Memory topics may reference each other with standard markdown links.

- Use workspace-relative paths starting with `memory/`, for example `[email tone](memory/email/tone-and-format.md)` — the same base `memory/index.md` uses.
- A link asserts a relationship; the kind lives in the surrounding prose. Add related links under a `## Related` heading when a topic depends on, supersedes, or informs another.
- When promoting, if the new topic clearly relates to an existing one, add a cross-link in the `## Related` section instead of duplicating content.
- Backlinks ("Cited by") are not stored in files. Compute them at read time by reversing the link graph when it aids retrieval.

## No Candidates

There are no candidates and no `memory/candidates/` directory. Memory is captured by ASKING in chat and is written only after the user confirms. Nothing is ever written to memory on inference alone. This replaces the old candidate budget, staleness, and dedup gating.

## Setup Workflow

Use when setting up this memory system in a workspace.

1. Create directories:
   - `memory/preferences/`
   - `memory/docs/`
   - `memory/voice/`
   - `memory/email/`
   - `memory/guides/`
   - `memory/workflows/`
   - `memory/decisions/`
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

Use lowercase hyphenated slugs. Default promoted topic files:

- `memory/preferences/assistant-style.md`
- `memory/email/tone-and-format.md`
- `memory/voice/voice-mode.md`
- `memory/docs/important-docs.md`
- `memory/workflows/session-end.md`
- `memory/workflows/approval-style.md`
- `memory/decisions/decision-<slug>.md`
- `memory/guides/<product>-<problem>.md`
- `memory/glossary.md` (single file; sections Clients / People / Acronyms / Codenames)

## Global Capture

Watch for capture triggers in every meaningful session, not only when the user says "remember this." Treat each as a hard trigger, not a judgment call:

- The user corrects you or overrides something you did.
- The user states a rule or preference about how to work ("always…," "never…," "we use X for Y," "keep it to…").
- The user describes how a process or workflow goes, or sets a boundary on one.
- A decision is settled that a future session would otherwise re-litigate.
- You discover a reusable fact while working (a fix, a gotcha, a tool quirk, how their stack is set up).

When a trigger fires:
1. Append this footnote to the end of your response — do NOT write anything to memory yet: *"It seems like this would be helpful if I remembered this: [short summary]. Should I?"*
2. On every later turn, if any asked-but-unconfirmed items are still outstanding, briefly re-surface them as a reminder until the user answers.

When the user says yes (or explicitly asks to remember something), promote it directly per the Explicit Remember Workflow. When unsure whether something qualifies, ask anyway — asking is cheap, re-learning is not.

End-of-session aggregation: before wrapping up meaningful work, gather the triggers from the session the user has NOT already answered (plus any reusable facts you noticed but didn't ask about) and propose them as ONE consolidated "here's what I'd remember" list for a single yes/no. Skip items already confirmed or declined.

Do not capture one-off task details, temporary instructions, guesses about personality, or private facts not needed for future work.

## Explicit Remember Workflow

When the user explicitly asks to remember something, or answers yes to a footnote/aggregation suggestion, treat that as approval to promote directly. Do not ask the user to approve the same memory twice.

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
   - `memory/guides/`
   - `memory/workflows/`
   - `memory/decisions/`
   - `memory/glossary.md` — entity directory (shorthand -> identity). Route here for plain label expansions; contested/overloaded terms go to `CONTEXT.md` instead. When first created it gets its OWN `index.md` row for discoverability; `gate.py audit` audits promoted folders only, not root files, so it will not flag a missing glossary row. Internal format: see the `glossary.md` template in `memory/TEMPLATES.md`.
4. Update frontmatter to `status: promoted` where relevant.
5. Create or update `memory/index.md` with the promoted row. Carry the file path either backticked (`` `memory/decisions/decision-x.md` ``) or as a markdown link (`[title](memory/decisions/decision-x.md)`) so `gate.py audit` can recognize the entry.
6. Create or update `memory/log.md` with a promotion entry.
7. In the final response, mention the promoted memory path changed. STOP THERE — the item is saved, so do NOT append the "It seems like this would be helpful if I remembered this… Should I?" footnote for it. That footnote is ONLY for items you have not yet saved.

## Conflict Resolution

- Promoted memory remains active until the user approves a change.
- If a confirmed item conflicts with existing promoted memory, surface the conflict and ask which rule wins before writing.
- After approval, update the promoted topic file and record the prior rule in notes as superseded.

## Recovery Workflow

Committed scaffold or ignored personal files may be missing in a fresh clone or
teammate workspace. Before writing any promoted memory in a run, ensure the
committed scaffold exists first, then recover the ignored files:

- If `memory/README.md` or `memory/TEMPLATES.md` is missing, recreate it — it is
  committed scaffold, not personal state. Restore `README.md` as the memory
  contract and `TEMPLATES.md` as the canonical templates, using the shapes
  described in this skill and in the `talk-it-through` format docs
  (`DECISIONS-FORMAT.md`, `PROMOTED-MEMORY-FORMAT.md`, `CONTEXT-FORMAT.md`).
- If `memory/index.md` is missing, recreate it from the `TEMPLATES.md` index template before writing promoted memory.
- If `memory/log.md` is missing, recreate it from the `TEMPLATES.md` log template before appending.
- If `TEMPLATES.md` is itself unavailable, do not block: fall back to the
  templates embedded in this skill and the format docs, and recreate
  `TEMPLATES.md` from them.
- Missing ignored files are normal, not an error.

## Lint Workflow

Use when asked to review memory health or before broad cleanup.

Run the deterministic index audit first:

`python3 .agents/skills/personal-memory/gate.py --memory memory audit`

It reports promoted files missing from `memory/index.md` and index entries pointing to files that no longer exist, and exits non-zero when the index needs tidying. For `gate.py audit` to recognize an index entry, the row must carry the file path either backticked (`` `memory/decisions/decision-x.md` ``) or as a markdown link (`[title](memory/decisions/decision-x.md)`).

Then also check for:

- Index rows pointing to missing files.
- Promoted files missing from `memory/index.md`.
- Empty promoted topic files.
- Conflicting active promoted rules.
- Cross-links pointing to memory files that do not exist (report only — broken links are tolerated, not auto-removed).

Report findings before making broad changes. Safe deterministic fixes include removing stale rows and adding missing index rows for existing files.

Note on `gate.py`: it provides a single `audit` command that checks `memory/index.md` against the promoted files on disk. (The old candidate budget/staleness/dedup gating was removed with the move to the ask-then-promote model.)

## Review Cadence

If promoted memory is relevant and older than 90 days, ask whether it is still current. Do not ask repeatedly when unrelated.

## Prune and Supersede

- When a promoted preference changes, update the promoted topic file and record prior rule in notes as superseded.
- If promoted memory is wrong or no longer useful, delete it and remove its index references (record the removal in `memory/log.md`).

## Output Rules

- Report exact memory paths changed.
- For confirmed memory, report the promoted memory path changed and do not ask for promotion again.
- After you have promoted an item this turn, do NOT also append the ask-to-remember footnote for that same item — it is already saved.
- For triggers not yet confirmed, ask one focused question (the footnote) rather than writing anything.
- Keep memory notes short and operational.
- Do not expose sensitive source text in chat when reporting capture.
