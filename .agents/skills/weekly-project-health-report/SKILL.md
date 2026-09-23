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
metadata:
  route_default: daily
  route_max: high
  route_class: weekly_project_health_report
---

<<<ROUTE default=daily max=high class=weekly_project_health_report>>>

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

- `itastack_itastack_grafana` operation `query_halo_sql`

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

Map by HaloPSA `UNAME.Unum` (agent id). The id values below were confirmed
against this Halo instance; the displayed first names differ slightly from the
role labels (e.g. "Riely Borek", "Michele Anderson"), so prefer matching by
`Unum` to avoid spelling ambiguity.

| Role | Included users | UNAME.Unum |
|------|----------------|------------|
| Technician | James, Kevin, Riely | 14, 20, 25 |
| Admin | Catalina | 56 |
| Unmapped/excluded | Laura, Heather, Michele | 23, 13, 57 |

User-to-id reference (confirmed):

| Display name | First name | Unum | Role |
|--------------|------------|------|------|
| James Schriever | James | 14 | Technician |
| Kevin Casper | Kevin | 20 | Technician |
| Riely Borek | Riely | 25 | Technician |
| Catalina Hernandez | Catalina | 56 | Admin |
| Laura Barbosa | Laura | 23 | Excluded |
| Heather Larsen | Heather | 13 | Excluded |
| Michele Anderson | Michele | 57 | Excluded |

If Halo user ids change or new technicians appear, re-confirm with a bounded
`UNAME` lookup. Use exact `Unum` match; do not guess ambiguous users.

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

Confirmed against this Halo instance during a prior run. Re-verify with bounded
discovery only if a query fails.

- Tickets table: `faults`
  - PK: `Faultid`
  - Type id: `RequestTypeNew` — `Project` = **5**, `Project Task` = **20**
    (other relevant: CMMC Project = 54, Project Opportunity = 30,
    Risk (Projects) = 26, T&M Project = 50)
  - Status id: `Status` — `New (email)` = **1** (also: New = 39,
    New (portal) = 37, New (Whoops) = 38)
  - Parent/project link: `fmainprojectid` (int). On a child Project Task it
    holds the parent Project's `Faultid`. CAVEAT: many recently created task
    tickets have `fmainprojectid = Faultid` (self-referencing) and are NOT
    linked to a parent — treat `fmainprojectid = Faultid` as "unlinked" and
    only join children where `c.fmainprojectid = <project Faultid>`.
  - Client/site: `areaint` (joins `AREA.Aarea`, name `Aareadesc`)
  - Created: `dateoccured` (epoch millis)
  - Deleted flag: `FDeleted` (filter `FDeleted = 0 OR FDeleted IS NULL`)
  - Summary: `Symptom`
  - Other project fields present but NOT used for budget: `FProjectTimeBudget`,
    `FProjectTimeActual`, `FProjectMoneyBudget`, `FProjectMoneyActual`.
    Halo also exposes milestones (`MileStone.MSTFaultId` = project,
    `FaultsMileStone`), but `FaultsMileStone` was empty for sampled projects, so
    do not rely on milestones to find child tasks.
- Ticket type table: `REQUESTTYPE`
  - PK: `RTid`, Name: `RTdesc`
- Status table: `TSTATUS`
  - Id: `Tstatus`, Name: `Tstatusdesc`
- Client/site table: `AREA`
  - Id: `Aarea`, Name: `Aareadesc`
- Budget table: `FaultBudget` (parent Project ticket Budget tab)
  - Ticket FK: `FBTfaultid`
  - Budget type FK: `FBTbtid` -> `BudgetType.BTid` (name `BudgetType.BTname`)
  - Budgeted hours: `FBThours` (use this; ignore `FBTrate`/money columns)
  - `Development` = Budgeted Technician Hours (`BTid` = 3)
  - `Admin (Project Management)` = Budgeted Admin Hours (`BTid` = 5)
  - Most New (email) projects had NO `FaultBudget` rows -> No Scope.
- Agent/user table: `UNAME`
  - PK: `Unum` (NOT `Uspid`/`Aint`; there is no `AGENT` table)
  - Names: `uname`, `ufirstname`, `ulastname`
  - Joins to `ACTIONS.whoagentid`
- Actions/time table: `ACTIONS`
  - Ticket FK: `Faultid`
  - Time hours: `timetaken` (may be NULL or 0; treat NULL as 0)
  - Adjusted time hours: `timetakenAdjusted`
  - Logged/work date: `Whe_` (epoch millis)
  - Agent FK: `whoagentid` (-> `UNAME.Unum`)
  - Billable flag: `ActIsBillable`
  - Non-billable bucket: `nonbilltime`
  - Billing plan id: `ActionBillingPlanID` (no standalone plan-name table was
    found; there is no simple `No Charge` lookup — see No Charge caveat below)

### No Charge exclusion caveat

No dedicated billing-plan name table (mapping `ActionBillingPlanID` -> a
"No Charge" label) was located via read-only schema discovery. Until a reliable
source is confirmed, report No Charge time as "not returned separately" rather
than fabricating a join. Do not invent a billing-plan table/column.

## Discovery-first policy

The "Schema facts already known" section above was confirmed against this Halo
instance. Trust those ids/tables and skip re-discovery unless a query errors or
returns unexpected results. If you do re-verify, confirm:

1. Ticket type ids for `Project` (5) and `Project Task` (20).
2. Status id for `New (email)` (1) or user-specified status.
3. Parent-child link: child `faults.fmainprojectid = <project Faultid>`
   (and remember `fmainprojectid = Faultid` means unlinked).
