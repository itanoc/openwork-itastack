---
name: halo-calendar
description: |
  Batch HaloPSA calendar operations in OpenWork — schedule, reschedule, and remove appointments for multiple tickets at once. Schedules each ticket against its already-assigned agent (does NOT workload-balance). Use when batch scheduling tickets to their existing owners, bulk-removing appointments, or working a list/queue of pre-assigned tickets onto agents' calendars.
metadata:
  route_default: daily
  route_max: medium
  route_class: halo_calendar
---

<<<ROUTE default=daily max=medium class=halo_calendar>>>

# Halo Calendar

Be extremely concise. Sacrifice grammar for concision in chat output.

Use this skill for batch HaloPSA calendar work: schedule, reschedule, or remove appointments for many tickets in one pass. The defining behavior: **each ticket is scheduled onto the calendar of the agent it is already assigned to** (`agent_id` on the ticket). This skill does NOT pick or balance technicians — assignment is an input, not an output.

Tool names are OpenWork ITAStack function names.

## When to use this skill vs sched-workload

- Use `halo-calendar` when tickets are already assigned and you want them scheduled onto the owner's calendar, or for bulk schedule/reschedule/remove operations.
- Use `sched-workload` when you need to DECIDE who should take work (workload balancing, recommending a technician, finding the least-loaded agent).

## Inputs

- Ticket IDs (one or many), a Halo list/`list_id`, a client/keyword search, or free-text describing the batch.
- Duration, date/time preference, or timeframe from chat. (Appointment type is fixed to Tentative - Remote — never an input.)
- Optional: an explicit agent override only if the user wants to reassign before scheduling (see Reassignment).
- Operation intent: schedule (default), reschedule, or remove.

## OpenWork Tools

Read tools:

- `itastack_itastack_halo` operation `get_ticket`
- `itastack_itastack_halo` operation `tickets.list` (use `list_id=<id>` for a saved Halo list; triage queue is `list_id=23`)
- `itastack_itastack_halo` operation `actions.list`
- `itastack_itastack_halo` operation `list_appointments` (slim; pass bounded `agent_id` + `start_date`/`end_date` — the broad `appointments.list` scan times out)
- `itastack_itastack_halo` operation `agents.list`
- `itastack_itastack_halo` operation `lookups.list_statuses`
- `itastack_itastack_halo` operation `clients.get`
- `itastack_itastack_halo` operation `users.get`

Write tools:

- `itastack_itastack_halo` operation `appointments.create`
- `itastack_itastack_halo` operation `appointments.update`
- `itastack_itastack_halo` operation `appointments.delete`
- Use write tools only after the user approves the exact plan (targets, times, agents, payload summary, and any note text).

Extension fallback:

- If a needed capability is missing, inspect `openwork_extension_list_actions` before saying unavailable.
- Do not use browser tools for OpenWork app control.

## Core principle: schedule by assignment

For every ticket in the batch, the scheduling agent is the ticket's current `agent_id`. Steps:

1. Fetch the ticket and read `agent_id` / `agent_name`.
2. If `agent_id` is unassigned, `0`, `1`, or a generic/system/dispatch agent, the ticket has no real owner — flag it and STOP scheduling that row (list it for manual assignment). Do NOT guess or balance.
3. Resolve each distinct `agent_id` to a name once via `agents.list` for display.
4. Pull each owning agent's calendar (bounded window) and place the appointment on it.

## Batch Schedule Workflow

Follow in order.

1. Determine operation intent (schedule / reschedule / remove). Default is schedule.
2. Confirm appointment duration once (30 / 60 / 90 minutes) unless the user already gave it. Appointment type is always `Tentative - Remote` (`appointment_type: 6`); never ask.
3. Build the batch ticket set from the source:
   - Explicit IDs: use the IDs given. Fetch each with `get_ticket` (`slim: true`).
   - Halo list: `tickets.list` with `list_id=<id>` and `count=100`. If the result hits `count`, page with `page_no` until exhausted; report the total. If empty, say so and stop.
   - Client/keyword: `tickets.list` with the search once.
   - Exclude closed/cancelled/resolved tickets (see Excluded statuses). List any skipped ID with its reason and continue with the rest. If none are valid, stop and say so.
4. For each ticket, resolve the owning agent from `agent_id` (see Core principle). Group tickets by owning agent.
5. Per owning agent, pull the calendar once with `list_appointments` (`agent_id`, bounded `start_date`/`end_date`, 7-day window unless the user gives a timeframe). Verify the returned `agent_id` matches; the server-side filter can be unreliable.
6. Compute slots per ticket using the Availability rules. Place each ticket in the owner's first fitting slot, avoiding slots already planned earlier in this same batch for that agent.
   - Calendar-read fallback: if `list_appointments` errors/times out, retry once with a tighter window; if still failing, mark the row `TBD (calendar unavailable)` and keep it in the plan.
7. Present the full plan as one table, one row per ticket, BEFORE any write:
   - `[#TICKET_ID] {summary} | {client} | owner: {agent_name} | {date} {start}-{end} PT | Tentative-Remote {duration}`
   - Show a per-agent count at the bottom so the dispatcher sees the spread (informational only — this skill does not rebalance).
   - Flag rows that are unassigned/TBD/unresolved, but keep them listed.
