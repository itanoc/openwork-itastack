# Personal Memory Templates

Use Markdown with small YAML frontmatter. Keep entries short and operational. There are no candidates — memory is written only after the user confirms, using the templates below.

## Promoted Topic File

```markdown
---
title: Topic Title
type: preference | doc | voice | email | workflow | context | decision
status: promoted
created: YYYY-MM-DD
updated: YYYY-MM-DD
topics: []
---

## Active memory

- Durable rule or preference.

## Related

- [Related topic](memory/preferences/other-topic.md) - how it relates.

## Notes

- Last reviewed: YYYY-MM-DD
- Superseded rules, if any.
```

## Cross-linking

Memory topics may link to each other with standard markdown links. Use workspace-relative paths that start with `memory/`, for example `[email tone](memory/email/tone-and-format.md)` — the same base `memory/index.md` uses. A link asserts a relationship; the kind of relationship lives in the surrounding prose. Broken links are tolerated — a link to a not-yet-written topic is not an error.

Backlinks ("Cited by") are not stored in files. Compute them at read time by reversing the link graph when it helps retrieval.

## Index

Rows stay link-only (one workspace-relative link per page). Do not add a backlinks column — backlinks are computed at read time. Cross-links between topics live in each topic file's `## Related` section, not here.

```markdown
# Memory Index

## Promoted Memory

| Page | Type | Summary | Updated |
|------|------|---------|---------|
```

## Decision Memory File

```markdown
---
title: Short Decision Title
type: decision
status: promoted
created: YYYY-MM-DD
updated: YYYY-MM-DD
topics: [decision]
---

## Decision

One concise summary of what was decided and why.

## Notes

- Decided during a decision-capture workflow on YYYY-MM-DD.
- Prefer role/process summaries over client names unless the client-specific constraint is essential.
- Supersedes or updates: related memory path, if any.
```

## Ticket Guide

```markdown
---
title: Short Ticket Guide Title
type: guide
status: promoted
created: YYYY-MM-DD
updated: YYYY-MM-DD
last_verified: YYYY-MM-DD
product_vendor: Product or vendor
problem_pattern: Short searchable pattern
risk_level: low | medium | high
source_ticket_id: optional-safe-ticket-id
topics: [ticket-guide]
---

## When to use

One concise description of the reusable ticket pattern.

## Symptoms

- Redacted symptom or error.

## Checks

- Diagnostic check.

## Fix

1. Safe remediation step.

## Verify

- Verification step.

## Notes

- Validation, rollback, source URL, or caution.
```

## glossary.md

Ignored personal entity directory — shorthand → full identity. A single root
file, one row per entity, grouped only under the sections that have content.
Keep entries thin (short form → expansion + a few words of identity); no contact
details or account cruft. Redact per the Safety rules in `README.md`. When first
created, give it its own `index.md` row (it is not in a promoted folder, so
`gate.py audit` will not flag it as missing).

```markdown
---
title: Entity Glossary
type: glossary
status: promoted
created: YYYY-MM-DD
updated: YYYY-MM-DD
topics: [glossary]
---

## Clients
| Short | Identity |
| --- | --- |
| ACME | Acme Corp — managed client since 2023 |

## People
| Shorthand | Identity |
| --- | --- |
| jd | John Doe — Acme IT manager, primary contact |

## Acronyms
| Term | Expansion |
| --- | --- |
| RMM | Remote Monitoring & Management |

## Codenames
| Codename | What |
| --- | --- |
| bluebird | Acme M365 tenant migration |
```

## Log

```markdown
# Memory Log

## YYYY-MM-DD type | Title

- Actor: agent or human
- Inputs: session summary or memory paths
- Outputs: changed memory paths
- Notes: promotion, cleanup, or unresolved question
```

## Default Promoted Topic Files

- `memory/preferences/assistant-style.md`
- `memory/email/tone-and-format.md`
- `memory/voice/voice-mode.md`
- `memory/docs/important-docs.md`
- `memory/workflows/session-end.md`
- `memory/workflows/approval-style.md`
- `memory/decisions/decision-<slug>.md`
- `memory/guides/<product>-<problem>.md`
- `memory/glossary.md` (single file; sections Clients / People / Acronyms / Codenames)
