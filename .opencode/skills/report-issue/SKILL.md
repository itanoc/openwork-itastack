---
name: report-issue
description: |
  Create a public-safe issue report file for the shared OpenWork ITAStack workspace that the teammate can send to James for triage.

  Triggers when user mentions:
  - "report issue"
  - "report a bug"
  - "skill issue"
  - "submit skill update"
  - "file an OpenWork issue"
---

# Report Issue

Use this skill when a teammate intentionally wants to report a bug, blocker, skill issue, skill update request, documentation/process gap, or feature request for the shared OpenWork ITAStack workspace.

This skill creates a local Markdown report file only. The teammate gives the file to James for triage. Do not open GitHub, create GitHub Issues, create PRs, or edit skills/docs/workflow files as part of this skill unless the user separately asks for implementation work after the report is complete.

Default related repo: `https://github.com/itanoc/openwork-itastack`

## Core Rules

- Ask at most 2-3 short user-facing questions before writing the report.
- Use active session context to infer everything else when safe.
- Always sanitize for a public GitHub repository.
- Always show the final report path and contents after writing the file.
- Never include secrets, tokens, credentials, private logs, sensitive screenshots, private URLs, or raw client/internal data.
- Do not rely on GitHub labels for routing; use title prefixes.
- Store a sanitized local report under `.issues/`.

## First-Time Setup

Before writing a report, ensure the local report folder exists:

1. Confirm `.issues/` exists. If not, create it.
2. Confirm `.issues/.gitkeep` exists. If not, create it.
3. Confirm `.gitignore` ignores report files while allowing `.gitkeep`:
   - `.issues/*`
   - `!.issues/.gitkeep`

Only perform the setup needed. Do not modify unrelated ignore rules.

## Reporter Identity

Read reporter identity from the top of `AGENTS.md` when available.

- Look for a simple line near the top like `Name: Jane Teammate`.
- Use only the reporter name in the report file.
- If no name is found, ask one short fallback question: "Who should I list as the reporter?"
- Do not include email, phone, or other personal contact details in the report file by default.

## User Questions

Ask only what is missing and needed. Keep it light.

Preferred questions:

1. "What kind of report is this: bug, skill update, blocker, docs/process gap, or feature request?"
2. "What happened or what needs to change?"
3. "What result did you expect or want?"

If the affected area is not obvious from session context, replace or combine one question with:

- "What skill, workflow, or area is this about?"

## Report Types and Title Prefixes

Use one of these title prefixes:

- `[Bug]`
- `[Skill Update]`
- `[Blocker]`
- `[Docs/Process]`
- `[Feature Request]`

Skill bugs and skill improvement requests are still local report files. Do not create a GitHub Issue, create a PR, or edit the skill in this workflow.

## Public-Safety Redaction

The report file must be safe to share by default.

Do not include:

- Client names unless the user explicitly confirms they are safe to include.
- Email addresses, phone numbers, IPs, hostnames, ticket IDs, private URLs, screenshots, logs, tokens, API keys, OAuth credentials, bearer strings, or passwords.
- Raw transcript excerpts that may include client, teammate, or internal data.
- Private OpenWork logs or local config values.

Use generic wording instead:

- "a client ticket"
- "a mailbox user"
- "an internal workflow"
- "the affected skill"
- "error details omitted because this repository is public"

Add this note when relevant:

"Some session context was intentionally omitted because this repository is public. The reporter can provide private details separately if needed."

## Report Format

Create a concise Markdown report with this structure:

- Summary
- Reporter
- Type
- Affected area
- What happened / what needs to change
- Expected behavior / requested outcome
- Public-safe context captured by OpenWork
- Sensitive context omitted
- Reporter notes

## Local Report File

Write the sanitized report file after collecting the minimum needed context.

Path format:

- `.issues/YYYY-MM-DD-short-title.md`

Filename rules:

- Use today's local date.
- Use lowercase words separated by hyphens.
- Keep the title short.
- Avoid client names and sensitive identifiers.

After writing the report, show the workspace-relative path and the report contents. Tell the teammate to send that file to James for triage.

## Handoff Flow

Do not submit to GitHub from this skill.

After writing and showing the report, say:

"Report saved at `.issues/<filename>.md`. Send this file to James for triage."

Do not ask the teammate to log into GitHub. Do not open a browser unless the user separately asks to view the repository.

## Optional Future Paths

If a future version adds authenticated tooling, use this fallback order only after James approves the change:

1. Local `.issues/` report file by default.
2. Centralized authenticated bot/app submission if explicitly configured and approved.
3. Browser-based GitHub issue creation only if the user explicitly requests it and understands GitHub login is required.

Do not implement PR creation in this skill.

## Example Prompts

- "Report issue: the halo-ticket-research skill asked for too much context before summarizing."
- "Skill issue: client-comm should include a shorter update option."
- "Report a bug with the OpenWork browser step."
- "I'm blocked and need to file an issue."