4. Budget rows in `FaultBudget` joined to `BudgetType` for hours.
5. Agent ids in `UNAME` (`Unum`) for the role mapping.
6. No `No Charge` plan-name lookup is known — see caveat above.

If any required schema cannot be confirmed, stop and report exactly what is missing. Do not fabricate table or column names.

## Working queries

These ran successfully against this Halo instance. Adjust the status id and
project-id list as needed. Re-discover only if one of these errors.

### 1. Project list (parent Project tickets, status filter)

```sql
SELECT TOP 50
  f.Faultid,
  f.Symptom,
  f.areaint,
  a.Aareadesc,
  f.Status,
  f.dateoccured
FROM faults f
LEFT JOIN AREA a ON a.Aarea = f.areaint
WHERE f.RequestTypeNew = 5
  AND f.Status = 1            -- New (email); change for other statuses
  AND (f.FDeleted = 0 OR f.FDeleted IS NULL)
ORDER BY f.dateoccured DESC
```

### 2. Budget rows for the project ids

```sql
SELECT TOP 100
  fb.FBTfaultid,
  bt.BTname,
  fb.FBThours
FROM FaultBudget fb
LEFT JOIN BudgetType bt ON bt.BTid = fb.FBTbtid
WHERE fb.FBTfaultid IN (<project id list>)
  AND fb.FBTbtid IN (3, 5)   -- 3 = Development (Tech), 5 = Admin (PM)
ORDER BY fb.FBTfaultid
```

### 3. Confirm child Project Tasks linked to the projects

```sql
SELECT TOP 50
  c.Faultid,
  c.fmainprojectid,
  c.Symptom
FROM faults c
WHERE c.RequestTypeNew = 20
  AND c.fmainprojectid IN (<project id list>)
-- NOTE: excludes self-referencing rows automatically, since a project's own
-- id never appears here unless a task genuinely points to it.
```

### 4. Actuals by project and role (only mapped users, child tasks)

```sql
SELECT TOP 100
  c.fmainprojectid AS project,
  CASE
    WHEN act.whoagentid IN (14, 20, 25) THEN 'Technician'
    WHEN act.whoagentid = 56 THEN 'Admin'
  END AS role,
  SUM(ISNULL(act.timetaken, 0)) AS ptd_hours,
  SUM(CASE WHEN act.Whe_ >= <window_start_millis>
           THEN ISNULL(act.timetaken, 0) ELSE 0 END) AS weekly_hours
FROM ACTIONS act
INNER JOIN faults c ON c.Faultid = act.Faultid
WHERE c.RequestTypeNew = 20
  AND c.fmainprojectid IN (<project id list>)
  AND act.whoagentid IN (14, 20, 25, 56)   -- mapped users only
GROUP BY c.fmainprojectid,
  CASE
    WHEN act.whoagentid IN (14, 20, 25) THEN 'Technician'
    WHEN act.whoagentid = 56 THEN 'Admin'
  END
ORDER BY c.fmainprojectid
```

### 5. Resolve / re-confirm user ids (only if mapping is in doubt)

```sql
SELECT TOP 50 Unum, uname, ufirstname, ulastname
FROM UNAME
WHERE Unum IN (13, 14, 20, 23, 25, 56, 57)
ORDER BY Unum
```

### Run learnings

- All sampled New (email) projects had `fmainprojectid IS NULL` on the parent
  and no child Project Task pointing back, so PTD/weekly actuals were 0 across
  the board. Time logged directly on the parent Project ticket is excluded by
  rule (actuals come only from child Project Tasks).
- Only one sampled project had any `FaultBudget` rows; the rest were No Scope.
- `timetaken` is frequently NULL or 0 on automation/system actions
  (`whoagentid = 0`); always wrap in `ISNULL(..., 0)` and filter to mapped
  users.

## Calculation workflow

1. State assumptions for default status/window.
2. Use the confirmed ids/tables in "Schema facts already known"; run discovery
   queries only if a query errors or returns unexpected results.
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

Include `Client` (from `AREA.Aareadesc`) so leadership can scan by customer.
Reference each project as `<summary> (#<Faultid>)`.

| Project | Client | Status | Tech Used | Admin Used | Total Used | Weekly Hours | Cost Variance | Notes |
|---------|--------|--------|-----------|------------|------------|--------------|---------------|-------|
| <project> (#<id>) | <client> | 🟡 Warning; 🔵 No Activity | 85% | 20% | 70% | 0.0 | +$1,250 | Tech near budget |

## Detail

### <Project Name> (#<ticket id>)

| Role | Budget Hours | PTD Hours | Weekly Hours | Used | Budgeted Cost | PTD Cost | Variance | Role Status |
|------|--------------|-----------|--------------|------|---------------|----------|----------|-------------|
| Technician | 40.0 | 34.0 | 2.0 | 85% | $10,000 | $8,500 | -$1,500 | 🟡 Warning |
| Admin | 5.0 | 1.0 | 0.0 | 20% | $1,000 | $200 | -$800 | 🟢 OK |
| Total | 45.0 | 35.0 | 2.0 | 78% | $11,000 | $8,700 | -$2,300 | 🟢 OK |

Notes:
- <short note based on status, missing scope, weekly activity, or variance>

When many projects share the same status (e.g. several No Scope / No Activity
projects with zero actuals), you may group them into a single combined detail
block listing their ids, rather than repeating an identical table per project.

## Exclusions and caveats

- Excluded No Charge time: <hours if available, else "not returned separately">
- Excluded unmapped users: Laura (23), Heather (13), Michele (57), and any unrecognized users.
- Budget source: parent Project ticket Budget tab (`FaultBudget`), hours only.
- Parent-child: child Project Tasks link via `faults.fmainprojectid`; note any projects with no linked child tasks (actuals = 0).
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
