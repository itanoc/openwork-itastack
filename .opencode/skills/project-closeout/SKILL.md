---
name: project-closeout
description: |
  Create ITA project retrospectives and closeout reports from HaloPSA, SharePoint/project-folder evidence, and approved Office templates.

  Triggers when user mentions:
  - "project retrospective"
  - "closeout report"
  - "Retrospectives {Client}"
  - "Closeout report {Client}"
---

# Retrospectives and Closeout Report

Be extremely concise. Sacrifice grammar for concision in chat output.

Use this skill when user asks to create project retrospectives, project closeout reports, or both for a completed ITA project.

## Goal

Produce concise, credible, template-faithful deliverables:

- `Retrospectives {Client} - {Project Name}.xlsx`
- `Closeout report {Client} - {Project Name}.docx`

## Required Inputs

Always collect:

- HaloPSA Ticket ID.
- SharePoint destination path or URL.
- Approved retrospective template source.
- Approved closeout report template source.

If templates are not directly accessible through OpenWork tools, ask user for local template file paths in an authorized folder.

## OpenWork Tools

Read tools:

- `itastack_itastack_halo` operation `get_ticket` for HaloPSA ticket context.
- `itastack_itastack_halo` operation `actions.list` when full action history is needed.
- `itastack_itastack_m365` operation `list_sharepoint_folder` when SharePoint folder browsing is available.
- `itastack_itastack_m365` operation `search_sharepoint_files` when SharePoint search is available.
- `itastack_itastack_m365` operation `replace_sharepoint_file` for approved replacement of an existing SharePoint file.
- Local file tools for reading/writing copied templates.

For Microsoft 365 calls, pass tenant as top-level dispatcher field, not inside `params`.

Capability gaps:

- Current OpenWork ITAStack Microsoft 365 toolset can replace existing SharePoint files with `file_base64` or a staged `upload_id`, but may not expose create-new upload.
- Current local file tools may not preserve complex Office formatting without helper scripts or libraries.
- If download/upload/template editing is unavailable, state gap, create best available local artifacts only after user approves, and give exact paths.
- Do not claim upload completed unless `replace_sharepoint_file` or another upload-capable tool succeeds and post-upload verification passes.

Extension fallback:

- If needed SharePoint, Office, or upload capability is missing, inspect `openwork_extension_list_actions` before saying unavailable.
- If extension exposes matching action, still apply write gate before calling it.
- Do not use browser tools for OpenWork app control.

## Guardrails

- Ask questions one at a time.
- Pull HaloPSA context when needed.
- Use project-folder documents before interviewing.
- Never create Office files from scratch unless user explicitly approves.
- Always work from copied templates.
- Follow template structure exactly.
- Do not alter headings, worksheet names, section order, styles, or required formatting.
- Keep wording concise, professional, and specific.
- Avoid celebratory filler.
- Include realistic improvement opportunities.
- If lessons imply documentation updates, call out exact ITGlue document if known.
- If source evidence is weak, ask targeted question instead of inventing content.
- Require final pre-upload summary before upload or handoff.

## Workflow

### Phase 1 - Project Context

1. If Ticket ID missing, ask for Ticket ID and stop.
2. If SharePoint destination missing, ask for SharePoint destination path/URL and stop.
3. Pull HaloPSA ticket with `itastack_itastack_halo` operation `get_ticket`:
   - `ticket_id`: provided Ticket ID
   - `include_actions`: `true`
   - `slim`: `false`
   - `max_note_chars`: `8000`
   - `max_actions`: `10`
4. Pull more actions with `itastack_itastack_halo` operation `actions.list` only if ticket action history is missing or too thin.
5. Resolve Client and Project Name from ticket context.
6. Confirm naming if ambiguous.

### Phase 2 - Source Review

1. Locate project-folder documents from provided SharePoint path if tools allow.
2. Review relevant project docs before interview.
3. Extract outcomes, risks, delays, scope changes, decisions, blockers, and metrics.
4. Identify missing template fields.
5. Ask one concise question at a time for gaps.

### Phase 3 - Interview

Cover only missing inputs needed by templates:

- what went well
- what did not go well
- measurable outcomes
- schedule/budget/scope variance
- customer impact
- internal handoff quality
- documentation gaps
- follow-up actions
- realistic improvements

Do not ask already-answered questions from HaloPSA or project docs.

### Phase 4 - Draft Deliverables

1. Copy approved templates.
2. Populate copied retrospective workbook.
3. Populate copied closeout report.
4. Use strict filenames:
   - `Retrospectives {Client} - {Project Name}.xlsx`
   - `Closeout report {Client} - {Project Name}.docx`
5. In Methodology section, include:

   `IT Assurance delivered this project using a traditional project management approach...`

6. In final section of closeout report, include only SharePoint URL.

### Phase 5 - Validate

Before upload or handoff, verify:

- files are copied from approved templates
- filenames match required format
- template structure unchanged
- required sections populated
- weak claims removed or marked for confirmation
- final closeout section contains only SharePoint URL
- no secrets or unnecessary internal notes included

### Phase 6 - Final Pre-Upload Summary

Before upload, show concise summary:

- output filenames
- source templates used
- SharePoint destination
- formatting/template fidelity status
- open questions or assumptions

Ask for approval before upload.

If no upload tool exists, say:

`Upload not available from current tools. Files are ready locally:`

Then list workspace-relative paths.

## Write Gate

WRITE GATE - DO NOT SKIP.

Before any tool/action call whose name matches:

- `*_create_*`
- `*_update_*`
- `*_delete_*`
- `*_send_*`
- `*_publish_*`
- `*_add_*`
- `*_remove_*`
- `*_reset_*`
- `*_upload_*`
- `*_move_*`

Or any action that uploads, overwrites, moves, deletes, publishes, emails, posts, sends, or changes remote records/files:

1. Summarize exact target, action, and content.
2. Ask for explicit approval.
3. Do not proceed until user says yes/apply/go ahead/upload.

Local copied-template file creation is allowed after user requests deliverables. Remote upload still requires approval.

## Output Requirements

Final artifacts:

- `Retrospectives {Client} - {Project Name}.xlsx`
- `Closeout report {Client} - {Project Name}.docx`

Final response must include exact workspace-relative file paths.

## Quality Bar

- Precise over broad.
- Evidence-based over invented.
- Professional over celebratory.
- Concise over comprehensive.
- Template-faithful over redesigned.
