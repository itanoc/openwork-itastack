---
name: itglue-docs
description: |
  Create, update, rewrite, review, draft, or publish ITGlue documentation using ITAStack ITGlue tools and IT Assurance documentation standards.

  Triggers when user mentions:
  - "create ITGlue document"
  - "update ITGlue document"
  - "rewrite ITGlue doc"
  - "review ITGlue documentation"
  - "publish ITGlue document"
  - "ITGlue-ready documentation"
  - "add Purpose / Check Your Work / Changelog"
  - "convert notes to ITGlue doc"
  - "ITGlue section"
  - "ITGlue template"
---

# ITGlue Documentation

Use this skill to create, review, rewrite, update, and prepare ITGlue documentation in OpenWork using ITAStack ITGlue tools.

Be extremely concise. Sacrifice grammar for concision. Use bullets. Skip sections that do not apply. Expand only when asked.

## Core Rule

OpenWork ITGlue mode is URL/ID-first, section-first, preserve-first, publish-explicit, confirm-gated.

ITGlue search is limited. Search helps discovery only. Search failure is not proof something does not exist.

## Primary Standard

Use IT Assurance standard template unless user explicitly names another standard.

- Template URL: `https://ita.itglue.com/450801/docs/7619919`
- Template organization ID: `450801`
- Template document ID: `7619919`
- Template name: `Document Template`

Required structure:
1. Purpose
2. Procedure-specific heading, such as Setup, Process, Troubleshooting, or named task heading
3. Step-by-step instructions using ITGlue step sections when writing sections
4. Check Your Work
5. Changelog

Default changelog format:
- `MM/DD/YYYY Created by requester/email when known`
- `MM/DD/YYYY Updated by requester/email when known`

If requester unknown in draft:
- `MM/DD/YYYY Created by [requester/email]`

If writing and requester unknown, ask once. If user says proceed:
- `MM/DD/YYYY Created by OpenWork per request`

## Inputs To Identify

- ITGlue organization: URL, ID, or exact name
- Target document: URL, ID, or exact name; or new document name
- Folder: URL or ID if destination matters
- Requester/email for changelog, if known
- Desired change
- Whether to draft only or publish

Ask one concise clarification question if organization, document, folder, or requested change is ambiguous.

## Entity Resolution

Priority order:

1. Exact ITGlue URL
   - Parse org ID, doc ID, folder ID when present.
2. Exact ID
   - Use direct get/list tools.
3. Known org + exact document title
   - Search docs within org.
   - If multiple or none, ask for URL/ID.
4. Client name only
   - Search orgs.
   - If fuzzy/multiple, ask for ITGlue URL or org ID.
5. Folder unknown
   - Ask for folder URL/ID.
   - Or draft with `destination folder TBD`.

Rules:
- Template is always fetched from org `450801`, document `7619919`.
- Target organization/document may differ.
- If multiple plausible docs/orgs exist, list top matches with IDs and ask user to choose.
- Never invent folder ID.
- If folder cannot be resolved, draft only or create at root only after explicit approval.

## Read Tools

- Search organizations: `itastack_itastack_itglue` operation `organizations.search`
- Get organization: `itastack_itastack_itglue` operation `organizations.get`
- Search documents: `itastack_itastack_itglue` operation `documents.search`
- Get document: `itastack_itastack_itglue` operation `documents.get`
- List documents in folder: `itastack_itastack_itglue` operation `documents.list_by_folder`
- List document sections: `itastack_itastack_itglue` operation `document_sections.list`
- Search configurations/assets: `itastack_itastack_itglue` operation `configurations.search`
- Search/list contacts: `itastack_itastack_itglue` operation `contacts.search`, `itastack_itastack_itglue` operation `contacts.list`
- Search/list locations: `itastack_itastack_itglue` operation `locations.search`, `itastack_itastack_itglue` operation `locations.list`
- Search/list password metadata only: `itastack_itastack_itglue` operation `passwords.search`, `itastack_itastack_itglue` operation `passwords.list`
- Do not call `itastack_itastack_itglue` operation `passwords.get` unless the user explicitly asks for a specific password record and output will be redacted.
- Generic read-only ITGlue REST query: `itastack_itastack_grafana` operation `query_itglue_endpoint`

