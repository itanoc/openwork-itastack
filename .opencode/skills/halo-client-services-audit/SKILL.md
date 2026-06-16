---
name: halo-client-services-audit
description: |
  Audit HaloPSA tickets for one client with read-only ITAStack Halo SQL and produce a concise services-value report.

  Triggers when user mentions:
  - "Halo client services audit"
  - "services-value report"
  - "audit HaloPSA tickets for a client"
---

# Halo Client Services Audit

Use this skill to audit HaloPSA ticket volume and logged work for one Halo client and produce a concise MSP account-conversation report.

## Goal

Produce a Markdown services-value report for one client by Halo client ID or client name:

- tickets per month
- ticket-type breakdown
- source breakdown
- top categories
- hours of work logged per month
- short narrative for an MSP account conversation

## Inputs

- `client`: Halo client ID / `faults.Areaint` positive integer, for example `244`, or Halo client name.
- `lookback_months`: optional integer `1-60`; default `12` when blank or invalid.
- If the user provides only one number, treat it as `client_id` and use default `lookback_months = 12`.
- If the user provides text that is not a positive integer, treat it as a client name and resolve it before running audit queries.

## Tool

Use only these OpenWork ITAStack tools:

- `itastack_halo_search_clients`
- `itastack_grafana_query_halo_sql`

Use `itastack_halo_search_clients` only for client-name resolution. Use `itastack_grafana_query_halo_sql` for all audit queries.

Tool call shape:

```json
{
  "sql": "SELECT TOP N ...",
  "limit": 100
}
```

## Execution Policy

- TOOL-FIRST:
  - If the user provides a numeric client ID, first substantive action must be `itastack_grafana_query_halo_sql` identity query from workflow step 3.
  - If the user provides a client name, first substantive action must be `itastack_halo_search_clients` client-name lookup from workflow step 2.
- Do not summarize without data.
- If `itastack_grafana_query_halo_sql` is unavailable, say exactly:
  `ITAStack Grafana Halo SQL tool is not available in this OpenWork session.`
  Then stop.
- Read-only. Do not call write tools or mutation tools.

## Defaults and Assumptions

- If `lookback_months` is blank or non-numeric, default to `12`. State assumption.
- Clamp `lookback_months` to integer range `1-60`.
- Treat resolved `client_id` as Halo `faults.Areaint`.
- Halo datetimes are UTC. Group by UTC calendar month. Do not convert timezone.
- Window is rolling `N` months using `DATEADD(month, -<N>, GETUTCDATE())`; monthly rows may span `N + 1` calendar buckets because the first and current months can be partial.
- Monthly trend buckets run from the UTC month containing the rolling start date through the UTC month containing the end date.
- Average-per-month headline metrics use the rolling `N`-month denominator, even when monthly trend has `N + 1` calendar rows.
- Action-level work time uses `ACTIONS.timetaken` hours.
- Billable-only time uses `SUM(timetaken WHERE ActIsBillable=1)`.
- MSSQL column names are case-insensitive; use canonical casing below.

## Schema Facts

- Tickets table: `faults`
  - PK: `Faultid`
  - Client FK: `Areaint`
  - Type id: `RequestTypeNew`
  - Status: `Status`
  - Created: `dateoccured`
  - Closed: `datecleared`
  - Source: `FRequestSource`
  - Deleted flag: `FDeleted` (`0=active`, `1=deleted`)
  - Summary: `Symptom`
- Category columns on `faults` are denormalized text:
  - `category2`, `category3`, `category4`, `category5`
  - Use `category2` as primary user-facing category.
  - No `category1`, `Fcat1`, or `Fcategory1`. Do not invent.
- Ticket type names:
  - Join `faults.RequestTypeNew` to `REQUESTTYPE.RTid`.
  - Name column: `REQUESTTYPE.RTdesc`.
- Client name lookup:
  - `area.aareadesc`
  - `area.Aarea = faults.Areaint`
  - Not `areaname`; not `area.areaint`.
- Actions table: `ACTIONS`
  - FK: `Faultid`
  - Time: `timetaken`
  - Adjusted time: `timetakenAdjusted`
  - Billable flag: `ActIsBillable`
  - Timestamp: `Whe_`
  - Agent: `whoagentid`
  - Non-billable bucket: `nonbilltime`
  - Travel: `TravelTime`
- Source map:
  - `0=Email/Default`
  - `2=Phone`
  - `3=RMM/Automation`
  - `12=Other`
  - Unknown source IDs display as `Unknown (<id>)`.
