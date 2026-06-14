# AGENTS.md

Instructions for AI agents working in this OpenWork workspace.

## Purpose

This directory is an OpenWork/OpenCode workspace configuration area, not normal application source code. Treat changes here as changes to how agents, skills, MCP servers, workflows, and OpenWork sessions behave.

Primary audience: AI agents. Secondary audience: teammates reading the same operating rules.

## Core behavior

- Be practical and concise.
- Prefer small, reversible changes.
- Ask one targeted question when requirements are ambiguous.
- Do not invent OpenWork behavior from memory when documentation or UI discovery can answer it.
- When work produces a reusable procedure, suggest capturing it as a skill or agent.
- Never store secrets, tokens, API keys, bearer strings, OAuth credentials, private logs, or sensitive screenshots in repo files.
- Silently redact secrets from any generated documentation or examples.

## OpenWork lookup and tool routing

Use the most direct source of truth and control surface.

- Product questions → read OpenWork docs first. Start with `https://openworklabs.com/docs/llms.txt` when unsure which page applies.
- Known docs URLs → use direct web fetch. Interactive sites → open through OpenWork's built-in browser first, then use the returned browser handle.
- OpenWork app control → use OpenWork UI actions, not browser automation.
- Missing capability → inspect available OpenWork extensions/actions before saying it cannot be done.
- Unclear or stale docs → inspect available UI actions or implementation code as a last resort, then label the answer as inferred.
- Final answers about OpenWork behavior → cite useful docs URLs or paths when helpful.

Common OpenWork routes:

- AI providers → Settings > AI Providers.
- MCP servers/extensions → Settings > Extensions. Custom MCP setup is Extensions > Advanced Settings > Add MCP server. Some MCP servers require OAuth/dynamic client registration; if unsupported, report that limitation without guessing a workaround.
- File access → Settings > Permissions / Authorized Folders.
- Skills → Settings > Skills.
- General preferences → Settings > General.
- Session management → session actions for rename, pin, archive, group, open, and transcript reading.

## Cross-chat memory

OpenWork cross-chat memory comes from saved session history exposed through app UI actions, not from hidden long-term model memory.

When the user asks what was said, decided, or done in another chat:

1. Use session listing to find matching sessions by session ID, title, workspace, or topic words.
2. If there is one clear match, open it and read the transcript.
3. If multiple sessions match, ask one short clarifying question.
4. Answer only from the returned transcript.
5. If the transcript is bounded or missing older context, say so instead of guessing.
6. If navigating away from the current chat, return when useful or tell the user what changed.

Reference: `https://openworklabs.com/docs/start-here/do-work-with-it/cross-chat-memory`.

## Personal OpenWork memory

This workspace uses `memory/` for local, personal, non-code memory. The committed files are only a reusable team scaffold; populated memory is personal state and must stay ignored by git.

Use the `personal-memory` skill when capturing, checking, promoting, pruning, or using memory under `memory/`.

### Directories

- `memory/README.md`: shared contract for the memory system.
- `memory/TEMPLATES.md`: candidate, promoted topic, index, and log templates.
- `memory/index.md`: ignored personal index of promoted memory and candidates.
- `memory/log.md`: ignored personal operation log.
- `memory/candidates/`: ignored auto-captured memory awaiting approval.
- `memory/preferences/`: ignored promoted assistant and working preferences.
- `memory/docs/`: ignored promoted important docs, links, and paths.
- `memory/voice/`: ignored promoted voice-mode preferences.
- `memory/email/`: ignored promoted email and message preferences.
- `memory/workflows/`: ignored promoted workflow habits and approval preferences.
- `memory/raw/`: ignored raw snippets; use only with explicit approval.

### Safety rules

- Never store secrets, tokens, passwords, API keys, bearer strings, OAuth credentials, or credential-like config in memory.
- Prefer short summaries over raw private content.
- Do not store full emails, screenshots, client documents, transcripts, or sensitive third-party data by default.
- Store raw material only when the user explicitly asks to keep it, and redact sensitive details first.

### Read policy

- At session start or first workspace-specific task, read `memory/index.md` if it exists.
- Read only promoted memory files relevant to the task.
- Before drafting email, voice scripts, Slack messages, reports, or other user-facing communication, check relevant promoted memory under `memory/email/`, `memory/voice/`, or `memory/preferences/`.
- Do not treat `memory/candidates/` as authoritative. Use candidates only for recurrence checks, promotion decisions, or when the user asks.

