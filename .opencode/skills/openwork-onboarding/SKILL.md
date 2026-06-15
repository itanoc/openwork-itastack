---
name: openwork-onboarding
description: |
  Guide first-time teammates through OpenWork Desktop onboarding, including teammate profile capture, HaloPSA agent lookup, AGENTS.md profile setup, safe file/browser checks, Claude Code presence, workstation tool readiness, and dynamic MCP/report examples.

  Triggers when user mentions:
  - "OpenWork onboarding"
  - "onboard my team"
  - "teach teammates OpenWork"
---

# OpenWork Onboarding

Use this skill when a teammate needs a guided first-run walkthrough of OpenWork Desktop.

Goal: capture the teammate's workspace identity, fetch their HaloPSA agent details, add confirmed profile context near the top of `AGENTS.md`, prove OpenWork can safely create/edit files, use the built-in browser for browser automations, detect possible Claude Code overlap, check common workstation tools used by coding agents and office/report automation, and show how MCP/extensions can pull information into a report.

Audience: non-technical or mixed-technical team members using OpenWork for the first time.

This onboarding starts by capturing the teammate's basic work identity so future agents know who is using the workspace. It asks for first and last name, uses HaloPSA to fetch onboarding-safe agent details, then adds the confirmed profile near the top of `AGENTS.md` after explicit approval.

## Safety rules

- Do not read secrets, tokens, `.env` files, credential stores, shell history, browser cookies, or private logs.
- Do not modify global config unless the user explicitly approves the exact change.
- Treat teammate profile data as shared workspace context, not private memory. Before writing name, Halo agent ID, email, initials, teams, timezone, workday, or active status to `AGENTS.md`, tell the user that `AGENTS.md` is repo/shared workspace context and ask for explicit confirmation.
- Store only onboarding-safe HaloPSA fields in `AGENTS.md`. Do not paste the raw Halo agent payload, department role GUIDs, cost/rate fields, billing flags, phone/SMS fields, or third-party authorization flags.
- Do not guess HaloPSA agent details. If Halo lookup fails or has multiple matches, ask the user to choose or continue with unknown values.
- Do not install workstation tools, packages, CLIs, or dependencies without explicit approval. Explain purpose, likely admin prompts, and consequences of skipping before asking.
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
- Optionally `onboarding/package-check.xlsx` — proof that the local Python reporting bundle can create Excel workbooks.
- `AGENTS.md` — update near the top with the confirmed onboarded teammate profile, unless the user declines.

If OpenWork shows a skill reload banner after this skill is installed or updated, reload skills before running onboarding.

## Required permissions

- Workspace write access for `onboarding/`.
- Built-in browser access for `https://example.com`.
- Shell access for OS and Claude Code detection.
- Optional: shell access for checking Python, uv, Git, Node.js/npm, OS package managers, and local reporting packages.
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

### Guided checkpoint rule

After each visible feature demo, stop and check in before continuing. Tell the user what happened, what they should see, and ask whether they have questions or want to continue.

Use this checkpoint format:

> You should now see <feature/result>. This shows <capability>. Any questions before we continue?

Required checkpoints:

- After the browser window opens, before capturing the browser snapshot.
- After `onboarding/example-report.md` is created and opened or manual-open instructions are given.

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
2. After the browser window opens, stop and inform the user:

   > You should now see `example.com` in the OpenWork browser panel. This shows OpenWork can open web pages for browser automation. I will inspect the page structure next to confirm automation access. Any questions before I continue?

   Wait for the user to continue before capturing the browser snapshot.

3. Use returned `browser_url` and `target_id` for all browser calls.
4. Capture browser snapshot.
5. Verify title/text contains `Example Domain`.
6. Optional: take screenshot only if user wants visual proof.

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

After `onboarding/example-report.md` is created, open it or direct the user to it using the same safe UI-action pattern from the file editor demo. Do not open another onboarding document as the document example.

Stop here and check in with the user:

> You should now see `onboarding/example-report.md`. This shows how OpenWork can pull read-only tool data or a template into a saved workspace report. Any questions before I continue to the final onboarding report?

