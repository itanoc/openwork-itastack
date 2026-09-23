---
name: halo-ticket-research
description: |
  Research a HaloPSA ticket with OpenWork ITAStack tools, personal Ticket Guides, and web research, then produce concise technician-facing resolution steps.

  Triggers when user mentions:
  - "research Halo ticket"
  - "HaloPSA ticket guide"
  - "solve ticket"
metadata:
  route_default: daily
  route_max: high
  route_class: ticket_research
---

<<<ROUTE default=daily max=high class=ticket_research>>>

# Halo Ticket Research

## DO THIS FIRST (before reading anything else)

1. Look at the message that invoked this skill. If it contains a ticket number (any integer, e.g. `68458`), that IS the ticket ID.
2. If you have a ticket ID: IMMEDIATELY call the tool `itastack_itastack_halo` with `operation` = `get_ticket` and params `{ "ticket_id": <id>, "slim": true, "include_actions": true, "slim_actions": true, "max_actions": 20 }`. Do this as your very first action. Do NOT write an intro. Do NOT say "please provide the ticket ID." Do NOT ask for anything. Just emit the tool call.
3. Only if there is genuinely NO number anywhere in the invocation, reply with exactly one line: "Which Halo ticket ID should I research?" and stop.

Everything below is detail for after you have made that first tool call.

---

Use this skill to research one HaloPSA ticket and produce concise, read-only, technician-facing steps to resolve the issue.

## Goal

Research a HaloPSA ticket using ticket context, personal Ticket Guides, and web research by default. Produce a concise step-by-step guide for solving the problem.

## Inputs

- `ticket_id`: Halo ticket ID.
- `client_name`: Client or organization name.
- `user_email`: User email address.
- Any free-text context from chat.

## Tools

How to call Halo: there is a single tool named `itastack_itastack_halo`. You do NOT call `get_ticket` as a tool. Instead, call the tool `itastack_itastack_halo` and pass the operation name in the `operation` parameter. `itastack_itastack_halo` is a tool, not a skill — do not try to "load" it.

IMPORTANT — fetch the ticket with this ONE call. It returns the header plus a compact action history (each action trimmed to 5 fields), small enough to never truncate. Never call `get_ticket` with `slim: false` — that returns the full action objects and the output gets truncated/saved to a file.

Single fetch call:

```json
{
  "tool": "itastack_itastack_halo",
  "operation": "get_ticket",
  "params": { "ticket_id": <id> }
}
```

This returns the header fields plus an `actions` array where each action already has only these five fields: `note`, `outcome`, `who`, `datetime`, `new_status_name`. Treat the non-empty `note` fields as the ticket history. The server does the trimming — you do not need to ignore extra fields.

If the result is ever truncated, re-call with a smaller `max_actions` (try `10`, then `5`). NEVER save the output to a file and NEVER hand it to the explore/Task agent — just lower `max_actions` and re-call.

If you cannot find or call the tool, do NOT ask the user to re-supply the ticket ID. The tool `itastack_itastack_halo` is always available — call it with the `operation` parameter as shown above.

- `itastack_itastack_halo` (operation `get_ticket`) — fetch the ticket header (compact actions can be retrieved separately via `actions.list`).
- `itastack_itastack_halo` (operation `actions.list` with `slim: true`) — fetch MORE history than `max_actions` returned, if needed
- `itastack_list_available_services`
- `itastack_ckb_query` — semantic search over company knowledge base prose (tech-stack standards and process/policy). Use for one scoping call (see Step 5b). NOT the technical fix.
- `glob`, `grep`, and `read` for local `memory/guides/` Ticket Guides
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

0. Fast path — act immediately:
   - If a ticket ID is already present in the user's message or chat context, DO NOT ask for it and DO NOT post the generic intro. Go straight to Step 2 and call `get_ticket` now.
   - Missing `client_name` or `user_email` is NOT a reason to stop. They are optional and can be derived from the ticket. Only ask a clarification question when the ticket ID itself is missing or genuinely ambiguous (e.g., two different IDs given).
   - Only show the "please provide the Halo ticket ID" prompt when no ticket ID was provided at all.

1. Identify required ticket, client, tenant, user, asset, and timeframe.
   - If no ticket ID was provided, ask one concise clarification question and stop.
   - If a ticket ID is provided, proceed to Step 2 without asking — even if client or user are unknown.

2. Fetch the ticket FIRST using the exact single call in the Tools section above. Do not invent your own params.
   - `operation` = `get_ticket`, params `{ "ticket_id": <id>, "slim": true, "include_actions": true, "slim_actions": true, "max_actions": 20 }` → header + compact action history in one call.
   - NEVER use `get_ticket` with `slim: false` — it overflows and gets saved to a file.
   - If the result is truncated, re-call with smaller `max_actions` (10, then 5). Never save to a file or hand to the explore/Task agent.
   - This is a real tool call, not a skill load. Do not announce that you will research, then stop — actually emit the call now.