## Write Tools

- Create document: `itastack_itastack_itglue` operation `documents.create`
  - Fields: `organization_id`, `name`, `content`, `document_folder_id`
- Update document: `itastack_itastack_itglue` operation `documents.update`
  - Fields: `document_id`, `name`, `content`
  - Use for document title or whole-content updates only.
- Delete document: `itastack_itastack_itglue` operation `documents.delete`
  - Fields: `document_id`
- Create document section using the specific helper operation when possible:
  - Text: `itastack_itastack_itglue` operation `document_sections.create_text` with `document_id`, `content`, and optional `sort`
  - Heading: `itastack_itastack_itglue` operation `document_sections.create_heading` with `document_id`, `content`, `level`, and optional `sort`
  - Step: `itastack_itastack_itglue` operation `document_sections.create_step` with `document_id`, optional `content`, optional `duration`, optional `reset_count`, and optional `sort`
  - Gallery: `itastack_itastack_itglue` operation `document_sections.create_gallery` with `document_id` and optional `sort`
  - Generic fallback: `itastack_itastack_itglue` operation `document_sections.create` with `document_id` and `section_data`
- Delete document section: `itastack_itastack_itglue` operation `document_sections.delete`
  - Params: `document_id`, `section_id`
- Publish document: `itastack_itastack_itglue` operation `documents.publish`
  - Fields: `document_id`

Configuration write tools exist but are not documentation tools:
- `itastack_itastack_itglue` operation `configurations.create`
- `itastack_itastack_itglue` operation `configurations.update`

Do not create/update ITGlue configurations unless user explicitly asks for asset/configuration changes.

## Section Rules

- Prefer section-level changes over whole-document HTML.
- Use `Document::Heading` for Purpose, procedure heading, Check Your Work, Changelog.
- Use `Document::Text` for explanatory paragraphs.
- Use `Document::Step` for procedure actions.
- Use `level: 2` for primary headings unless template shows different.
- Use explicit `sort` values when inserting sections.
- Do not include `publish` in section create/delete calls; publish separately with `documents.publish` only after user approved publish explicitly.
- If user asked only for draft, never publish.

Section edit limitation:
- No update-section tool currently exists.
- Replacing content requires create-new + delete-old.
- Prefer append or add missing sections unless user approved replacement.
- Safer replacement pattern: create replacement section, verify it exists, delete old section, publish last.

## Workflow: Review Or Rewrite

1. Resolve ITGlue organization.
2. Search/fetch target document.
3. List target document sections.
4. Fetch template doc `7619919` if template details needed or writing substantial content.
5. Compare target against standard structure.
6. Summarize missing or weak sections.
7. Draft proposed content in standard structure.
8. Stop for approval before any write tool.

## Workflow: Create New Document

1. Resolve organization and folder if provided.
2. Fetch template org `450801` / doc `7619919`.
3. Draft section plan:
   - Purpose
   - Procedure heading
   - Step-by-step instructions
   - Check Your Work
   - Changelog
4. Show proposed document name, location, section plan, and exact payloads.
5. Stop for approval.
6. After approval, create document.
7. Fetch created document.
8. Add sections in template order.
9. Publish only after explicit approval or approved exact batch.

Do not claim template was cloned. Say “structured using template.”

## Workflow: Update Existing Document

1. Fetch current document.
2. List current sections.
3. Identify smallest safe mutation.
4. Prefer adding/replacing sections in template order.
5. If replacing section content, show delete/create plan.
6. Preserve section IDs not listed for deletion.
7. Stop for approval before each write or approved exact batch.
8. Verify by fetching live document/sections after write.

