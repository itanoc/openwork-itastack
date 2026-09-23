---
name: halo-triage
description: |
  Batch-close bulk notification tickets from the Triage view. Pulls the Triage
  queue, groups tickets by dynamically normalized summary (strips IPs, FQDNs,
  UUIDs), and offers to close groups of 3+ similar tickets.

  Triggers when user mentions:
  - "triage the queue"
  - "batch close"
  - "bulk close notifications"
  - "close the 3CX alerts"
  - "clean up triage"
metadata:
  route_default: daily
  route_max: medium
  route_class: halo_triage
---

<<<ROUTE default=daily max=medium class=halo_triage>>>

# Halo Triage — Batch Close Bulk Notifications

## Goal

Pull all tickets from the **Triage view** (list ID 23), detect groups of 3+
tickets with similar summaries, present findings to the user, and batch-close
confirmed groups.

## How it works

1. Fetch tickets from the Triage view using the Halo API in small pages (count=50).
2. Filter out already-closed tickets (`hasbeenclosed: true`) immediately — only
   open tickets are candidates for grouping.
3. Filter out tickets with **client replies** (any action with `type=1` or
   incoming email from a non-alert sender) — these need human review, not batch close.
4. Normalize each summary by stripping variable fragments (IPs, FQDNs, UUIDs,
   hostnames, timestamps) so tickets like "3CX Alert: IP X on PBX Y" and
   "3CX Alert: IP Z on PBX W" collapse into one group.
5. Group tickets by their normalized summary.
6. Flag groups with 3+ tickets for batch closure. Groups with fewer than 3
   tickets are skipped — they're not bulk.
7. Show the user: normalized group summary, ticket count, and one real example.
8. Ask yes/no per group before closing.
9. Close confirmed tickets (set status_id=9) and advance the workflow step to
   its terminal sequence. Post a private batch note on each.

## Implementation

### Step 1 — Fetch Triage tickets

Use the raw Halo API to pull tickets from view list 23 in small pages to
avoid response overflow:

```
itastack_itastack_halo get path=/tickets view_id=23 count=50 page_no=1
```

Paginate through pages until a page returns fewer than `count` results:

```
itastack_itastack_halo get path=/tickets view_id=23 count=50 page_no=2
itastack_itastack_halo get path=/tickets view_id=23 count=50 page_no=3
```

Each response is a dict with a `"tickets"` array and `"record_count"` total.
Collect all ticket objects across pages into a single list.

If any individual page still overflows the output limit, reduce `count` to 20
and resume from the same `page_no`. Keep reducing until the page fits.

### Step 1a — Filter safe candidates

Before normalizing or grouping, filter the collected tickets:

1. **Remove closed tickets**: skip `hasbeenclosed: true`.
2. **Remove tickets with client communication**: check each ticket's
   `reported_by` — skip if the reported-by email does not look like an
   internal/system sender (e.g. `emailalerts@`, `noreply@`, or empty/null).
   If a ticket has a real client name in `user_name` that isn't a generic
   "General User" or "Client Alerts", flag it for human review instead.
3. **Remove assigned tickets**: skip tickets with an `agent_id` that is not
   the generic triage/unassigned agent (1 = unassigned/triage).

A ticket is safe for batch-close only if it is:
- Auto-generated (alert source)
- No client communication (reported-by is system)
- Unassigned or assigned to triage agent (agent_id 1)
- Not already closed

### Step 2 — Normalize summaries

Apply dynamic normalization to each summary string before grouping:

1. Strip IPv4 addresses: `\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}`
2. Strip FQDNs/hostnames: sequences of word chars separated by dots, containing
   at least one dot (e.g. `coavacoffee.my3cx.us`, `HLWD-MM-Server..hlwd`)
3. Strip UUIDs: `[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}`
4. Strip timestamps/dates: common date and time patterns
5. Collapse multiple spaces to single space
6. Trim whitespace

The result is a "normalized summary key" for grouping.

### Step 3 — Group and filter

- Group tickets by normalized summary key
- Filter to groups with **3+ tickets** (only count safe, open, filtered tickets)
- Sort groups by ticket count descending (biggest groups first)

### Step 4 — Present to user

For each qualifying group, report:

```
Found 6 tickets matching: "3CX Alert: IP ... has been blacklisted on PBX ..."
Example: "3CX Alert: IP 172.86.119.222 has been blacklisted on PBX coavacoffee.my3cx.us"
Close these 6 tickets? (yes/no)
```

Ask one group at a time. If the user says no, skip that group without asking
about the rest — offer to continue to the next group.

### Step 5 — Close tickets

For each confirmed group, close each ticket:

1. **Set status to closed** — advance the workflow step to its terminal
   sequence (`workflow_seq` of the current `workflow_step`). On the 3CX Alert
   tickets, terminal was `workflow_seq: 2` in `workflow_step: 6`:
   ```
   itastack_itastack_halo tickets.update ticket_id=<id> payload={"status_id": 9}
   ```

2. **Post a private internal note** noting the batch closure:
   ```
   itastack_itastack_halo actions.create payload=[{"ticket_id": <id>, "note": "Bulk closed via auto-triage - notification ticket", "type": 4, "private": true, "note_html": ""}]
   ```

3. **If the close fails for any ticket**, log the error and continue with the
   next ticket. Report failed tickets in the final summary.

## Notes

- **Read-only until confirmed per group.** Do not close anything without user approval.
- The Triage view (ID 23) is hardcoded as the source — this skill always operates on it.
- The 3-ticket threshold is the default; you can suggest a different threshold if the user asks.
- After closing, summarize what was closed and what was skipped (skipped = groups
  below threshold, tickets with client replies, already-closed tickets).
- **Not safe for tickets with client communication.** If a notification ticket
  has a client reply or a real end-user name, the skill flags it for human
  review instead of offering it for batch-close.
- If pagination fails on a page, report the error and continue with the data
  collected so far rather than abandoning the whole batch.