---
name: vsa-offline
description: |
  List VSA agents that have not checked in for a configurable number of days using read-only ITAStack VSA REST inventory data.

  Triggers when user mentions:
  - "offline VSA agents"
  - "stale VSA agents"
  - "agents not checked in"
  - "agent activity audit"
---

# VSA Offline Agent Report

Use this skill to investigate offline or stale VSA agents from REST inventory check-in data.

## Output style

- Be extremely concise.
- Sacrifice grammar for concision.
- Short sections only.
- Bullets over prose.
- Skip sections that do not apply.
- Expand only if user asks.

## Goal

Identify VSA agents that have not checked in for a specified number of days.

## Inputs

Use placeholders when known:

- `{ticket_id}`
- `{client_name}`
- `{user_email}`
- free-text context from user
- optional `{days_threshold}`; default `90`

## Trigger boundary

Use for:

- offline VSA agents
- stale VSA agents
- agents not checked in
- agent activity audits
- machines offline for X days

Important distinction:

- “Offline agents” here means stale REST inventory check-in.
- It does not mean live connectivity troubleshooting.

## Allowed tools

Strict tool boundary. Use only:

- `itastack_vsa_list_agents`
- `question` only when one concise clarification or next-step choice is required

Do not call:

- subagents
- browser or web tools
- file tools
- bash or shell tools
- VSA Data Warehouse tools
- generic execution tools
- other ITAStack tool families

If the user explicitly asks for a separate DWH-backed investigation, stop and confirm scope first.

## Capability gaps

- VSA Data Warehouse is not used by this skill.
- REST inventory check-in data only.
- Agent deletion unavailable via OpenWork VSA REST tools.

If a gap applies, state it before fallback path.

## Workflow

### 1. Determine scope

Identify:

- days threshold
- client or organization, if provided
- ticket, user, asset, or timeframe if relevant

If missing identifiers block the workflow, ask one concise clarification question.

Defaults:

- If no threshold provided, use `90` days.
- If threshold is invalid, use `90` days.
- If no client provided, audit all returned agents.

### 2. Fetch inventory

Call `itastack_vsa_list_agents` with:

```json
{"limit": 0}
```

If the tool fails or is unavailable:

- report exact failure briefly
- stop

### 3. Filter agents

Client-side filtering only.

For each agent:

- read `last_check_in_time`
- calculate elapsed days from today
- keep agents where elapsed days are greater than or equal to threshold
- if `last_check_in_time` missing or invalid, list separately as “Unknown check-in”
- if `{client_name}` provided, match against available organization/client fields

Sort stale agents by days offline, most stale first.

### 4. Format report

Produce user-facing output only.

Do not include:

- internal reasoning
- hidden tool-call transcript
- implementation details
- raw tool output

## Output sections

Use only sections that apply.

### Request understood

- Threshold: `{days_threshold}` days
- Scope: `{client_name or all clients}`
- Source: VSA REST inventory

### Evidence gathered

- Total agents checked: N
- Stale agents found: N
- Unknown check-in: N
- Oldest stale check-in: date / days offline

If stale agents found, include compact table:

| Agent | Agent ID | Last Check-in | Days Offline | Organization |
|---|---:|---|---:|---|

Rules:

- Max 20 rows by default.
- Say “showing top 20” if more.
- Highlight `180+ days` as removal-review candidates.

If zero stale agents:

- Confirm all checked agents are within threshold.

### Recommended action

- Review stale agents with client/team.
- For `180+ days`: consider VSA console cleanup.
- Warning: deleting VSA entry does not uninstall agent software from endpoint.

### Next step

Offer one concise next step:

- “Export CSV”
- “Show all rows”
- “Filter to one client”
- “Stop here”

Use `question` only if choosing the next step would materially change the workflow. Otherwise, ask in chat.

## Stop conditions

- Stop if VSA REST inventory tool fails.
- Stop if tenant, client, ticket, or requested identity is ambiguous and needed.
- Stop if user requests write/delete action.
- Stop if requested scope requires DWH but user has not approved separate DWH investigation.

## Write gate

Not applicable. Workflow is read-only.

## Examples

User:

> Show offline VSA agents for 90+ days.

Action:

- Use 90-day threshold.
- Fetch all VSA agents.
- Report stale agents.

User:

> Audit stale agents for Acme over 180 days.

Action:

- Use 180-day threshold.
- Fetch all VSA agents.
- Filter to Acme when organization fields allow.
- Report stale agents and cleanup candidates.
