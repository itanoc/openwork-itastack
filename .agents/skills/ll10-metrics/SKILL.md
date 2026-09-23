---
name: ll10-metrics
description: |
  Build LL10 leadership scorecard metrics for James Schriever's support team using read-only OpenWork ITAStack Grafana Halo SQL tools.

  Triggers when user mentions:
  - "LL10 metrics"
  - "leadership scorecard"
  - "weekly scorecard"
  - "James team metrics"
  - "SLA triage"
  - "FCR"
metadata:
  route_default: daily
  route_max: high
  route_class: ll10_metrics
---

<<<ROUTE default=daily max=high class=ll10_metrics>>>

# LL10 Metrics

Use this skill to build weekly Level 10 (LL10) leadership scorecard metrics for James Schriever's support team.

## DO THIS FIRST — exact tool call

Your first substantive action is a tool call to `itastack_itastack_grafana`.
The `params` object MUST contain a `sql` key whose value is the full query
string. NEVER call with empty `params`. Copy this shape and replace the `sql`
string with the real query:

{"operation":"query_halo_sql","params":{"sql":"SELECT TOP 1 COUNT(*) AS TotalTickets FROM faults WHERE fdeleted = 0","limit":1}}

- The query text goes INSIDE `params.sql` as a string. `params` is never `{}`.
- If you get the error `query_halo_sql requires params.sql`, you forgot to put
  the query string in `params.sql`. Fix that one call and retry ONCE. Do not
  repeat the same empty call.
- Only say Grafana is unavailable if a `__describe__` call itself fails — never
  after a `requires params.sql` error (that error means the tool IS available).

## Output style

- Keep every section short.
- Use bullets over prose.
- Skip sections that do not apply.
- Expand only if the user asks for more detail.

## Goal

Build LL10 leadership scorecard metrics using OpenWork ITAStack Grafana query tools.

## Inputs

- Date range or lookback period.
- Any free-text context from chat.
- Use placeholders when known:
  - `{ticket_id}`
  - `{client_name}`
  - `{user_email}`
- If no date range is provided, default to last 7 days and state that assumption before the first tool call.

## Tools

Use only read-only OpenWork ITAStack Grafana tools:

- `itastack_itastack_grafana` operation `query_halo_sql`
- `itastack_itastack_grafana` operation `query_itglue_endpoint`

For LL10 metrics, use `itastack_itastack_grafana` operation `query_halo_sql`.

## Execution policy

- TOOL-FIRST: first substantive action must be a read-only Grafana SQL tool call.
- If date range is missing, say: `Assumption: using last 7 days.`
- Then immediately call `itastack_itastack_grafana` operation `query_halo_sql`
  with the SQL string in `params.sql` (see "DO THIS FIRST" above). `params` is
  never empty.
- SQL must be one bounded `SELECT TOP N` statement.
- Use `TOP 1` for aggregate metric queries.
- Do not perform web research.
- Do not summarize workflow instead of querying data.
- Do not mutate reports, dashboards, tickets, ITGlue records, or any external system.
- Only if a `__describe__` call to `itastack_itastack_grafana` itself fails
  (tool genuinely unavailable), say:
  - `Grafana MCP tools are not available in this chat; enable the ITAStack/OpenWork Grafana tool and retry.`
  - A `requires params.sql` error does NOT mean the tool is unavailable — it
    means you sent empty params; fix `params.sql` and retry.

## Capability gap

- Read-only Grafana MCP tools only.
- No dashboard/report mutation.
- No writes to HaloPSA or ITGlue.

## Stop conditions

- Stop if credentials, tenant, client, ticket identity, or timeframe is ambiguous and required.
- Stop if requested action would write data.
- Stop if SQL cannot be expressed as one bounded `SELECT TOP N`.

## Output sections

- Request understood
- Evidence gathered
- Recommended action
- Next step

## Metric owner

- James Schriever: Manager / 1st Line
- Agent ID: 14
- Metrics are team-based:
  - SLA triage %
  - 1-day close %
  - First Contact Resolution

## Team agents

