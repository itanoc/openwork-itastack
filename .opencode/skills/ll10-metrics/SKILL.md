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
---

# LL10 Metrics

Use this skill to build weekly Level 10 (LL10) leadership scorecard metrics for James Schriever's support team.

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
- Then immediately call `itastack_itastack_grafana` operation `query_halo_sql`.
- SQL must be one bounded `SELECT TOP N` statement.
- Use `TOP 1` for aggregate metric queries.
- Do not perform web research.
- Do not summarize workflow instead of querying data.
- Do not mutate reports, dashboards, tickets, ITGlue records, or any external system.
- If `itastack_itastack_grafana` operation `query_halo_sql` is unavailable, say:
  - `Grafana MCP tools are not available in this chat; enable the ITAStack/OpenWork Grafana tool and retry.`

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
| Riely Borek | 25 |
| Emilio | 70 |

Use team filters:

- `f.Assignedtoint IN (14, 20, 23, 25, 70)`
- `a.whoagentid IN (14, 20, 23, 25, 70)` where action ownership matters

## Definitions

- SLA triage %:
  - Tickets created during business hours.
  - Mon-Fri, 7:30 AM-5:30 PM Pacific.
  - First agent action within 12 minutes.
  - Exclude outside-hours tickets.
- Tickets closed in 1 business day:
  - Closed tickets where `datecleared` is within 24 hours of `dateoccured`.
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
  AND f.Assignedtoint IN (14, 20, 23, 25, 70)
  AND f.dateoccured >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE())
  AND f.RequestTypeNew NOT IN (5, 20, 22, 26, 30, 50)
  AND DATEPART(WEEKDAY, tz.LocalCreated) NOT IN (1, 7)
  AND CAST(tz.LocalCreated AS TIME) BETWEEN '07:30:00' AND '17:30:00'
```

## Query 2 - Team closed in 1 business day

```sql
SELECT TOP 1
    COUNT(*) AS TotalClosed,
    SUM(CASE
        WHEN DATEDIFF(HOUR, f.dateoccured, f.datecleared) <= 24
        THEN 1 ELSE 0
    END) AS ClosedIn1Day,
    CAST(100.0 *
        SUM(CASE
            WHEN DATEDIFF(HOUR, f.dateoccured, f.datecleared) <= 24
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
    AS DECIMAL(5,1)) AS PctClosedIn1Day
FROM faults f
WHERE f.fdeleted = 0
  AND f.Assignedtoint IN (14, 20, 23, 25, 70)
  AND f.status IN (8, 9)
  AND f.datecleared >= DATEADD(DAY, -@PERIOD_DAYS, GETDATE())
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
  AND f.Assignedtoint IN (14, 20, 23, 25, 70)
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
