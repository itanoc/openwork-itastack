---
name: personalize-opencode
description: |
  Produce a sanitized, shareable copy of one of your OpenCode skills, agents, or an AGENTS.md — stripping work-specific detail so it can be safely given to a friend.

  Triggers when the user wants to share or clean up OpenCode config for someone outside their work, including phrases like:
  - "share this skill with a friend"
  - "personalize this skill" / "personalize-opencode"
  - "take the work stuff out of this"
  - "make this agent safe to share"
  - "sanitize this AGENTS.md"
  - "give a friend one of my skills"
metadata:
  route_default: daily
  route_max: medium
  route_class: personalize_opencode
---

<<<ROUTE default=daily max=medium class=personalize_opencode>>>

# Personalize OpenCode

Use this skill to turn a work-oriented OpenCode artifact (a skill, an agent, or an `AGENTS.md`) into a clean, shareable copy that a friend could drop into their own setup without exposing work-specific detail.

The originals are **never modified**. Every sanitized artifact is written to `personal-opencode/` at the workspace root.

## Core Principles

- **Read-only on source.** Never edit, move, or delete the original. Only read it.
- **Output goes to `personal-opencode/`**, mirroring the source layout (see Output Layout).
- **Secrets are always removed**, never echoed into chat and never written to the output.
- **Hybrid sanitization** (see Workflow step 3): auto-strip the unambiguous work detail silently; pause and ask on judgment calls.
- **Don't break the skill unnecessarily.** Prefer a working, generic version over a hollow one.

## What Counts as Work-Specific

Six categories to remove or generalize:

1. **Client / company names** — `ITAStack` and any specific client names → generic ("your company", "a client").
2. **Internal tools / integrations** — Halo, VSA, 3CX, Fortinet, M365 tenants, Pax8, Blumira, Telnyx, UniFi, Grafana, ITGlue, Exchange, Typeform, and similar → removed or replaced with a generic equivalent ("your ticketing system", "your RMM", "your phone system").
3. **Infrastructure specifics** — hostnames, IP addresses, absolute paths under a user's home dir, tenant IDs, org IDs, device names.
4. **Private processes** — internal SOPs, billing rules, and references to personal `memory/` (decisions, preferences, workflows, docs).
5. **Secrets / credentials** — API keys, tokens, passwords. Always removed. Never generalized, never echoed.
6. **References to other workspace skills / agents / workflows** — a sanitized artifact that says "use the `endpoint-sync` skill" points the friend at something they don't have. Generalize the reference ("use your sync skill") or drop it if it isn't essential.

## Output Layout

Mirror the source under `personal-opencode/`:

- A skill → `personal-opencode/skills/<name>/` (sanitize **all** files in the skill folder, not just `SKILL.md`).
- An agent → `personal-opencode/agents/<name>.md` (match the source filename/extension).
- An `AGENTS.md` → `personal-opencode/AGENTS.md`.

Preserve the internal structure of multi-file skills (subfolders, reference docs, scripts) — sanitize each file in place within the output copy.

**Non-Markdown files (scripts, code, configs) are in scope.** They are the most likely place for hardcoded hostnames, tenant/org IDs, API endpoints, and secrets. Open and scan every such file, not just the `.md` files. If a script is only meaningful against a work tool and can't be genericized into something a friend could use, replace its work-specific internals with a clearly-marked `TODO:` shell (see Workflow step 4) or drop it and note the drop in the summary — never copy it through unscanned.

## Workflow

### 1. Identify the Source

Determine what the user wants to share. Accept:

- A skill name → look under `.agents/skills/<name>/`.
- An agent name → look under `.opencode/agents/`. This folder may not exist in every workspace; if it's absent or the named agent isn't there, ask once for the exact path and stop.
- `AGENTS.md` → the given path (workspace root or a subfolder).
- A direct file or folder path.

If the source can't be found, ask once for the exact name or path and stop. If multiple candidates match, list them and ask which.

Read the full source (every file, for a multi-file skill) before changing anything.

### 2. Scan and Categorize

Go through the source and mark each work-specific hit against the five categories above. Sort each hit into:

- **Auto-strip (silent):** secrets, credentials, IPs, hostnames, absolute home-dir paths, tenant/org IDs, device names, `memory/` references. Handle without asking.
- **Judgment call (ask):** an integration or process that is *core to the skill's logic* — where removing it changes what the skill does (e.g. a ticket-based workflow, a phone-audit skill).

### 3. Sanitize (Hybrid)

- **Auto-strip** the unambiguous items silently:
  - Remove secrets entirely; leave a clearly-marked placeholder only if structurally needed (e.g. `<YOUR_API_KEY>`).
  - Replace IPs, hostnames, tenant IDs, device names with generic placeholders.
  - Replace absolute paths under a home dir with relative or generic paths.
  - Strip `memory/` references and internal SOP/billing specifics.
  - Generalize company/client names ("ITAStack" → "your company").
- **For each judgment call, pause and ask** the user whether to: **genericize**, **remove**, or **keep**. Present the specific item and why it's a judgment call. Batch related questions where sensible, but don't guess.

### 4. Handle Deeply Tool-Integrated Skills

When a skill is *fundamentally built around* a work tool (it's meaningless without it — e.g. `ticket-summary`, `3cx-audit`):

- **Genericize into a reusable shell**: replace the specific tool with a generic name ("your ticketing system"), strip the specific API operations/dispatcher calls, and leave a clearly-marked `TODO:` note where the friend would wire in their own tool. This applies to script/code files too — replace work endpoints and calls with a `TODO:` shell rather than copying them through.
- The result should be a working *template*, not a broken skill and not a leak of the integration detail.

(Note: such skills are rarely worth sharing — treat this as the fallback for the occasional case, not the main path.)

### 5. Write the Output

- Check whether the mirrored output path already exists. If it does, tell the user and ask whether to overwrite before writing; note the overwrite in the summary.
- Create the mirrored path under `personal-opencode/` (see Output Layout).
- Write each sanitized file. Preserve the `<<<ROUTE>>>` line and `metadata` block — these aren't work-identifying — but keep them generic.
- Keep frontmatter (`name`, `description`, etc.) intact except where it names work tools/clients, which get generalized.
- Never write secrets to the output.

### 6. Summarize

Give a short report:

- Source and output path (workspace-relative).
- What was **stripped** (by category, counts are fine — don't echo secret values).
- What was **genericized** (e.g. "Halo → your ticketing system").
- Any **TODOs** left for the friend to complete.
- Any judgment calls and how they were resolved.

## Safety

- Never echo a secret value into chat, even to say what was removed — refer to it by kind ("an API token was removed").
- Never modify the source artifact.
- If unsure whether something is work-identifying, treat it as a judgment call and ask.

## Example

**User:** "Personalize the `brainstorm-idea` skill so I can send it to a friend."

**Skill:**
1. Reads `.agents/skills/brainstorm-idea/SKILL.md`.
2. Auto-strips: a reference to `scripts/ai/context.sh` internal path, `memory/` mentions, "OpenWork extensions" if work-specific.
3. Judgment call: "This skill mentions `task` subagents for repo research — generic enough to keep. No work tools are core here." → keeps.
4. Writes `personal-opencode/skills/brainstorm-idea/SKILL.md`.
5. Reports: "Copied to `personal-opencode/skills/brainstorm-idea/`. Stripped 2 internal path references and 1 memory reference. No secrets found. No TODOs — this one's fully generic."
