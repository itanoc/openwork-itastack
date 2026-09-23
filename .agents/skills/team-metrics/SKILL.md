---
name: team-metrics
description: |
  Build weekly technician and team KPI metrics using read-only OpenWork ITAStack Grafana Halo SQL tools.

  Triggers when user mentions:
  - "team metrics"
  - "weekly team report"
  - "performance dashboard"
  - "technician KPI"
  - "FCR"
metadata:
  route_default: daily
  route_max: high
  route_class: team_metrics
---

<<<ROUTE default=daily max=high class=team_metrics>>>

# Team Metrics

Use this skill to run weekly team performance metrics from HaloPSA data through OpenWork ITAStack Grafana MCP tools.

Do not use this skill for individual ticket research or ad-hoc troubleshooting. Use `ticket-summary` or `halo-ticket-research` instead.

## Output style

- Keep every section short.
- Use bullets over prose.
- Skip sections that do not apply.
- Expand only if the user asks for more detail.
- Keep each output section to five bullets or fewer unless detail is required.

## Goal

Build technician or team KPI metrics using read-only OpenWork ITAStack Grafana query tools.

## Inputs

- Date range or lookback period.
- Optional placeholders when provided:
  - `{ticket_id}`
  - `{client_name}`
  - `{user_email}`
- Any free-text context from chat.

Default:

- If no date range is provided, use last 7 days.
- Before first tool call, say: `Assumption: using last 7 days.`

Date handling:

- The report period is always anchored to the database clock (`GETDATE()`), not the wall-clock or any assumed year. The Halo DB may run a different year than you expect.
- Prefer the relative `@PERIOD_DAYS` / `DATEADD(DAY, -N, GETDATE())` pattern. It self-anchors to the DB clock and cannot drift to the wrong year.
- Only use explicit literal dates when the user gives a full month/day AND an explicit year. If the user gives month/day with no year (e.g. "July 19-25"), resolve the year from the DB clock: build the range relative to `GETDATE()` instead of hardcoding a year.
- `dateoccured`, `datecleared`, and `Whe_` are SQL `datetime` columns (the MCP tool serializes them to epoch-ms in its JSON output; do not compare them against integer epoch values in SQL).

## Required tools

Use only read-only OpenWork ITAStack Grafana tools:

- `itastack_itastack_grafana` operation `query_halo_sql`
- `itastack_itastack_grafana` operation `query_itglue_endpoint` only if ITGlue context is explicitly needed

For this workflow, use `itastack_itastack_grafana` operation `query_halo_sql`.

Tool call shape:

```json
{
  "operation": "query_halo_sql",
  "params": {
    "sql": "SELECT TOP 1 ...",
    "limit": 100
  }
}
```

## Execution policy

- TOOL-FIRST: first substantive action must be a read-only Grafana tool call.
- If date range is missing, state the last-7-days assumption, then immediately call `itastack_itastack_grafana` operation `query_halo_sql`.
- Use only `itastack_itastack_grafana` operations that match this workflow.
- Use one bounded read-only SQL query per tool call.
- Prefer `SELECT TOP 1` for aggregate metric queries.
- Do not perform web research.
- Do not summarize the workflow instead of querying Grafana.
- Do not mutate reports, dashboards, tickets, ITGlue records, or any external system.
- If `itastack_itastack_grafana` operation `query_halo_sql` is unavailable, say: `Grafana MCP tools are not available in this chat; enable the ITAStack/OpenWork Grafana tool and retry.`

## Capability gap

- Read-only Grafana MCP tools only.
- No dashboard/report mutation.
- No writes to HaloPSA or ITGlue.
- No direct Grafana dashboard edits.

If the user asks for a write or dashboard mutation, state the gap first, then give a read-only fallback path.

## Stop conditions

- Stop if required credentials, tenant, client, ticket identity, or timeframe is ambiguous.
- Stop if requested action would write data.
- Stop if required Grafana tool is unavailable.

## Output sections

Use these sections when applicable:

- Request understood
- Evidence gathered
- Recommended action
- Next step

For complete team reports, include:

- Total queries executed and success/failure count
- Compiled summary dashboard
- Any errors encountered with the failed section name
- Timestamp of report generation

## Team agents

