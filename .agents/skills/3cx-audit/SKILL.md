---
name: 3cx-audit
description: |
  Audit a 3CX system from a backup file. Unzips the backup, parses the config
  database and data tables, and produces a comprehensive Markdown audit report
  (system info, extensions, DIDs, trunks, queues, IVRs, certificates, call-data
  volumes), then asks what the technician needs next.

  Triggers when user mentions:
  - "3CX audit"
  - "audit this 3CX backup"
  - "what's in this 3CX backup"
  - "review 3CX backup / config"
metadata:
  route_default: daily
  route_max: high
  route_class: 3cx_audit
---

<<<ROUTE default=daily max=high class=3cx_audit>>>

# 3CX Audit

Use this skill to turn a 3CX backup into a readable, comprehensive Markdown
inventory of the system, for internal IT Assurance technicians.

This is a **read-and-report** skill. It does not diagnose a specific incident
(use `3cx-troubleshooter` for that). It extracts and documents everything the
backup reveals about the system.

## Role and Audience

You are an internal 3CX documentation assistant for IT Assurance technicians.
Be accurate and concise. Report exactly what is in the backup. Do not invent
configuration, and clearly state what could not be found.

## Inputs

- `backup_path`: required. Path to a 3CX backup `.zip`, `.tar`/`.tar.gz`, or an
  already-extracted folder.
- `client_name`: optional label for the report.
- `out_path`: optional Markdown output path.

If `backup_path` is not provided, ask for the exact path or upload, then stop.

## Output Policy (read carefully)

- **Do NOT redact anything** in the Markdown report. Include SIP/extension auth
  IDs, passwords, voicemail PINs, license keys, SMTP credentials, FQDNs, and DID
  numbers exactly as found. The report is an internal audit artifact.
- **Save the Markdown first**, before summarizing in chat. Write it to
  `artifacts/3cx-audit/<client-or-name>-<timestamp>.md` (workspace-relative).
- Treat the saved report as sensitive: it contains credentials. Do not paste the
  full credential tables into chat unless asked; the saved file is the record of
  truth.

## Workflow

### 1. Locate and verify the backup

- Confirm `backup_path` is accessible from OpenWork. If it is outside the
  authorized workspace and access fails, ask the user to move/copy it into the
  workspace or authorize the parent folder in OpenWork Settings > Permissions.
- Never modify the original backup file.

### 2. Run the auditor script

Run the bundled parser. It extracts the archive to a temp working folder (never
touching the original), parses `*Db.xml` plus `DbTables/*.csv`, and writes the
Markdown report.

```bash
python3 .agents/skills/3cx-audit/scripts/audit_3cx_backup.py \
  "<backup_path>" \
  --out "artifacts/3cx-audit/<client-or-name>-<timestamp>.md" \
  --workdir "$TMPDIR/3cx-audit/<timestamp>"
```

- Pure Python stdlib (`zipfile`, `tarfile`, `csv`, `xml.etree`); Mac/Linux
  portable. No installs required.
- The script auto-detects `*Db.xml` and the `DbTables` folder regardless of the
  backup's top-level folder name.
- If the script fails (unexpected schema/version), fall back to inspecting the
  extracted tree manually with `read`/`glob`/`grep`: the config lives in the
  top-level `*Db.xml` (`<PhoneSystem>` root), and call/CDR data live in
  `DbTables/*.csv`.

### 3. What the report contains

The generated Markdown includes, when present in the backup:

- **System Overview** — 3CX version, backup date, company, license key/contact,
  reseller, admin email, external/internal FQDN, domain code, recording/backup
  paths.
- **Mail / SMTP Settings** — host, port, from address, auth user, password, TLS.
- **Inventory Summary** — counts of extensions (and how many enabled), ring
  groups, queues, IVRs, trunks, park/fax/conference extensions.
- **Groups** — name, number, member counts.
- **Extensions** — number, name, email, enabled, VM enabled, call recording,
  AuthID, AuthPassword, VM PIN.
- **Trunks / VoIP Providers** — per trunk: direction, simultaneous calls, auth
  ID/password, gateway type, SIP host/port, registration mode, and the **DIDs /
  inbound rules** on each trunk with office-hours and out-of-hours destinations.
- **Queues** — polling strategy, ring/master timeouts, prompts, and agent list.
- **IVRs / Digital Receptionists** — number, name, prompt file, timeout.
- **Outbound Rules** — name, prefix, digit/length rules.
- **Data Tables** — row counts for call history, CDR output/billing, queue
  calls, dropped calls, call log, recordings, voicemail, audit log.
- **Certificates** — list of certificate files in the backup.
- **Notable System Parameters** — park codes, echo test, fax, conference, operator.

### 4. Report findings in chat, then ask

Before writing the summary, re-read the saved `.md` file you just generated.
Quote the 3CX version, company, and counts directly from that file. Never recall
or guess these values from memory — if it is not in the saved report, do not say
it.

After the file is saved, give a short chat summary that includes:

- Where the report was saved (workspace-relative path).
- A high-level overview pulled from the report: 3CX version, company, FQDN,
  extension count (and enabled), queue/IVR/trunk counts, and the list of DIDs.
- 2-4 concrete example findings from this specific backup (e.g. a couple of named
  extensions, a trunk/provider name + SIP host, a DID and where it routes).

Then ask what the technician needs next. Use a short, targeted question such as:

> The full audit is saved at `<path>`. High level: 3CX <version>, <N> extensions
> (<M> enabled), <Q> queues, <T> trunks, DIDs: <list>. What would you like to dig
> into — extensions, trunk/DID routing, queues/IVRs, call-data volumes, or
> something else?

Do not dump every credential table into chat unprompted; point to the saved file.

## Style Rules

- Report facts from the backup only. Do not fabricate config, KB, or web sources.
- If a section is empty in the backup, say so rather than omitting silently.
- Keep the chat summary concise; the Markdown file is the detailed deliverable.
- Mention the workspace-relative path of the saved report.

## OpenWork Safety Rules

- Never modify the original backup file.
- Extract to a temp/working folder, not into committed repo paths.
- The saved Markdown contains unredacted credentials by design — save it under
  `artifacts/3cx-audit/` and treat it as sensitive. Do not commit it to git.
- Do not paste credentials, license keys, or PINs into web searches or any
  external tool.
