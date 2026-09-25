---
name: 3cx-summary
description: |
  Find the latest transcribed ITA 3CX call for a named person, or the local teammate profile `Name:` default, and produce a first-person Halo ticket update ready to upload.

  Triggers when user mentions:
  - "3CX call note"
  - "latest 3CX call"
  - "transcribed call summary"
  - "Halo internal note from 3CX"
metadata:
  route_default: daily
  route_max: daily
  route_class: 3cx_summary
---

<<<ROUTE default=daily max=daily class=3cx_summary>>>

# ITA 3CX Call Note

Be extremely concise. Sacrifice grammar for concision.

## Goal

Find the latest transcribed 3CX call for the target person in ITA 3CX. Create a first-person Halo ticket update, written the way the technician would log the call, ready to upload to the ticket.

## Input

- `your_name`: optional person name.
- If no person name is provided, use workspace-root `memory/preferences/current-openwork-teammate.md` `Name:` line.

## Allowed Tools

- Read workspace-root `memory/preferences/current-openwork-teammate.md` only when `your_name` is blank.
- `itastack_itastack_threecx` operation `extensions.search`
- `itastack_itastack_threecx` operation `calls.list`

## Target Person

1. If `your_name` is provided, use it.
2. If `your_name` is blank, read workspace-root `memory/preferences/current-openwork-teammate.md`.
3. Find first explicit line matching `Name: <person name>`.
4. Use `<person name>` as target.
5. Do not infer person from local username, path, account name, git config, session title, or other memory content.
6. If `your_name` is blank and no `Name:` line exists, ask only:

```text
Who should I search for in ITA 3CX?
```

## Tenant

- Always use tenant `ita`.
- Ignore any user-provided tenant unless they explicitly ask to modify this skill.
- Call `itastack_itastack_threecx` with top-level `tenant: "ita"`, operation, and `params`.

## Workflow

1. Resolve target person from input or `memory/preferences/current-openwork-teammate.md` `Name:` line.
2. Search 3CX extensions for target person in tenant `ita`.
3. Choose person match in this fixed order; stop at the first that applies:
   a. Exactly one result whose full name equals the target -> use it.
   b. Else exactly one result whose email/UPN contains the target -> use it.
   c. Else exactly one result whose display name contains all name tokens -> use it.
   d. Else if multiple plausible results and none is an exact full-name match -> ask: `Multiple 3CX matches for <target person>. Which extension?`
4. Pull recent call history for tenant `ita` with `hours_back=72`, `top=100`.
5. Consider only calls that include transcript/transcription text.
6. Select the call in this fixed order; default is the first that applies:
   a. Most recent transcribed call matching the chosen extension.
   b. Else most recent transcribed call where `from_display_name` or `to_display_name` matches the full name.
   c. Else treat as no match (go to step 8 retry, then No-Result Output).
8. If no matching transcribed call is found in 72 hours, retry once with `hours_back=168`, `top=100`.
9. Stop after 168 hours unless user asks to search further.
10. Do not summarize tenant-wide history, activity logs, recordings lists, or unrelated calls.
11. Do not invent extension, caller identity, transcript details, ticket numbers, action items, owners, risk, or impact.
12. Use transcript text as source for all details and next steps. If transcript is short or unclear, say so plainly.
13. Do not mention tool names, tool calls, IDs, sources, citations, or internal workflow in final answer.
14. Avoid full phone numbers and emails unless operationally needed for the ticket.

## Output Requirements

Output must be ready to copy and paste straight into the Halo ticket. Write it in the first person as the technician (`I called...`, `I confirmed...`, `I advised...`); never refer to yourself in the third person (`the tech`, `support`, `client was advised`). Use plain MSP ticket language. No chat or meta language.

Output exactly this shape:

```text
3CX call summary:
<2-4 sentence first-person paragraph: I called <who I spoke with, if known>, what the call was about, what I did or decided, and risk/impact if stated. No bullets unless multiple distinct issues.>

Details discussed:
- <specific technical/process detail from transcript>
- <specific technical/process detail from transcript>
- <specific technical/process detail from transcript>

Next steps:
- <agreed follow-up, owner if known>
- <next ticket/customer action if known>
```

## Voice

- First person, past tense, as the technician's own record of the call: `I called...`, `I confirmed...`, `I walked the user through...`, `I advised...`.
- `Details discussed:` bullets stay terse and verb-first (`Confirmed...`, `Moved...`, `Advised...`). No repeated `I` at the start of every bullet, and never describe yourself in the third person.
- Name the other party only when the transcript names them; otherwise say `the user`.
- Never write as an outsider describing your own work (`Spoke with...` about yourself, `the technician`, `support advised`).

## Rules for Missing Content

Apply these deterministically. Always emit both sections.

`Details discussed:`
- Emit one bullet per real technical/process detail from the transcript. Never pad to a fixed count.
- If zero real details exist, emit exactly this single bullet and nothing else:

```text
- No additional technical details captured in transcript.
```

`Next steps:`
- Emit one bullet per agreed follow-up. Never pad.
- If zero follow-ups were agreed, emit exactly this single bullet and nothing else:

```text
- No explicit follow-up agreed on the call.
```

## No-Result Output

If no matching transcribed call is found, output exactly:

```text
3CX call summary:
I could not find a matching transcribed 3CX call for <target person> in recent call history.

Details discussed:
- No transcript available to review.

Next steps:
- No explicit follow-up agreed on the call.
```

## Style Rules

- Do not include "Request understood," "Person searched," "Tenant used," "Matched person," "Tool used," or diagnostics.
- Do not mention extension number unless useful to the ticket note.
- Do not say "latest transcribed call" unless useful to ticket wording.
- Use natural first-person ticket wording: "I called the user about...", "I confirmed...", "I advised the user...", "I recommended...", "Next step is...".
- Keep wording factual, professional, concise. No AI phrasing. No citations.