3. Use these fields as evidence:
   - Header: `summary`, `client_name`, `client_id` (end customer only, not MSP/agent org), `user_name`/requester, `site_name`, `category_1`, dates (`dateoccurred`, `fixbydate`), `status_id`.
   - `actions` array: each action already has only `note`, `outcome`, `who`, `datetime`, `new_status_name`. Treat the non-empty `note` fields as the ticket history.

4. Stop conditions (these are the ONLY reasons to stop after a ticket ID is given):
   - Ticket fetch returns restricted/CMMC, 403/forbidden, or 404/not found → stop and report the exact condition.
   - Provided `client_name` clearly conflicts with the fetched ticket client → stop and ask one clarification question.
   - In every other case, keep going. Missing client ID, tenant code, user email, or asset is NOT a stop condition — just note it as unknown and continue. Do not guess these values; proceed with what the ticket gives you.
   - If action history is still truncated after lowering `max_actions` to 5, note that in your output and continue with what you have. Do not save to a file or use another agent.

5. Check personal Ticket Guides before web research:
   - Look under `memory/guides/` after ticket fetch and stop-condition checks.
   - If the directory does not exist or no guide matches, continue normally.
   - Search guide filenames and content using product, vendor, symptom, error, service, asset type, and other ticket-derived signals. Local lookup may use full ticket-derived context.
   - Treat matching Ticket Guides as starting points, not authority.
   - If a guide is stale, vendor-sensitive, security-related, outage-risk, destructive, tenant-wide, or uncertain, validate with current vendor docs, web research, or read-only service checks before recommending steps.
   - Do not save, update, or create Ticket Guides during research unless the technician explicitly approves the save prompt and then approves the drafted guide.

5b. Make ONE company knowledge base (CKB) call before web research, aimed at the TECH STACK:
   - First name the ticket's technology area from its summary/category (e.g. VoIP/phones, firewall/network, email, backup, antivirus, RMM).
   - Then call `itastack_ckb_query` ONCE with a query that asks for the ITA standard vendor/product for that area, e.g. literally:
     `{"tool": "itastack_ckb_query", "operation": null, "params": {"query": "ITA technology stack standard vendor for <technology area>"}}`
     Example for a VoIP ticket: query `"ITA technology stack standard vendor for VoIP phone system"`. One call only — do not query the CKB again later.
   - The CKB is an INTERNAL source. It does exactly two things, and is NEVER the technical fix:
     1. Tech-stack facts → identify the SPECIFIC ITA vendor/product for this ticket, then search the web for THAT product by name. ITA standards: VoIP/phones = 3CX (on AWS Lightsail, SIP via VoIP Innovations, SMS via Telnyx); firewall/switch/Wi-Fi = Fortigate; hypervisor = Hyper-V; backup = Veeam to Synology NAS + VSPC; AV/EDR = Bitdefender; SIEM = Blumira; vuln mgmt = Tenable; RMM = Kaseya VSA; email/licensing = Microsoft 365 + Pax8. You MUST name the matching product in your output and search the web for it specifically (e.g. "3CX", "Bitdefender", "Fortigate") instead of generic terms ("VoIP", "antivirus", "firewall").
     2. Policy/process guidance → shape HOW the guide is framed and the routing/next-step language (e.g. a client-facing update is required on every client-facing ticket; escalation needs brief, complete, documented troubleshooting; BSS clients have a 2-hour remote-time finance-approval gate).
   - The actual technical fix still comes from Ticket Guides + web/vendor docs — never from the CKB.
   - Privacy: ticket-derived signals may be used locally for this CKB call (same as Ticket Guides), but never paste CKB content into web searches.
   - If the CKB returns nothing relevant, continue normally.

6. Always do web research before writing the guide. Follow this order exactly:
   - a. Search symptoms, exact error messages, vendor docs, known issues, patches, workarounds, and best practices. Use the SPECIFIC ITA vendor/product you identified in Step 5b (e.g. 3CX for VoIP). Prefer recent authoritative sources: vendor docs, Microsoft/vendor KBs, release notes, known-issue pages.
   - b. To research, use `webfetch` on the vendor's OWN documentation/KB URL directly (e.g. `https://www.3cx.com/docs/`, `https://learn.microsoft.com/...`). Do NOT `webfetch` a Google/Bing search-results URL — those return no usable content. If you don't know the exact doc URL, fetch the vendor's docs root and navigate from there. This is background-safe and needs no approval — use it directly.
   - c. Do NOT open the visible OpenWork browser unless the user explicitly approves browser UI.
   - d. Only if you have no usable URL to fetch AND no background search tool is available, ask one question: "Open visible browser for web search, or provide a URL?" Otherwise, do not ask — just fetch.
   - Privacy rule for every search: never paste client names, user emails, internal hostnames, logs, or ticket text. Search only generic errors, product names, and vendor terms.
   - Record useful source URLs and what each contributed.

7. Analyze ticket context plus Ticket Guide and web findings:
   - reported problem
   - prior actions
   - affected users/assets
   - business impact
   - recurring pattern
   - likely cause
   - safest practical fix
   - risks / rollback if relevant

