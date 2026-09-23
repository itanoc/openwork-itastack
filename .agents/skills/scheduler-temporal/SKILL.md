---
name: scheduler-temporal
description: |
  Author and manage bounded watcher checks through ITAStack MCP tools for Halo tickets.

  Triggers when user mentions:
  - "create a watcher"
  - "watch this ticket"
  - "let me know when the agent comes back"
  - "list my watchers"
  - "cancel watcher"
metadata:
  route_default: daily
  route_max: daily
  route_class: scheduler
---

<<<ROUTE default=daily max=daily class=scheduler>>>

# Scheduler

Use this skill when a technician wants OpenWork to create, list, or cancel bounded watchers through ITAStack MCP tools.

## What a bounded watcher is

A bounded watcher is a technician-initiated, temporary check that:

- polls a vetted read-only condition on a fixed interval;
- runs for a bounded number of days;
- writes exactly one note to a named Halo ticket when the condition becomes true;
- then self-terminates;
- silently removes itself at the deadline if it never fires.

Watchers are owner-scoped. Each technician only sees and cancels their own watchers.

## Tools

- `itastack_watcher_list_probe_types`: discover available probe types and required `probe_params` schemas.
- `itastack_watcher_create`: create a bounded watcher. This is a WRITE action because it can later post a Halo ticket note.
- `itastack_watcher_list`: list the caller's running watchers.
- `itastack_watcher_cancel`: cancel the caller's watcher for one Halo ticket.

## Hard rules

- Always call `itastack_watcher_list_probe_types` first for create, list, and cancel requests. Show the technician valid probe types and required params in plain English.
- Never hard-code the probe catalog. Use live probe data from `itastack_watcher_list_probe_types`.
- Confirm before calling `itastack_watcher_create`, because watcher creation is a WRITE action.
- Confirmation must include:
  - `probe_type`
  - `ticket_id`
  - `interval_hours`
  - `days`
  - `fire_note`
  - `probe_params`
  - `reopen_status_id`, if provided
- Do not call `itastack_watcher_create` until the technician explicitly approves the exact watcher.
- Do not retry failed create/cancel calls blindly. Explain what to fix.

## Server-enforced constraints to surface clearly

- `interval_hours` must be one of `4`, `8`, `12`, or `24`.
- `days` must be from `1` through `30`.
- Only one watcher can exist per ticket.
- Each technician can have at most 10 running watchers.
- `probe_params` must match the selected probe's schema from `itastack_watcher_list_probe_types`.
- Known probes may change. Still call `itastack_watcher_list_probe_types` before using any probe.

## Live probe examples

These examples reflect the current watcher catalog, but the live catalog from `itastack_watcher_list_probe_types` is always the source of truth.

- `halo_ticket_status`
  - Fires when a Halo ticket reaches one of the target statuses.
  - Required params: `ticket_id` integer, `target_status_ids` integer array with at least one value.
- `m365_user_has_license`
  - Fires when a Microsoft 365 user in a tenant has a matching license SKU.
  - Required params: `tenant_code` string, `user` string, `sku_part_number` string.
- `pax8_subscription_status`
  - Fires when a Pax8 subscription is in one of the target statuses.
  - Required params: `subscription_id` string, `target_statuses` string array with at least one value.
- `threecx_extension_exists`
  - Fires when a 3CX extension matching a search term exists on a configured instance.
  - Required params: `instance` string, `search_term` string.
  - Current instance values from live schema: `mal`, `gsh`, `comp`, `ita`.
- `unifi_device_online`
  - Fires when a UniFi device has the target status.
  - Required params: `device_name` string.
  - Optional param: `status` string, default `online`.
- `vsa_agent_exists`
  - Fires when a VSA agent name matches.
  - Required param: `agent_name` string.

## Workflow: create watcher

1. Call `itastack_watcher_list_probe_types`.
2. Present available probe types and required params in plain text.
3. Parse the technician request into watcher fields:
   - `probe_type`
   - `ticket_id`
   - `interval_hours`
   - `days`
   - `fire_note`
   - `probe_params`
   - optional `reopen_status_id`
4. Validate obvious constraints before asking for confirmation:
   - interval is `4`, `8`, `12`, or `24` hours;
   - days is `1..30`;
   - required probe params are present;
   - ticket ID is known.