- Status map:
  - `1=New (email)`
  - `2=Waiting`
  - `8=Resolved`
  - `9=Closed`
  - `24=Pre-Process`
  - `27=Scheduled`
  - `40=Closed-Silent`
  - `49=Waiting on User`
- Standard ticket filter: `FDeleted = 0`
- Do not exclude RMM alert tickets. Include `RequestTypeNew = 21`.

## Workflow

1. Validate inputs:
   - `client` is either a positive integer or non-empty client-name text.
   - `lookback_months` is integer `1-60`; default `12` if invalid.
   - If only one number is provided, treat it as `client_id` and assume `lookback_months = 12`.
   - Report window as: `from <UTC start date> to <UTC end date> (last N months)`.

2. Resolve client name when needed:

   If `client` is not a positive integer, call `itastack_halo_search_clients`:

   ```json
   {
     "search": "<client name>",
     "count": 10
   }
   ```

   Selection rules:

   - If zero matches, stop:

     ```text
     client name '<name>' not found in HaloPSA clients
     ```

   - If exactly one clear match exists, use that match's Halo client ID as `client_id`.
   - A clear match is an exact case-insensitive name match, or a single returned client whose name plainly matches the user's input with only punctuation, suffix, or abbreviation differences.
   - If multiple possible matches exist, ask the user to choose before running audit queries. Show only client names and IDs needed for selection.
   - Do not guess between similar client names.

3. Confirm client identity. First SQL tool call for numeric-input flow, or first SQL tool call after name resolution:

   ```sql
   SELECT TOP 2
     aareadesc AS client_name,
     Aarea AS client_id
   FROM area
   WHERE Aarea = <client_id>
   ```

   Use `limit: 2`.

   If zero rows, stop:

   ```text
   client_id <n> not found in HaloPSA area table
   ```

   If more than one row, stop:

   ```text
   client_id <n> resolved to multiple HaloPSA area rows
   ```

4. Totals roll-up:

   ```sql
   SELECT TOP 1
     (SELECT COUNT(*) FROM faults WHERE Areaint = <id> AND FDeleted = 0) AS total_alltime,
     (SELECT COUNT(*) FROM faults WHERE Areaint = <id> AND FDeleted = 0 AND dateoccured >= DATEADD(month, -<N>, GETUTCDATE())) AS total_window,
     (SELECT MIN(dateoccured) FROM faults WHERE Areaint = <id> AND FDeleted = 0) AS first_ticket,
     (SELECT MAX(dateoccured) FROM faults WHERE Areaint = <id> AND FDeleted = 0) AS last_ticket
   FROM (SELECT 1 AS x) z
   ```

   Use `limit: 1`.

5. Tickets per month:

   ```sql
   SELECT TOP 100
     YEAR(dateoccured) AS yr,
     MONTH(dateoccured) AS mo,
     COUNT(*) AS tickets
   FROM faults
   WHERE Areaint = <id>
     AND FDeleted = 0
     AND dateoccured >= DATEADD(month, -<N>, GETUTCDATE())
   GROUP BY YEAR(dateoccured), MONTH(dateoccured)
   ORDER BY yr, mo
   ```

   Use `limit: 100`.

6. Ticket type breakdown:

   ```sql
   SELECT TOP 50
     f.RequestTypeNew AS type_id,
     ISNULL(rt.RTdesc, '(unknown)') AS type_name,
     COUNT(*) AS n
   FROM faults f
   LEFT JOIN REQUESTTYPE rt ON rt.RTid = f.RequestTypeNew
   WHERE f.Areaint = <id>
     AND f.FDeleted = 0
     AND f.dateoccured >= DATEADD(month, -<N>, GETUTCDATE())
   GROUP BY f.RequestTypeNew, rt.RTdesc
   ORDER BY n DESC
   ```

   Use `limit: 50`.

7. Source breakdown:

   ```sql
   SELECT TOP 20
     FRequestSource AS src,
     COUNT(*) AS n
   FROM faults
   WHERE Areaint = <id>
     AND FDeleted = 0
     AND dateoccured >= DATEADD(month, -<N>, GETUTCDATE())
   GROUP BY FRequestSource
   ORDER BY n DESC
   ```

   Use `limit: 20`.

