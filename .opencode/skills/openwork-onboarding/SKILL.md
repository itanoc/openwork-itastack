---
name: openwork-onboarding
description: |
  Guide first-time teammates through OpenWork Desktop onboarding, including teammate profile capture, HaloPSA agent lookup, AGENTS.md profile setup, safe file/browser checks, Claude Code presence, and dynamic MCP/report examples.

  Triggers when user mentions:
  - "OpenWork onboarding"
  - "onboard my team"
  - "teach teammates OpenWork"
---

# OpenWork Onboarding

Use this skill when a teammate needs a guided first-run walkthrough of OpenWork Desktop.

Goal: capture the teammate's workspace identity, fetch their HaloPSA agent details, add confirmed profile context near the top of `AGENTS.md`, prove OpenWork can safely create/edit files, use the built-in browser for browser automations, detect possible Claude Code overlap, and show how MCP/extensions can pull information into a report.

Audience: non-technical or mixed-technical team members using OpenWork for the first time.

This onboarding starts by capturing the teammate's basic work identity so future agents know who is using the workspace. It asks for first and last name, uses HaloPSA to fetch onboarding-safe agent details, then adds the confirmed profile near the top of `AGENTS.md` after explicit approval.

## Safety rules

- Do not read secrets, tokens, `.env` files, credential stores, shell history, browser cookies, or private logs.
- Do not modify global config unless the user explicitly approves the exact change.
- Treat teammate profile data as shared workspace context, not private memory. Before writing name, Halo agent ID, email, initials, teams, timezone, workday, or active status to `AGENTS.md`, tell the user that `AGENTS.md` is repo/shared workspace context and ask for explicit confirmation.
- Store only onboarding-safe HaloPSA fields in `AGENTS.md`. Do not paste the raw Halo agent payload, department role GUIDs, cost/rate fields, billing flags, phone/SMS fields, or third-party authorization flags.
- Do not guess HaloPSA agent details. If Halo lookup fails or has multiple matches, ask the user to choose or continue with unknown values.
- If Claude Code is not installed, continue silently.
- If Claude Code is installed, ask before changing anything related to Claude Code, Claude Code skills, or shared skill paths.
- Use harmless demo files under `onboarding/` in the current workspace.
- Use public browser checks only unless the user explicitly asks for an internal app check.
- Keep examples dynamic. Do not assume any specific MCP server, ticket system, or customer tool exists.

## Outputs

Create or update:

- `onboarding/openwork-demo.txt` — simple file creation/editing demo.
- `onboarding/openwork-onboarding-report.md` — run log and results.
- Optionally `onboarding/example-report.md` — sample report generated from available read-only MCP/extension data.
- `AGENTS.md` — update near the top with the confirmed onboarded teammate profile, unless the user declines.

If OpenWork shows a skill reload banner after this skill is installed or updated, reload skills before running onboarding.

## Required permissions

- Workspace write access for `onboarding/`.
- Built-in browser access for `https://example.com`.
- Shell access for OS and Claude Code detection.
- Read-only HaloPSA agent lookup access, or user-provided fallback values if Halo is unavailable.
- Optional: OpenWork UI actions for editor/navigation demos.
- Optional: extension/MCP action access for dynamic final demo.

## Onboarding workflow

### Start here: capture teammate profile first

Before explaining checks, detecting OS, creating files, opening browser, or discovering MCP/extensions, capture the teammate profile and handle the HaloPSA lookup in step 1 below. Do not run other onboarding checks until this profile step is complete, skipped because Halo is unavailable, or explicitly declined for `AGENTS.md` storage.

### Result capture schema

Record each check result immediately after it runs. Do not wait until the end and reconstruct from memory.

Use this shape in working notes and then write it into `onboarding/openwork-onboarding-report.md`:

```text
check: <name>
severity: blocker | warning | info
status: pass | fail | skipped | manual
evidence: <path, command output summary, page title, tool count, etc.>
error: <empty if none>
next_action: <what user should do next, if anything>
```

Severity rules:

- `blocker`: file create/edit fails or workspace cannot be written.
- `warning`: browser automation fails or editor demo cannot be shown.
- `info`: Claude Code absent, MCP/extensions absent, or optional demo skipped.

### 1. Capture teammate profile and update AGENTS.md

Capture teammate identity before running the technical checks. This is a required onboarding step; only the `AGENTS.md` write is optional if the user declines shared-context storage.

