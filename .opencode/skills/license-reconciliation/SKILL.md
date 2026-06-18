---
name: license-reconciliation
description: |
  Run read-only ITAStack license reconciliation across Microsoft 365 and HaloPSA for one target license, defaulting to BUSINESS_PREMIUM.

  Triggers when user mentions:
  - "license reconciliation"
  - "Business Premium reconciliation"
  - "reconcile M365 and Halo licenses"
  - "verify license counts"
  - "SPB license audit"
---

# License Reconciliation

Use this skill to reconcile one target license across Microsoft 365 and HaloPSA using read-only OpenWork ITAStack tools.

## Operating mode

- Concise, target-license-only report.
- Read-only only.
- Confirm ITAStack services once per run.
- Query Halo once with a bounded target-license SQL query.
- Gather M365 license summaries for in-scope tenants.
- Optional Pax8 checks only after M365/Halo mapping reveals a procurement follow-up.
- Do not include raw tool output in final report.

## Default target

Default license: `BUSINESS_PREMIUM`.

For `BUSINESS_PREMIUM`:

- M365 target SKU: `SPB`.
- Halo target rows match any of:
  - `lproductsku = 'SPB'`
  - `lvendorproductsku = 'SPB'`
  - `LDesc LIKE '%Business Premium%'`
  - `lproductsku = 'MST-NCE-103-C100'`
  - `lvendorproductsku = 'CFQ7TTC0LCHC-0002'`
- Treat Halo nonprofit/donation descriptions containing `Business Premium` as target rows.
- Do not treat M365 `O365_BUSINESS_PREMIUM` as Business Premium unless source evidence explicitly says Microsoft 365 Business Premium.
- Ignore non-target SKUs silently.

If user requests another target license and aliases are unknown, ask one concise mapping question before querying.

## Allowed tools

Use only read-only tools:

- `itastack_list_available_services`
- `itastack_itastack_m365` operation `get_subscribed_skus`
- `itastack_itastack_grafana` operation `query_halo_sql`

Optional targeted Pax8 tools:

- `itastack_itastack_pax8` operation `companies.list`
- `itastack_itastack_pax8` operation `subscriptions.list`
- `itastack_itastack_pax8` operation `products.list`
- `itastack_itastack_pax8` operation `products.get`

Do not call write-capable ITAStack tools.

## Safety limits

- Do not create, update, delete, write notes, open tickets, update subscriptions, change licenses, change groups, or change users.
- Do not run broad all-license Halo queries.
- Halo SQL must be target-license-bounded and use `TOP 300` or lower.
- Do not call `itastack_itastack_pax8` operation `subscriptions.list` with `limit=0`.

## Workflow

### 1. Confirm services

Call `itastack_list_available_services` with:

```json
{"verbose": true}
```

Continue only if M365 and Grafana/Halo are available. If one is unavailable, report unavailable source and stop.

### 2. Choose scope

- Default target: `BUSINESS_PREMIUM`.
- Default tenant scope: all configured M365 tenants returned by service discovery.
- If many tenants are configured, process all unless user asks for a smaller batch.
- Keep track of processed tenants in the report.

### 3. Collect M365 counts

For each in-scope tenant, call `itastack_itastack_m365` with top-level `tenant: "<tenant>"`, operation `get_subscribed_skus`, and empty `params`.

For `BUSINESS_PREMIUM`, extract only rows where `sku_part_number` or `skuPartNumber` is `SPB`.

Use:

- `prepaid_units.enabled` or `prepaidUnits.enabled` as M365 Purchased.
- `consumed_units` or `consumedUnits` as M365 Assigned.

### 4. Collect Halo counts

For `BUSINESS_PREMIUM`, call `itastack_itastack_grafana` operation `query_halo_sql` with `limit: 300` and:

