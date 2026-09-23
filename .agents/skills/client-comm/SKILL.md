---
name: client-comm
description: |
  Draft, suggest, or polish concise client-facing HaloPSA ticket updates/messages from ticket context. Use when asked to write, draft, suggest, polish, or rewrite a client update/email/message for a Halo ticket, with or without a communication topic.
metadata:
  route_default: daily
  route_max: daily
  route_class: client_comm
---

<<<ROUTE default=daily max=daily class=client_comm>>>

# Halo Client Update

Be extremely concise. Sacrifice grammar for concision in chat output.

Use this skill to draft, suggest, or polish short, client-facing HaloPSA ticket messages from ticket context. If topic is missing, pull ticket context and recommend best client communication.

Do not use for ticket research, SQL reports, scheduling, or troubleshooting plans. Do not save files unless user asks.

Act immediately when inputs are present. If `ticket_id` is present, proceed with the workflow now — do not recite an intro, re-ask, or wait for more input. The only reasons to stop before drafting are listed under Guardrails.

## Inputs

- `ticket_id`: Halo ticket ID.
- `communication_topic`: optional client communication topic/purpose. If missing, infer best topic from ticket evidence.
- `rough_draft`: optional rough text to polish.
- `sender_name`: optional sending technician name. If absent, read workspace `memory/preferences/current-openwork-teammate.md` and look for `Name:`.
- Free-text chat context.

## OpenWork Tools

Read tools:

- `itastack_itastack_halo` operation `get_ticket`
- `itastack_itastack_halo` operation `actions.list`
- `itastack_itastack_halo` operation `tickets.list`
- `itastack_itastack_halo` operation `clients.get`
- `itastack_itastack_halo` operation `lookups.get_site`
- `itastack_itastack_halo` operation `users.get`
- `itastack_itastack_halo` operation `users.list`
- `itastack_itastack_halo` operation `appointments.list`
- `itastack_list_available_services`
- `read` for workspace `memory/preferences/current-openwork-teammate.md` sender identity lookup

Write/send capability:

- If a send/update/create action is requested, check `openwork_extension_list_actions` for a matching write action.
- If one exists, apply the Write Gate before calling it.
- If none exists, output the Capability Gap section with a copy-paste draft.
- Do not use browser tools for OpenWork app control.

## Workflow

1. If `ticket_id` is missing, ask one concise question and stop. Otherwise proceed.
2. Determine mode (pick the first that matches; default is Suggest):
   - Polish mode: a rough draft is provided → rewrite it using ticket context.
   - Template mode: a topic is provided but no draft → draft from ticket context.
   - Suggest mode (default): no topic and no draft → pull ticket and recommend the best client communication. Never stop just because the topic is missing; inferring it is the job.
3. If the user explicitly asks to polish but provides no rough draft, ask for the draft and stop. (Does not apply to Template/Suggest mode.)
4. Fetch ticket with `itastack_itastack_halo` operation `get_ticket`:
   - `ticket_id`: provided/resolved ticket ID
   - `include_actions`: `true`
   - `slim`: `false`
   - `max_note_chars`: `8000`
   - `max_actions`: `5`
5. If ticket fetch fails or ID ambiguous, use `itastack_itastack_halo` operation `tickets.list` once to identify likely ticket, then ask user to confirm.
6. If action history missing or too thin, use `itastack_itastack_halo` operation `actions.list` with `count: 10`.
7. Fetch related records only when useful and IDs are present:
   - Client: `itastack_itastack_halo` operation `clients.get`
   - Requester: `itastack_itastack_halo` operation `users.get`
   - Site: `itastack_itastack_halo` operation `lookups.get_site`
   - Appointments: `itastack_itastack_halo` operation `appointments.list` only if timing/scheduling is part of topic.
8. Identify sender:
   - If user provides sender name, use it.
   - Otherwise read workspace `memory/preferences/current-openwork-teammate.md` and look for a line containing `Name:`.
   - Use sender name only to tailor voice and sign-off; do not invent role/title.
   - If no sender name found, omit sender personalization.
