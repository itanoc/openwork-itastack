---
name: halo-queue
description: |
  Pull all open HaloPSA tickets assigned to the current technician, analyze each
  one's true next action, and produce a prioritized, easiest-first work queue
  grouped into Close-out, Client communication, Scheduling, and Research. Drill
  into specific tickets on request to draft the actual response, schedule, or
  resolution steps. Read-only by default; per-item approval before any Halo write.

  Triggers when user mentions:
  - "work my tickets"
  - "triage my queue"
  - "help with my tickets"
  - "what can I knock out"
  - "go through my Halo tickets"
metadata:
  route_default: daily
  route_max: high
  route_class: halo_queue
---

<<<ROUTE default=daily max=high class=halo_queue>>>

# Halo Queue

Use this skill to triage the calling technician's entire open HaloPSA queue and
produce a single ranked work plan ordered by how easy each ticket is to clear.
Status is a **signal**, not a router — read each ticket and reason about what it
actually needs, including catching stale/inconsistent states.

This is a standalone skill. It reuses analysis patterns from `halo-ticket-research`
for the deep-dive step but does not delegate to it.

## Goal

Answer: "Of all my open tickets, what can I knock out, in what order, and how?"
Group tickets by primary next action, sort easiest-first, surface the immediate
unblock for each, and only drill into full drafts/steps when asked.

## Inputs

- Technician identity: read from
  `/Users/james/Documents/openwork-itastack/memory/preferences/current-openwork-teammate.md`
  (use the Halo agent ID). If that file is missing or has no agent ID, ask once
  for the agent name/ID and stop.
- Optional free-text scope from chat (e.g. "just <client>", "only scheduling",
  "top 10 by SLA").

## Tools

- `itastack_itastack_halo` operation `tickets.list` — pull the queue.
- `itastack_itastack_halo` operation `get_ticket` — per-ticket detail (notes/actions).
- `itastack_itastack_halo` operation `lookups.list_statuses` — map `status_id` → name.
- `itastack_itastack_halo` operation `list_appointments` — detect Scheduled-without-appointment.
- `itastack_itastack_halo` operation `actions.list` — when action history is incomplete.
- `itastack_list_available_services` — discover other dispatchers when drilling in.
- For Research-bucket drill-ins, web research as defined in `halo-ticket-research`
  (background-safe `webfetch`; visible browser only with explicit user approval).

## Citation Rules

- No raw tool IDs, operation IDs, or bracket-number citations in output.
- Use tool results as plain-text evidence.
- Web sources: normal URLs only when useful.

## Workflow

### 1. Resolve technician

- Read the teammate preferences file and extract the Halo agent ID.
- If absent/ambiguous, ask one concise question and stop.

### 2. Pull the open queue

- `tickets.list` filtered to the agent, open/unresolved only.
- **Primary assignee only.** The `tickets.list` agent filter matches tickets
  where the technician is primary *or* secondary/additional assignee. After
  pulling, drop any ticket whose `agent_id` (the primary assignee) does not
  equal the technician's agent ID. Only the primary owner's tickets are worked.
- Exclude closed/resolved/invoiced statuses: Closed (9), Closed Order (13),
  Closed Item (15), Closed - Silent (40), Closed: No Response (44),
  Closing: No Response (45), Resolved (8), Invoiced (16).
- Cap at ~50 tickets. If the queue exceeds the cap, surface the cap and total
  count, and work the most SLA/age-critical first.
- `tickets.list` returns null `status_name`/`tickettype_name`; map IDs to names
  via `lookups.list_statuses` (cache once per run).

### 3. Per-ticket needs analysis

For each ticket, read enough to reason about its real next action. Use the slim
list payload first; fetch `get_ticket` (with notes) for anything non-obvious.
Derive **current state → why → next action(s)** from:

- `summary` / `details` / latest notes
- `status_id` (signal only — see inconsistency checks)
- last update / ticket age / SLA dates (`fixbydate`, `respondbydate`)
- appointments (`list_appointments` by `ticket_id`/agent) when scheduling-related

**Inconsistency / stale checks (high value — get these right):**

- **Scheduled (27) / Pending Appointment (42) but no appointment** → stale;
  primary action = scheduling, and flag that a technical look is also warranted.
- **Waiting on User (49/31) but the user already replied** (e.g. status implies
  hold yet a recent customer note exists / Customer Note Added 22) → primary
  action = client communication or technical follow-up.
- **Pending Closure (34) / Completed (35) / Wrap-up (47) with no new client
  activity** → close-out candidate.
- **Genuine waits** (Waiting on Vendor 32, Waiting for Vendor 5, Waiting
  Parts/Repair 30, Payment Pending 43, With CAB 10) with no actionable step →
  list under "Needs your eyes" with the wait reason, not force-bucketed.

### 4. Bucket each ticket (one primary bucket)

Place each ticket by its **easiest actionable step** (not its deepest need).
Secondary needs ride along as annotations.

1. **Close-out** — looks done; suggest closing.
2. **Client communication** — a reply is owed; draft one.
3. **Scheduling** — needs a time booked / appointment fixed.
4. **Research** — needs technical investigation + resolution steps.

Example: Scheduled-without-appointment → **Scheduling** bucket, annotated
"+ technical look".

Tickets that are pure genuine-wait or truly ambiguous → **Needs your eyes** footer.

### 5. Sort and present

- Order buckets: Close-out → Client communication → Scheduling → Research.
- Within each bucket, sort by SLA/age (most at-risk first).
- Output the chat roll-up (see Output Format). Do not write a file unless asked.
- Then offer to drill into specific ticket(s).

### 6. Drill-in (on request)

When the user names ticket(s) to work:

- **Close-out** → draft the closure note + the close action to take (no write).
- **Client communication** → draft the client-facing reply.
- **Scheduling** → propose time(s) / appointment payload; reconcile the status.
- **Research** → run the `halo-ticket-research` deep-dive workflow and produce
  the step-by-step technician guide.

## Write behavior

- Read-only by default. Produce drafts and proposed actions only.
- Never write to Halo (notes, status, appointments, closures) without explicit
  per-item approval. On approval, execute that single item, then confirm.
- Never paste client-identifying details into public web searches.

## Guardrails

- Read-only against Halo and all client systems unless the user approves a
  specific write.
- Always scope to the calling agent's tickets; never another agent's queue
  without explicit instruction.
- Use ticket end-customer `client_id`; never MSP/agent org ID.
- Treat empty/null tool results as context, not failure.
- If a ticket fetch is restricted/CMMC/403/404, skip it and note the condition.
- Never store secrets, tokens, or private logs in artifacts.

## Output Format

```md
## My queue — N open (easiest first)

### Close-out (k)
- #ID · Client · short-summary · state → next action [+secondary]

### Client communication (k)
- #ID · Client · short-summary · state → next action [+secondary]

### Scheduling (k)
- #ID · Client · short-summary · state → next action [+secondary]

### Research (k)
- #ID · Client · short-summary · state → next action [+secondary]

### Needs your eyes (k)
- #ID · Client · short-summary · why (genuine wait / ambiguous)

Drill into any ticket(s) and I'll draft the reply, schedule, closure, or steps.
```

## Examples

- "Triage my queue."
- "What can I knock out today?"
- "Go through my Halo tickets, easiest first."
- "Work my tickets, then draft the client replies for the comms bucket."