| Name | Agent ID / Assignedtoint | Uname DB key / unum | Role |
|------|---------------------------|---------------------|------|
| James Schriever | 14 | 14 | Manager / 1st Line |
| Kevin Casper | 20 | 20 | 1st Line Support |
| Laura Barbosa | 23 | 23 | 1st Line Support / Triage / Dispatch |
| JP | 73 | 73 | 2nd Line Support |
| Emilio | 70 | 70 | 2nd Line Support (absorbed Riely's former queue) |

Departed agents:

- Riely Borek (25) is no longer with the company. Emilio (70) now owns that work. Riely is excluded from the active team filter.
- Only query agent 25 when explicitly investigating orphaned/unreassigned tickets that were never moved off Riely's ID. Do not include 25 in routine team reports.

Team agent filter:

- `f.Assignedtoint IN (14, 20, 23, 73, 70)`

## Definitions

- Closed ticket: `Status IN (8, 9)` and `datecleared` within the period.
- Standard ticket filters: `fdeleted = 0 AND RequestTypeNew NOT IN (5, 20, 22, 26, 30, 50)`.
- FCR: closed ticket completed after exactly one non-deleted appointment; denominator excludes closed tickets with zero non-deleted appointments.
- Closed in 1 business day: open-cohort metric. Denominator is tickets opened in the period. Pass = closed on the same Pacific business day or by the end of the next Pacific business day; weekends skip to Monday. Tickets still open or closed later count as fails.
- Closed in 2 business days: open-cohort metric. Denominator is tickets opened in the period. Pass = closed on the same Pacific business day or by the end of the second Pacific business day; weekends skip to Monday. Tickets still open or closed later count as fails.
- Appointment count source: `Appointment` where `APFaultid = f.Faultid` and `APdeleted = 0`.
- Onsite appointment: `apappointmenttype IN (5, 7)`.
- Billable hours: `ACTIONS.timetakenAdjusted` where `ActIsBillable = 1`; use this for technician KPI worked time, not invoice charge hours.
- HaloPSA datetimes are UTC.
- Convert business-hour filters with `AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'`.

## Schema notes

| Purpose | Correct column | Avoid |
|---------|----------------|-------|
| Appointment ticket FK | `APFaultid` | `Faultid` in `Appointment` |
| Appointment deleted flag | `APdeleted` |  |
| Appointment owner | `APunum` |  |
| Ticket assigned agent | `Assignedtoint` |  |
| Action owner | `whoagentid` |  |

## Query rules

- Replace `@PERIOD_DAYS` with the numeric lookback period before executing.
- If the user supplies explicit dates WITH a year, replace relative predicates with bounded start/end date predicates (`>= 'YYYY-MM-DD' AND < 'YYYY-MM-DD'`, end-exclusive).
- If the user gives month/day WITHOUT a year, do not hardcode a year. Resolve the range from the DB clock so it lands in the DB's current year, e.g. build start/end from `GETDATE()` (or `DATEFROMPARTS(YEAR(GETDATE()), MM, DD)`). Never assume the year is the wall-clock year.
- Sanity-check before reporting: if the whole team returns zero or near-zero volume for a period that should be busy, verify the period actually overlaps live data (e.g. compare against `GETDATE()`) before writing conclusions. Do not invent explanations for empty results caused by a wrong-year window.
- Keep each query as one bounded read-only `SELECT TOP N` query.
- Do not use `SET DATEFIRST`; use `DATENAME(WEEKDAY, ...) NOT IN ('Saturday', 'Sunday')` for weekday filtering.
- If one query fails, show the error, note it in the report, and continue to the next query.
- If Laura dispatch time times out, retry that single query once before reporting failure.

## Query 1 - Team-wide metrics

```sql
SELECT TOP 1
    SUM(CASE WHEN f.Status IN (8, 9) AND f.datecleared >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE()) THEN 1 ELSE 0 END) AS [Total Closed],
    SUM(CASE WHEN f.dateoccured >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE()) THEN 1 ELSE 0 END) AS [Total Opened],
    SUM(CASE WHEN f.dateoccured >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE()) AND f.Status IN (8, 9) AND tz.CloseDate <= nbd.NextBizDay THEN 1 ELSE 0 END) AS [Closed in 1 Biz Day Count],
    CAST(ROUND(100.0 * SUM(CASE WHEN f.dateoccured >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE()) AND f.Status IN (8, 9) AND tz.CloseDate <= nbd.NextBizDay THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN f.dateoccured >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE()) THEN 1 ELSE 0 END), 0), 1) AS DECIMAL(5,1)) AS [% Closed in 1 Biz Day],
    SUM(CASE WHEN f.dateoccured >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE()) AND f.Status IN (8, 9) AND tz.CloseDate <= nbd.SecondBizDay THEN 1 ELSE 0 END) AS [Closed in 2 Biz Days Count],
    CAST(ROUND(100.0 * SUM(CASE WHEN f.dateoccured >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE()) AND f.Status IN (8, 9) AND tz.CloseDate <= nbd.SecondBizDay THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN f.dateoccured >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE()) THEN 1 ELSE 0 END), 0), 1) AS DECIMAL(5,1)) AS [% Closed in 2 Biz Days],
    SUM(CASE WHEN f.Status IN (8, 9) AND f.datecleared >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE()) AND apt.AppointmentCount >= 1 THEN 1 ELSE 0 END) AS [FCR Eligible],
    SUM(CASE WHEN f.Status IN (8, 9) AND f.datecleared >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE()) AND apt.AppointmentCount = 1 THEN 1 ELSE 0 END) AS [FCR Count],
    CAST(ROUND(100.0 * SUM(CASE WHEN f.Status IN (8, 9) AND f.datecleared >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE()) AND apt.AppointmentCount = 1 THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN f.Status IN (8, 9) AND f.datecleared >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE()) AND apt.AppointmentCount >= 1 THEN 1 ELSE 0 END), 0), 1) AS DECIMAL(5,1)) AS [% FCR]
FROM faults f
CROSS APPLY (
    SELECT COUNT(*) AS AppointmentCount
    FROM Appointment a2
    WHERE a2.APFaultid = f.Faultid
      AND a2.APdeleted = 0
) apt
CROSS APPLY (
    SELECT CAST(CAST(f.dateoccured AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time' AS DATETIME) AS DATE) AS OpenDate,
           CAST(CAST(f.datecleared AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time' AS DATETIME) AS DATE) AS CloseDate
) tz
CROSS APPLY (
    SELECT CASE DATENAME(WEEKDAY, tz.OpenDate)
        WHEN 'Friday' THEN DATEADD(DAY, 3, tz.OpenDate)
        WHEN 'Saturday' THEN DATEADD(DAY, 2, tz.OpenDate)
        ELSE DATEADD(DAY, 1, tz.OpenDate)
    END AS NextBizDay,
    CASE DATENAME(WEEKDAY, tz.OpenDate)
        WHEN 'Thursday' THEN DATEADD(DAY, 4, tz.OpenDate)
        WHEN 'Friday' THEN DATEADD(DAY, 4, tz.OpenDate)
        WHEN 'Saturday' THEN DATEADD(DAY, 3, tz.OpenDate)
        WHEN 'Sunday' THEN DATEADD(DAY, 2, tz.OpenDate)
        ELSE DATEADD(DAY, 2, tz.OpenDate)
    END AS SecondBizDay
) nbd
WHERE f.fdeleted = 0
  AND f.RequestTypeNew NOT IN (5, 20, 22, 26, 30, 50)
  AND f.Assignedtoint IN (14, 20, 23, 73, 70)
  AND (
      f.dateoccured >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE())
      OR f.datecleared >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE())
  )
```

Display as:

## Team-Wide (Last 7 Days)

| Metric | Value |
|--------|-------|
| Total Tickets Closed | N |
| Total Tickets Opened | N |
| % Closed in 1 Business Day | X% (N/M) |
| % Closed in 2 Business Days | X% (N/M) |
| % First Contact Resolution | X% (N/M eligible) |

## Query 2a - JP FCR

```sql
SELECT TOP 1
    COUNT(*) AS [Total Closed],
    SUM(CASE WHEN apt.AppointmentCount >= 1 THEN 1 ELSE 0 END) AS [FCR Eligible],
    SUM(CASE WHEN apt.AppointmentCount = 1 THEN 1 ELSE 0 END) AS [FCR Count],
    CAST(ROUND(100.0 * SUM(CASE WHEN apt.AppointmentCount = 1 THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN apt.AppointmentCount >= 1 THEN 1 ELSE 0 END), 0), 1) AS DECIMAL(5,1)) AS [% FCR]
FROM faults f
CROSS APPLY (
    SELECT COUNT(*) AS AppointmentCount
    FROM Appointment a2 WHERE a2.APFaultid = f.Faultid AND a2.APdeleted = 0
) apt
WHERE f.fdeleted = 0
  AND f.Status IN (8, 9)
  AND f.RequestTypeNew NOT IN (5, 20, 22, 26, 30, 50)
  AND f.Assignedtoint = 73
  AND f.datecleared >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE())
```

## Query 2b - JP tickets closed

```sql
SELECT TOP 1 COUNT(*) AS [Tickets Closed]
FROM faults f
WHERE f.fdeleted = 0
  AND f.Status IN (8, 9)
  AND f.RequestTypeNew NOT IN (5, 20, 22, 26, 30, 50)
  AND f.Assignedtoint = 73
  AND f.datecleared >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE())
```

## Query 2c - JP onsites

```sql
SELECT TOP 1 COUNT(*) AS [Onsites]
FROM Appointment a
WHERE a.APdeleted = 0
  AND a.APunum = 73
  AND a.apappointmenttype IN (5, 7)
  AND a.APStartDate >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE())
  AND a.APStartDate < GETDATE()
```

Display as:

## JP (Last 7 Days)

| Metric | Value |
|--------|-------|
| % First Contact Resolution | X% |
| Tickets Closed | N |
| Onsites | N |

## Query 3a - Emilio FCR

```sql
SELECT TOP 1
    COUNT(*) AS [Total Closed],
    SUM(CASE WHEN apt.AppointmentCount >= 1 THEN 1 ELSE 0 END) AS [FCR Eligible],
    SUM(CASE WHEN apt.AppointmentCount = 1 THEN 1 ELSE 0 END) AS [FCR Count],
    CAST(ROUND(100.0 * SUM(CASE WHEN apt.AppointmentCount = 1 THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN apt.AppointmentCount >= 1 THEN 1 ELSE 0 END), 0), 1) AS DECIMAL(5,1)) AS [% FCR]
FROM faults f
CROSS APPLY (
    SELECT COUNT(*) AS AppointmentCount
    FROM Appointment a2 WHERE a2.APFaultid = f.Faultid AND a2.APdeleted = 0
) apt
WHERE f.fdeleted = 0
  AND f.Status IN (8, 9)
  AND f.RequestTypeNew NOT IN (5, 20, 22, 26, 30, 50)
  AND f.Assignedtoint = 70
  AND f.datecleared >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE())
```

## Query 3b - Emilio tickets closed

```sql
SELECT TOP 1 COUNT(*) AS [Tickets Closed]
FROM faults f
WHERE f.fdeleted = 0
  AND f.Status IN (8, 9)
  AND f.RequestTypeNew NOT IN (5, 20, 22, 26, 30, 50)
  AND f.Assignedtoint = 70
  AND f.datecleared >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE())
```

Display as:

## Emilio (Last 7 Days)

| Metric | Value |
|--------|-------|
| % First Contact Resolution | X% |
| Tickets Closed | N |

## Query 4 - Kevin Casper billable hours

```sql
SELECT TOP 1
    CAST(ROUND(COALESCE(SUM(a.timetakenAdjusted), 0), 1) AS DECIMAL(10,1)) AS [Billable Hours]
FROM ACTIONS a
WHERE a.whoagentid = 20
  AND a.ActIsBillable = 1
  AND a.Whe_ >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE())
```

Display as:

## Kevin Casper (Last 7 Days)

| Metric | Value |
|--------|-------|
| Billable Hours | X.X hrs |

## Query 5a - Laura Barbosa average triage time

```sql
SELECT TOP 1
    COUNT(*) AS [Tickets Triaged],
    CAST(ROUND(AVG(triageMin), 1) AS DECIMAL(10,1)) AS [Avg Triage (min)]
FROM (
    SELECT
        f.Faultid,
        CAST(DATEDIFF(MINUTE, f.dateoccured, fa.FirstLauraAction) AS FLOAT) AS triageMin
    FROM faults f
    CROSS APPLY (
        SELECT TOP 1 a.Whe_ AS FirstLauraAction
        FROM ACTIONS a
        WHERE a.Faultid = f.Faultid AND a.whoagentid = 23
        ORDER BY a.actionnumber ASC
    ) fa
    CROSS APPLY (
        SELECT
            CAST(f.dateoccured AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time' AS DATETIME) AS LocalCreated,
            CAST(fa.FirstLauraAction AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time' AS DATETIME) AS LocalAction
    ) tz
    WHERE f.fdeleted = 0
      AND f.RequestTypeNew NOT IN (5, 20, 22, 26, 30, 50)
      AND fa.FirstLauraAction >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE())
      AND DATEDIFF(MINUTE, f.dateoccured, fa.FirstLauraAction) BETWEEN 0 AND 540
      AND DATENAME(WEEKDAY, tz.LocalCreated) NOT IN ('Saturday', 'Sunday')
      AND (
          CAST(tz.LocalCreated AS TIME) BETWEEN '07:30:00' AND '12:30:00'
          OR CAST(tz.LocalCreated AS TIME) BETWEEN '13:30:00' AND '16:30:00'
      )
      AND (
          CAST(tz.LocalAction AS TIME) BETWEEN '07:30:00' AND '12:30:00'
          OR CAST(tz.LocalAction AS TIME) BETWEEN '13:30:00' AND '16:30:00'
      )
) sub
```

## Query 5b - Laura Barbosa average dispatch time

```sql
SELECT TOP 1
    COUNT(*) AS [Tickets Dispatched],
    CAST(ROUND(AVG(dispatchMin), 1) AS DECIMAL(10,1)) AS [Avg Dispatch (min)]
FROM (
    SELECT
        f.Faultid,
        CAST(DATEDIFF(MINUTE, fa.FirstLauraAction, f.dateassigned) AS FLOAT) AS dispatchMin
    FROM faults f
    CROSS APPLY (
        SELECT TOP 1 a.Whe_ AS FirstLauraAction
        FROM ACTIONS a
        WHERE a.Faultid = f.Faultid AND a.whoagentid = 23
        ORDER BY a.actionnumber ASC
    ) fa
    CROSS APPLY (
        SELECT CAST(fa.FirstLauraAction AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time' AS DATETIME) AS LocalAction
    ) tz
    WHERE f.fdeleted = 0
      AND f.RequestTypeNew NOT IN (5, 20, 22, 26, 30, 50)
      AND f.dateassigned IS NOT NULL
      AND fa.FirstLauraAction >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE())
      AND DATEDIFF(MINUTE, fa.FirstLauraAction, f.dateassigned) BETWEEN 0 AND 540
      AND DATENAME(WEEKDAY, tz.LocalAction) NOT IN ('Saturday', 'Sunday')
      AND (
          CAST(tz.LocalAction AS TIME) BETWEEN '07:30:00' AND '12:30:00'
          OR CAST(tz.LocalAction AS TIME) BETWEEN '13:30:00' AND '16:30:00'
      )
) sub
```

Display as:

## Laura Barbosa — Triage & Dispatch Times (Last 7 Days)

| Metric | Value |
|--------|-------|
| Avg Triage Time | X.X min (N tickets) |
| Avg Dispatch Time | X.X min (N tickets) |

## Final dashboard shape

# Team Metrics — Week of {date}

## Team-Wide

| Metric | Value |
|--------|-------|
| Total Tickets Closed | N |
| Total Tickets Opened | N |
| % Closed in 1 Business Day | X% (N/M) |
| % Closed in 2 Business Days | X% (N/M) |
| % First Contact Resolution | X% (N/M eligible) |

## JP

| Metric | Value |
|--------|-------|
| % FCR | X% |
| Tickets Closed | N |

## Emilio

| Metric | Value |
|--------|-------|
| % FCR | X% |
| Tickets Closed | N |

## Kevin Casper

| Metric | Value |
|--------|-------|
| Billable Hours | X.X hrs |

## Laura Barbosa

| Metric | Value |
|--------|-------|
| Avg Triage Time | X.X min |
| Avg Dispatch Time | X.X min |

## Version

- Version: 1.0.3
- Created: 2026-06-18
- Source: converted from Open WebUI prompt and sanitized agent-zero notes

## Changelog

- 1.0.0: Converted Open WebUI Grafana prompt to OpenWork skill using `itastack_itastack_grafana` read-only MCP operations. Removed bash, `sops-run.sh`, Open WebUI tool aliases, and direct Grafana API execution pattern.
- 1.0.1: Added required team-wide `% Closed in 2 Business Days` metric.
- 1.0.2: Replaced Riely Borek (agent 25) with JP (agent 73) in roster, team filter, and per-agent queries.
- 1.0.3: Added DB-clock date-anchoring guidance (resolve bare month/day against `GETDATE()`, never assume wall-clock year); noted `datetime` column types; added zero-volume sanity check; documented Riely (25) as departed with Emilio (70) absorbing the queue.
