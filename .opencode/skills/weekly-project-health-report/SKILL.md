---
name: weekly-project-health-report
description: |
  Generate the Weekly Project Health Report for IT Assurance from read-only HaloPSA project, budget, and child project-task actuals.

  Triggers when user mentions:
  - "Weekly Project Health Report"
  - "project health report"
  - "weekly project budget report"
  - "pull project health"
  - "run project health"
---

# Weekly Project Health Report

Use this skill when the user asks to run, pull, or generate the Weekly Project Health Report for IT Assurance.

Produce a concise Markdown report from HaloPSA data using read-only OpenWork ITAStack tools.

## Output

- Markdown only unless the user asks for another format.
- Default artifact path when saving to workspace: `reports/weekly-project-health-report.md`.
- Keep report concise and technician/leadership friendly.
- Include caveats for missing budget rows, unknown schema fields, or excluded/unmapped time.

## Required tool

Use only read-only Halo SQL:

- `itastack_grafana_query_halo_sql`

Do not call Halo write tools. Do not mutate tickets, budgets, appointments, clients, or actions.

Tool call shape:

```json
{
  "sql": "SELECT TOP N ...",
  "limit": 100
}
```

Every SQL query must be one bounded `SELECT TOP N` statement.

## Defaults

- Project status filter: `New (email)` unless user specifies another project status.
- Weekly window: last 7 days based on work/logged date of the time entry.
- Project scope: parent Halo tickets where Ticket Type = `Project`.
- Actuals source: child tickets where Ticket Type = `Project Task`.
- Child task status: include all child project task tickets regardless of task status.

State defaults before first query when user did not specify filters:

```text
Assumption: projects with status New (email), weekly window last 7 days.
```

## Business rules

### Budget source

- Use the parent Project ticket Budget tab.
- Budget row `Admin (Project Management)` = Budgeted Admin Hours.
- Budget row `Development` = Budgeted Technician Hours.
- Ignore Halo budget tab cost/rate values.

### Actuals

- PTD actuals = all included time from beginning of project.
- Weekly actuals = included time in last 7 days, based on time entry work/logged date.
- Include time only from child tickets with Ticket Type = `Project Task`.
- Exclude billing tier/line named `No Charge`.
- Exclude unmapped users.

### Role mapping

| Role | Included users |
|------|----------------|
| Technician | Riley, James, Kevin |
| Admin | Catalina |
| Unmapped/excluded | Laura, Heather, Michelle |

If Halo user names are spelled differently, map by obvious exact-person match only. Do not guess ambiguous users.

### Rates

| Role | Rate |
|------|------|
| Technician | $250/hr |
| Admin | $200/hr |

### Status logic

- Status is based on hours only, not cost.
- Role statuses: `OK`, `Warning`, `Over Budget`, `No Scope`.
- `Warning` = PTD hours are 80% or more of budgeted hours.
- `Over Budget` = PTD hours exceed budgeted hours.
- Role `No Scope` = role budget missing or zero.
- Project `No Scope` = both Tech and Admin budgets missing or zero.
- Project status uses total budgeted hours vs total PTD hours.
- `No Activity` applies only at project level when there are no included hours in last 7 days.
- Show multiple project statuses when applicable, for example `🟡 Warning; 🔵 No Activity`.

### Icons

| Status | Icon |
|--------|------|
| OK | 🟢 |
| Warning | 🟡 |
| Over Budget | 🔴 |
| No Activity | 🔵 |
| No Scope | ⚪ |

### Budget and cost calculations

- Show Tech/Admin/Total Budget Used %.
- Use `N/A` for No Scope roles/projects.
- Budgeted cost = budgeted hours × role rate.
- PTD actual cost = PTD hours × role rate.
- Cost variance = PTD actual cost - budgeted cost.
- Show variance for Tech, Admin, and Total.
- Positive variance means actual cost is over budget.
- Negative variance means actual cost is under budget.

## Schema facts already known

Known HaloPSA fields used elsewhere in this workspace:

- Tickets table: `faults`
  - PK: `Faultid`
  - Parent/project relationship is schema-dependent; discover before using.
  - Type id: `RequestTypeNew`
  - Status id: `Status`
  - Created: `dateoccured`
  - Deleted flag: `FDeleted`
  - Summary: `Symptom`
- Ticket type table: `REQUESTTYPE`
  - PK: `RTid`
  - Name: `RTdesc`
- Actions/time table: `ACTIONS`
  - Ticket FK: `Faultid`
  - Time hours: `timetaken`
  - Adjusted time hours: `timetakenAdjusted`
  - Logged/work date: `Whe_`
  - Agent FK: `whoagentid`
  - Billable flag: `ActIsBillable`
  - Non-billable bucket: `nonbilltime`

## Discovery-first policy

Halo budget and parent-child schema can vary. Before calculating, run bounded discovery queries to confirm:

1. Ticket type ids for `Project` and `Project Task`.
2. Status id for `New (email)` or user-specified status.
3. Parent-child relationship column/table for project tasks.
4. Budget tab table and fields for budget category/name and hours.
5. Agent/user table and field names needed to map Riley, James, Kevin, Catalina, Laura, Heather, Michelle.
6. Billing tier/line field or lookup needed to exclude `No Charge`.

If any required schema cannot be confirmed, stop and report exactly what is missing. Do not fabricate table or column names.

## Suggested discovery queries

Use these in order, adapting only after a query result proves different schema.

### 1. Resolve ticket type ids