Wait for the user to continue before writing the final onboarding report.

### 10. Optional workstation readiness check: install common agent tools

Purpose: help the teammate install common local tools during onboarding so OpenWork does not stop later in the middle of real work.

This step is optional, but strongly recommended. It is not just for developers. Many normal OpenWork tasks rely on local command-line tools behind the scenes, including Excel reports, CSV cleanup, PDF parsing, document generation, chart creation, repeatable checks, browser previews, and small automation scripts.

Before running checks, tell the teammate:

> This step is optional, but I strongly recommend completing it now. If we skip it, OpenWork may stop later and ask you to install tools in the middle of real work. Installing them during onboarding means future tasks like Excel reports, project closeouts, ticket exports, PDF parsing, and data cleanup are more likely to work without interruption.

Give concrete examples:

- Creating an Excel workbook from ticket or project data often needs Python plus Excel libraries.
- Making a formatted `.xlsx` report may require Python packages such as `openpyxl` or `xlsxwriter`.
- Cleaning, filtering, and merging CSV exports is faster and safer with Python and `pandas`.
- Creating Word documents, PowerPoint decks, charts, or PDF extracts may require Python report packages.
- Running repeatable remediation or investigation scripts often depends on Python or `uv`.
- Installing task-specific helpers safely without polluting the whole computer is easier with `uv`.
- Using many community MCP tools, browser previews, or developer utilities may require Node.js/npm.

Ask one targeted question before checking tools:

> I can check for Python, uv, Git, Node.js/npm, and OS-specific package tools. These help OpenWork create Excel files, process reports, run repeatable checks, and avoid future interruptions. Do you want me to run the readiness check now?

If the user declines, record the skip in `onboarding/openwork-onboarding-report.md` and continue. Do not pressure them beyond one concise explanation of consequences.

#### Tool checks by OS

Use OS-appropriate commands. If the current OpenWork agent runtime is not the same OS as the teammate's computer, ask the teammate to run the checks locally and paste output. Do not pretend the current host proves the teammate's machine state.

macOS/Linux:

```bash
uname -s
python3 --version
uv --version
git --version
node --version
npm --version
```

macOS additional:

```bash
brew --version
xcode-select -p
```

Windows PowerShell:

```powershell
$PSVersionTable.PSVersion
py --version
python --version
python3 --version
py -c "import sys; print(sys.executable); print(sys.version)"
uv --version
where.exe uv
git --version
where.exe git
node --version
where.exe node
npm --version
winget --version
```

Windows command preference:

- Prefer `py` first for Python checks, then `python`, then `python3`.
- Do not assume `python3` is the best Windows Python command. On some machines it resolves to a Microsoft Store Python while `py` and `python` resolve to a newer separately installed Python.
- Use `py -c "import sys; print(sys.executable)"` to record the actual Python executable.
- Use `where.exe uv`, `where.exe git`, and `where.exe node` to record command precedence when multiple installs exist.
- Developer workstations may have several Python, Node.js, or uv installs. Typical onboarding users may have none. Command behavior is more important than package-manager records.

Recommended core tools:

- Python 3 — powers Excel, CSV, PDF, report, cleanup, and automation workflows.
- `uv` — creates isolated Python environments and installs Python helpers quickly and safely.
- Git — lets OpenWork inspect workspace history, compare changes, and work with shared configuration safely.
- Node.js/npm — supports many MCP servers, browser tooling, previews, and JavaScript utilities.

OS-specific useful tools:

- Homebrew on macOS — simplest package manager for Python, uv, Git, Node.js, and other tools.
- Xcode Command Line Tools on macOS — required by some build/install workflows.
- winget on Windows — simplest package manager for Windows installs.
- PowerShell 7 on Windows — better shell compatibility for modern automation.
- VS Code command-line launcher, only if the team uses VS Code.
- `pipx`, only if the team commonly installs standalone Python CLI apps that way.

#### Install guidance

Never install anything automatically without explicit approval. Ask before each installation group, or ask for one approval covering the recommended tool bundle. Explain that installs may require admin rights. Never ask for passwords; if elevation appears, the user should handle it directly.

