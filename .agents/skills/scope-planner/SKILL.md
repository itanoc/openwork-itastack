---
name: scope-planner
description: |
  Scope planner for Sales Scope Template projects. Use when user says "scope planner", "fill out the scope template", "plan this project", "build the tasklist", or asks to create a day-by-day project scope from HaloPSA and ITGlue context.
metadata:
  route_default: high
  route_max: high
  route_class: scope_planner
---

<<<ROUTE default=high max=high class=scope_planner>>>

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

Ask for these first when available, but do not block draft planning when they are missing:

- `ticket_id`: HaloPSA ticket/project ID.
- Scope workbook location:
  - Preferred: SharePoint site URL + folder path + filename for the existing technician-copied `.xlsx` workbook.
  - Local path to the technician's copied `.xlsx` workbook is acceptable as a fallback.
- Optional `project_type`: `auto`, `server-migration`, `network-refresh`, `m365-migration`, `3cx-deployment`, or `mixed`.
- Optional ITGlue organization ID when client name search is ambiguous.

If no ticket ID, SharePoint link, or local workbook path is provided, enter fallback template mode:

- Use `references/Sales Scope Template.xlsx` from this skill directory as the source template.
- Create a working copy before writing; never edit the template directly.
- Default working copy path: `artifacts/scope-plans/scope_plan_<project_slug_or_date>.xlsx`.
- Build the plan from local baselines, local references, and the technician interview.

## Always Load Local References

Use these local skill files as baseline context for every scope-planner run, including fallback template mode with no ticket or SharePoint link:

- `knowledge/baseline-server-migration.md`
- `knowledge/baseline-network-refresh.md`
- `knowledge/baseline-m365-migration.md`
- `knowledge/baseline-3cx-deployment.md`
- `references/itglue-types.md`
- `references/plan-json-format.md`
- `references/Sales Scope Template.xlsx` when a workbook copy must be created locally.
- `scripts/write_scope.py` when writing the approved JSON plan into a workbook copy.

## OpenWork Tool Map

Use these OpenWork tools instead of Agent Zero `/a0` paths:

- HaloPSA:
  - `itastack_itastack_halo` operation `get_ticket`
  - `itastack_itastack_halo` operation `actions.list`
  - `itastack_itastack_halo` operation `clients.list` when client identity is ambiguous
- ITGlue:
  - `itastack_itastack_itglue` operation `organizations.search`
  - `itastack_itastack_itglue` operation `configurations.search`
  - `itastack_itastack_itglue` operation `flexible_assets.list_by_organization`
  - `itastack_itastack_itglue` operation `locations.list`
  - `itastack_itastack_itglue` operation `contacts.list`
  - `itastack_itastack_itglue` operation `documents.search`
- Microsoft 365 / SharePoint read-only discovery/download:
  - `itastack_itastack_m365` operation `list_sharepoint_folder`
    - Use for folder discovery and file metadata.
    - `folder_path` should be relative to the document library root and usually omit `Shared Documents`.
    - Returned file objects may include `id`, `e_tag`, `web_url`, and temporary `download_url`.
  - `itastack_itastack_m365` operation `get`
    - For a read-only workbook overview, do not fetch `download_url`. Resolve the SharePoint site, then read `/workbook/worksheets` and each relevant `/workbook/worksheets/{sheet}/usedRange(valuesOnly=true)?$select=address,values` Graph path using the workbook file ID.
    - Start with visible worksheets. Use a hidden checklist only when it affects the project scope.
  - `itastack_itastack_m365` operation `search_sharepoint_files`
    - Optional only; it may require additional Graph permissions and can return 403 even when folder listing works.