Least-change order:
1. Add missing section.
2. Append update note.
3. Create replacement section.
4. Delete old section.
5. Whole-document update.
6. Document delete only as last resort.

## Documentation Style

- Clear task-oriented titles.
- Purpose: 1–2 short paragraphs.
- H2 headings for primary sections.
- Step sections for procedural actions.
- Start each step with imperative verb.
- Include expected result or validation when useful.
- Use Check Your Work for objective verification steps.
- Use Changelog for date, action, and author/requester.
- Avoid internal reasoning.
- Avoid speculation.
- Avoid unsupported assumptions.
- Avoid raw tool dumps unless user asks.

Screenshots/gallery:
- No image upload workflow is available by default.
- Use placeholders: `[Screenshot: Settings page showing X]`.
- Use `Document::Gallery` only if actual image IDs/upload method exists.
- Never fabricate screenshots.

## Evidence Rules

Every doc change needs source category:
- Current ITGlue document
- Template document `7619919`
- User-provided notes
- Halo ticket
- ITGlue configuration/contact/location

Asset names, IPs, serials, URLs, and contacts only from:
- user-provided text
- ITGlue fetched data
- ticket content, if cited

No source = placeholder or ask.

## Security And Privacy

Never include:
- passwords
- API keys
- bearer tokens
- OAuth secrets
- private keys
- MFA codes
- recovery codes
- unredacted tokens
- sensitive screenshots
- license keys unless user explicitly approves and they are intended for documentation

Use ITGlue password record metadata/name only. Never request or expose actual password values.

## Write Gate — Mandatory

Before any tool/action whose name or purpose includes create, update, delete, publish, add, remove, send, reset, record, or other mutation:

1. Show exact tool/action name.
2. Show complete intended payload, including:
   - organization ID
   - document ID
   - folder ID
   - document name
   - section IDs
   - section names
   - full section content
   - sort order
   - publish flag
   - delete/replace behavior
3. State whether existing content will be preserved, replaced, deleted, or published.
4. Stop and wait for user to type exactly: `confirm`
5. If next user message is not exactly `confirm`, do not perform write.
6. Apply gate per write action.
7. Multiple writes require multiple confirmations unless user explicitly approved exact shown batch.

Batch rule:
- Allowed only if exact batch is shown.
- Any payload change after approval requires new `confirm`.

Delete rule:
- List section/document being deleted.
- Show replacement if any.
- State impact.
- Require explicit `confirm`.
- Document delete requires separate confirmation even inside batch.

Publish rule:
- Publishing makes changes visible in ITGlue UI.
- Default `publish: false` unless user asked publish.
- If section tool default publishes, override payload explicitly.
- Publishing requires approval.

## Stop Conditions

Stop if:
- Organization ambiguous.
- Target document ambiguous.
- Folder required but unknown.
- Requested rewrite scope unclear.
- Search results conflict.
- Requested write lacks exact approval.
- Requested delete lacks explicit approval.
- Requested change conflicts with IT Assurance documentation standard.
- Tool cannot perform requested write.

For standard conflict:
- Explain conflict.
- Propose compliant alternative.
- If user wants client-specific exception, ask whether to follow exception or ITA standard.

## Verification

After any write:
1. Fetch live document/sections.
2. Compare expected section names/order/content presence.
3. Report:
   - succeeded
   - partial
   - verification failed

If verification fetch fails:
- Report write result and verification gap.
- Do not retry mutation without approval.

## Default Output Sections

- Request understood
- Evidence gathered
- Proposed documentation
- Changes to apply
- Next step

For read-only requests:
- Provide answer or review findings.
- Include document ID/name.
- Include template comparison when relevant.
- Do not ask for write approval unless actual write needed.

For long drafts/reviews:
- Offer Markdown artifact under `docs-drafts/` or `reports/`.
- Create artifact only when useful or user asks.
