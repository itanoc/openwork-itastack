---
name: project-progress-audit
description: Audit an ITA HaloPSA project against its sold scope: pull the project ticket by number, place it in ITA's project lifecycle, verify every step up to the current stage was actually done, and surface gaps and unstated risks. Optionally cross-check the sold scope when the driver attaches or pastes it. Triggers when the user mentions "audit project progress", "where is this project", "check project against scope", or "project gap check".
---

# project-progress-audit

Audit an in-progress ITA MSP project: given a HaloPSA project ticket number (and optionally the sold Sales Scope xlsx, attached or pasted by the driver), determine where the project stands, confirm the work up to this point was actually done across the parent and all child tickets, surface gaps and unstated risks, and orient the driver on the next actions.

## Inputs

- **Required:** a HaloPSA ticket number for the project. It may be the parent Project or one of its child tasks — Step 0 resolves to the parent.
- **Optional but recommended:** the sold Sales Scope (SharePoint xlsx) attached or pasted by the driver — SharePoint links are not fetchable from here. Without it, the audit still runs but at reduced confidence.

## Permissions & tools

- HaloPSA read-only via `itastack_halo`: `get_ticket`, `actions.list`, `relationships.list_children`, `lookups.list_statuses`, `lookups.list_ticket_types`.
- **Never call `get_ticket` with `include_actions: true` on a Project-type ticket.** Project tickets carry the full tickettype field-schema, so the payload balloons past the token limit and dumps to an overflow file that is not reachable from the bash sandbox. Instead: pull the core ticket with `slim: true, include_actions: false`, then fetch history separately via `actions.list` (use `slim: true` and a `count`/`max_actions` cap). Do the same for children.
- On any overflow, re-query narrower (smaller `count`, `slim`) rather than trying to read the dumped temp file — it is single-line JSON on an unreachable host path and defeats Read/Grep.
- `relationships.list_children` returns `status_name` and `actions` as null — resolve `status_id` against `lookups.list_statuses`, and pull each child's actions with `actions.list`. Cap the number of children fetched and summarize if there are many.
- The sold scope xlsx lives in SharePoint and is **not** fetchable by URL from here (long share links exceed fetch limits and require SharePoint auth). Ask the driver to attach or download the xlsx, or paste its contents. Do not attempt to fetch a SharePoint URL and do not guess the scope's contents.
- This skill only reads; it makes no changes to Halo. Any change (ticket note, email, schedule) happens only in Step 6 after the driver picks an action and confirms it.

## What to do

Run the steps in order. Each step feeds the next; carry the prior step's output forward. The `agents/*.md` persona files referenced below live in this skill's own folder (`.agents/skills/project-progress-audit/agents/`); adopt each inline for its step — they are not registered subagents.

### Step 0 — Resolve to the parent Project

Read `agents/project-shepherd.md` and take on that persona for this step. Pull the given ticket (`slim: true, include_actions: false`) and inspect `tickettype_id` and `parent_id`/`main_project_id`. If it is a Project (type 5), it is the parent. If it is a Project Task (type 20) or has a `parent_id` pointing elsewhere, walk up to that parent Project and audit **that** — do not enumerate children of a task (a task has none). State the resolved parent id + summary to the driver before continuing.

Complete when: the parent Project id is identified (and confirmed to the driver if the input was a task), so the rest of the audit runs against the parent.

### Step 1 — Pull the project record

Read `agents/project-shepherd.md` and take on that persona for this step. Pull the parent Project core with `slim: true, include_actions: false`, then fetch its actions via `actions.list` (slim, capped). Enumerate **every child ticket** via `relationships.list_children`, then for each child resolve its `status_id` to a name via `lookups.list_statuses` and fetch its actions via `actions.list`. Capture parent type, status, team, and key dates.

Complete when: every child ticket is listed with id, summary, resolved status name, assignee, and its actual action history, and the parent metadata is captured — nothing left unread.

