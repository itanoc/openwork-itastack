---
name: email
description: |
  Use for current-teammate Microsoft 365 email work in the ITA tenant: search/read mailbox messages, inspect headers, review mailbox settings/rules/usage, draft and send email after explicit confirmation, and retrieve attachments after explicit confirmation.

  Triggers when user mentions:
  - "email"
  - "mailbox"
  - "email attachment"
  - "search my email"
  - "read my email"
metadata:
  route_default: daily
  route_max: high
  route_class: email
---

<<<ROUTE default=daily max=high class=email>>>

# Email

Use this skill for Microsoft 365 email work on the current teammate's mailbox only.

## Boundaries

- Tenant is always `ita`.
- Mailbox is always the `Email:` value in `memory/preferences/current-openwork-teammate.md`.
- If the profile file is missing, create parent directory `memory/preferences/` if needed, ask for the user's name and email, then create `memory/preferences/current-openwork-teammate.md` with those known fields only.
- If the profile file exists but lacks `Email:`, ask for the email address and update the profile with that field only.
- If the user asks for another mailbox, stop and say this skill is limited to the current teammate mailbox.
- Do not enumerate other mailboxes or guess mailbox addresses from names.
- Default mode is read, draft, and send only after explicit confirmation.
- Do not delete email, move email, mark read/unread, create inbox rules, change forwarding, or change mailbox settings.
- Creating a draft in an external email system is allowed only when a tool exists and the user explicitly asks for draft creation.
- Sending email is allowed only from the current teammate mailbox, only after showing a final send preview, and only after the user explicitly confirms the final preview in the current session.
- Never send after vague approval. Require confirmation that clearly references sending, such as `send it`, `yes send`, or `send this email`.
- Never print raw attachment binary or base64 in chat.
- Never store email content, headers, attachments, or mailbox output inside `.agents/skills/email/`.

## Local storage

- Default attachment output folder is workspace-local `email/`.
- Treat `email/` as private local output that must not be published or committed.
- Use subfolders like `email/YYYY-MM-DD_subject-or-messageid/`.
- Sanitize folder and file names: remove path separators, control characters, secrets, and very long strings.
- If creating `email/` for the first time, create `email/README.md` explaining the folder contains private local mailbox exports and should stay ignored.
- If `.gitignore` does not contain `/email/`, ask before editing `.gitignore` unless the user has already approved adding it.

## Profile lookup

1. Read `memory/preferences/current-openwork-teammate.md`.
2. If the file is missing, create `memory/preferences/` if needed, ask one question requesting the user's name and email address, then create the file with only:
   - `Name: <answer>`
   - `Email: <answer>`
3. If the file exists but lacks `Email:`, ask for the email address and add only `Email: <answer>`.
4. Parse simple `Key: Value` lines.
5. Require `Email:` before using mailbox tools.
6. Use that email for every mailbox tool call.
7. Keep profile data out of committed files; `memory/preferences/current-openwork-teammate.md` is ignored personal memory.
8. Do not invent Halo agent ID, initials, team, timezone, workday, or active status. Other skills may ask later for a fuller profile.
9. Do not update `memory/index.md` or `memory/log.md` for this profile bootstrap unless the user specifically asks for memory indexing.

Expected profile shape:

- `Name: Teammate Name`
- `Halo agent ID: 123`
- `Email: teammate@itassurance.com`
- `Initials: TN`
- `Primary team: Team Name`
- `Teams: Team Name, Other Team Name`
- `Timezone: Pacific Standard Time`
- `Workday: Default Working Hours`
- `Active in Halo: true`

## Available M365 mailbox operations

Use `itastack_itastack_m365` with `tenant: "ita"`.

Read/list operations:

- `check_recent_mail(email, top=10)` — recent Inbox messages.
- `search_messages(email, sender=None, subject=None, received_after=None, received_before=None, search_query=None, top=25)` — search/list messages, newest-first when no filter is provided.
- `get_sent_items(email, top=10)` — recent Sent Items.
- `get_deleted_items(email, top=10)` — recent Deleted Items.
- `peek_junk_folder(email, top=5)` — recent Junk Email.
- `get_message_detail(email, message_id, include_headers=True)` — message body and internet headers.
- `get_message_attachments(email, message_id)` — attachment metadata only.
- `get_inbox_rules(email)` — inbox rules.
- `get_mailbox_settings(email)` — mailbox settings such as auto-reply and forwarding.
- `get_mailbox_usage(email)` — mailbox folder item-count breakdown.
- `send_mail(to, subject, body, cc=None, bcc=None, content_type="Text", save_to_sent_items=True, attachments=None)` — send email as the authenticated caller, with optional small inline attachments.

Raw Graph operations:

- Use `get` or similar generic M365 Graph operation only when the typed helper does not expose required read-only data.
- Use raw Graph only for read-only requests. Do not use raw Graph to send mail when `send_mail` is available.
- For attachment bytes, first use `get_message_attachments` for metadata, then ask for explicit confirmation before retrieving content.

Send tool shape for new messages:

