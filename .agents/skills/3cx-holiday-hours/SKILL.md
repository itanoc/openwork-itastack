---
name: 3cx-holiday-hours
description: |
  Configure or verify a 3CX holiday closure by reusing an existing holiday entry when possible, preserving its prompt unless explicitly asked to change it, and verifying the saved date and hours.

  Triggers when user mentions:
  - "3CX holiday hours"
  - "3CX holiday closure"
  - "update Labor Day in 3CX"
  - "set holiday hours in 3CX"
metadata:
  route_default: daily
  route_max: medium
  route_class: 3cx_holiday_hours
---

<<<ROUTE default=daily max=medium class=3cx_holiday_hours>>>

# 3CX Holiday Hours

Set or verify one 3CX holiday closure through the browser UI. Keep chat output terse.

## Inputs

- 3CX URL. Ask only if absent.
- Holiday name, date, and hours. Ask for any missing value before navigating. Interpret a confirmed full-day closure as `12:00 AM–11:59 PM`.
- Scope: all groups or one target group/department. If the server has multiple groups and scope is not stated, ask: `Update all groups, or choose one group?`
- Optional test URL. A demo test is read-only until the user explicitly approves saving a test entry.

## Rules

- Use the OpenWork built-in browser. Call `openwork_execute` with id `browser.open_url`, then retain its returned browser handle for all browser work.
- Use normal browser UI behavior. Inspect the current page, visible controls, and saved rows before a write.
- Select holiday rows by exact displayed name. Never edit the first table row by position; confirm the editor's holiday name before changing it.
- Treat the selected group as a required scope. Never assume the first selected group is correct when more than one is available.
- For all-groups work, inspect, plan, write, and verify every group independently. Never infer that one group's holiday settings apply to another.
- Read the displayed 3CX global time zone from the Time Zone control and state it in the plan. Use it for all requested dates and hours.
- Set dates through the 3CX calendar picker; do not type a date into its text field.
- For a new full-day entry, explicitly set `12:00 AM–11:59 PM` and verify those times. Do not rely on the `Whole day` button alone.
- Preserve the attached holiday prompt by default. Do not upload, record, remove, or replace it unless explicitly requested.
- Prefer an existing exact holiday-name match, including a past one, over creating a new entry. This prevents duplicate closures.
- Before creating a new entry, scan all existing holiday names for the requested holiday and close variants. If uncertain, stop and ask.
- Preserve the holiday occurrence (`Once` or `Annually`). Never convert it without explicit approval.
- Do not change normal office hours, call handling, IVRs, routing, or other holidays.
- Production saves require explicit approval of: server, group, holiday record, date, hours, and prompt action.

## Workflow

1. Confirm all required inputs: URL, holiday name, date, hours/full-day, and scope when already supplied.
   - Completion: no target value is inferred.
2. Open the 3CX URL and navigate to `Admin` → `Office Hours` → `Office Holidays`.
   - Completion: the holiday table is visible.
3. Identify the selected group, enumerate available groups, and read the global time zone.
   - If more than one group exists and scope is not stated, ask exactly: `Update all groups, or choose one group?`
   - For one-group scope, require one listed group name. For all-groups scope, target every listed group.
4. Inspect the holiday table for the requested holiday in every target group.
   - Record each group's current name, date, hours, occurrence, prompt filename, and other editable values as rollback data.
   - Completion: identify exactly one existing entry or establish that none exists for every target group.
5. Build the plan, one row per target group.
   - Existing entry: update its date and hours; retain its prompt and occurrence.
   - No entry: create one only after duplicate check and approval. Set occurrence only when the user explicitly supplied it; otherwise ask. Leave prompt untouched unless user provided an approved prompt action.
   - State server, scope, target groups, holiday records, date, hours, time zone, occurrence, prompt action, and whether the change is demo or production. Ask for approval if it has not already been given.
6. After approval, edit or create one entry per target group through the form and save it.
   - Existing entry: select its exact named row and verify the editor name before changing it.
   - Use the calendar picker to select the date.
   - New full-day entry: explicitly set the end time to `11:59 PM`.
   - Before every save, re-check server URL, selected group, holiday name, date, times, occurrence, and displayed prompt attachment.
   - For all-groups scope, save and verify the first group before continuing. Stop if its saved row differs from the plan.
   - Completion: the form closes without an error.
7. Refresh or reopen `Office Holidays`, then verify every target group in the table.
   - Re-read each target row and confirm name, date, hours, time zone, occurrence, and retained/changed prompt.
   - If the wrong row changed or a value differs, restore the captured original values for the affected row, verify the restoration, then stop. Do not retry blindly.

## Demo-first mode

When the user requests a demo test before production:

1. Run steps 2–4 against the demo URL, including the scope gate.
2. Inspect the edit/create form and report its fields without saving unless a test write is explicitly approved.
3. Use the verified UI path and same target values to prepare the production plan.
4. Do not copy demo prompts, group identifiers, routing assumptions, or time-zone assumptions to production.

## Output

After inspection:

- `Found: <group> → <holiday> — <date>, <hours>, <time zone>, <occurrence>, prompt: <filename or none>.`
- `Plan: <update/create> <holiday> in <group> to <date>, <hours>, <time zone>, <occurrence>; prompt <preserved/changed>. Confirm?`
- For all-groups scope, emit one `Found` and `Plan` line per group, then ask for one batch approval.

After a verified save:

- `Updated and verified after refresh: <group> → <holiday> — <date>, <hours>, <time zone>, <occurrence>; prompt <filename or none>.`
- For all-groups scope, emit one verified line per group and identify any stopped group.

On ambiguity or failure, state the exact group, row, or UI condition and the safest next action.