1. Ask for the teammate's first and last name.
2. Search HaloPSA agents with the full name using the read-only Halo agent list/search tool when available, e.g. `itastack_halo_list_agents` with `search: "<first> <last>"`.
3. From the selected Halo agent record, extract only onboarding-safe fields:

   - name
   - firstname
   - surname
   - id
   - email
   - initials
   - primary team (`team`)
   - team names from `teams[]`
   - timezone
   - workday name
   - active status derived from `isdisabled` when available

4. If exactly one likely agent matches, present the name, agent ID, email, initials, primary team, teams, timezone, workday, and active status for confirmation.
5. If multiple likely agents match, ask the user to choose the correct record. Show only enough fields to disambiguate: name, agent ID, email, primary team, and active status if available.
6. If no Halo agent matches, ask whether to continue with name only or retry with a different spelling/email.
7. Before writing to `AGENTS.md`, ask explicit confirmation:

   > I can add this profile near the top of `AGENTS.md`: name, Halo agent ID, email, initials, primary team, teams, timezone, workday, and active status. `AGENTS.md` is shared workspace/repo context, not private memory. Add it?

8. If confirmed, insert or update this exact marked block near the top of the root `AGENTS.md`, after the `# AGENTS.md` title and before `## Purpose` when possible:

   ```markdown
   <!-- openwork-onboarding:personal-profile:start -->
   ## Current OpenWork teammate profile

   - Name: <First Last>
   - First name: <first name>
   - Last name: <last name or surname without pronoun text when obvious>
   - Halo surname field: <raw Halo surname field when it includes useful pronoun text, or unknown>
   - Halo agent ID: <agent_id or unknown>
   - Email: <email or unknown>
   - Initials: <initials or unknown>
   - Primary team: <team or unknown>
   - Teams: <comma-separated team names or unknown>
   - Timezone: <timezone or unknown>
   - Workday: <workday_name or unknown>
   - Active in Halo: <true/false/unknown>
   - Source: OpenWork onboarding HaloPSA lookup

   <!-- openwork-onboarding:personal-profile:end -->
   ```

9. If the marked block already exists, replace only the content inside the markers. Do not rewrite unrelated `AGENTS.md` content.
10. If the user declines, do not write profile data to `AGENTS.md`; record the skip in the onboarding report.
11. If `AGENTS.md` cannot be written, stop and explain the workspace permissions problem before continuing.

Record profile capture in `onboarding/openwork-onboarding-report.md`:

- first and last name provided
- Halo lookup result: matched / multiple candidates / not found / unavailable
- selected Halo agent ID, email, initials, primary team, teams, timezone, workday, and active status, if confirmed
- `AGENTS.md` update status: updated / declined / failed

### 2. Explain what OpenWork will check

Tell the teammate:

> This onboarding records your confirmed teammate profile, uses HaloPSA to find your agent ID, email, initials, team memberships, timezone, workday, and active status, checks that OpenWork can create and edit files in this workspace, uses the built-in browser for browser automation, detects whether Claude Code is installed, and shows how available MCP/extensions can pull information into a report.

Explain the built-in browser:

> OpenWork includes a built-in browser panel. Agents can open websites, click buttons, fill forms, read page structure, and take screenshots. This enables browser automation for tasks like testing web apps, collecting public data, or walking through web workflows with your approval.

### 3. Detect OS

Use a safe OS check.

Preferred shell commands:

- macOS/Linux: `uname -s`
- Windows PowerShell: `$PSVersionTable.PSVersion; [System.Environment]::OSVersion.VersionString`

Record detected OS in `onboarding/openwork-onboarding-report.md`.

### 4. Check file create/edit access

Create directory and file:

`onboarding/openwork-demo.txt`

Initial file text:

```text
OpenWork onboarding demo

Step 1: OpenWork created this file in the workspace.
Step 2: OpenWork will edit this file to prove write access.
```

Then edit file by appending:

```text

Edit check: OpenWork updated this file successfully.
```

If write fails:

1. Stop onboarding.
2. Explain likely permissions issue.
3. Offer to open Settings > Permissions using OpenWork UI action `settings.panel.open` with `{panel:"permissions"}`.
4. Ask user to authorize current workspace or parent folder.

### 5. Demonstrate file editor

Open or direct user to `onboarding/openwork-demo.txt`.