| Agent | Agent ID |
|-------|----------|
| James Schriever | 14 |
| Kevin Casper | 20 |
| Laura Barbosa | 23 |
| Emilio | 70 |
| Riely Borek | 25 (through 2026-07-27 Pacific) |
| JP | 73 (from 2026-07-28 Pacific) |

Use date-aware team filters:

- Always include Agent IDs `14, 20, 23, 70`.
- Include Agent ID `25` when the metric cohort timestamp is before `2026-07-28T07:00:00` UTC.
- Include Agent ID `73` when the metric cohort timestamp is on or after `2026-07-28T07:00:00` UTC.
- For `f` ticket ownership, use `f.dateoccured` for triage and 1-business-day closure, and `f.datecleared` for FCR.
- For `a` action ownership, use `a.Whe_` as the cohort timestamp.

## Definitions

- SLA triage %:
  - Tickets created during business hours.
  - Mon-Fri, 7:30 AM-5:30 PM Pacific.
  - First agent action within 12 minutes.
  - Exclude outside-hours tickets.
- Tickets closed in 1 business day:
  - Open-cohort: scope to tickets CREATED in the period
    (`dateoccured` within period), regardless of when they cleared.
    Do NOT also filter on `datecleared` within period -- that creates
    survivorship bias by silently excluding slow tickets that close
    after the window, inflating the rate toward 100%.
  - Denominator = closed tickets opened in the period (`Status IN
    (8, 9)`). A ticket opened in-period but still open counts as a
    fail (it did not close within 1 business day).
  - Pass = closed on the same business day it was opened OR by the end
    of the next business day (calendar-based, Pacific). Weekends skip
    to the following Monday.
  - Example: opened Fri -> next business day is Mon; opened Mon ->
    next business day is Tue.
- First Contact Resolution:
  - Closed tickets with exactly one non-deleted appointment.
  - `APdeleted = 0`.
  - Exclude tickets with zero appointments from denominator.
- Standard ticket filters:
  - `fdeleted = 0`
  - `RequestTypeNew NOT IN (5, 20, 22, 26, 30, 50)`
- Closed ticket:
  - `Status IN (8, 9)`
  - `datecleared` within period

## Schema notes

- HaloPSA stores all datetimes in UTC.
- Use `AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'` for business-hours filtering.
- Correct columns:
  - Appointment deleted flag: `APdeleted`
  - Appointment ticket FK: `APFaultid`

## Query rules

- Replace `@PERIOD_DAYS` with actual lookback days before executing.
- If user supplies explicit dates, replace relative date predicate with bounded date predicates.
- Keep each query as one bounded `SELECT TOP N` statement.
- If a query fails, note error and continue with remaining metrics where possible.

## Query 1 - Team triaged within 12 minutes

```sql
SELECT TOP 1
    COUNT(*) AS TotalTickets,
    SUM(CASE
        WHEN DATEDIFF(MINUTE, f.dateoccured, FirstAction.FirstActionTime) <= 12
        THEN 1 ELSE 0
    END) AS TriagedWithin12Min,
    CAST(100.0 *
        SUM(CASE
            WHEN DATEDIFF(MINUTE, f.dateoccured, FirstAction.FirstActionTime) <= 12
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
    AS DECIMAL(5,1)) AS PctTriaged
FROM faults f
CROSS APPLY (
    SELECT TOP 1 a.Whe_ AS FirstActionTime
    FROM ACTIONS a
    WHERE a.Faultid = f.Faultid
      AND a.whoagentid > 0
    ORDER BY a.actionnumber ASC
) AS FirstAction
CROSS APPLY (
    SELECT CAST(f.dateoccured AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time' AS DATETIME) AS LocalCreated
) AS tz
WHERE f.fdeleted = 0
  AND (f.Assignedtoint IN (14, 20, 23, 70)
       OR (f.Assignedtoint = 25 AND f.dateoccured < '2026-07-28T07:00:00')
       OR (f.Assignedtoint = 73 AND f.dateoccured >= '2026-07-28T07:00:00'))
  AND f.dateoccured >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE())
  AND f.RequestTypeNew NOT IN (5, 20, 22, 26, 30, 50)
  AND DATEPART(WEEKDAY, tz.LocalCreated) NOT IN (1, 7)
  AND CAST(tz.LocalCreated AS TIME) BETWEEN '07:30:00' AND '17:30:00'
```