```sql
SELECT TOP 300
  l.LID,
  l.LDesc,
  l.LCount,
  l.lconsumedcount,
  l.Larea AS ClientId,
  a.aareadesc AS ClientName,
  l.LSite,
  l.LTenantName,
  l.LDeleted,
  l.LIsActive,
  l.lproductsku,
  l.lvendorproductsku
FROM dbo.Licence l
LEFT JOIN dbo.AREA a ON a.Aarea = l.Larea
WHERE ISNULL(l.LDeleted, 0) = 0
  AND ISNULL(l.LIsActive, 1) = 1
  AND (
    l.LDesc LIKE '%Business Premium%'
    OR l.lproductsku = 'SPB'
    OR l.lvendorproductsku = 'SPB'
    OR l.lproductsku = 'MST-NCE-103-C100'
    OR l.lvendorproductsku = 'CFQ7TTC0LCHC-0002'
  )
ORDER BY a.aareadesc, l.LID
```

If exactly 300 rows return, note possible cap and recommend narrower read-only follow-up. Do not broaden query in same run.

### 5. Map tenants to Halo clients

Default tenant alias map:

| Tenant | Halo client aliases |
|--------|---------------------|
| `ita` | Integrated Tech, ITA, IT Assurance |
| `wei` | Wei |
| `rce` | RCE |
| `awwi` | American Water Works, AWWI |
| `ager` | Ager |
| `amwp` | Advanced Metal |
| `ccc` | Capital Credit |
| `cpti` | Columbia Power |
| `lcc` | Life Care |
| `omwp` | Oregon Manufacturing, OMWP |
| `qbfw` | QB Fabrication, QBFW |
| `sitm` | SITM |
| `tcfn` | TCFN |
| `rmcn` | RMCN, Raimore |

Match priority:

1. Exact `ClientName` or `LTenantName` match.
2. Alias map match.
3. Count match between M365 purchased and Halo count.
4. NCE/vendor alias row if it is only confident Business Premium row for client.

Ambiguous target-shaped Halo rows are not automatic discrepancies. Put missing mapping fact in `Next Actions`.

### 6. Classify

Use exactly one category per tenant/client/license:

- `Count Discrepancy`: confident M365 purchased differs from canonical Halo count.
- `Assignment Overrun`: M365 assigned exceeds M365 purchased.
- `Halo Consumption Overrun`: Halo consumed exceeds Halo count.
- `Duplicate/Stale Halo Row`: multiple active Halo target rows exist for same client/license.
- `Mapping Ambiguity`: target-shaped row exists but tenant/client mapping unresolved.
- `Match`: confident M365 and Halo counts agree.

High-risk:

- Assignment Overrun.
- Halo Consumption Overrun.
- Active duplicate/stale row that could affect billing.
- Mapping ambiguity involving active paid license rows.

Duplicate/stale caution:

- Use all active candidate LIDs and counts when judging duplicates.
- Do not call a row stale unless evidence proves inactive, superseded, deleted, non-billing, or otherwise non-canonical.
- If stale is inferred only because another row matches M365, mark confidence `unverified` in `Next Actions` or rationale text.

## Final report format

Use these sections only.

### 1. Executive Summary

Max 5 bullets:

- Target license.
- Systems checked.
- Tenants checked.
- Findings by category.
- High-risk count.

### 2. Findings

Include only non-match categories.

Columns only:

```text
Tenant | Client | Category | Target License | M365 Purchased | M365 Assigned | Halo Count | Halo Consumed | Delta | Severity
```

No `Evidence` or `Recommended Action` columns.

### 3. Matched Target Licenses

Target-license matches only.

Columns only:

```text
Tenant | Client | Target License | M365 Purchased | M365 Assigned | Halo Count | Halo Consumed
```

### 4. Reclassification Rationale

Include only when continuing prior report and changing earlier classification.

Use bullets:

- Prior claim → final classification; confidence; source facts used; remaining gap.

### 5. Next Actions

Read-only follow-up checks or human remediation steps.

Prefer bullets. If table needed, columns only:

```text
Tenant/Client | Action | Reason | Owner
```

Include exact missing fact for unresolved mapping issues.

## Final check

Before responding:

- Every processed tenant appears in Findings, Matched Target Licenses, or Next Actions.
- High-risk count includes high-risk Findings and high-risk Next Actions.
- No stale/duplicate/canonical claim lacks evidence or confidence.
- No `0 high-risk` claim when high-risk exists.
