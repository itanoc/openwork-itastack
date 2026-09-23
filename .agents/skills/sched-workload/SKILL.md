---
name: sched-workload
description: |
  Workload-balanced HaloPSA appointment scheduling in OpenWork. Use when scheduling appointments, finding available times, or balancing technician workload from Halo tickets and appointments.
metadata:
  route_default: medium
  route_max: high
  route_class: sched_workload
---

<<<ROUTE default=medium max=high class=sched_workload>>>

# Sched Workload

Be extremely concise. Sacrifice grammar for concision in chat output.

Use this skill to analyze scheduled work and workload from HaloPSA tickets and appointments, recommend who should take work, and identify next available appointment slots.

OpenWork version of older Open WebUI prompt. Tool names are OpenWork ITAStack function names, not Open WebUI operation IDs.

## Inputs

- `ticket_id`: Halo ticket ID.
- `client_name`: Client or organization name.
- `user_email`: User email address.
- Technician names or Halo agent IDs from chat.
- Duration, date/time preference, or timeframe from chat. (Appointment type is fixed to Tentative - Remote — never an input.)
- Any free-text scheduling context.

## Triage List

- The triage queue is Halo list `selid=23`. Pull it with `itastack_itastack_halo` operation `tickets.list` using param `list_id=23`.

## When to use Batch Mode

- Triggers Batch Mode (see below), not the single-ticket workflow, when the user:
  - asks to pull/work the triage list ("work the triage list", "triage batch"), or
  - lists multiple ticket IDs to schedule (e.g. "schedule #68311, 68299, 68298").
- A single ticket ID (or one client/keyword) uses the single-ticket Workflow.

## OpenWork Tools

Read tools:

- `itastack_itastack_halo` operation `get_ticket`
- `itastack_itastack_halo` operation `tickets.list` (use `list_id=23` for the triage list)
- `itastack_itastack_halo` operation `actions.list`
- `itastack_itastack_halo` operation `list_appointments` (slim; pass bounded `agent_id` + `start_date`/`end_date` — the broad `appointments.list` scan times out)
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
8. Appointment type is always `Tentative - Remote` (`appointment_type: 6`). Do not ask; do not use other types.
9. Calculate workload for each eligible agent:
   - Use `itastack_itastack_halo` operation `tickets.list` with agent/name search where useful.
   - Count active assigned tickets by status.
   - Apply weights below.
   - Recommend lowest weighted load.
   - If tied, show both agents and let dispatcher choose.
10. Check availability:
    - Use `itastack_itastack_halo` operation `list_appointments` for each target agent, passing `agent_id` + bounded `start_date`/`end_date` (the broad `appointments.list` scan times out).
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
      - Create appointments with `appointments.create` using the verified shape in Appointment Create Payload (type always `Tentative - Remote` / `6`).
      - Conflict handling: if create returns `CODE:EVE01` (clash), step to the next 15-min slot and retry; do NOT auto-`_force`. Only add `"_force": true` on explicit dispatcher request.
      - After write, verify with `itastack_itastack_halo` operation `list_appointments` or `actions.list` as appropriate.
      - If write capability fails or is unavailable, provide exact fallback details for manual HaloPSA entry.

## Batch Mode

Use when the user wants to auto-assign + schedule multiple tickets at once. Two ticket sources:

- Triage list: user asks to pull/work the triage list (`selid=23`).
- Explicit IDs: user lists ticket IDs (e.g. "schedule #68311, 68299, 68298").

Goal: every ticket in the batch ends up assigned AND scheduled, balanced between the two eligible agents. Do NOT skip RMM/automated tickets — they get scheduled too in v1.

Eligible agent pool (v1, fixed):

- Emilio Villa — `agent_id=70`
- Riely Borek — `agent_id=25`

Follow in order.

1. Confirm the agent pool: Emilio (70) and Riely (25). Only deviate if the user explicitly names a different pool this run.
2. Appointment type is always `Tentative - Remote` (`appointment_type: 6`); never ask. Ask once for duration (30 / 60 / 90 minutes) unless the user already gave it.
3. Build the batch ticket set from the source:
   - Triage list: `tickets.list` with `list_id=23` and `count=100`. If the result hits `count`, page with `page_no` until exhausted and tell the user the total. If empty, report "Triage list empty" and stop.
   - Explicit IDs: use the IDs the user gave. Fetch each with `get_ticket` (`slim: true`) to resolve summary/client/status. If any ID is not found, restricted, or already closed/cancelled/resolved, list it as skipped with the reason and continue with the rest. If none are valid, stop and say so.
   - Either way, exclude closed/cancelled/resolved tickets.
4. Seed each eligible agent's running load once (see Workload Weights). Optional for v1 — if workload read is slow, start both at 0 and rely on round-robin.
5. For each batch ticket, in order:
   - Assign to the lower running-load agent; on tie, alternate (round-robin) so the batch splits evenly between Emilio and Riely.
   - Increment that agent's running load by the chosen duration so the next ticket balances against it.
   - Pick the first candidate slot for that agent. Use `list_appointments` with `agent_id`, `start_date`, `end_date` (bounded 7-day window, Pacific) and the availability rules in the single-ticket workflow (business hours 9:30–17:30, 15-min buffer, weekends skipped, 15-min increments). Avoid slots already planned earlier in this same batch for that agent.
   - Calendar-read fallback: if `list_appointments` errors or times out, retry once with a tighter window; if still failing, mark the slot `TBD (calendar unavailable)` and note it in the plan.