Preferred macOS approach:

- If Homebrew is available, prefer Homebrew.
- Python: `brew install python`
- uv: `brew install uv`
- Git: `brew install git`
- Node.js/npm: `brew install node`

Preferred Windows approach:

- Treat winget as an install helper, not the source of truth for whether a command works.
- Check command behavior first: `py --version`, `uv --version`, `git --version`, `node --version`, and `npm --version`.
- Use winget package IDs only for install recommendations when a command is missing or unsuitable.
- Use `winget show --id <package-id> --exact --accept-source-agreements` before install to preview package metadata.
- Do not rely on `winget install --dry-run`; it is not supported on all Windows Package Manager versions.
- Do not rely on `winget --output json`; it is not supported on all Windows Package Manager versions.
- Expect winget output to include progress bars/spinner characters. Summarize results instead of pasting raw output into the onboarding report.
- Use safer install flags when winget is approved: `--exact --scope user --silent --accept-package-agreements --accept-source-agreements --no-upgrade --disable-interactivity`.
- Python: `winget install --id Python.Python.3.12 --exact --scope user --silent --accept-package-agreements --accept-source-agreements --no-upgrade --disable-interactivity`
- uv: `winget install --id astral-sh.uv --exact --scope user --silent --accept-package-agreements --accept-source-agreements --no-upgrade --disable-interactivity` when available, otherwise use the official Astral installer with user approval.
- Git: `winget install --id Git.Git --exact --scope user --silent --accept-package-agreements --accept-source-agreements --no-upgrade --disable-interactivity`
- Node.js/npm: `winget install --id OpenJS.NodeJS.LTS --exact --scope user --silent --accept-package-agreements --accept-source-agreements --no-upgrade --disable-interactivity`
- PowerShell 7: `winget install --id Microsoft.PowerShell --exact --scope user --silent --accept-package-agreements --accept-source-agreements --no-upgrade --disable-interactivity`
- After every winget install, verify the active command with `where.exe <command>` and `<command> --version`. winget success does not guarantee its installed command wins PATH precedence.
- If multiple command paths exist and an older one appears first, report a PATH precedence issue instead of assuming the install failed.

Preferred Linux approach:

- Identify distro first.
- Use the native package manager where practical: `apt`, `dnf`, `yum`, `pacman`, or the organization's standard package manager.
- Install Python 3, Git, and Node.js/npm from trusted distro or vendor repositories.
- Install uv using the official Astral installer or approved package source.

#### Optional local Python reporting/data package bundle

If Python and uv are available, offer to install a local reporting/data package bundle. Explain that these packages enable common non-coding OpenWork work: Excel workbooks, Word documents, PowerPoint decks, PDF extraction, CSV cleanup, charts, API pulls, HTML parsing, and template-based reports.

Recommended bundle:

- `openpyxl` — create and edit `.xlsx` Excel workbooks.
- `xlsxwriter` — create formatted Excel workbooks with tables, formulas, charts, and styles.
- `pandas` — clean, filter, merge, summarize, and export tabular data.
- `python-docx` — create or edit Word `.docx` documents.
- `python-pptx` — create PowerPoint `.pptx` decks.
- `pypdf` — read, split, merge, or extract text from PDFs.
- `pillow` — basic image processing for screenshots and report images.
- `matplotlib` — create charts and graphs.
- `requests` — call APIs and download files.
- `beautifulsoup4` — parse HTML pages and tables.
- `lxml` — faster and more capable XML/HTML parsing.
- `pyyaml` — read and write YAML config and workflow files.
- `jinja2` — fill reusable report and document templates.
- `rich` — cleaner terminal output for scripts.

Ask before installing:

> Do you want me to install the recommended local Python reporting bundle now? This helps future OpenWork tasks create Excel files, clean CSVs, parse PDFs, generate charts, and build reports without stopping to install packages later.

Do not install the bundle globally with `pip install ...` by default. Prefer a workspace-managed environment for proof during onboarding:

```bash
uv venv onboarding/.venv
uv pip install --python onboarding/.venv/bin/python openpyxl xlsxwriter pandas python-docx python-pptx pypdf pillow matplotlib requests beautifulsoup4 lxml pyyaml jinja2 rich
```

