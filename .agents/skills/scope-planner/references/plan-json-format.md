# Scope Plan JSON Format (Pre-Write)

Use this structure when preparing data for `scripts/write_scope.py` before workbook write-back.

## 1) Expected Top-Level Shape

```json
{
  "metadata": {
    "project_name": "Client - Project",
    "ticket_number": "12345",
    "prepared_by": "Technician Name",
    "date": "2026-03-31"
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

## 2) Task Line Requirements

Each task should include:
- `description` (clear, actionable)
- `time_min` (hours, typically 0.5 increments)
- `downtime` (`Yes`/`No`)
- `afterhours` (`Yes`/`No`)
- `location` (`remote`, `onsite`, `vendor`, `client`, `procurement`)

Use dependency callouts inside `description` when needed (e.g., `⚠️ DEPENDENCY: ISP cutover must complete first`).

## 3) Color/Location Metadata

`location` drives row color styling in the workbook:
- `remote` → blue
- `onsite` → purple
- `vendor` → red
- `client` → yellow
- `procurement` → green

If omitted, no location color is applied.

## 4) Parts / Dependencies / Comments

### `parts` entries
```json
{
  "description": "Firewall appliance",
  "quantity": 1,
  "part_number": "FG-100F",
  "url": "https://vendor.example/item",
  "price": 2200.0,
  "alternative": "FG-90G"
}
```

### `client_dependencies`
Summarize client actions required for schedule success (approvals, user comms, access windows).

### `vendor_dependencies`
Capture vendor coordination details that can block sequencing.

### `comments`
Use for context that should be retained but does not belong in task lines.

## 5) Quality Checks Before Write-Back

- Day plans are chronological and executable.
- Daily hours are realistic (target <= 8 where possible).
- Downtime/after-hours flags match actual impact.
- Dependencies are explicit enough for handoff.
- Metadata, parts, dependencies, and comments are populated (or intentionally blank).
