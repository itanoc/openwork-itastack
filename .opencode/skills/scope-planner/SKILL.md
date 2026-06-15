---
name: scope-planner
description: |
  Scope planner for Sales Scope Template projects. Use when user says "scope planner", "fill out the scope template", "plan this project", "build the tasklist", or asks to create a day-by-day project scope from HaloPSA and ITGlue context.
---

# Scope Planner

Use this skill to guide a project technician through a practical, day-by-day scope plan for the Sales Scope Template workflow using OpenWork ITAStack tools, local workbook editing, and technician review before any write-back.

## Output Style

- Keep chat responses concise.
- Lead with result or next needed input.
- Ask focused question groups, not one giant questionnaire.
- Call assumptions out explicitly.
- Do not write to any workbook, SharePoint file, Halo ticket, ITGlue document, tenant, PBX, RMM, or client system until user approves exact write action.

## Goal

Produce a technician-reviewed project task plan that can be written into the technician's copied Sales Scope Template workbook.

Expected plan quality:

- Chronological day-by-day plan.
- Column A-ready task descriptions.
- Column C minimum labor hours.
- Column G/H downtime and after-hours flags.
- Location values for color coding: `remote`, `onsite`, `vendor`, `client`, `procurement`.
- Complete parts, client dependency, vendor dependency, downtime, and comments sections.
- Realistic daily load: target 8 hours or less per day including travel.

## Inputs

Ask for these first:

- `ticket_id`: HaloPSA ticket/project ID.
- Scope workbook location:
  - Preferred: local path to technician's copied `.xlsx` workbook, or
  - SharePoint site URL + folder path + filename if user wants file discovery first.
- Optional `project_type`: `auto`, `server-migration`, `network-refresh`, `m365-migration`, `3cx-deployment`, or `mixed`.
- Optional ITGlue organization ID when client name search is ambiguous.

## OpenWork Tool Map

Use these OpenWork tools instead of Agent Zero `/a0` paths:

- HaloPSA:
  - `itastack_halo_get_ticket`
  - `itastack_halo_list_ticket_actions`
  - `itastack_halo_search_clients` when client identity is ambiguous
- ITGlue:
  - `itastack_itglue_search_organizations`
  - `itastack_itglue_search_configurations`
  - `itastack_itglue_list_flexible_assets_by_organization`
  - `itastack_itglue_list_locations`
  - `itastack_itglue_list_contacts`
  - `itastack_itglue_search_documents`
- Microsoft 365 / SharePoint read-only discovery:
  - `itastack_m365_list_sharepoint_folder`
  - `itastack_m365_search_sharepoint`
- Web research:
  - Prefer `webfetch` for known vendor URLs.
  - Use OpenWork visible browser only after explicit user approval; start with `openwork_browser_open_url`.
  - If no background web search extension exists, ask user for browser approval or source URLs.
- Local workbook write:
  - Use `scripts/write_scope.py` from this skill directory against a user-provided local copy of the scope workbook.
  - The script writes structured JSON into the `Tasklist` sheet and creates a backup by default.

## Hard Guardrails

- Never modify the master Sales Scope Template.
- Only modify the technician's copied workbook after explicit draft approval.
- Verify workbook file exists before writing.
- Treat HaloPSA, ITGlue, M365, 3CX, VSA, and SharePoint ITAStack tools as read-only unless tool name explicitly writes and user asked for that exact write.
- Do not commit secrets, tokens, private logs, SharePoint cookies, Graph tokens, or downloaded client files.
- Do not paste client-identifying details, internal hostnames, ticket text, or logs into public web search.
- If SharePoint download/upload is needed and no safe OpenWork tool is available, stop and ask user to provide local workbook copy or approve visible-browser/manual SharePoint handling.
- If source ticket, client, ITGlue org, workbook path, or project type is ambiguous, ask one targeted clarification question and stop.

## Workflow

### Phase 1 — Gather Context and Verify Workbook

1. Collect ticket ID and workbook location.
2. If SharePoint discovery is requested, list/search folder with:
   - `itastack_m365_list_sharepoint_folder` with tenant and site URL provided by user or known context.
   - `itastack_m365_search_sharepoint` when only filename/query is known.
3. If local workbook path is provided, verify it exists before write-back.
4. Fetch Halo ticket with `itastack_halo_get_ticket`:
   - `include_actions`: `true`
   - `slim`: `false`
   - `max_note_chars`: `8000`
   - `max_actions`: `0`
5. Extract:
   - client name and client ID
   - project summary and details/typeform fields
   - parent/child ticket clues
   - assigned technician / prepared by
   - client POC, constraints, notes, and actions
6. Present concise ticket summary and ask technician to confirm or correct scope.

Stop if ticket is restricted, missing, ambiguous, or client conflicts with user-provided context.

### Phase 2 — Select Baseline and Build Environment Understanding

1. Identify project type:
   - `server-migration`
   - `network-refresh`
   - `m365-migration`
   - `3cx-deployment`
   - `mixed`
2. Load relevant baseline(s):
   - `knowledge/baseline-server-migration.md`
   - `knowledge/baseline-network-refresh.md`
   - `knowledge/baseline-m365-migration.md`
   - `knowledge/baseline-3cx-deployment.md`
3. Search ITGlue organization by client name unless org ID is provided.
4. Pull project-relevant ITGlue data:
   - configurations
   - flexible assets
   - locations
   - contacts
   - related documents only when needed
5. Use `references/itglue-types.md` to filter for items that change:
   - task order
   - duration
   - risk
   - ownership
   - timing window
6. Present environment summary and ask what is stale, missing, or out of scope.

