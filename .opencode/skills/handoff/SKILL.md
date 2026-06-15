---
name: handoff
description: Create a handoff document for another OpenWork agent or session to continue current work. Use when user asks for handoff, session handoff, continuation prompt, or next-session context.
argument-hint: "What will the next session be used for?"
---

# Handoff

Preserve current session context so fresh OpenWork session or agent can continue work without rereading whole conversation.

## Workflow

1. Identify next-session focus from user arguments, if provided.
2. Gather only necessary context from current session:
   - goal and current state
   - decisions made
   - files, artifacts, tickets, URLs, commands, and tool results that matter
   - blockers, risks, assumptions, and next steps
   - suggested skills for next session
3. Avoid duplicating content already captured in artifacts, PRDs, plans, ADRs, issues, commits, or diffs. Reference those by path, ticket ID, URL, or commit instead.
4. Create handoff document at temp path produced by the current OS:

   macOS/Linux shell:

   ```bash
   mktemp -t handoff-XXXXXX.md
   ```

   Windows PowerShell:

   ```powershell
   $Path = Join-Path ([System.IO.Path]::GetTempPath()) "handoff-$([guid]::NewGuid()).md"
   New-Item -ItemType File -Path $Path | Select-Object -ExpandProperty FullName
   ```

   Read file before writing to it.
5. Write concise Markdown handoff. Use normal prose in document, not chat-style caveman prose.
6. Return only short copy-paste prompt for next session. Prompt must reference handoff file path and name any suggested skills to start with. Do not inline or reprint document contents.

## Handoff document shape

```markdown
# Handoff: <short topic>

## Next-session focus

<what next session should accomplish>

## Current state

<where work stands now>

## Key context

- <decision, evidence, or fact>
- <path, URL, ticket ID, command, or artifact reference>

## Suggested skills

- `<skill-name>` — <why>

## Next steps

1. <first action>
2. <second action>

## Risks / blockers

- <if any>
```

## Output prompt shape

```text
Continue from handoff: <absolute-temp-file-path>. Focus on <next-session focus>. Start with skill(s): <skill names>, if useful.
```