8. Top categories:

   ```sql
   SELECT TOP 20
     ISNULL(NULLIF(category2, ''), '(none)') AS category,
     COUNT(*) AS n
   FROM faults
   WHERE Areaint = <id>
     AND FDeleted = 0
     AND dateoccured >= DATEADD(month, -<N>, GETUTCDATE())
   GROUP BY category2
   ORDER BY n DESC
   ```

   Use `limit: 20`.

9. Hours logged per month:

   ```sql
   SELECT TOP 100
     YEAR(a.Whe_) AS yr,
     MONTH(a.Whe_) AS mo,
     COUNT(*) AS actions,
     SUM(CAST(a.timetaken AS float)) AS hours_logged,
     SUM(CASE WHEN a.ActIsBillable = 1 THEN CAST(a.timetaken AS float) ELSE 0 END) AS hours_billable,
     SUM(CAST(a.timetakenAdjusted AS float)) AS hours_adjusted
   FROM ACTIONS a
   INNER JOIN faults f ON f.Faultid = a.Faultid
   WHERE f.Areaint = <id>
     AND f.FDeleted = 0
     AND a.Whe_ >= DATEADD(month, -<N>, GETUTCDATE())
   GROUP BY YEAR(a.Whe_), MONTH(a.Whe_)
   ORDER BY yr, mo
   ```

   Use `limit: 100`.

10. Compute from returned data only:
   - `tickets/month = total_window / N` using the rolling `N`-month denominator.
   - `tickets/week = total_window / (N * 4.345)`
   - `hours/month = SUM(hours_logged) / N` using the rolling `N`-month denominator.
   - `hours/week = SUM(hours_logged) / (N * 4.345)`
   - Same averages for billable hours.
   - Alert/human split:
     - alerts = ticket type count where `type_id = 21`
     - human = `total_window - alerts`
   - Use `total_alltime`, `first_ticket`, and `last_ticket` in the header context line; do not leave roll-up fields unused.

11. Build zero-filled monthly trend:
    - Include every calendar month from the UTC month containing the rolling start date through the UTC month containing the end date.
    - If no tickets or hours for a month, show `0`.
    - Expect a rolling `N`-month window to sometimes show `N + 1` rows because start and end months may both be partial.

## Output Format

Markdown only. Tables over prose. Short sections.

```md
# Audit: <client_name> (Halo client_id <id>)

Data pulled <UTC date>. Window: last <N> months (<UTC start> to <UTC end>).
All-time Halo tickets: <total_alltime>. First ticket: <first_ticket>. Last ticket: <last_ticket>.

## Headline numbers (last <N> months)

| Metric | Value |
|---|---:|
| Total tickets | <n> |
| Tickets/month avg (rolling <N>-month denominator) | <n.nn> |
| Tickets/week avg | <n.nn> |
| Hours logged | <n.nn> |
| Hours billable | <n.nn> |
| Avg hours/month logged (rolling <N>-month denominator) | <n.nn> |
| Avg hours/week logged | <n.nn> |
| Alert vs human ticket split | <alerts> alert / <human> human |

## Ticket type split

| Type | Count | Share |
|---|---:|---:|
| <type_name> | <n> | <pct>% |

## Source

| Source | Count |
|---|---:|
| <mapped source name> | <n> |

## Top categories

| Category | Count |
|---|---:|
| <category2 value> | <n> |

## Monthly trend

| Month | Tickets | Hours logged | Hours billable |
|---|---:|---:|---:|
| YYYY-MM | <n> | <n.nn> | <n.nn> |

## Narrative for the client conversation

<Short paragraph about raw consumption. Low ticket count means low recorded support usage. Keep factual.>

<Short paragraph about silent value. RMM/automation alerts show behind-the-scenes monitoring/remediation. Do not invent incidents.>

## Caveats

- `timetaken` and `timetakenAdjusted` may diverge.
- RMM alerts inflate ticket counts.
- `category2` may be empty on auto-closed alerts.
- Window uses UTC calendar months.
- Rolling `N`-month windows can span `N + 1` calendar month rows because first/current months may be partial.
- Monthly averages use the rolling `N`-month denominator, not the number of displayed calendar rows.
- Numbers reflect HaloPSA only; no other systems included.
```

Top categories: show top 10 only.

## Guardrails

- Read-only. Do not call write tools or mutation tools while executing audit.
- Stop if `client_id` resolves to zero rows.
- Do not fabricate numbers.
- If a query returns zero rows, show exact zero in table.
- Do not invent columns.
- If a query errors with `Invalid column name`, drop that section and add caveat:
  - `<section> omitted: invalid Halo column <column>.`
- Keep sections short. Expand only if asked.