If ITGlue data is incomplete, collect explicit fallback facts before planning.

### Phase 3 — Technician Interview

Interview in focused groups. Confirm each group before moving on.

Area A — Environment and scope specifics:

- What exact systems, sites, users, devices, mailboxes, circuits, phone numbers, or vendors are in scope?
- What must stay unchanged?
- What is known stale or missing in ITGlue?

Area B — Client constraints:

- Maintenance windows, blackout dates, onsite access, security requirements, business critical workflows.
- Client POC availability and decision authority.

Area C — Dependencies:

- Procurement, licensing, vendor tickets, ISP/carrier lead time, access credentials, backups, approvals.

Area D — Technical plan:

- Preferred approach, migration/cutover method, rollback path, validation checks.

Area E — Parts/procurement:

- Hardware, licensing, mounting/cabling, alternatives, quantities, prices if known.

Area F — Client/vendor dependencies:

- Who must do what, by when, and why it blocks sequencing.

Area G — Downtime and after-hours:

- What workflows are affected, expected duration, who approves, communication needed, rollback trigger.

After each group, ask:

- What changed from initial assumptions?
- Does technician input conflict with ITGlue?
- Should tasks split, reorder, or move across days to reduce risk?

### Phase 4 — Targeted Web Research

Run limited research for model/version-specific gotchas only after enough detail exists.

Research targets:

- vendor install docs
- release notes / known issues
- migration prerequisites
- sizing limits
- firmware/software caveats
- porting/cutover requirements

Search safely:

- Use generic product/model/error terms.
- Do not include client names, ticket content, internal hostnames, user emails, or private logs.
- Record source URL and what it changed in the plan.

Proceed directly to draft generation after presenting key findings; do not ask “ready to generate?” unless major uncertainty remains.

### Phase 5 — Draft Plan and Review

Build draft using template conventions:

- Day headers: `Day 1 - 8hrs max`, etc.
- 8-hour target per day, including travel.
- Travel time and EOD walkthrough for onsite days.
- Dependency callouts with `⚠️`.
- `At completion` expectations preserved by workbook writer.
- Location values: `remote`, `onsite`, `vendor`, `client`, `procurement`.

Include:

- task table with day, description, hours, downtime, afterhours, location, notes/dependencies
- parts list
- downtime explanation
- client dependencies
- vendor dependencies
- comments

Present full draft to technician. Iterate until technician explicitly approves.

Do not write workbook yet.

### Phase 6 — Build JSON, Write Local Workbook, Verify

After explicit approval:

1. Build plan JSON following `references/plan-json-format.md`.
2. Save JSON under `artifacts/scope-plans/scope_plan_<ticket_id>.json` when useful.
3. Write to local workbook with:

```bash
python3 .opencode/skills/scope-planner/scripts/write_scope.py \
  --input artifacts/scope-plans/scope_plan_<ticket_id>.json \
  --file "<local scope workbook copy>.xlsx"
```

4. Verify script output:
   - success message
   - day count
   - task count
   - daily hour totals
   - any over-8-hour warnings
5. If SharePoint upload is required, ask user for approved method:
   - user uploads local workbook manually, or
   - user approves visible-browser SharePoint upload, or
   - user provides approved extension/tool path if available.

Report back with:

- local workbook path
- backup workbook path from script output
- plan JSON path if created
- SharePoint upload status if performed by user-approved method
- any warnings needing human review

## Plan JSON Shape

Use `references/plan-json-format.md` as source of truth.

Minimum shape:

```json
{
  "metadata": {
    "project_name": "Client - Project",
    "ticket_number": "12345",
    "prepared_by": "Technician Name",
    "date": "2026-06-15"
  },
  "days": [
    {
      "label": "Day 1 - 8hrs max",
      "tasks": [
        {
          "description": "Travel time bi-directional",
          "time_min": 1.0,
          "downtime": "No",
          "afterhours": "No",
          "location": "onsite"
        }
      ]
    }
  ],
  "downtime_explanation": "What workflows are impacted and when.",
  "parts": [],
  "client_dependencies": "Client approvals/access/prep requirements.",
  "cat_herding": "No",
  "vendor_dependencies": {
    "vendors": [],
    "support_current": "Unknown",
    "vendor_charges": "Unknown",
    "existing_ticket": "",
    "contact": "",
    "hours": ""
  },
  "comments": "Additional planning notes."
}
```

## Quality Checks

Before draft approval:

- Another engineer could execute plan without guessing.
- Dependencies explain why they matter.
- Downtime/after-hours flags match actual impact.
- Each day is realistic; over-8-hour days are intentional and called out.
- Parts and vendor/client dependencies are explicit or marked intentionally blank.
- ITGlue conflicts or stale data are noted.

Before declaring workbook complete:

- JSON is valid.
- `write_scope.py` succeeded.
- Backup file exists.
- Daily totals are reviewed.
- User knows whether SharePoint upload is manual, pending, or completed.

## Artifact Paths

- Plan JSON: `artifacts/scope-plans/scope_plan_<ticket_id>.json`
- Optional planning notes: `artifacts/scope-plans/scope_plan_<ticket_id>.md`
- Workbook: use user-provided local path; do not copy client workbook into repo unless user explicitly asks.

## Files Used by This Skill

- `scripts/write_scope.py` — writes structured plan JSON into local workbook copy.
- `knowledge/baseline-*.md` — baseline task libraries by project type.
- `references/itglue-types.md` — ITGlue relevance mapping for scope interviews.
- `references/plan-json-format.md` — JSON schema, color coding, and workbook writer expectations.
