---
name: 3cx-summary
description: |
  Find the latest transcribed ITA 3CX call for a named person, or the workspace AGENTS.md `Name:` default, and produce a Halo-ready internal note.

  Triggers when user mentions:
  - "3CX call note"
  - "latest 3CX call"
  - "transcribed call summary"
  - "Halo internal note from 3CX"
---

# ITA 3CX Call Note

Be extremely concise. Sacrifice grammar for concision.

## Goal

Find the latest transcribed 3CX call for the target person in ITA 3CX. Create a ticket-ready Halo internal note.

## Input

- `your_name`: optional person name.
- If no person name is provided, use workspace-root `AGENTS.md` `Name:` line.

## Allowed Tools

- Read workspace-root `AGENTS.md` only when `your_name` is blank.
- `itastack_threecx_search_extension`
- `itastack_threecx_list_call_history`

## Target Person

1. If `your_name` is provided, use it.
2. If `your_name` is blank, read workspace-root `AGENTS.md`.
3. Find first explicit line matching `Name: <person name>`.
4. Use `<person name>` as target.
5. Do not infer person from local username, path, account name, git config, session title, or other `AGENTS.md` content.
6. If `your_name` is blank and no `Name:` line exists, ask only:

```text
Who should I search for in ITA 3CX?
```

## Tenant

- Always use tenant `ita`.
- Ignore any user-provided tenant unless they explicitly ask to modify this skill.

## Workflow

1. Resolve target person from input or `AGENTS.md` `Name:` line.
2. Search 3CX extensions for target person in tenant `ita`.
3. Choose best person match: exact full name > email/UPN match > display name containing all name tokens > strongest unique result.
4. Pull recent call history for tenant `ita` with `hours_back=72`, `top=100`.
5. Consider only calls that include transcript/transcription text.
6. Pick most recent transcribed call matching chosen extension.
7. If no extension match, pick most recent transcribed call where `from_display_name` or `to_display_name` matches full name.
8. If no matching transcribed call is found in 72 hours, retry once with `hours_back=168`, `top=100`.
9. Stop after 168 hours unless user asks to search further.
10. Do not summarize tenant-wide history, activity logs, recordings lists, or unrelated calls.
11. Do not invent extension, caller identity, transcript details, ticket numbers, action items, owners, risk, or impact.
12. Use transcript text as source for all details and next steps. If transcript is short or unclear, say so plainly.
13. Do not mention tool names, tool calls, IDs, sources, citations, or internal workflow in final answer.
14. Avoid full phone numbers and emails unless operationally needed for the ticket.

## Output Requirements

Output must be ready to copy and paste into Halo as an internal note. Use plain MSP ticket language. No chat or meta language.

Output exactly this shape:

```text
3CX call summary:
<2-4 sentence paragraph. State who spoke with whom if known, what call was about, what was decided, and risk/impact if stated. No bullets unless multiple distinct issues.>

Details discussed:
- <specific technical/process detail from transcript>
- <specific technical/process detail from transcript>
- <specific technical/process detail from transcript>

Next steps:
- <agreed follow-up, owner if known>
- <next ticket/customer action if known>
```

## Rules for Missing Content

- If fewer than 3 real details exist, use only real detail bullets. Do not pad.
- If no useful technical/process details exist, write:

```text
- No additional technical details captured in transcript.
```

- If no action items were agreed, write exactly:

```text
- No explicit follow-up agreed on the call.
```

- If only one real next step exists, use one bullet only. Do not pad.

## No-Result Output

If no matching transcribed call is found, output exactly:

```text
3CX call summary:
No matching transcribed 3CX call found for <target person> in recent call history.

Details discussed:
- No transcript available to review.

Next steps:
- No explicit follow-up agreed on the call.
```

## Style Rules

- Do not include “Request understood,” “Person searched,” “Tenant used,” “Matched person,” “Tool used,” or diagnostics.
- Do not mention extension number unless useful to the ticket note.
- Do not say “latest transcribed call” unless useful to ticket wording.
- Use natural ticket-note wording: “Spoke with…”, “Confirmed…”, “Client advised…”, “Recommended…”, “Next step is…”.
- Keep wording factual, professional, concise. No AI phrasing. No citations.