- Use `send_mail` with tenant `ita`.
- Sender is bound to the authenticated caller by MCP identity mapping. Do not pass or invent a sender parameter.
- Expected sender should match the profile `Email:` value. If the send result reports a different sender, report the mismatch and stop future sends until identity mapping is fixed.
- Set `save_to_sent_items: true`.
- Use plain text body by default: `content_type: "Text"`.
- Use HTML only if the user asks for HTML or the source content requires it.
- Include recipients as exact addresses in `to`, `cc`, and `bcc`.
- Include file attachments only when the user explicitly names local files to attach and confirms them in the final preview.
- Attachment shape: `{ "name": "note.txt", "content_base64": "aGk=", "content_type": "text/plain" }`.
- Total decoded attachment bytes must stay under 3 MiB. Larger files are not supported until staged-upload support exists.
- Never print `content_base64` in chat.

## Common workflows

### Search or list messages

1. Load profile and get current teammate email.
2. Use `search_messages` when the user gives sender, subject, date range, or KQL.
3. Use `check_recent_mail` when the user asks for recent Inbox email.
4. Return concise results: date, sender, subject, message id, and whether attachments exist if available.
5. Do not include full bodies unless the user asks to read a specific message.

### Read a message

1. Load profile and confirm target message came from the current teammate mailbox search/list results, or the user supplied a message id.
2. Use `get_message_detail` with `include_headers=True` by default.
3. Summarize body, sender, recipients, received time, and relevant headers.
4. Avoid dumping full headers unless needed for troubleshooting.

### Review attachments

1. Load profile.
2. Find or confirm `message_id`.
3. Use `get_message_attachments`.
4. Report metadata only: file name, content type, size, attachment id if present.
5. If user wants files, ask explicit confirmation before fetching bytes.

### Download attachments

Proceed only after explicit confirmation such as "download attachments" or "save them".

1. Load profile.
2. Confirm `message_id` and target attachment(s).
3. Use `get_message_attachments` and identify attachment ids/names.
4. Create target folder under `email/`, normally `email/YYYY-MM-DD_subject-or-messageid/`.
5. Fetch attachment content with read-only Graph if available. Prefer Microsoft Graph fileAttachment content retrieval; many file attachments expose `contentBytes` from `/users/{email}/messages/{message_id}/attachments/{attachment_id}`.
6. Decode content safely and write files only under `email/`.
7. Verify saved file size and, when practical, SHA256.
8. Report saved workspace-relative paths only.

If Graph response does not include content bytes, or permission blocks attachment download, say metadata was available but bytes could not be retrieved with current tools.

### Draft, reply, or send email

1. Use message context only from current teammate mailbox.
2. Draft text in chat unless the user explicitly asks to create a draft using an available tool.
3. Preserve privacy: omit unnecessary internal headers, IDs, and unrelated mailbox details.
4. If the user wants to send, prepare a final send preview before any send action.
5. Use a new message by default with `send_mail`.
6. If the user asks to reply to an existing message and no true reply tool is available, clearly say `send_mail` will send a new message and may not guarantee conversation threading.
7. Final send preview must include:
   - From identity: authenticated caller via MCP, expected to match profile `Email:`
   - To
   - Cc
   - Bcc, if any
   - Subject
   - Body
   - Attachments, if any
8. Require at least one exact recipient email address across To/Cc/Bcc before previewing send.
9. Warn in the preview if any recipient is outside `itassurance.com`.
10. Use plain text body by default; use HTML only if requested.
11. Do not attach outbound files unless the user explicitly names local file paths.
12. Before sending with attachments, verify each file exists, is a regular file, and total decoded size is under 3 MiB.
13. Base64-encode attachments for the tool call only. Never print or store base64 in chat, skills, memory, or logs.
14. Before sending with attachments, show each attachment name, content type, and size in the preview.
15. Ask for explicit confirmation after the preview. Example: `Confirm send? Reply "send it" to send, or tell me what to change.`
16. Send only if the next user response clearly confirms sending the previewed email.
17. If the user changes anything, show a new final preview and require confirmation again.
18. After sending, report concise API success, reported sender, recipients, subject, and attachment names. Do not claim delivery, receipt, or read status.

### Mailbox safety review

Use only read-only operations:

- `get_inbox_rules` for suspicious rules.
- `get_mailbox_settings` for forwarding, auto-reply, and delegate-relevant settings exposed by the tool.
- `get_mailbox_usage` for folder count context.
- `search_messages` for suspicious sender/subject/date patterns.

## Response style

- State tenant and mailbox source briefly when useful: `Using tenant ita and current teammate mailbox from profile.`
- Keep results compact.
- Ask one targeted question when search scope is unclear.
- For attachment download, always confirm before fetching bytes.
- For sending, always show final preview and require explicit confirmation after that preview.
- For external recipients outside `itassurance.com`, include a visible warning in the final preview.
- After creating files under `email/`, mention exact workspace-relative paths.

## Examples

User: "search my email for attachments from vendor@example.com this week"

Assistant workflow:

1. Read profile.
2. Use tenant `ita` and profile email.
3. Search current mailbox with sender/date filters.
4. List matching messages and attachment metadata.
5. Ask whether to download selected attachments.

User: "download the PDF from that email"

Assistant workflow:

1. Confirm target message and PDF attachment.
2. Fetch bytes only after this explicit request.
3. Save under `email/`.
4. Report saved path.
