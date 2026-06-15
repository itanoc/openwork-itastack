---
name: brainstorm-idea
description: |
  Brainstorm, riff on, or creatively explore a raw idea with optional project context and web research before planning or implementation.

  Triggers when user mentions:
  - "brainstorm"
  - "I have an idea"
  - "riff on this"
  - "what could this become"
  - "explore possibilities"
---

# Brainstorm Idea

Use this skill for exploratory, idea-generating conversations where goal is discovery, not commitment.

Prefer this skill when user wants to expand possibilities, make unexpected connections, compare directions, or see where a concept could go.

Do not use it when user already wants a concrete implementation plan, code changes, ticket research, formal requirements, or strict technical design. Use `dev-plan`, `explore`, `interview`, or task-specific skills instead.

## Output Style

- Keep chat responses concise and idea-forward.
- Lead with useful ideas, not process narration.
- Use short bursts, bullets, and options.
- Ask one focused question at a time when needed.
- Do not create long reports unless user asks to save or formalize output.

## OpenWork Tool Mapping

This skill is adapted from an Agent Zero workflow. Use OpenWork equivalents:

| Agent Zero concept | OpenWork equivalent |
| --- | --- |
| `response` | normal chat response, or `question` when multiple-choice input helps |
| `code_execution_tool` | `read`, `glob`, `grep`, and limited `bash` for repo inspection |
| `call_subordinate` | `task` subagents for parallel research or codebase exploration |
| `search_engine` | background-only search through OpenWork extensions when available |
| `document_query` | `webfetch`, `read`, or background extension fetches depending on source |

## Workflow

### 1. Capture Core Idea

Identify:

- core idea in one sentence
- why user cares, if stated
- any requested exploration mode
- any project path or workspace context
- any boundaries: practical, wild, technical, business, client-safe, cost-sensitive, time-sensitive

If idea is missing or too vague, ask one concise clarification question and stop.

If user supplied a project path, verify it exists before relying on it. Use `read` for directories when possible. Use `bash` only for commands that are needed and safe.

If no project path exists, continue without project context.

### 2. Gather Lightweight Context

If current workspace or supplied project context matters, gather only enough context to brainstorm well.

Look for:

- what project or workflow does
- relevant stack, architecture, documents, or process constraints
- existing skills, agents, docs, tickets, or artifacts connected to idea
- natural integration points
- gaps or friction points idea might address

Preferred inspection order:

1. Read `AGENTS.md`, `README*`, `wiki/index.md`, or obvious docs when relevant.
2. Use `glob` and `grep` for targeted discovery.
3. Use helper scripts such as `scripts/ai/context.sh` only when broad repo context is useful.
4. Use `task` with `explore` subagent for medium/broad codebase exploration, not for tiny lookups.

Keep context summary short. This is not design review.

### 3. Frame Idea Back

Before generating many ideas, restate framing in 1-2 sentences.

Then ask one focused question only if answer will materially improve brainstorming.

Useful question patterns:

- "What mode helps most: wild ideas, practical directions, technical angles, or surprising analogies?"
- "What sparked this?"
- "What constraint matters most: speed, cost, user delight, reliability, security, or reuse?"
- "Should this stay exploratory, or should promising ideas turn into next steps?"

When a few clear modes fit, use `question` with options such as:

1. Broad creative exploration
2. Practical product directions
3. Technical concept exploration
4. Surprising cross-domain ideas
5. Mix of all

If user wants deeper structured questioning, load and use `interview` skill.

### 4. Pick Exploration Angles

Turn current understanding into 3-5 distinct angles. Avoid minor wording variants.

Good angle mix:

- product or user experience
- technical system design
- workflow or operations
- business model or adoption path
- adjacent-domain analogy
- contrarian or failure-mode perspective

Present angles briefly and ask how to proceed when needed:

- explore all angles
- focus top 2-3
- revise angles
- skip research and riff directly

If user clearly wants immediate riffing, skip permission loop and continue.

### 5. Background Research Only When It Adds Energy

Use research when external evidence, examples, competitors, implementation patterns, or market context will improve ideas.

Skip research when topic is personal, speculative, private, internal-only, or already clear enough.

Research safety:

- Do not send client-identifying details, private tickets, user emails, internal hostnames, private logs, or secrets to public search/pages.
- Search generic terms, product names, errors, and public concepts.
- Use `webfetch` for known URLs.
- Use background-only search through OpenWork extensions when available.
- Do not open visible browser UI for research as part of this skill.
- Do not use `openwork_browser_open_url`, `browser_snapshot`, `browser_click`, `browser_fill`, `browser_eval`, or `browser_screenshot` for this skill's research phase.
- If search is needed and no background search extension exists, ask user for URLs or continue without web research.
- If needed search capability is unavailable, inspect `openwork_extension_list_actions` before saying unavailable.

For parallel research, use `task` subagents. Assign one angle per subagent:

```text
Research this brainstorming angle for idea: <idea>

Angle: <angle>
Context: <short safe context>

Return:
- 3-5 concise insights
- 1-2 surprising or contrarian findings
- useful source URLs, if any
- no private/client-identifying data
Keep output compact and idea-generative.
```

Synthesize findings into short briefing before riffing.

### 6. Riff Collaboratively

Core behavior:

1. Seed discussion with 2-4 interesting directions.
2. Build on user reactions instead of forcing fixed structure.
3. Connect across domains, patterns, audiences, and technologies.
4. Offer alternatives, combinations, "what if" variants, and smaller versions.
5. Name tensions and tradeoffs without killing momentum.
6. Periodically summarize emerging themes.

Useful idea moves:

- "Smallest useful version"
- "Weird version"
- "Enterprise version"
- "Ops-friendly version"
- "AI-native version"
- "Manual-first version"
- "What this replaces"
- "What this should never become"
- "Failure mode worth designing around"
- "Adjacent domain analogy"

If one direction becomes implementation-oriented, say so and offer to switch to `dev-plan`, `explore`, `prototype`, or `to-issues`. Do not start implementation unless user explicitly approves.

### 7. Capture Session When Useful

When session winds down, summarize:

- core concept
- most interesting directions
- important connections or tensions
- promising next moves
- open questions

Ask whether user wants summary saved unless they already requested an artifact.

Default artifact path:

- `brainstorming/idea-<topic-slug>-<YYYY-MM-DD>.md`

Use normal prose in saved Markdown. Do not include secrets or raw private material. Mention exact workspace-relative path after writing.

## Saved Summary Format

```markdown
# Idea Exploration: <idea>

## Context

<project context or "No project context provided">

## What Sparked This

<brief description, if known>

## Research Findings

- <finding or "No web research performed">

## Ideas Explored

### <direction 1>

- Why it is interesting: <...>
- Risks or tensions: <...>
- Possible extension: <...>

### <direction 2>

- Why it is interesting: <...>
- Risks or tensions: <...>
- Possible extension: <...>

## Connections Made

- <unexpected connection>

## Promising Next Steps

- <next step>

## Open Questions

- <question>
```

## Final Report

When wrapping up, report briefly:

- idea explored
- whether project context was reviewed
- whether web research was performed
- strongest directions that emerged
- any file written and workspace-relative path
- natural next step
