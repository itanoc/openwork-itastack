---
name: halo-ticket-research
description: |
  Research a HaloPSA ticket with OpenWork ITAStack tools and web research, then produce concise technician-facing resolution steps.

  Triggers when user mentions:
  - "research Halo ticket"
  - "HaloPSA ticket guide"
  - "solve ticket"
---

# Halo Ticket Research

Use this skill to research one HaloPSA ticket and produce concise, read-only, technician-facing steps to resolve the issue.

## Goal

Research a HaloPSA ticket using ticket context plus web research by default. Produce a concise step-by-step guide for solving the problem.

## Inputs

- `ticket_id`: Halo ticket ID.
- `client_name`: Client or organization name.
- `user_email`: User email address.
- Any free-text context from chat.

## Tools

- `itastack_itastack_halo` operation `get_ticket`
- `itastack_itastack_halo` operation `actions.list`
- `itastack_list_available_services`
- `webfetch`
- OpenWork built-in browser tools for external websites:
  - Use only after explicit user approval, because it opens visible browser UI.
  - Always start with `openwork_browser_open_url` after approval.
  - Use returned `browser_url` and `target_id` with browser tools.
- OpenWork extension tools:
  - If required capability is missing, inspect `openwork_extension_list_actions` before saying unavailable.

## Citation Rules

- Final answer must not include raw tool IDs, operation IDs, bracket-number citations, or internal source markers.
- Use tool results as evidence, but write evidence in plain text.
- For web research, include normal source URLs only when useful.
- Do not cite internal tool calls.

## Workflow

1. Identify required ticket, client, tenant, user, asset, and timeframe.
   - If ticket identity, client identity, tenant, or user is ambiguous, ask one concise clarification question and stop.

2. Fetch Halo ticket first with `itastack_itastack_halo` operation `get_ticket`:
   - `ticket_id`: provided ticket ID
   - `include_actions`: `true`
   - `slim`: `false`
   - `max_note_chars`: `8000`
   - `max_actions`: `0`

3. Extract ticket context:
   - `summary`
   - `details`
   - `client_name` or `client_info.name`
   - `client_id` from ticket response — end customer only, not MSP/agent org
   - requester / user
   - asset references
   - dates / timeframe
   - full `actions` list
   - concatenate non-empty action `note` fields into `actions_text`

4. Stop conditions:
   - If ticket fetch returns restricted/CMMC, 403/forbidden, or 404/not found, stop and report exact condition.
   - If provided `client_name` conflicts with fetched ticket client, stop and ask one clarification question.
   - Do not guess missing client IDs, tenant codes, user emails, or assets.
   - If action history is truncated, state that and ask before relying on incomplete history.

5. Use web research by default:
   - Search symptoms, exact error messages, vendor docs, known issues, patches, workarounds, and best practices.
   - Prefer recent authoritative sources: vendor docs, Microsoft/vendor KBs, release notes, known issue pages, reputable technical references.
   - Prefer background-safe research: use `webfetch` for known URLs and use any available non-UI search extension if present.
   - Do not open the visible OpenWork browser for search unless the user explicitly allows browser UI.
   - If search is needed and no background search tool/extension is available, ask: “Open visible browser for web search, or provide a URL?”
   - Never paste client-identifying details, user emails, internal hostnames, logs, or ticket text into public web searches. Search generic errors, product names, and vendor terms.
   - Record useful source URLs and what each contributed.

6. Analyze ticket context plus web findings:
   - reported problem
   - prior actions
   - affected users/assets
   - business impact
   - recurring pattern
   - likely cause
   - safest practical fix
   - risks / rollback if relevant

7. Produce concise technician guide:
   - Ground each step in ticket evidence or web research.
   - Use bullets over prose.
   - Keep sections short.
   - Mark assumptions explicitly.
   - If safe fix is not clear, output “Need more data” with exact missing data.

8. If deeper investigation is needed, gather specific evidence with current service dispatchers instead of the deprecated ticket investigation helper:
   - Use `itastack_itastack_halo` operation `actions.list` when ticket action history is incomplete.
   - Use the relevant ITAStack dispatcher only after identifying the required tenant/service from ticket evidence.
   - Stop and ask when tenant, client, user, asset, PBX, mailbox, or service scope is ambiguous.
   - Treat empty/null results as context, not failure.

## Guardrails

- Read-only against Halo, client systems, cloud tenants, phone systems, mailboxes, RMM assets, configs, and scripts.
- Local generated artifacts are allowed only when requested or clearly useful.
- Stop if credentials, tenant, client, ticket identity, or user identity is ambiguous.
- Stop if requested action would write data.
- Do not use the deprecated ticket investigation helper; it is not available in the current dispatcher toolset.
- Use `ticket_description` and `actions_text` from `get_ticket` plus targeted dispatcher reads instead.
- Always use ticket end-customer `client_id`; never MSP org ID, agent ID, or guessed ID.
- Use `user_email` only to disambiguate requester/affected user; do not override ticket data without evidence.
- For outage-risk, destructive, tenant-wide, billing/license, DNS/mail-routing, or security-policy changes, include precheck, rollback, and require human approval.
- Never store secrets, tokens, passwords, bearer strings, OAuth credentials, or private logs in artifacts.

## Artifact Paths

Write generated artifacts only when requested or clearly useful:

- Ticket research reports: `artifacts/tickets/`
- Web search notes: `artifacts/web-search/`
- Screenshots: `artifacts/tickets/`

## Output Format

```md
## Problem summary
- ...

## Evidence gathered
- Ticket:
  - ...
- Web:
  - URL — what it contributed

## Step-by-step solution guide
1. ...
2. ...
3. ...

## Verification / next step
- ...
- Optional: offer live service/API investigation if needed.
```

## Examples

- “Research Halo ticket 12345 for Acme, user jane@example.com.”
- “Use ticket 98765 and make tech steps. Client is Contoso.”
- “Solve ticket 45678; do web research first, no live tenant checks unless needed.”
