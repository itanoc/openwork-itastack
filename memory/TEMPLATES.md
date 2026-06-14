# Personal Memory Templates

Use Markdown with small YAML frontmatter. Keep entries short and operational.

## Candidate

```markdown
---
title: Short Memory Title
type: preference | doc | voice | email | workflow | context
status: candidate
created: YYYY-MM-DD
updated: YYYY-MM-DD
confidence: low | medium | high
topics: []
source: session
conflicts_with: []
---

## Candidate memory

One concise summary of the possible durable preference or context.

## Evidence

- Short redacted note about why this was captured.

## Promotion question

Should this become promoted memory? If yes, which topic file should own it?
```

## Important Doc Candidate

```markdown
---
title: Important Doc Title
type: doc
status: candidate
created: YYYY-MM-DD
updated: YYYY-MM-DD
confidence: high
topics: []
source: session
conflicts_with: []
---

## Document reference

- Title: 
- Path or URL: 
- Why it matters: 

## Usage guidance

- When should agents consult this doc?

## Promotion question

Promote this to `memory/docs/important-docs.md`?
```

## Promoted Topic File

```markdown
---
title: Topic Title
type: preference | doc | voice | email | workflow | context
status: promoted
created: YYYY-MM-DD
updated: YYYY-MM-DD
topics: []
---

## Active memory

- Durable rule or preference.

## Notes

- Last reviewed: YYYY-MM-DD
- Superseded rules, if any.
```

## Index

```markdown
# Memory Index

## Promoted Memory

| Page | Type | Summary | Updated |
|------|------|---------|---------|

## Candidate Review Queue

Candidates are discoverability aids only. Do not treat them as promoted memory.

| Candidate | Type | Summary | Created | Status |
|-----------|------|---------|---------|--------|
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