### Capture triggers

Auto-capture a concise candidate under `memory/candidates/` when the session contains a clear durable signal:

- Preference: “I prefer X,” “do not do Y,” or “use this style.”
- Repeated correction: the user corrects agent behavior in a way likely to apply again.
- Important doc/link/path: the user says something should matter later.
- Communication style: email, voice, meeting, report, summary, or response preferences.
- Workflow habit: preferred sequence, tool choice, approval style, or final-answer format.
- Personal work context: role, responsibilities, or recurring projects, only when useful for future work.
- Stable decision: “from now on,” “default to,” “always,” or “never.”

Do not capture one-off task details, temporary instructions, guesses about personality, or private facts not needed for future work.

### Session-end memory check

Before reporting a meaningful task complete, run a memory check:

1. Review the current session for capture triggers.
2. Check `memory/candidates/` for similar unresolved candidates.
3. Auto-write clear new candidates using `memory/TEMPLATES.md`, update `memory/index.md`, and append `memory/log.md`.
4. If a candidate repeats or is confirmed, recommend promotion and ask one focused question.
5. If promoted, merge relevant candidate content into the right topic file, delete obsolete candidate files, remove stale candidate rows from `memory/index.md`, and append `memory/log.md`.
6. If nothing qualifies, state: `Memory check: nothing worth capturing.`

## Session workflow

Use OpenWork session groups to keep work organized. Preferred default groups:

- `Research` — documentation lookup, product investigation, architecture exploration, external references.
- `In progress` — active implementation, config work, workspace setup, file edits.
- `Needs review` — waiting on user decision, approval, safety check, or human review.
- `Done` — completed work worth keeping for future reference.

Behavior:

- If a useful group is missing, ask whether to create it and move the chat there.
- If a group exists and classification is obvious, move the session without repeated confirmation.
- If classification is uncertain, ask before moving.
- Never delete sessions unless the user explicitly confirms deletion.
- Archive only when the user asks or gives a standing instruction.
- Pin only when work is important enough to reuse or revisit.

Useful session primitives include listing groups, creating groups, moving sessions to groups, renaming sessions, pinning sessions, and archiving sessions.

Typical mappings:

- Docs lookup or research artifact created → `Research`.
- Active file/config changes underway → `In progress`.
- User decision needed → `Needs review`.
- Completed useful work → `Done`.

## Next-best OpenWork action suggestions

When helpful, suggest one concrete OpenWork action based on work type:

- Research results → save a Markdown artifact and move session to `Research`.
- Repeatable procedure → propose a new `.opencode/skills/<name>/SKILL.md`.
- Role-specific behavior → propose a new `.opencode/agents/<name>.md`.
- Config or workspace convention changed → update `AGENTS.md` or a relevant skill.
- User decision needed → move session to `Needs review` and ask one focused question.
- Finished useful work → move session to `Done`; pin only if it should stay easy to find.
- Browser-heavy task → use or suggest OpenWork browser control.
- App setup task → open the relevant OpenWork settings panel directly.

Keep suggestions lightweight. Do not turn every response into a workflow checklist.

## Artifacts

Use standard files for user-visible deliverables so OpenWork can preview, edit, and download them.

- Use Markdown (`.md`) for research notes, plans, runbooks, handoffs, and decision summaries.
- Use CSV (`.csv`) for simple tables and inventories.
- Use Excel (`.xlsx`) only when the user asks for an Excel workbook or formatting matters.
- Use PowerPoint (`.pptx`) only when the user asks for slides.
- Use `index.html` or a local `http://localhost:<port>` URL for browser previews.

After creating or updating an artifact, mention the exact workspace-relative path in the final answer.

## Reusable behavior

Keep this file as the high-level operating policy.

Use reusable project files when behavior becomes repeated:

- `.opencode/skills/<skill-name>/SKILL.md` for repeatable workflows.
- `.opencode/agents/<agent-name>.md` for role-specific agent behavior.
- `opencode.jsonc` for OpenCode/OpenWork configuration.

Create new skills or agents only when the user asks or agrees.

## Answer style

- Be direct.
- Mention exact workspace-relative artifact paths after creating or updating files.
- For OpenWork behavior, include docs URL when useful.
- For uncertain behavior, say what was verified and what remains inferred.