### Step 2 — Place it in the lifecycle

Read `agents/project-shepherd.md` and take on that persona for this step. Infer the current ITA lifecycle stage primarily from the **child tickets** — their phase-named summaries (e.g. Scope, procure/verify payment, migration/execution, porting/SMS, Wrap-up) and their resolved statuses (Closed/Completed = phase done; New/Scheduled/in-progress = phase active or pending). Do **not** rely on the parent ticket's status, which is often a generic value (e.g. New) that does not reflect the stage. Name the single current stage, cite the child tickets that prove it, then state the one expected next step. Also classify the project as **scope-phase** (still being scoped — the Sales Scope is the deliverable, no sold scope exists yet) or **post-scope** (scope is signed and is now the contract to check work against); Steps 3–4 branch on this.

Complete when: the current stage is named with the specific child tickets (id + status) that justify it, the project is classified scope-phase vs post-scope, and the single expected next step is stated.

### Step 3 — Load & parse the sold scope

Read `agents/project-shepherd.md` and take on that persona for this step.

If the project is **scope-phase** (from Step 2), there is no sold scope to check against — the scope is the deliverable. Skip scope-parsing and instead note that Step 4 assesses scope-building progress (is the scope being produced?), not delivery against a contract. Record "scope-phase — no sold scope yet."

If the project is **post-scope**, the scope xlsx is not fetchable by URL from here — ask the driver to attach or download the xlsx (or paste its contents), then turn it into a checkable list of scoped deliverables / tasklist items (functionality table, tasklist, checklists). Cross-check the scope source the driver provides against the project folder link recorded in the initiation typeform (in the parent ticket actions); flag any mismatch (wrong client code, different folder, e.g. OPEN vs OSIG) rather than assuming they are the same project. If the driver provides no scope, record that explicitly and continue at reduced confidence.

Complete when: post-scope → every scope line is a checkable row (or "no scope provided — reduced confidence" recorded) and any provided-vs-recorded folder mismatch is flagged; scope-phase → "scope-phase — no sold scope yet" is recorded.

### Step 4 — Reconcile completed work

Read `agents/evidence-collector.md` and take on that persona for this step. Enumerate every expected step up to the current stage and reconcile each against the evidence across the parent and every child ticket. For a **post-scope** project, the expected items are ITA process steps **plus** the sold-scope deliverables from Step 3. For a **scope-phase** project, the expected items are the scoping process steps (scope requested, tech assigned, prework/tasklist built, handoff meeting, billable agreement) — i.e. is the scope itself being produced. Mark each done / not-done / unclear with the specific evidence cited (ticket #, action, date) or "no evidence found."

Complete when: every expected item has a status and a cited evidence pointer, across parent and all children — nothing left blank.

### Step 5 — Find gaps & read between the lines

Read `agents/workflow-architect.md` and take on that persona for this step. From the reconciliation, the parsed scope, and the lifecycle position, surface a prioritized gap list: skipped or implicit handoffs, missing/orphaned child tasks, scope drift, stale or unverified info, identifier/identity mismatches (e.g. client code or folder that doesn't match across scope and tickets), ordering/dependency risks, 5-5-5 and billing exposure, and unstated delivery risks. Tie each gap to the expectation, scope item, or rule it violates, with a severity.

Complete when: every gap is listed with its violated expectation and a severity, ranked with anything blocking the expected next step at the top.

### Step 6 — Orient & drive the next actions

Read `agents/project-shepherd.md` and take on that persona for this step. From the current stage, the reconciliation, and the gaps, produce a prioritized next-action list — each action with an owner and a one-line rationale (coordination/handoff email, schedule a tech, escalate per 5-5-5, more research, chase the client, notify Finance, update IT Glue, etc.). Then offer to execute the top action. Write a full standalone report only if the driver asks for one.

Complete when: a ranked next-action list exists (each action with owner and rationale) and the top action is offered for execution.
