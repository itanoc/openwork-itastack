---
name: cli-handoff
description: |
  Create a terse unattended Windows remediation-or-investigation handoff prompt for the `pi` CLI agent from current chat/session context, often after Halo ticket research.

  Triggers when user mentions:
  - "cli handoff"
  - "pi handoff"
  - "handoff for pi"
  - "copy-paste prompt for pi"
  - "pi remediation"
---

# CLI Handoff

Be extremely concise. Sacrifice grammar for concision in chat output.

Use this skill when user asks for one copy-paste prompt for `pi` CLI coding agent to run unattended on a client Windows host, PowerShell 5.1+. This is commonly used after `halo-ticket-research` when a technician needs pi to try a safe fix first, then gather evidence for a ticket update if the fix cannot be completed safely.

Goal: distill current OpenWork chat/session into exactly two sections: short human handoff summary and one terse self-contained pi prompt that either performs a safe remediation or gathers ticket-update evidence.

## Hard Rules

- Do not run tools for the handoff unless user explicitly asks to gather more facts first.
- Use only facts already present in current chat/session.
- Do not invent host, user, timestamp, IDs, evidence, or hypotheses.
- If required facts are missing, use `<<REPLACE_ME:name>>` placeholders.
- Redact secrets as `<<REPLACE_ME:secret_name>>`.
- Prefer safe remediation when current session contains a clearly recommended low-risk fix.
- If remediation is unsafe, ambiguous, privileged, disruptive, or likely to affect production, pi must skip remediation and gather evidence for a ticket update instead.
- Section 2 must be self-contained; pasting only fenced block into pi must be enough to run unattended after placeholders are replaced.
- Safety words are non-negotiable in section 2: include `read-only`, `Do not modify anything`, and `silently — no popups`.
- For remediation prompts, safety wording must say baseline mode is read-only and the only allowed state change is the explicitly named safe remediation.
- Section 2 fenced block target length: 700-1300 characters, hard cap 1500 characters.
- After section 2 fenced block, print exact character count as `chars: <N>`.
- If section 2 exceeds 1500 chars, shorten before responding.

## Output Structure

Return exactly two sections, in this order.

```md
## 1. Handoff summary (for human, ~8 lines)
- One-line problem statement.
- Target host / user / timestamp / key IDs already known.
- Known evidence: event IDs, process names, paths, IPs, error codes.
- What chat already ruled out.
- Recommended safe remediation, if any.
- Top 2-3 hypotheses or next steps still worth testing, ranked.
- Required `<<REPLACE_ME>>` tokens operator must fill before pasting.
- Safety note if host access, privilege, or business impact is unclear.
- Report filename pi should create.

## 2. Copy-paste prompt for pi
```text
ONE PARAGRAPH ONLY
```
chars: <N>
```

## Section 2 Required Content

Write one paragraph of natural-language prose addressed to pi. No headers, bullets, nested code blocks, or markdown inside fenced block.

Compress content in this order:

1. Action + scope: `Perform a silent safe-remediation attempt for <ticket/problem> on <host> for <user> at <timestamp>, then fall back to read-only evidence gathering if remediation is unsafe or fails.`
2. Known ticket context/evidence in one sentence: only relevant ticket IDs, symptoms, event IDs, process names, paths, IPs, error codes, prior research conclusions.
3. Safety clause: `Default to read-only. Do not modify anything except the explicitly named safe remediation. Run silently — no popups, no UAC, no new windows, no interactive prompts. Skip any probe or fix that needs elevation, restart, service interruption, data deletion, policy/registry/security change, install, user contact, or user disruption.`
4. Safe remediation ask in one sentence: attempt only the clearly named low-risk fix from the ticket research; verify success using read-only checks; stop after first successful fix.
5. Fallback data collection in one comma-separated sentence: relevant Windows logs, ±15-30 minute window or ticket-relevant window, processes, services, scheduled tasks, network, recent files, app state, and error output as applicable.
6. Analysis ask: `Determine whether the fix succeeded, failed safely, was skipped as unsafe, or remains inconclusive.`
7. Output ask: `Save a markdown report to pi's current project directory as pi-report-<timestamp>.md and echo it to stdout. Do not write files outside pi's current project directory except the explicitly named safe remediation. Include executive summary, attempted fix, verification, key evidence, ticket update draft, gaps, and recommended next step.`

## Style Exemplar

Match this style: terse, declarative, single paragraph, no list.