6. Present the full plan as one table, one row per ticket, before any write:
   - `[#TICKET_ID] {summary} | {client} | -> {agent_name} | {date} {start}-{end} PT | {type} {duration}`
   - Show the per-agent count/load split at the bottom so the dispatcher can see balance.
   - Flag any row with a TBD slot or unresolved client/site, but keep it in the plan.
7. Ask for ONE batch approval covering all rows. Do not write before approval.
8. On approval, execute per ticket in order with `appointments.create` (see Appointment Create Payload). Creating the appointment assigns the agent AND moves the ticket out of its current queue on its own — do NOT call `dispatch_ticket` for scheduled tickets.
   - Verify-first: do the first `appointments.create`, confirm it via `list_appointments`, then proceed with the rest. If the first create fails for a payload reason, stop, report the error, and do not continue.
   - Conflict handling (do NOT auto-`_force`): if create returns `CODE:EVE01` (clash), step to the next 15-min slot in the window and retry. If no clean slot is found in the window, mark the row TBD and leave it for manual scheduling.
   - For TBD rows (no slot / calendar unavailable): leave them unscheduled and list them for manual handling. If the dispatcher explicitly wants one double-booked, re-run that single row with `"_force": true`.
   - If any single ticket fails, record the error, continue with the rest, report failures at the end.
9. After execution, verify with `list_appointments` and report a concise summary: scheduled, TBD/unscheduled, failed (with reason). Provide manual HaloPSA entry details for any TBD/failed rows.

## Appointment Create Payload

Verified shape for `appointments.create` (param key `payload`):

```json
{
  "subject": "Short work summary",
  "start_date": "2026-06-24T16:30:00Z",
  "end_date": "2026-06-24T17:00:00Z",
  "agent_id": 70,
  "ticket_id": 68311,
  "appointment_type": 6,
  "online": 1,
  "all_day": false
}
```

- `start_date`/`end_date`: ISO 8601 UTC (`Z`). Convert Pacific slot times to UTC.
- Halo checks conflicts server-side and rejects clashes with `CODE:EVE01`, listing the conflicting appointments. Add `"_force": true` to override (use only on explicit dispatcher request).
- Creating an appointment reassigns the ticket's agent and advances it out of its current queue; no separate dispatch call needed.

`appointment_type`: always `6` (`Tentative - Remote`). This skill never sets any other type.

Full mapping for reference (lookup group 63): Reminder 0, Firm - Remote 4, Firm - Onsite 5, Tentative - Remote 6, Tentative - Onsite 7.

## Workload Weights

Weights reflect how much active attention a ticket demands. Statuses are this Halo's actual statuses (`status_id` in parentheses).

| Status (id) | Weight |
| --- | ---: |
| Working Issue Now (29) | 1.0 |
| Action Required (3) | 1.0 |
| Quick Fix (26) | 0.8 |
| Pre-Process (24) | 0.8 |
| New (39) | 0.8 |
| New (email) (1) | 0.8 |
| New (portal) (37) | 0.8 |
| New (Whoops) (38) | 0.8 |
| Re-Opened (23) | 0.8 |
| Customer Note Added (22) | 0.8 |
| Update Required (33) | 0.8 |
| Scheduling Required (25) | 0.6 |
| Scheduled (27) | 0.6 |
| Pending Appointment (42) | 0.6 |
| Scope (46) | 0.6 |
| Wrap-up (47) | 0.6 |
| Pending Closure (34) | 0.4 |
| Pending Acknowledgement (41) | 0.4 |
| Payment Pending (43) | 0.3 |
| Ticket Waiting (2) | 0.3 |
| Waiting on User (49) | 0.3 |
| Waiting on User (Autoclose) (31) | 0.3 |
| Awaiting Client Confirmation (48) | 0.3 |
| Waiting Parts/Repair (30) | 0.3 |
| Waiting on Vendor (32) | 0.3 |
| Waiting for Vendor (5) | 0.3 |

Formula:

- `weighted_load = sum(ticket_count[status] * weight[status])`

Excluded (closed/terminal — never count toward load):

- Closed (9), Closed - Silent (40), Closed: No Response (44), Closing: No Response (45), Resolved (8), Completed (35), Invoiced (16), Closed Order (13), Closed Item (15).

Unknown statuses:

- Treat as `0.8` only if active work; exclude if clearly closed/cancelled/resolved.

## Appointment Type

Always `Tentative - Remote` (`appointment_type: 6`). This skill sets no other type; never ask the user to choose.

## Output

Use only needed sections. Keep each short. Max 5 bullets per section unless user asks for detail.

### Request understood

- Ticket/client/timeframe/techs/duration.
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
- Batch plan not approved: present the plan and stop before any `appointments.create`.
- First `appointments.create` in a batch fails for a payload reason: stop, report the error, do not continue.

## Error Handling

- Ticket not found: stop and inform user.
- No availability: report no slots found in next 7 business days; suggest extending search.
- Both agents fully booked: show message; suggest manual scheduling or wider search.
- API/tool error: show concise error; do not retry automatically unless safe and user asks.
- Truncated ticket/actions: state limitation before relying on it.
