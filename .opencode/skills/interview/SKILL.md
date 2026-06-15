---
name: interview
description: Conduct a thorough interview about project plans, ideas, goals, or technical decisions. Use when user wants to be interviewed about a plan, design, architecture, workflow, documentation change, or OpenWork behavior — drills into reasoning with one question at a time across technical, operational, security, testing, business, and workflow tradeoff dimensions.
---

# Interview

Conduct a thorough interview about project plans, ideas, goals, technical decisions, office workflows, documentation changes, or OpenWork behavior. $ARGUMENTS

## Phase 1 — Context Gathering

Before first question:

1. Determine interview topic from user request. If user gave no topic, ask one scoping question first.
2. Check relevant workspace context before asking detailed questions:
   - For project/code work: `AGENTS.md`, `CLAUDE.md`, `README.md`, `wiki/index.md`, `wiki/ROUTING.md` when present.
   - For OpenWork behavior: relevant docs under `packages/docs/` when available, then implementation only if docs are missing or stale.
   - For personal workflow or communication preferences: promoted memory under `memory/` only when relevant.
3. Extract only useful constraints: project type, architecture, audience, approval rules, privacy constraints, existing services, known risks, and deadline or business constraints.
4. If user specified scope, stay inside it. Do not broaden into unrelated architecture, process, or product questions.
5. Explore project structure lightly only when needed; avoid broad repo scans unless context is missing.

## Phase 2 — Interview

Ask questions **one at a time**. Do not batch multiple questions.

Ask sharp, context-aware questions. Avoid obvious questions unless truly unknown and blocking.

Avoid questions like:

- "What language will you use?" when repo already shows it.
- "How many users?" unless scale is central to decision.
- "What is your goal?" when user already stated it.

Ask probing questions like:

- "How will you handle [specific failure mode] given [observed constraint]?"
- "What is rollback path if [change] creates client impact?"
- "What happens if [assumption] turns out false?"
- "What private data or credentials could this touch, and where should they not be stored?"
- "How will support know this worked without reading implementation details?"

Rotate through relevant categories:

- Technical implementation: architecture, data flow, edge cases, error handling
- Operational: deployment, rollback, monitoring, ownership, handoff
- Security/privacy: secrets, client data, audit trail, least privilege
- Testing/validation: acceptance criteria, regression tests, manual checks
- Business tradeoffs: cost, complexity, maintainability, user impact
- Workflow/documentation: approval point, audience, artifact format, reuse as skill/agent/checklist

Apply patterns:

- **Five Whys**: drill into reasoning behind decisions.
- **Premortem**: "Pretend this failed later — what went wrong?"
- **Constraint challenge**: "What if you could not use X?"
- **Edge case hunt**: "What happens when [unexpected input] occurs?"
- **Alternative challenge**: "Why not [different approach]?"
- **Approval checkpoint**: "Is this discussion only, or should this become a file change after we decide?"

Continue until user says they are done, all major topics are covered, or next useful step is clear.

## Phase 3 — Summary

When user ends interview or asks for recap, output structured summary:

```markdown
## Interview Summary

### Topic
### Questions Asked
### Areas Covered
### Key Discussion Points
### Decisions Made
### Concerns & Risks Identified
### Action Items / Follow-up
### Open Questions to Revisit
### Suggested Next OpenWork Action
```

Include:

- Number of questions asked.
- Which areas were covered.
- Critical gaps that remain.
- Whether discussion produced durable knowledge that should become memory, wiki content, skill, agent, checklist, or artifact.

Do not edit files from interview output unless user explicitly approves the change.