```text
Perform a read-only investigation of Blumira finding F-26-20-9B67 on mti-fs01 for user marc.manzanares at 2026-05-18T14:56:23Z. Evidence shows Windows 4624 Logon Type 9, logon process seclogo, process C:\Windows\System32\svchost.exe, client_ip ::1, host IP 10.0.0.177. Do not modify anything. Run silently — no popups, no UAC, no new windows, no interactive prompts. Skip any probe that needs elevation or state change. Collect Security, Sysmon, PowerShell, service, scheduled task, process, network, and recent file evidence around ±30 minutes. Determine whether this is pass-the-hash, expected admin/service activity, or inconclusive. Save a markdown report to pi's current project directory as pi-report-20260518T145623Z.md and echo it to stdout. Include executive summary, key evidence, timeline, suspicious indicators, gaps, and next steps.
```

Remediation-oriented exemplar:

```text
Perform a silent safe-remediation attempt for Halo ticket 123456 printer mapping failure on ws-01 for user jane.doe at 2026-06-15T14:00:00Z, then fall back to read-only evidence gathering if remediation is unsafe or fails. Ticket research indicates the likely issue is a stale per-user printer connection to \\print01\copier with error 0x00000709. Default to read-only. Do not modify anything except the explicitly named safe remediation. Run silently — no popups, no UAC, no new windows, no interactive prompts. Skip any probe or fix that needs elevation, restart, service interruption, data deletion, policy/registry/security change, install, user contact, or user disruption. Attempt only reconnecting the named per-user printer mapping if it can be done without elevation, then verify default printer and test visibility with read-only checks. If not fixed, collect print service, Application, System, relevant app logs, printer state, spooler status, mapped printers, recent errors, and user-context evidence. Determine whether the fix succeeded, failed safely, was skipped as unsafe, or remains inconclusive. Save a markdown report to pi's current project directory as pi-report-20260615T140000Z.md and echo it to stdout. Do not write files outside pi's current project directory except the explicitly named safe remediation. Include executive summary, attempted fix, verification, key evidence, ticket update draft, gaps, and recommended next step.
```

## Character Count Method

- Count characters inside section 2 fenced block only.
- Include spaces and punctuation.
- Exclude opening and closing fences.
- For normal use, estimate conservatively and stay well under 1500.
- Use a local Python or shell count only when user explicitly asks for exact-count validation or allows tool use for handoff generation.

## Missing Data Handling

Common placeholders:

- `<<REPLACE_ME:thing>>`
- `<<REPLACE_ME:host>>`
- `<<REPLACE_ME:user>>`
- `<<REPLACE_ME:timestamp>>`
- `<<REPLACE_ME:key_id>>`
- `<<REPLACE_ME:evidence>>`
- `<<REPLACE_ME:safe_fix>>`
- `<<REPLACE_ME:hypothesis_A>>`
- `<<REPLACE_ME:hypothesis_B>>`

Keep placeholders short. List every placeholder in section 1. Reuse same placeholders in section 2 so operator can replace them before pasting.

## Safety Defaults

- Favor read-only Windows evidence collection.
- Allow remediation only when the current session names a low-risk, reversible, user-scoped fix.
- Safe examples: reconnect one explicitly named per-user printer, clear one explicitly named non-business app cache/temp path from ticket research, close/reopen one explicitly named user-mode app only if it is not running or user approved, refresh one explicitly named user-context mapped drive, repair one explicitly named non-production shortcut, run a built-in read-only diagnostic.
- Unsafe examples: registry edits, service restarts, scheduled task changes, firewall changes, account changes, EDR/AV changes, Group Policy changes, installs/uninstalls, driver changes, deleting business data, reboot/logoff, broad cleanup, tenant/cloud changes.
- Never ask pi to change registry, services, tasks, files, firewall, users, sessions, EDR, AV, policy, or production state unless the user explicitly approved that exact action in the current chat.
- Tell pi to skip probes or fixes requiring elevation or state change outside the explicitly allowed remediation.
- Avoid interactive commands, GUI commands, browser popups, UAC prompts, new windows, installs, downloads, restarts, logoffs, disconnecting sessions, contacting users, killing active business apps, and remoting changes.
- Tell pi to write only the markdown report in pi's current project directory unless performing the explicitly named safe remediation.
- If evidence may include sensitive client data, ask pi to summarize and redact secrets in report.

## Ticket Update Draft Requirements

When remediation fails or is skipped, make pi include a concise ticket update draft:

- What was attempted or why remediation was skipped.
- Verification result.
- Evidence found.
- Likely cause or remaining uncertainty.
- Recommended next step for technician or client.
