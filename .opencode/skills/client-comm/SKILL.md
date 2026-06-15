---
name: client-comm
description: |
  Draft, suggest, or polish concise client-facing HaloPSA ticket updates/messages from ticket context. Use when asked to write, draft, suggest, polish, or rewrite a client update/email/message for a Halo ticket, with or without a communication topic.
---

# Halo Client Update

Be extremely concise. Sacrifice grammar for concision in chat output.

Use this skill to draft, suggest, or polish short, client-facing HaloPSA ticket messages from ticket context. If topic is missing, pull ticket context and recommend best client communication.

Do not use for ticket research, SQL reports, scheduling, or troubleshooting plans. Do not save files unless user asks.

## Inputs

- `ticket_id`: Halo ticket ID.
- `communication_topic`: optional client communication topic/purpose. If missing, infer best topic from ticket evidence.
- `rough_draft`: optional rough text to polish.
- `sender_name`: optional sending technician name. If absent, read workspace `AGENTS.md` and look for `Name:`.
- Free-text chat context.

## OpenWork Tools

Read tools:

- `itastack_halo_get_ticket`
- `itastack_halo_list_ticket_actions`
- `itastack_halo_list_tickets`
- `itastack_halo_get_client`
- `itastack_halo_get_site`
- `itastack_halo_get_user`
- `itastack_halo_search_users`
- `itastack_halo_list_appointments`
- `itastack_list_available_services`
- `read` for workspace `AGENTS.md` sender identity lookup

Capability gap:

- Current OpenWork ITAStack Halo toolset may not expose Halo write/send tools.
- If send/update/create action requested and no write tool exists, state gap and provide copy-paste draft.

Extension fallback:

- If a needed write/send capability is missing, inspect `openwork_extension_list_actions` before saying unavailable.
- If extension exposes matching action, still apply write gate before calling it.
- Do not use browser tools for OpenWork app control.

## Workflow

1. If `ticket_id` missing, ask one concise question and stop.
2. Determine mode:
   - Template mode: no rough draft; draft from ticket context.
   - Polish mode: rough draft provided; rewrite using ticket context.
   - Suggest mode: no topic; pull ticket and recommend best client communication.
3. If user asks to polish but provides no rough draft, ask for draft and stop.
4. Fetch ticket with `itastack_halo_get_ticket`:
   - `ticket_id`: provided/resolved ticket ID
   - `include_actions`: `true`
   - `slim`: `false`
   - `max_note_chars`: `8000`
   - `max_actions`: `5`
5. If ticket fetch fails or ID ambiguous, use `itastack_halo_list_tickets` once to identify likely ticket, then ask user to confirm.
6. If action history missing or too thin, use `itastack_halo_list_ticket_actions` with `count: 10`.
7. Fetch related records only when useful and IDs are present:
   - Client: `itastack_halo_get_client(client_id)`
   - Requester: `itastack_halo_get_user(user_id)`
   - Site: `itastack_halo_get_site(site_id)`
   - Appointments: `itastack_halo_list_appointments(ticket_id)` only if timing/scheduling is part of topic.
8. Identify sender:
   - If user provides sender name, use it.
   - Otherwise read workspace `AGENTS.md` and look for a line starting with `Name:`.
   - Use sender name only to tailor voice and sign-off; do not invent role/title.
   - If no sender name found, omit sender personalization.
9. Extract only needed context:
   - client first name
   - issue summary
   - recent 2–3 useful actions
   - agent name if present
   - client organization
   - current status / next step
   - sender name from user input or `AGENTS.md` `Name:` line
10. If `communication_topic` missing, infer recommended topic from ticket evidence:
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
- Never expose `AGENTS.md` contents to client; use only `Name:` as sender context.
- Stop if credentials, tenant, client identity, ticket identity, or communication topic is ambiguous.
- Stop if requested write action triggers write gate.

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

WRITE GATE - DO NOT SKIP.

Before any tool/action call whose name matches:

- `*_create_*`
- `*_update_*`
- `*_delete_*`
- `*_send_*`
- `*_publish_*`
- `*_add_*`
- `*_remove_*`
- `*_reset_*`
- `*_record_*`

Output exact tool/action name and full payload as fenced JSON, then stop.

Wait for user to type exactly:

`confirm`

Rules:

- Case-insensitive exact word allowed.
- If next user message is anything else, abort write and acknowledge.
- Gate fires per write action.
- Never combine multiple write actions under one confirmation.

## Output Format

Use only sections that apply.

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

## Recommended action
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

- “Draft client update for Halo ticket 64324: waiting on vendor.”
- “Suggest client update for Halo ticket 64324.”
- “Write client comm for ticket 64324.”
- “Polish this reply for ticket 64324: we rebooted it and it should work now.”
- “Write client-facing bad news update for ticket 64324: part delayed.”