```sql
SELECT TOP 20
  RTid,
  RTdesc
FROM REQUESTTYPE
WHERE RTdesc IN ('Project', 'Project Task')
   OR RTdesc LIKE '%Project%'
ORDER BY RTdesc
```

### 2. Resolve status ids

```sql
SELECT TOP 50
  TStatus,
  TStatusDesc
FROM TSTATUS
WHERE TStatusDesc = '<STATUS_NAME>'
   OR TStatusDesc LIKE '%<STATUS_NAME>%'
ORDER BY TStatusDesc
```

If `TSTATUS` or field names fail, discover likely status tables with a bounded `INFORMATION_SCHEMA.COLUMNS` query.

### 3. Discover parent-child fields on `faults`

```sql
SELECT TOP 100
  COLUMN_NAME,
  DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'faults'
  AND (
    COLUMN_NAME LIKE '%parent%'
    OR COLUMN_NAME LIKE '%project%'
    OR COLUMN_NAME LIKE '%main%'
    OR COLUMN_NAME LIKE '%linked%'
  )
ORDER BY COLUMN_NAME
```

### 4. Discover budget tables/fields

```sql
SELECT TOP 100
  TABLE_NAME,
  COLUMN_NAME,
  DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME LIKE '%budget%'
   OR COLUMN_NAME LIKE '%budget%'
   OR COLUMN_NAME LIKE '%hours%'
ORDER BY TABLE_NAME, COLUMN_NAME
```

### 5. Discover agent/user names

```sql
SELECT TOP 100
  TABLE_NAME,
  COLUMN_NAME,
  DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%agent%'
   OR COLUMN_NAME LIKE '%user%'
   OR COLUMN_NAME LIKE '%name%'
ORDER BY TABLE_NAME, COLUMN_NAME
```

After candidate user table is identified, query names for role mapping. Use exact or obvious first-name matches only.

### 6. Discover no-charge billing fields

```sql
SELECT TOP 100
  TABLE_NAME,
  COLUMN_NAME,
  DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%charge%'
   OR COLUMN_NAME LIKE '%billing%'
   OR COLUMN_NAME LIKE '%bill%'
   OR COLUMN_NAME LIKE '%tier%'
   OR COLUMN_NAME LIKE '%line%'
ORDER BY TABLE_NAME, COLUMN_NAME
```

## Calculation workflow

1. State assumptions for default status/window.
2. Run discovery queries.
3. Build one project list query:
   - parent tickets only
   - ticket type `Project`
   - status filter
   - not deleted
   - include parent ticket id, client, project summary/name, status, created date
4. Build one budget query:
   - parent project ticket id
   - budget rows named `Admin (Project Management)` and `Development`
   - hours only
5. Build one actuals query:
   - child project task tickets only
   - all task statuses
   - actions/time entries on child tasks
   - exclude `No Charge`
   - include only mapped users
   - group by parent project and role
   - return PTD hours and weekly hours
6. Calculate statuses, percentages, costs, and variances in reasoning from query results.
7. Produce final Markdown report.

## Required report format

```markdown
# Weekly Project Health Report

Window: <start date> to <end date>
Project status filter: <status>

## Summary

- Projects reviewed: <n>
- Needs attention: <n>
- No activity this week: <n>
- Over budget: <n>
- Missing scope/budget: <n>

## Project Health

| Project | Status | Tech Used | Admin Used | Total Used | Weekly Hours | Cost Variance | Notes |
|---------|--------|-----------|------------|------------|--------------|---------------|-------|
| <project> | 🟡 Warning; 🔵 No Activity | 85% | 20% | 70% | 0.0 | +$1,250 | Tech near budget |

## Detail

### <Project Name> (#<ticket id>)

| Role | Budget Hours | PTD Hours | Weekly Hours | Used | Budgeted Cost | PTD Cost | Variance | Role Status |
|------|--------------|-----------|--------------|------|---------------|----------|----------|-------------|
| Technician | 40.0 | 34.0 | 2.0 | 85% | $10,000 | $8,500 | -$1,500 | 🟡 Warning |
| Admin | 5.0 | 1.0 | 0.0 | 20% | $1,000 | $200 | -$800 | 🟢 OK |
| Total | 45.0 | 35.0 | 2.0 | 78% | $11,000 | $8,700 | -$2,300 | 🟢 OK |

Notes:
- <short note based on status, missing scope, weekly activity, or variance>

## Exclusions and caveats

- Excluded No Charge time: <hours if available, else "not returned separately">
- Excluded unmapped users: Laura, Heather, Michelle, and any unrecognized users.
- Budget source: parent Project ticket Budget tab, hours only.
```

## Formatting rules

- Round hours to one decimal place.
- Round percentages to whole percentages.
- Format money with dollars and thousands separators.
- Use `N/A` for no-scope percentages and cost variance where no budget exists.
- Keep notes short; no more than two bullets per project.
- Sort projects by severity first:
  1. Over Budget
  2. Warning
  3. No Activity
  4. No Scope
  5. OK

## Stop conditions

Stop and ask one targeted question if:

- User-requested status is ambiguous.
- Required Halo schema cannot be discovered safely with read-only queries.
- Budget tab data cannot be located.
- Parent-child project task relationship cannot be identified.

Stop and refuse if:

- User asks to write to Halo or change budgets from this skill.
- User asks to include excluded No Charge or unmapped-user hours without changing the business rules explicitly.

## Example user prompts

- `Run the Weekly Project Health Report.`
- `Pull project health for active New email projects.`
- `Generate the weekly project budget report for Waiting projects.`