On Windows, the venv Python path is typically:

```powershell
onboarding\.venv\Scripts\python.exe
```

Windows local venv install example:

```powershell
uv venv onboarding\.venv
uv pip install --python onboarding\.venv\Scripts\python.exe openpyxl xlsxwriter pandas python-docx python-pptx pypdf pillow matplotlib requests beautifulsoup4 lxml pyyaml jinja2 rich
```

After installation, run an import proof using the venv Python. Use the correct Python path for the OS:

```bash
onboarding/.venv/bin/python -c "import openpyxl, xlsxwriter, pandas, docx, pptx, pypdf, PIL, matplotlib, requests, bs4, lxml, yaml, jinja2, rich; print('ok')"
```

Windows import proof:

```powershell
onboarding\.venv\Scripts\python.exe -c "import openpyxl, xlsxwriter, pandas, docx, pptx, pypdf, PIL, matplotlib, requests, bs4, lxml, yaml, jinja2, rich; print('ok')"
```

Create `onboarding/package-check.xlsx` with `openpyxl` to prove Excel creation works. The workbook should contain a simple sheet named `Package Check` with rows for package, purpose, and status. Keep it harmless and non-client-specific.

If any package fails to install or import, record the failure and continue unless the user wants to troubleshoot. Do not let optional package setup block core onboarding.

Record in `onboarding/openwork-onboarding-report.md`:

- Tool checks run or skipped.
- Python, uv, Git, Node.js/npm status.
- Windows command precedence from `where.exe` for uv, Git, Node.js, and other tools when checked.
- OS package manager status.
- Missing tools and recommended install command.
- winget package availability from `winget show`, when used.
- PATH precedence issues discovered after install.
- Whether installs were approved, completed, failed, or skipped.
- Python reporting bundle status: installed, partially installed, failed, or skipped.
- `onboarding/package-check.xlsx` creation status when attempted.

### 11. Write final onboarding report

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
| Workstation readiness | <pass/partial/skipped/fail> | <Python/uv/Git/Node/package manager summary> |
| Python reporting bundle | <installed/partial/skipped/fail> | <venv path/package-check.xlsx status> |

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
- OpenWork can check whether common local tools are available before real work depends on them.
- Installing Python, uv, and the local reporting bundle during onboarding helps future Excel, CSV, PDF, document, chart, and automation tasks work without stopping later.

## Useful next prompts

- "Create a report from this ticket and save it as Markdown."
- "Open this website and test the login flow."
- "Search our connected tools for this customer and summarize findings."
- "Create a checklist for this process in the workspace."
```

### 12. Close onboarding

End with concise next steps:

- Mention exact file paths created.
- Mention whether `AGENTS.md` was updated with the teammate profile.
- Mention whether browser automation passed.
- Mention whether Claude Code was detected only if detected or if report includes it.
- Mention whether workstation readiness was checked, skipped, or needs follow-up.
- Mention `onboarding/package-check.xlsx` if the Python reporting bundle proof file was created.
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
- [ ] Stopped after browser window opened and checked for questions before snapshot.
- [ ] Claude Code detection handled per OS.
- [ ] No Claude Code blocking/config edits performed without explicit confirmation.
- [ ] MCP/extension example stayed dynamic.
- [ ] Created and opened or directed user to `onboarding/example-report.md` as the one document example.
- [ ] Stopped after example report opened and checked for questions.
- [ ] Asked before running the optional workstation readiness check.
- [ ] Checked Python, uv, Git, Node.js/npm, and OS package manager using OS-appropriate commands, or recorded skip.
- [ ] Explained why each missing tool matters before asking to install it.
- [ ] Did not install tools, packages, CLIs, or dependencies without explicit approval.
- [ ] Installed the Python reporting bundle only in a local environment by default, or recorded skip/failure.
- [ ] Verified Python reporting packages by importing them and creating `onboarding/package-check.xlsx`, or recorded why verification was skipped.
- [ ] Wrote `onboarding/openwork-onboarding-report.md`.