9. Extract only needed context, each from its source:
   - client first name — from `get_ticket` requester, or `users.get`
   - issue summary — from `get_ticket` summary/details
   - recent 2–3 useful actions — from `get_ticket` actions or `actions.list`
   - agent name if present — from `get_ticket` agent field
   - client organization — from `get_ticket` client, or `clients.get`
   - current status / next step — from `get_ticket` status and latest action
   - sender name — from user input, else the `Name:` line in `memory/preferences/current-openwork-teammate.md`
   Use only values that appear in tool results. Do not assemble or guess fields that are absent.
10. If `communication_topic` missing, infer recommended topic from ticket evidence (pick the first that matches; if none match, default to "honest status update + next action"):
   - waiting on client: ask for exact missing info or availability
   - waiting on vendor/internal escalation: status update + next update expectation only if supported
   - work completed / likely resolved: resolution confirmation + ask client to verify
   - stalled/no recent update: honest status update + next action
   - appointment/time-sensitive context: scheduling-aware status only; read-only, do not schedule
   - bad news/risk/delay: use bad news pattern
11. Draft or polish message using style guide and sender identity if available.
12. If write/send/update requested, apply write gate before any write action.

## Guardrails

- Do not invent ticket facts.
- Do not mention internal notes, tool results, IDs, logs, or uncertainty unless useful to client.
- Keep one topic per email.
- Never blame client.
- Never promise exact time unless ticket context confirms it.
- Never say work is complete unless evidence supports it.
- Never expose teammate profile contents to client; use only `Name:` as sender context.

Stop conditions (these are the only reasons to stop before drafting):

- Stop if credentials, tenant, or secret handling is involved or ambiguous.
- Stop if `ticket_id` is missing (see Workflow step 1) or the resolved ticket is genuinely ambiguous after a `tickets.list` lookup.
- Stop if a requested write/send/update action triggers the Write Gate.

A missing or unclear communication topic is NOT a stop condition — infer it (Workflow step 10).

## Style Guide

- Warm, conversational, confident, direct.
- Empathetic when needed.
- Under 150 words when possible.
- Use contractions.
- Avoid jargon.
- End with clear next step or invitation to respond.

Greetings:

- `Hey [FirstName],`
- `Hi [FirstName],`

Avoid greetings:

- Dear
- To whom it may concern
- Good afternoon

Sign-offs:

- Talk soon
- Let me know if you need anything
- Thanks
- Thanks,
  [SenderName]

Avoid sign-offs:

- Best regards
- Sincerely
- Kind regards

## Bad News Pattern

1. Acknowledge briefly.
2. State what is working/protected.
3. Explain issue simply.
4. State plan.
5. Give next-update timeline only if confirmed or safe.

## Write Gate

WRITE GATE - NEVER SKIP THESE STEPS.

Applies before any tool/action call whose name matches:

- `*_create_*`
- `*_update_*`
- `*_delete_*`
- `*_send_*`
- `*_publish_*`
- `*_add_*`
- `*_remove_*`
- `*_reset_*`
- `*_record_*`

Steps (do all, in order, never skip):

1. Output the exact tool/action name and full payload as fenced JSON.
2. Stop. Do not call the tool yet.
3. Wait for the user to reply with exactly `confirm` (case-insensitive, exact word).
4. If the reply is `confirm`, make the call. If it is anything else, abort the write and acknowledge.

Rules:

- The gate fires once per write action.
- Never combine multiple write actions under one confirmation.

## Output Format

Always emit all four sections below, in this order. Never omit the Draft. If a field has no value, write `not found` rather than dropping the line.

```md
## Request understood
- Ticket: #...
- Topic: provided / inferred: ...
- Mode: Template / Polish / Suggest
- Sender: ... / not found

## Evidence gathered
- Requester/client: ...
- Issue: ...
- Recent context:
  - ...
  - ...

## Draft
Hi [FirstName],

...

Thanks

## Next step
- ...
```

## Capability Gap Output

If user asks to send/update and no safe write tool exists:

```md
## Capability gap
- I can draft message from Halo context.
- No Halo send/update tool exposed here.

## Next step
- Copy draft into HaloPSA, or enable write-capable extension/tool.
```

## Examples

- "Draft client update for Halo ticket 64324: waiting on vendor."
- "Suggest client update for Halo ticket 64324."
- "Write client comm for ticket 64324."
- "Polish this reply for ticket 64324: we rebooted it and it should work now."
- "Write client-facing bad news update for ticket 64324: part delayed."