## Query 2 - Team closed in 1 business day

Open-cohort: denominator is every ticket OPENED in the period (no
`datecleared` filter). Pass = closed on the same business day it was
opened OR by the end of the next business day (calendar-based, Pacific;
weekends skip to Monday). Tickets still open, or closed after the next
business day, count as fails.

```sql
SELECT TOP 1
    COUNT(*) AS TotalOpenedInPeriod,
    SUM(CASE
        WHEN f.status IN (8, 9) AND tz.CloseDate <= nbd.NextBizDay
        THEN 1 ELSE 0
    END) AS ClosedBySameOrNextBizDay,
    CAST(100.0 *
        SUM(CASE
            WHEN f.status IN (8, 9) AND tz.CloseDate <= nbd.NextBizDay
            THEN 1 ELSE 0
        END)
        / NULLIF(COUNT(*), 0)
    AS DECIMAL(5,1)) AS PctClosedSameOrNextBizDay
FROM faults f
CROSS APPLY (
    SELECT CAST(CAST(f.dateoccured AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time' AS DATETIME) AS DATE) AS OpenDate,
           CAST(CAST(f.datecleared AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time' AS DATETIME) AS DATE) AS CloseDate
) AS tz
CROSS APPLY (
    SELECT CASE DATEPART(WEEKDAY, tz.OpenDate)
        WHEN 6 THEN DATEADD(DAY, 3, tz.OpenDate)  -- Fri -> Mon
        WHEN 7 THEN DATEADD(DAY, 2, tz.OpenDate)  -- Sat -> Mon
        ELSE DATEADD(DAY, 1, tz.OpenDate)
    END AS NextBizDay
) AS nbd
WHERE f.fdeleted = 0
  AND (f.Assignedtoint IN (14, 20, 23, 70)
       OR (f.Assignedtoint = 25 AND f.dateoccured < '2026-07-28T07:00:00')
       OR (f.Assignedtoint = 73 AND f.dateoccured >= '2026-07-28T07:00:00'))
  AND f.dateoccured >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE())
  AND f.RequestTypeNew NOT IN (5, 20, 22, 26, 30, 50)
```

## Query 3 - Team FCR

```sql
SELECT TOP 1
    COUNT(*) AS TotalClosed,
    SUM(CASE WHEN appt.AppointmentCount >= 1 THEN 1 ELSE 0 END) AS FCR_Eligible,
    SUM(CASE WHEN appt.AppointmentCount = 1 THEN 1 ELSE 0 END) AS FCR_Count,
    CAST(100.0 *
        SUM(CASE WHEN appt.AppointmentCount = 1 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN appt.AppointmentCount >= 1 THEN 1 ELSE 0 END), 0)
    AS DECIMAL(5,1)) AS FCR_Pct
FROM faults f
CROSS APPLY (
    SELECT COUNT(*) AS AppointmentCount
    FROM APPOINTMENT ap
    WHERE ap.APFaultid = f.Faultid
      AND ap.APdeleted = 0
) AS appt
WHERE f.fdeleted = 0
  AND (f.Assignedtoint IN (14, 20, 23, 70)
       OR (f.Assignedtoint = 25 AND f.datecleared < '2026-07-28T07:00:00')
       OR (f.Assignedtoint = 73 AND f.datecleared >= '2026-07-28T07:00:00'))
  AND f.status IN (8, 9)
  AND f.datecleared >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE())
  AND f.RequestTypeNew NOT IN (5, 20, 22, 26, 30, 50)
```

## Final dashboard format

```markdown
# LL10 Metrics - {date range}

## James Schriever - Team Performance
| Metric | Value |
|--------|-------|
| % tickets triaged within 12 min | X% (N/M) |
| % tickets closed in 1 business day | X% (N/M) |
| First Contact Resolution | X% (N FCR of M tickets w/ appointment) |

## Notes & Flags
- Flag failed queries.
- Flag empty denominators.
- Flag concerning low percentages.
- Flag schema/tool limitations.
```

## Version

- Version: 1.0.0-openwork
- Created: 2026-06-14