- Microsoft 365 / SharePoint write-back:
  - `itastack_itastack_m365` operation `replace_sharepoint_file`
    - Use only to replace an existing `.xlsx` workbook after explicit final approval.
    - Requires latest file `id`, latest `e_tag`, target path, modified workbook bytes or staged `upload_id`, and expected SHA256.
    - Normal scope-planner write-back uses replace, not upload-new, because the workbook should already exist in SharePoint.
  - For all Microsoft 365 calls, pass tenant as top-level dispatcher field, not inside `params`. ITA SharePoint (`myitassurance.sharepoint.com`) uses tenant `ita` (not `myitassurance`). Even `operation='__describe__'` needs a tenant.
  - Some runtimes reject batching multiple ITAStack calls in one `tool_call`; issue one call per invocation.
- SharePoint file creation (browser fallback):
  - `replace_sharepoint_file` cannot create new files. Use the visible browser only when a SharePoint destination workbook must be created (new scope from template, or new ScopeN copied from an existing scope). Never use the browser to overwrite; overwrite stays with `replace_sharepoint_file`.
  - Client folders live under one of two roots on the ITADocs site:
    - Root A: `https://myitassurance.sharepoint.com/sites/ITADocs/Shared%20Documents/Forms/AllItems.aspx?id=%2Fsites%2FITADocs%2FShared%20Documents%2F1%2E%20Client%20Notes&viewid=874e0ce8%2D58ec%2D425d%2D80ff%2Dc7a78c39dc29&newTargetListUrl=%2Fsites%2FITADocs%2FShared%20Documents&viewpath=%2Fsites%2FITADocs%2FShared%20Documents%2FForms%2FAllItems%2Easpx` (Graph `folder_path`: `1. Client Notes`)
    - Root B (hourly clients): `https://myitassurance.sharepoint.com/sites/ITADocs/Shared%20Documents/Forms/AllItems.aspx?id=%2Fsites%2FITADocs%2FShared%20Documents%2F1%2E%20Client%20Notes%2F2%2E%20Hourly%20Clients&viewid=874e0ce8%2D58ec%2D425d%2D80ff%2Dc7a78c39dc29&newTargetListUrl=%2Fsites%2FITADocs%2FShared%20Documents&viewpath=%2Fsites%2FITADocs%2FShared%20Documents%2FForms%2FAllItems%2Easpx` (Graph `folder_path`: `1. Client Notes/2. Hourly Clients`)
  - Destination must be inside the client folder's current projects folder (e.g. `<client>/3. Current Projects/<project>`). Find the client folder in Root A first, then Root B. If the client folder or its current projects folder is not found or ambiguous, stop and ask; do not create client or current projects folders.
  - Browser copy steps:
    1. Get user approval for the exact source file, destination folder, and new filename.
    2. Navigate from the root to the client folder, then current projects, then the project folder.
    3. Source is the Sales Scope Template (ask user for its SharePoint location if unknown) or the existing scope the user named. Preferred (reliable): from the signed-in SharePoint page, run in-page `fetch` to get a form digest (`POST /sites/ITADocs/_api/contextinfo`), then `POST /sites/ITADocs/_api/SP.MoveCopyUtil.CopyFileByPath()` with JSON body `srcPath`/`destPath` (`SP.ResourcePath`, absolute `DecodedUrl`) and `options` `KeepBoth:false`, `ResetAuthorAndCreatedOnCopy:true`. `200 {"odata.null":true}` = success. Fallback: UI `Copy to`, then rename.
       - Do not use `GetFileByServerRelativePath(...)/copyTo(...)`: long client paths fail with `400 ... exceeds the configured maxUrlLength`.
       - Never pass an overwrite flag; if the destination name exists, stop and ask.
    4. Confirm the new file with `list_sharepoint_folder` (capture `id`, `e_tag`; a fresh copy starts at eTag version 2, same size as source), then continue with normal write-back via `replace_sharepoint_file`.
  - Browser startup/recovery (Hermes agent browser; OpenWork uses its own browser tools):
    - Check `curl -s http://127.0.0.1:9222/json/version`. If refused, start it yourself with `~/dotfiles/bin/agent-chrome` (background); do not ask the user to start it.
    - SharePoint pages are SPAs: `browser_navigate` often times out while the page still loads. Wait ~10s, then check `location.href` / `document.title` instead of retrying navigate.
    - If Microsoft login hangs on "Pick an account" (spinner, blank page after click), the copied profile session is stale: stop the agent browser (kill by PID from `pgrep -f google-chrome-agent`, never `pkill -f` from the same shell — it kills its own command) and relaunch with `agent-chrome --refresh`.
    - After a relaunch, `browser_navigate`/`browser_snapshot` may stay bound to the dead session (`CDP WebSocket connect failed: 404`). Use `browser_cdp`: `Target.getTargets` (or `curl /json/list`) for the page `targetId`, then `Page.navigate` and `Runtime.evaluate` with that `target_id`.
    - If none of this works, report the blocker and ask the user to make the copy manually; do not fall back to other upload methods.