8. Produce concise technician guide:
   - Ground each step in ticket evidence, Ticket Guide content, or web research.
   - Use bullets over prose.
   - Keep sections short.
   - Mark assumptions explicitly.
   - If safe fix is not clear, output "Need more data" with exact missing data.

9. If deeper investigation is needed, gather specific evidence with current service dispatchers:
   - Use `itastack_itastack_halo` operation `actions.list` when ticket action history is incomplete.
   - Use the relevant ITAStack dispatcher only after identifying the required tenant/service from ticket evidence.
   - If tenant, client, user, asset, PBX, mailbox, or service scope is ambiguous, skip that specific lookup and note it as a recommended next step — do not stop the whole task.
   - Treat empty/null results as context, not failure.

## Guardrails

- Read-only against Halo, client systems, cloud tenants, phone systems, mailboxes, RMM assets, configs, and scripts.
- Local generated artifacts are allowed only when requested or clearly useful.
- Stop only if the requested action would write data, or if the ticket ID itself is missing/ambiguous. (See Step 4 for the full, short list of stop conditions. Unknown client/user/asset is never a stop condition.)
- Always use ticket end-customer `client_id`; never MSP org ID, agent ID, or guessed ID.
- Use `user_email` only to disambiguate requester/affected user; do not override ticket data without evidence.
- For outage-risk, destructive, tenant-wide, billing/license, DNS/mail-routing, or security-policy changes, include precheck, rollback, and require human approval.
- Never store secrets, tokens, passwords, bearer strings, OAuth credentials, or private logs in artifacts.
- Ticket Guides stay personal/local in `memory/guides/` by default; do not present them as team standards.
- Saved Ticket Guides must be redacted. Do not include client names, user emails, hostnames, IPs, tenant IDs, raw logs, passwords, secrets, or full ticket text.
- Saving a Ticket Guide is a 3-step gate. Never skip a step:
  1. After delivering the guide, IF (and only if) the research produced a reusable fix/diagnostic pattern, add the one-line save footnote (see Output Format).
  2. Only if the technician replies yes, draft the redacted guide content and show it for review. Do not write any file yet.
  3. Only after the technician approves that draft, write the file to `memory/guides/`.
- If unsure whether the result is reusable, do not add the footnote.

## Artifact Paths

Write generated artifacts only when requested or clearly useful:

- Ticket research reports: `artifacts/tickets/`
- Web search notes: `artifacts/web-search/`
- Screenshots: `artifacts/tickets/`

## Memory Paths

- Personal Ticket Guides: `memory/guides/`
- Use flat, searchable filenames, for example `memory/guides/m365-shared-mailbox-send-as-failure.md`.

## Output Format

Always output these four sections in this order, every time, and then the save footnote line. Use bullets, keep it short. The output is NOT complete until you have decided about the footnote — do not stop after "Verification / next step".

```md
## Problem summary
- ...

## Evidence gathered
- Ticket:
  - ...
- Ticket Guides:
  - matched guide path, updated/verified date, and what it contributed; or "No matching Ticket Guide found."
- Company KB:
  - tech-stack fact or policy that shaped the search terms / framing; or "No relevant company KB result."
- Web:
  - URL — what it contributed

## Step-by-step solution guide
1. ...
2. ...
3. ...

## Verification / next step
- ...

This might be helpful in the future. Want me to save it as a Ticket Guide?
```

(The save-footnote line above is the required last step — include it per the footnote rule. Do NOT emit any HTML comments or template scaffolding.)

Footnote rule — this is a MANDATORY final step, not optional polish. After "Verification / next step", you MUST decide whether the research produced a reusable fix or diagnostic pattern:
- A reusable pattern is ANY troubleshooting that another tech could reuse on a similar future ticket: a vendor product issue, a recurring error, a hardware fault (e.g. UPS/battery, printer, server), a config fix, a how-to. Most resolved tickets qualify. When in doubt, treat it as reusable and add the footnote.
- If reusable: end your message with EXACTLY this one line and nothing after it: "This might be helpful in the future. Want me to save it as a Ticket Guide?"
- Only omit the footnote if the ticket is purely informational with no reusable steps (e.g. "what is my password policy"). If you omit it, add no other closing line.

## Ticket Guide Save Draft

After the technician approves the save footnote, draft the proposed guide and ask for final approval before writing it to `memory/guides/`.

Required guide content:

- Title
- Product/vendor
- Problem pattern
- Redacted symptoms/errors
- Diagnostic checks
- Safe fix steps
- Verification steps
- Risk level
- Rollback or validation notes, if relevant
- Source ticket ID only if safe to store
- Source URLs, if used
- Created, updated, and last verified dates

## Examples

- “Research Halo ticket 12345 for Acme, user jane@example.com.”
- “Use ticket 98765 and make tech steps. Client is Contoso.”
- “Solve ticket 45678; do web research first, no live tenant checks unless needed.”