Preferred behavior:

1. Call `openwork_ui_list_actions` first.
2. Use an exact editor/open-file action only if the returned action list contains one.
3. Do not invent OpenWork UI action IDs.
4. If no action exists, tell user: “Open `onboarding/openwork-demo.txt` from workspace file tree. You should see the created and edited text.”

Record editor demo status in report:

- opened with UI action
- manual open instructions given
- skipped because UI action unavailable

### 6. Check browser automation

Use the built-in browser tools.

1. Open `https://example.com` with `openwork_browser_open_url`.
2. Use returned `browser_url` and `target_id` for all browser calls.
3. Capture browser snapshot.
4. Verify title/text contains `Example Domain`.
5. Optional: take screenshot only if user wants visual proof.

Important: do not call `browser_navigate` first. OpenWork browser automation must start with `openwork_browser_open_url`, then use the returned `browser_url` and `target_id`.

Pass condition:

- Browser opens `example.com`.
- Snapshot includes `Example Domain`.

If check fails:

- Explain that OpenWork browser automation may be blocked by network, proxy, app state, or browser process issue.
- Suggest restarting OpenWork, clearing proxy if used, and trying again.
- Record failure and error in report.

### 7. Detect Claude Code and ask before blocking

Purpose: find whether Claude Code is installed and could introduce overlapping global skills or behavior.

Do not ask anything if Claude Code is not installed. Continue silently and record “not detected” in report.

Checks:

macOS/Linux:

```bash
command -v claude
claude --version
```

Windows PowerShell:

```powershell
where.exe claude
claude --version
```

If onboarding is being run from a non-Windows agent host for a Windows teammate, ask the Windows user to run the PowerShell commands locally and paste the output. Do not pretend the current macOS/Linux runtime proves Windows state.

If Claude Code is detected, explain:

> Claude Code appears installed. Some teams share Claude/OpenCode/OpenWork skill folders or global agent config. If overlapping skill paths are enabled, Claude Code skills may affect prompts or behavior in ways new teammates do not expect.

Then ask one targeted question:

> Do you want to leave Claude Code skills/config alone, or review options to isolate/block Claude Code skill paths for this onboarding environment?

Recommended answer: leave unchanged for onboarding unless the team has known overlap.

Safe options to present:

1. Leave unchanged — recommended for normal onboarding.
2. Inspect only — list likely Claude/OpenCode/OpenWork config paths and report possible overlap.
3. Written recommendation — create a note describing how to isolate skill paths manually.
4. Edit config — only after a second confirmation naming exact file and exact change.

Only after explicit approval, inspect relevant config paths. Never edit config automatically.

Possible config paths to inspect after approval:

- macOS/Linux: `~/.claude/`, `~/.config/opencode/`, workspace `.opencode/`
- Windows: `%USERPROFILE%\.claude\`, `%APPDATA%\opencode\`, workspace `.opencode\`

If blocking/isolation is requested, prefer documentation/manual instructions first. Any actual config edit needs a second confirmation naming exact file and change.

### 8. Discover dynamic MCP/extension capabilities

Do not assume any specific MCP server exists.

Use available discovery tools in this order:

1. `openwork_extension_list_actions` with no extension filter, if available. If the tool schema requires an argument, call it with `{ "extensionId": "" }`.
2. OpenWork UI action list if needed.
3. Built-in MCP/tool list known in current session.

Summarize available read-only actions in report. Group by likely use:

- tickets/support
- documents/files
- email/calendar
- cloud/admin
- databases/reporting
- unknown/other

If no MCP/extensions are configured, say:

> No custom MCP or extension actions were discovered in this session. You can add integrations in Settings > Extensions. Once connected, OpenWork can use those tools to pull information and write reports.

### 9. Give dynamic MCP-to-report example

If read-only MCP/extension actions are available, offer a safe demo:

1. Ask user which available data source to use.
2. Ask for a harmless query, such as one ticket ID, one document name, or a small recent-results limit.
3. Call only read-only actions.
4. Save concise result to `onboarding/example-report.md`.

Do not call actions whose names or descriptions imply mutation during onboarding, including:

- delete
- update
- create
- send
- post
- patch
- remove
- revoke
- retry
- upgrade
- archive
- restore

Exception: user explicitly switches from onboarding demo into a real task and confirms the exact action.

If ticket/helpdesk tools are available, example prompt:

> Pull ticket `<ticket-id>`, summarize status, requester, recent notes, and next action, then save it to `onboarding/example-report.md`.

If document/search tools are available, example prompt:

> Search for `<topic>`, summarize the top results, and save source links plus next steps to `onboarding/example-report.md`.

If email/calendar tools are available, example prompt:

> Find recent messages matching `<subject or sender>`, summarize what happened, and save it to `onboarding/example-report.md`.

If no tools are available, create a template-only `onboarding/example-report.md` showing how the flow will look once extensions are connected:

```markdown
# Example MCP Report