- Web research:
  - Prefer `webfetch` for known vendor URLs.
  - Vendor fetch gotchas: `help.ui.com` (Ubiquiti KB) returns a Cloudflare JS challenge to plain fetch/curl; use the browser for it or cite `techspecs.ui.com` / `store.ui.com`, which fetch fine. Record any unreachable source as a planning risk.
  - Use OpenWork visible browser only after explicit user approval; start with `openwork_browser_open_url`.
  - If no background web search extension exists, ask user for browser approval or source URLs.
- Local workbook write:
  - Use `scripts/write_scope.py` from this skill directory against a user-provided local copy of the scope workbook or a fallback copy created from `references/Sales Scope Template.xlsx`.
  - The script writes structured JSON into the `Tasklist` sheet and creates a backup by default.

## Hard Guardrails

- Never modify the master Sales Scope Template.
- If a ticket and SharePoint workbook are provided, assume the technician has already copied the Sales Scope Template workbook into the project SharePoint folder before this skill runs.
- If no ticket ID, SharePoint link, or local workbook path is provided, create a local working copy from `references/Sales Scope Template.xlsx` and fill that copy after explicit draft approval.
- Do not create a new SharePoint workbook during normal scope-planner execution unless the user requests a new scope file; then use the browser fallback in "SharePoint file creation" (copy into the client's current projects folder only, after approval). Replace an existing workbook only after explicit final approval.
- Only modify a workbook copy after explicit draft approval.
- Verify workbook file exists before writing.
- Treat HaloPSA, ITGlue, M365, 3CX, VSA, and SharePoint ITAStack tools as read-only unless tool name explicitly writes and the user approved that exact write.
- Do not commit secrets, tokens, private logs, SharePoint cookies, Graph tokens, or downloaded client files.
- Treat SharePoint `download_url` values as private temporary auth URLs: do not paste them in final answers, commit them, save them in artifacts, or include them in logs beyond transient tool use.
- Do not paste client-identifying details, internal hostnames, ticket text, or logs into public web search.
- If SharePoint download is available through a returned `download_url`, it may be used transiently to create a local working copy under the OS/session temp dir (`$TMPDIR/scope-planner/`; macOS example `/var/folders/.../T/opencode`) or another user-approved non-repo temp path.
- Before SharePoint replace, re-list the folder and verify the current `id` and `e_tag`; if the eTag changed since download, stop and ask the user to review because someone else may have edited the workbook.
- If SharePoint replace is needed and no safe OpenWork tool is available, stop and ask user to upload the modified local copy manually. Browser handling is for creating new files only (see "SharePoint file creation").
- Do not retry a failed replace blindly. Always re-list folder metadata first to determine whether the upload actually happened.
- If client, ITGlue org, or project type is ambiguous, ask one targeted clarification question before planning.
- If source ticket or workbook path is missing, do not stop; use fallback template mode unless the user specifically wants SharePoint write-back.

## Workflow

### Phase 1 — Gather Context and Choose Workbook Source

1. Collect ticket ID and workbook location when available.
2. If neither SharePoint nor local workbook path is provided, set workbook source to fallback template mode:
   - Source template: `references/Sales Scope Template.xlsx`.
   - Working copy path: `artifacts/scope-plans/scope_plan_<project_slug_or_date>.xlsx`.
   - Do not create or write the copy until the draft plan is explicitly approved.
   - If the user wants the scope in SharePoint (ticket given but no workbook yet), locate the client's current projects folder under Root A or Root B and plan a browser copy of the Sales Scope Template there (see "SharePoint file creation").
3. If SharePoint discovery is requested, list the folder with:
   - `itastack_itastack_m365` operation `list_sharepoint_folder` with top-level `tenant`, plus `site_url` and `folder_path` in `params` from user or known context.
   - Use a folder path relative to the document library root, for example `1. Client Notes/...`, not `Shared Documents/1. Client Notes/...`.
   - Prefer folder listing over search when the folder is known.
   - Use `itastack_itastack_m365` operation `search_sharepoint_files` only as a fallback when filename/query is known but folder is not; search may be denied even when listing works.
4. If SharePoint listing returns the file:
   - Confirm name, `id`, `e_tag`, size, modified timestamp, modified by, and web URL.
   - For a quick overview or other read-only workbook inspection, use Graph workbook reads instead of downloading the file:
     1. Call `get_sharepoint_site` with `site_url` and retain the returned site ID.
     2. Call `get` on `/sites/{site_id}/drive/items/{file_id}/workbook/worksheets`.
     3. Call `get` on `/sites/{site_id}/drive/items/{file_id}/workbook/worksheets/{sheet}/usedRange(valuesOnly=true)?$select=address,values` for each relevant visible sheet.
     4. If a range is too large, query the sheet in smaller ranges or use `$select=address,values`; do not use `download_url` as a fallback for read-only inspection.
   - If a `download_url` is present and a local workbook is needed, use it only transiently to download a working copy outside the repo.
   - Never expose or store the `download_url`.
5. If local workbook path is provided, verify it exists before write-back.
6. If ticket ID is provided, fetch Halo ticket with `itastack_itastack_halo` operation `get_ticket`:
   - `include_actions`: `true`
   - `slim`: `false`
   - `max_note_chars`: `8000`
   - `max_actions`: `0`
7. Extract ticket context when ticket data exists:
   - Full `get_ticket` output is large (150KB+ with 50+ actions) and may spill to a file. Parse it locally with a script: sort `actions` by `datetime`, strip HTML, skip appointment/status noise, print notes. Newest client/technician notes win over the original typeform request.
   - client name and client ID
   - project summary and details/typeform fields
   - parent/child ticket clues
   - assigned technician / prepared by
   - client POC, constraints, notes, and actions
8. Present concise ticket summary when a ticket exists; otherwise present known assumptions from user input and local baselines, then ask technician to confirm or correct scope.
9. Scope revisions: when the user asks to update an existing scope with new client changes, compare the latest ticket notes against the workbook's current Tasklist and list what changed. If the change invalidates the scope's core solution (e.g. the option was put on hold), ask whether to rewrite in place or create a new `ScopeN_<short_name>.xlsx` beside it; do not silently overwrite a scope sales may still quote.
10. Check the workbook's ticket cell (`B2`/`B3` area) against the scope ticket ID; existing copies often carry a related ticket number. Flag mismatches.

Stop if a provided ticket is restricted, ambiguous, or conflicts with user-provided context. Do not stop merely because no ticket was provided.

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
3. Search ITGlue organization by client name unless org ID is provided. Skip ITGlue lookup when no client identity is known yet.
4. Pull project-relevant ITGlue data when an organization is known:
   - configurations
   - flexible assets
   - locations
   - contacts
   - related documents only when needed
5. Use `references/itglue-types.md` to filter ITGlue or interview facts for items that change:
   - task order
   - duration
   - risk
   - ownership
   - timing window
6. Present environment summary and ask what is stale, missing, or out of scope.

If ITGlue data is incomplete or unavailable, collect explicit fallback facts before planning.

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

### Phase 4 — Mandatory Web Research Verification

Always perform web research before the final scope draft, including fallback template mode with no ticket or SharePoint link. Use web research to verify assumptions, catch vendor/model/version-specific requirements, and identify risks that would change task order, labor, downtime, dependencies, rollback, or validation.

Research inputs may come from:

- Halo ticket context when provided.
- ITGlue data when available.
- Technician interview answers.
- Local baseline files when ticket, SharePoint, or ITGlue context is missing.

Research targets:

- vendor installation and deployment guides
- vendor release notes and known issues
- migration prerequisites and limitations
- sizing, licensing, and compatibility limits
- firmware/software caveats
- porting/cutover requirements
- rollback and validation procedures
- end-of-life/end-of-support notices

Source priority:

1. Vendor official documentation.
2. Vendor release notes / KB / support docs.
3. Microsoft, 3CX, Fortinet, or other platform official documentation.
4. Reputable community or forum posts only for gotchas; never use them as the only source for a required project step.

Search query patterns:

- `[vendor] [model] installation guide`
- `[vendor] [model] firmware release notes`
- `[product] [version] migration prerequisites`
- `[product] [version] known issues`
- `[vendor] porting requirements`
- `[model] sizing limits`
- `[product] rollback procedure`
- `[product] licensing requirements`

Research evidence requirements:

- Check at least one official source for each major vendor/product in scope when possible.
- Record source URL, relevant finding, plan impact, task added or changed, and risk if ignored.
- If no official source is found for a major item, state that clearly and treat the item as a planning risk.
- If web search, webfetch, or browser access is unavailable, stop and ask for approval to use visible browser search or ask the user for vendor/source URLs. Do not claim details were verified without sources.

Search safely:

- Use generic vendor/product/model/version terms only.
- Do not include client names, ticket content, internal hostnames, user emails, private IPs, serial numbers, license keys, or private logs.
- Do not paste client-identifying details into public search engines or vendor sites.

Proceed directly to draft generation after presenting key findings and plan impacts; do not ask “ready to generate?” unless major uncertainty remains.

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
- research evidence table with source URL, finding, plan impact, task added/changed, and risk if ignored
- comments

Present full draft to technician. Iterate until technician explicitly approves.

Do not write workbook yet.

### Phase 6 — Build JSON, Prepare Workbook Copy, Write, Replace, Verify

After explicit approval:

1. Build plan JSON following `references/plan-json-format.md`.
2. Save JSON under `artifacts/scope-plans/scope_plan_<ticket_id>.json` when useful.
3. Prepare a local workbook copy:
    - Standard path: use `itastack_itastack_m365` operation `list_sharepoint_folder` to find the existing copied workbook in the project folder.
    - If the destination workbook does not exist yet (new scope from template, or new ScopeN), create it first with the browser fallback in "SharePoint file creation", then re-list to capture its `id` and `e_tag`.
    - Capture source `id`, `e_tag`, name, size, modified timestamp, modified by, and web URL.
    - If user provided a local workbook path, use that path.
    - If no SharePoint workbook or local workbook path is available, copy `references/Sales Scope Template.xlsx` to `artifacts/scope-plans/scope_plan_<project_slug_or_date>.xlsx` and write to that copy.
    - If SharePoint listing returned a `download_url`, download it to a non-repo temp path such as `$TMPDIR/scope-planner/<safe-filename>.xlsx`.
    - Python: `openpyxl` may be missing and system pip blocked (PEP 668); run the writer with `uv run --with openpyxl python3 <script> ...` when available.
    - Do not save SharePoint temporary URLs in repo files, plan JSON, notes, or final response.
    - Do not put client workbook copies under the repo unless user explicitly asks.
    - Exception: fallback template mode intentionally writes the new local workbook copy under `artifacts/scope-plans/`.
4. Write to local workbook with the current OS:

Pre-write layout check (required): `write_scope.py` auto-detects Tasklist rows from section labels, so it handles both the master template and shifted technician copies (e.g. template row 1 deleted, tasks start at `A4`). Run `write_scope.py --file "<copy>.xlsx" --show-layout` first and confirm the detected rows look right. If it reports missing labels, stop: do not hand-edit; report which labels are missing and ask whether to write into a fresh template copy.

macOS/Linux shell:

```bash
python3 .agents/skills/scope-planner/scripts/write_scope.py \
  --input artifacts/scope-plans/scope_plan_<ticket_id>.json \
  --file "<local scope workbook copy>.xlsx"
```

Windows PowerShell:

```powershell
py .agents\skills\scope-planner\scripts\write_scope.py `
  --input artifacts\scope-plans\scope_plan_<ticket_id>.json `
  --file "<local scope workbook copy>.xlsx"
```

5. Verify script output:
   - success message
   - day count
   - task count
   - daily hour totals
   - any over-8-hour warnings
6. Verify the local file SHA256: macOS `shasum -a 256 "<file>"`; Linux `sha256sum "<file>"`; Windows PowerShell `(Get-FileHash "<file>" -Algorithm SHA256).Hash`.
7. Encode the workbook bytes only when needed for the tool call; do not save base64 in repo files, artifacts, notes, logs, or final response.
8. Re-list and replace: run `itastack_itastack_m365` operation `list_sharepoint_folder` to refresh `original_file_id` and `original_etag`, then call `itastack_itastack_m365` operation `replace_sharepoint_file` with top-level `tenant` and params containing `site_url`, `target_path`, `original_file_id`, `original_etag`, either `file_base64` or `upload_id`, and `expected_sha256`.
9. If the workbook is too large for safe `file_base64` transfer and no approved staged `upload_id` is available in the current session, stop and report the local modified workbook path for manual upload or ask the user for an approved staging method. Do not read MCP bearer tokens from config files and do not hand-roll authenticated `curl` uploads.
10. After replace, re-list the folder and verify:
   - file `id` stayed the same
   - `e_tag` advanced
   - modified timestamp advanced
   - size is reasonable for the modified workbook
   - modified by is expected
11. If `itastack_itastack_m365` operation `replace_sharepoint_file` returns an eTag mismatch or verification error:
   - Do not retry automatically.
   - Re-list the folder immediately.
   - If same file `id` now has an advanced `e_tag`, updated modified timestamp, and reasonable size, report that replace appears successful but tool verification returned an error.
   - If metadata did not change, report replace failed and keep the modified local workbook path for manual upload or retry after user approval.

Report back with:

- local workbook path
- backup workbook path from script output
- plan JSON path if created
- SharePoint source metadata if discovered by folder listing
- SharePoint replace status and post-replace metadata
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

- Per-day/phase hour totals in the draft must be the computed sum of listed task hours (sum them, don't estimate); mismatched totals inflate the quote.
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
- Workbook: use user-provided local path; in fallback template mode use `artifacts/scope-plans/scope_plan_<project_slug_or_date>.xlsx`; do not copy client workbook into repo unless user explicitly asks.

## Files Used by This Skill

- `scripts/write_scope.py` — writes structured plan JSON into local workbook copy.
- `knowledge/baseline-*.md` — baseline task libraries by project type.
- `references/itglue-types.md` — ITGlue relevance mapping for scope interviews.
- `references/plan-json-format.md` — JSON schema, color coding, and workbook writer expectations.
- `references/Sales Scope Template.xlsx` — fallback source template when no SharePoint workbook or local workbook path is provided.