5. If anything is missing or invalid, ask one targeted question or explain the exact fix.
6. Confirm the full watcher in plain English before create.
7. After explicit approval, call `itastack_watcher_create`.
8. On success, echo back:
   - `workflow_id`
   - plain-English schedule, for example `polling every 8h for up to 14 days`
   - ticket that will receive the fire note
9. On failure, explain the likely fix:
   - duplicate ticket watcher: cancel existing watcher or choose another ticket;
   - cap exceeded: cancel one watcher first;
   - unknown probe: choose one from live probe list;
   - missing/invalid params: provide params matching schema;
   - invalid interval/days: choose allowed values.

## Workflow: list watchers

1. Call `itastack_watcher_list_probe_types` first and briefly show valid probe types.
2. Call `itastack_watcher_list`.
3. Present running watchers in plain text.
4. Do not expose raw tool IDs, operation IDs, bracket-number citations, or internal source markers.
5. If no watchers exist, say that plainly.

## Workflow: cancel watcher

1. Call `itastack_watcher_list_probe_types` first and briefly show valid probe types.
2. Get the Halo `ticket_id` to cancel.
3. If ticket ID is missing, ask one targeted question.
4. Confirm cancellation in plain English.
5. After explicit approval, call `itastack_watcher_cancel` with the ticket ID.
6. Present success or failure in plain text.
7. If not found, explain that the watcher may not exist or may belong to another technician.

## Workflow: quick test / reload check

Use this when the technician asks to test the scheduler skill or verify watcher tooling after restarting OpenWork.

1. Call `itastack_watcher_list_probe_types`.
2. Call `itastack_watcher_list`.
3. Report in plain text:
   - skill loaded;
   - visible probe names and required params;
   - current watcher count;
   - whether a dry-run create would require confirmation before any WRITE.
4. Do not call `itastack_watcher_create` during a quick test unless the technician explicitly asks to create a real watcher and approves the full confirmation.
5. Treat an empty watcher list as success, not failure.

## Citation and output rules

- Do not include raw tool IDs, operation IDs, bracket-number citations, or internal source markers.
- Use tool results as evidence, but write user-facing output in plain text.
- Keep output short and technician-facing.
- Never expose secrets or credentials in `fire_note` or outputs.

## Example: create watcher

Technician: Watch ticket 4821 and tell me if agent fs01 comes back online, check every 8h for 2 weeks.

Assistant:

1. Calls `itastack_watcher_list_probe_types`.
2. Sees live probe `vsa_agent_exists`, requiring `agent_name`.
3. Asks for confirmation:

Create watcher?

- Probe: `vsa_agent_exists`
- Ticket: `4821`
- Schedule: polling every 8h for up to 14 days
- Fire note: `Watcher fired: VSA agent fs01 exists again. Please verify agent health and continue remediation.`
- Params: `agent_name=fs01`

Technician: Yes, create it.

Assistant calls:

- `itastack_watcher_create` with `probe_type="vsa_agent_exists"`, `ticket_id=4821`, `interval_hours=8`, `days=14`, `fire_note="Watcher fired: VSA agent fs01 exists again. Please verify agent health and continue remediation."`, `probe_params={"agent_name":"fs01"}`.

Assistant response:

- Watcher created.
- Workflow: `<workflow_id from tool>`
- Schedule: polling every 8h for up to 14 days.
- Fire note will post to Halo ticket 4821 when the probe fires.

## Example: list and cancel watcher

Technician: Show my watchers.

Assistant:

1. Calls `itastack_watcher_list_probe_types`.
2. Calls `itastack_watcher_list`.
3. Presents results in plain text, for example:

- Ticket 4821: watching `vsa_agent_exists` for `agent_name=fs01`, polling every 8h until deadline.

Technician: Stop watching 4821.

Assistant:

1. Calls `itastack_watcher_list_probe_types`.
2. Confirms: `Cancel your watcher for Halo ticket 4821?`
3. After approval, calls `itastack_watcher_cancel` with `ticket_id=4821`.
4. Responds: `Watcher for ticket 4821 cancelled.`

## Quick defaults

- If technician says `every 2 weeks`, interpret as duration only when interval is also stated. Watcher intervals are hours; valid values are 4, 8, 12, and 24.
- If technician asks to reopen the ticket on fire but does not provide a status ID, ask for `reopen_status_id` or create without reopening.
- If fire note is not provided, propose a concise internal note and confirm it before create.
- If testing after restart, run the quick test workflow and avoid any WRITE action.
