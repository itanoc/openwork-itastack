---
name: sched-workload
description: |
  Workload-balanced HaloPSA appointment scheduling in OpenWork. Use when scheduling appointments, finding available times, or balancing technician workload from Halo tickets and appointments.
---

# Sched Workload

Be extremely concise. Sacrifice grammar for concision in chat output.

Use this skill to analyze scheduled work and workload from HaloPSA tickets and appointments, recommend who should take work, and identify next available appointment slots.

OpenWork version of older Open WebUI prompt. Tool names are OpenWork ITAStack function names, not Open WebUI operation IDs.

## Inputs

- `ticket_id`: Halo ticket ID.
- `client_name`: Client or organization name.
- `user_email`: User email address.
- Technician names or Halo agent IDs from chat.
- Duration, appointment type, date/time preference, or timeframe from chat.
- Any free-text scheduling context.

## OpenWork Tools

Read tools:

- `itastack_itastack_halo` operation `get_ticket`
- `itastack_itastack_halo` operation `tickets.list`
- `itastack_itastack_halo` operation `actions.list`
- `itastack_itastack_halo` operation `appointments.list`
- `itastack_itastack_halo` operation `agents.list`
- `itastack_itastack_halo` operation `lookups.list_statuses`
- `itastack_itastack_halo` operation `lookups.list_priorities`
- `itastack_itastack_halo` operation `lookups.list_teams`
- `itastack_itastack_halo` operation `clients.get`
- `itastack_itastack_halo` operation `users.get`
- `itastack_itastack_halo` operation `lookups.get_site`

Write tools:

- `itastack_itastack_halo` operation `appointments.create`
- `itastack_itastack_halo` operation `appointments.update`
- `itastack_itastack_halo` operation `appointments.delete`
- `itastack_itastack_halo` operation `actions.create`
- Use write tools only after the user approves the exact target ticket/appointment, time, agent, payload summary, and any note text.

Extension fallback:

- If a needed capability is missing, inspect `openwork_extension_list_actions` before saying unavailable.
- Do not use browser tools for OpenWork app control.

## Workflow

Follow in order.

1. Identify client, tenant, ticket, requester/user, asset, timeframe, eligible technicians, duration, and appointment type from chat.
2. If ticket identity is missing or ambiguous:
   - If `client_name` or keywords exist, use `itastack_itastack_halo` operation `tickets.list` once.
   - If still ambiguous, ask one concise clarification question and stop.
3. Fetch ticket first when `ticket_id` is known:
   - `ticket_id`: provided/resolved ID
   - `include_actions`: `true`
   - `slim`: `false`
   - `max_note_chars`: `8000`
   - `max_actions`: `0`
4. Display fetched ticket briefly:
   - `[#TICKET_ID] {summary} | Priority: {priority} | Client: {client_name}`
5. If ticket not found, restricted, or client/user conflicts with provided context, stop and say why.
6. Resolve eligible technicians:
   - Use explicitly provided technicians first.
   - Resolve names with `itastack_itastack_halo` operation `agents.list`.
   - If no eligible technicians supplied and ticket has assigned agent, ask whether to schedule with assigned agent or workload-balance.
   - If no assigned agent and no technician list, ask for technicians.
7. If duration missing, ask one concise question with options:
   - 30 minutes
   - 60 minutes
   - 90 minutes
8. If appointment type missing, ask one concise question with options:
   - Firm - Remote
   - Firm - Onsite
   - Tentative - Remote
   - Tentative - Onsite
9. Calculate workload for each eligible agent:
   - Use `itastack_itastack_halo` operation `tickets.list` with agent/name search where useful.
   - Count active assigned tickets by status.
   - Apply weights below.
   - Recommend lowest weighted load.
   - If tied, show both agents and let dispatcher choose.
10. Check availability:
    - Use `itastack_itastack_halo` operation `appointments.list` for each target agent.
    - Window: next 7 business days unless user gives timeframe.
    - Verify returned `agent_id` matches requested agent; server-side filter may be unreliable.
    - Ignore ticket activity entries where subject matches `^#\d+:`.
    - Convert UTC timestamps to `America/Los_Angeles`.
    - Business hours: 9:30 AM–5:30 PM Pacific.
    - Buffer: 15 minutes between appointments.
    - Weekends skipped.
    - Slot increment: 15 minutes.
11. Recommend first fitting slot:
    - `Next available: {agent_name} — {date} {start_time}-{end_time} PT`
12. If user asks to create/update/delete appointment or add a ticket note:
     - Summarize exact target, time, agent, and payload.
     - Ask for explicit approval before calling a write operation.
     - After write, verify with `itastack_itastack_halo` operation `appointments.list` or `actions.list` as appropriate.
     - If write capability fails or is unavailable, provide exact fallback details for manual HaloPSA entry.

## Workload Weights

| Status | Weight |
| --- | ---: |
| In Progress | 1.0 |
| New | 0.8 |
| Open | 0.8 |
| Scheduled | 0.6 |
| Pending | 0.6 |
| Waiting on User | 0.3 |
| Waiting on 3rd Party | 0.3 |

Formula:

- `weighted_load = sum(ticket_count[status] * weight[status])`

Unknown statuses:

- Treat as `0.8` only if active work.
- Exclude closed/cancelled/resolved tickets.

## Appointment Types

Use exact strings:

- `Firm - Remote`
- `Firm - Onsite`
- `Tentative - Remote`
- `Tentative - Onsite`

## Output

Use only needed sections. Keep each short. Max 5 bullets per section unless user asks for detail.

### Request understood

- Ticket/client/timeframe/techs/duration/type.
- Note missing identifiers if blocked.

### Evidence gathered

- Ticket context.
- Workload scores.
- Calendar conflicts / slot basis.
- Capability gaps, if any.

### Recommended action

- Recommended technician.
- Recommended slot.
- Reason in one bullet.

### Next step

- Ask one confirmation/choice question, or
- Ask for write approval, confirm completed write, or provide manual HaloPSA entry details if write is unavailable, or
- State exact missing input.

## Stop Conditions

- Ticket identity ambiguous.
- Client, tenant, user, or technician identity ambiguous.
- Ticket fetch returns restricted/CMMC/403/404.
- User requests a write but exact target/payload approval is missing.
- No safe recommendation can be made from available schedule data.

## Error Handling

- Ticket not found: stop and inform user.
- No availability: report no slots found in next 7 business days; suggest extending search.
- Both agents fully booked: show message; suggest manual scheduling or wider search.
- API/tool error: show concise error; do not retry automatically unless safe and user asks.
- Truncated ticket/actions: state limitation before relying on it.