## Source

No MCP/extension source connected during onboarding.

## Example request

Pull a ticket, document, email thread, or system record with a read-only MCP tool.

## Example output

- Summary
- Key fields
- Recent activity
- Recommended next action
- Source references
```

### 10. Write final onboarding report

Create or update `onboarding/openwork-onboarding-report.md` with:

```markdown
# OpenWork Onboarding Report

## Environment

- OS: <detected>
- Workspace: <path>

## Teammate Profile

- Name: <First Last>
- First name: <first name>
- Last name: <last name>
- Halo surname field: <raw Halo surname field or unknown>
- Halo agent ID: <agent_id or unknown>
- Email: <email or unknown>
- Initials: <initials or unknown>
- Primary team: <team or unknown>
- Teams: <comma-separated team names or unknown>
- Timezone: <timezone or unknown>
- Workday: <workday_name or unknown>
- Active in Halo: <true/false/unknown>
- Halo lookup: <matched/multiple candidates/not found/unavailable>
- AGENTS.md update: <updated/declined/failed>

## Checks

| Check | Result | Notes |
| --- | --- | --- |
| File create | <pass/fail> | <path/error> |
| File edit | <pass/fail> | <path/error> |
| File editor demo | <pass/manual/skipped/fail> | <notes> |
| Browser automation | <pass/fail> | example.com snapshot result |
| Claude Code | <detected/not detected> | <version or blank> |
| Claude Code blocking | <not asked/left unchanged/review requested/changed> | <notes> |
| MCP/extensions | <found/not found> | <count/list summary> |
| Personal profile | <updated/declined/fail> | <Halo agent ID/email or reason skipped> |

## Detailed Results

| Check | Severity | Status | Evidence | Error | Next action |
| --- | --- | --- | --- | --- | --- |
| <name> | <blocker/warning/info> | <pass/fail/skipped/manual> | <evidence> | <error> | <next action> |

## What you learned

- OpenWork can create and edit workspace files.
- OpenWork has a built-in browser for browser automation.
- OpenWork can use configured MCP/extensions to retrieve information.
- OpenWork can save results into workspace reports.
- OpenWork can look up your HaloPSA agent record and, with confirmation, save onboarding-safe teammate context near the top of `AGENTS.md`.

## Useful next prompts

- "Create a report from this ticket and save it as Markdown."
- "Open this website and test the login flow."
- "Search our connected tools for this customer and summarize findings."
- "Create a checklist for this process in the workspace."
```

### 11. Close onboarding

End with concise next steps:

- Mention exact file paths created.
- Mention whether `AGENTS.md` was updated with the teammate profile.
- Mention whether browser automation passed.
- Mention whether Claude Code was detected only if detected or if report includes it.
- Mention how to add extensions: Settings > Extensions.
- Mention how to manage folders: Settings > Permissions.
- Ask whether the user wants to keep or delete demo files. Default: keep them as proof of onboarding.

## Example user prompts

- "Run OpenWork onboarding for a new teammate."
- "Onboard my team member and check file editing, browser automation, and MCP tools."
- "Teach teammates OpenWork and create a setup report."

## Verification checklist for agent using this skill

- [ ] Created/edited `onboarding/openwork-demo.txt` or explained permission blocker.
- [ ] Asked for first and last name.
- [ ] Looked up HaloPSA agent details when the tool was available.
- [ ] Asked before writing teammate profile data to `AGENTS.md`.
- [ ] Updated only the marked `AGENTS.md` profile block, or recorded skip/decline.
- [ ] Browser check attempted against `https://example.com`.
- [ ] Claude Code detection handled per OS.
- [ ] No Claude Code blocking/config edits performed without explicit confirmation.
- [ ] MCP/extension example stayed dynamic.
- [ ] Wrote `onboarding/openwork-onboarding-report.md`.
