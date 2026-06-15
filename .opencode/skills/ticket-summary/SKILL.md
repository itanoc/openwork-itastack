---
name: ticket-summary
description: |
  Concise HaloPSA ticket summary for current state, blockers, evidence, and next action. Use when asked to summarize a ticket, give a quick overview, digest ticket status/key events, or identify what should happen next from ticket evidence.
---

# Ticket Summary

Be extremely concise. Sacrifice grammar for concision in chat output.

Use this skill to fetch one HaloPSA ticket and produce a tight state-of-ticket summary in chat. Include client, requester, current status, blockers, key events, and next action grounded in ticket evidence.

This OpenWork version intentionally includes an evidence-based next action because the requested goal asks for it. If user asks for “state only” or “no recommendation,” omit `Recommended action` and keep `Current state` plus `Next step` factual.

Do not save files. Do not do web research. Do not perform writes.

## Inputs

- `ticket_id`: Halo ticket ID.
- `client_name`: Client or organization name, optional but useful for validation.
- `user_email`: User email address, optional for disambiguation.
- Free-text chat context.

## OpenWork Tools

Read tools:

- `itastack_halo_get_ticket`
- `itastack_halo_list_tickets`
- `itastack_halo_get_client`
- `itastack_halo_get_user`
- `itastack_halo_get_site`
- `itastack_halo_list_ticket_actions`
- `itastack_halo_list_appointments`
- `itastack_halo_list_statuses`
- `itastack_halo_list_priorities`
- `itastack_halo_list_teams`
- `itastack_halo_list_agents`

Capability gap:

- Halo write tools are not exposed in this OpenWork toolset: create/update ticket, create ticket action, create/update/delete appointment.
- If user requests a write, state gap and give fallback: “Use HaloPSA UI or ask for a draft note/update text.”

Extension fallback:

- If a needed capability is missing, inspect `openwork_extension_list_actions` before saying unavailable.
- Do not use browser tools for OpenWork app control.

## Workflow

1. Identify ticket, client, requester/user, asset, tenant, and timeframe from user text.
2. If ticket identity is missing or ambiguous:
   - If `client_name` or keywords exist, use `itastack_halo_list_tickets` once to search likely tickets.
   - If still ambiguous, ask one concise clarification question and stop.
3. Fetch ticket with `itastack_halo_get_ticket`:
   - `ticket_id`: provided/resolved ticket ID
   - `include_actions`: `true`
   - `slim`: `false`
   - `max_note_chars`: `8000`
   - `max_actions`: `0`
4. If action history is absent or clearly truncated, use `itastack_halo_list_ticket_actions` for more action context.
5. Fetch related records only when useful and IDs are present:
   - Client: `itastack_halo_get_client(client_id)`
   - Requester: `itastack_halo_get_user(user_id)`
   - Site: `itastack_halo_get_site(site_id)`
   - Appointments: `itastack_halo_list_appointments(ticket_id)` when scheduling/current workload matters
   - Status/priority/team/agent lookups: only when ticket response has IDs but not human-readable names
6. Validate provided `client_name` and `user_email` against ticket data.
   - If they conflict, ask one concise clarification question and stop.
7. Extract:
   - ticket summary/details, status, priority, team/agent, category, dates/SLA
   - client/org, site, requester/end-user contact details
   - current assignment and appointment/scheduling context
   - meaningful key events from action history
   - explicit blockers and unresolved asks
   - next action from ticket evidence only
   - whether more data is required before action

## Event Digest Rules

Include only key events:

- Status changes: opened, escalated, closed, reopened, moved queue/status.
- Assignment changes: assigned/reassigned.
- Resolution attempts: fix/workaround/troubleshooting performed.
- Client/user replies: new facts, approvals, denials, availability, impact.
- Escalations: internal/vendor/security/escalation notes.
- Scheduling events: appointment booked/rescheduled/no-show when relevant.

Skip:

- automated SLA/timer entries
- system notifications with no new info
- duplicates
- email signatures/quoted history
- routine “left voicemail” unless it blocks progress

Limit:

- Maximum 8 key events.
- If more events exist, summarize omitted range: `... N routine/older updates omitted (MM/DD–MM/DD)`.

Each event line:

- `MM/DD HH:mm — Actor: action/result`

## HTML / Text Cleanup

- Strip HTML tags from descriptions and notes.
- Decode common entities.
- Remove quoted email chains unless needed.
- Keep names/emails only when operationally useful.

## Stop Conditions

- Ticket identity ambiguous.
- Client/user conflict cannot be resolved.
- Ticket fetch returns 401/403/restricted/CMMC: stop and report restricted access.
- Ticket fetch returns 404/not found: stop and report not found.
- Other Halo tool errors: stop, report short error, do not infer ticket state.
- Required action would write data: stop, state write tool gap, offer draft text.
- Credentials/tool auth unavailable: stop and report tool/credential issue.

## Output Style

- Use only sections needed.
- Bullets over prose.
- Five bullets or fewer per section unless needed.
- Lead with answer/current state.
- Always include `Current state` unless ticket fetch fails.
- Expand only if user asks.
- No raw tool IDs in final unless needed to explain capability gap.

## Output Format

```md
## Request understood
- Ticket: #...
- Client/user: ...
- Ask: summary / current state / blockers / next action

## Evidence gathered
- Status/priority/owner: ...
- Client/requester/site: ...
- Key events:
  - MM/DD HH:mm — Actor: action/result
  - ...
- Blockers: ...

## Current state
- ...
- ...

## Recommended action
- Evidence-based next action: ...
- If no clear next action: Need more data: ...

## Next step
- ...
```

## Recommendation Rules

- Do not invent solution research.
- Recommended action must come from ticket evidence, current status, blocker, or obvious process next step.
- If ticket lacks enough data, say `Need more data` and list exact missing item.
- For technical solve steps or web/vendor research, offer `halo-ticket-research` instead.

## Examples

- “Summarize Halo ticket 64324.”
- “Ticket 64324 current state and blockers.”
- “Give me quick digest and next action for 64324, user jane@example.com.”