8. Ask for ONE batch approval covering all rows. Do not write before approval.
9. On approval, execute per ticket in order with `appointments.create` (see Appointment Create Payload). Creating the appointment also advances the ticket out of its current queue on its own — do NOT separately dispatch.
   - Verify-first: do the first `appointments.create`, confirm it via `list_appointments`, then continue. If the first create fails for a payload reason, stop, report the error, do not continue.
   - Conflict handling (do NOT auto-`_force`): if create returns `CODE:EVE01` (clash), step to the next 15-min slot in the window and retry. If no clean slot is found, mark the row TBD for manual handling. Only add `"_force": true` on explicit dispatcher request.
   - If any single ticket fails, record the error, continue with the rest, report failures at the end.
10. After execution, re-pull `list_appointments` for each touched agent and confirm each new appointment id is present. Report a concise summary: scheduled, TBD/unscheduled, failed (with reason). Provide manual entry details for any TBD/failed rows.

## Batch Reschedule Workflow

1. Identify the target appointments (by ticket IDs, agent + window, or a prior batch).
2. Read current appointments via `list_appointments` for each owning agent; map appointment id -> ticket -> agent.
3. Compute new slots on the SAME owning agent's calendar using Availability rules (unless the user explicitly reassigns — see Reassignment).
4. Present a before/after plan table; ask for one batch approval.
5. On approval, `appointments.update` each (keep `agent_id` = owner unless reassigning). Same EVE01 conflict handling as scheduling.
6. Verify with `list_appointments`; report results.

## Batch Remove Workflow

1. Collect the appointment ids to delete. If only ticket ids are known, resolve appointment ids first via `list_appointments` (bounded by owning agent + window) and match on `ticket_id`.
2. Present the exact list (appointment id, ticket, agent, time) and ask for one batch approval.
3. On approval, call `appointments.delete` per id.
   - The delete response may echo the deleted record rather than a clean confirmation, and a second delete of the same id returns `Record not found`. Do NOT trust the raw response alone.
   - Verify by re-pulling `list_appointments` for each affected agent/window and confirming none of the target ids remain.
4. Report which ids are gone vs still present.

## Reassignment (optional, explicit only)

This skill schedules by existing assignment. Only change a ticket's agent if the user explicitly asks to reassign as part of the batch. When reassigning:

- Confirm the new `agent_id` for the affected tickets in the plan table (`owner: {old} -> {new}`).
- Creating/updating the appointment with the new `agent_id` reassigns the ticket.
- Never silently reassign because a calendar looks full — mark TBD and surface it instead.

## Availability rules

- Window: next 7 business days unless the user gives a timeframe.
- Business hours: 9:30 AM–5:30 PM Pacific.
- Convert UTC timestamps to `America/Los_Angeles`; convert Pacific slot times back to UTC for payloads.
- Ignore calendar entries whose subject matches `^#\d+:` (ticket-activity entries, not real blocks).
- Buffer: 15 minutes between appointments.
- Slot increment: 15 minutes.
- Weekends skipped.

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

- `agent_id`: the ticket's existing owner (or the explicitly-confirmed reassignment target).
- `start_date`/`end_date`: ISO 8601 UTC (`Z`). Convert Pacific slot times to UTC.
- Halo checks conflicts server-side and rejects clashes with `CODE:EVE01`, listing the conflicting appointments. Add `"_force": true` to override (only on explicit dispatcher request).
- Creating an appointment advances the ticket out of its current queue; no separate dispatch call needed.

`appointment_type`: always `6` (`Tentative - Remote`). This skill never sets any other type. Full mapping (lookup group 63): Reminder 0, Firm - Remote 4, Firm - Onsite 5, Tentative - Remote 6, Tentative - Onsite 7.

## Triage List

The triage queue is Halo list `list_id=23` for `tickets.list`.

## Excluded statuses (never schedule)

Closed (9), Closed - Silent (40), Closed: No Response (44), Closing: No Response (45), Resolved (8), Completed (35), Invoiced (16), Closed Order (13), Closed Item (15). Exclude these from the batch and report them as skipped.

## Output

Use only needed sections. Keep each short.

### Plan
- One row per ticket: `[#TICKET_ID] {summary} | {client} | owner: {agent_name} | {date} {start}-{end} PT | Tentative-Remote {duration}`.
- Per-agent count at the bottom (informational).
- Flag unassigned / TBD / unresolved rows.

### Next step
- Ask for one batch approval, OR
- Confirm completed writes with verification, OR
- State exact missing input / list TBD rows with manual entry details.

## Stop Conditions

- Ticket identity ambiguous, restricted, CMMC/403/404.
- A ticket has no real owner (unassigned/system/dispatch agent) — flag and skip that row.
- User requests a write but the exact plan/payload is not approved.
- Plan not approved: present the plan and stop before any write.
- First `appointments.create` in a batch fails for a payload reason: stop, report, do not continue.

## Error Handling

- Ticket not found: list as skipped, continue.
- No availability for an owner in the window: mark TBD, suggest extending the window or rescheduling that owner's other work.
- API/tool error: show concise error; do not auto-retry unless safe.
- Truncated calendar/ticket data: state the limitation before relying on it; delegate large tool-output files to an explore agent for parsing rather than reading them whole.
