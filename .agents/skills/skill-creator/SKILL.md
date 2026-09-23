---
name: skill-creator
description: Guide for creating or editing a skill. Use when the user wants to
  create, author, update, or improve a skill that extends OpenCode/OpenWork with
  specialized knowledge, workflows, or tool integrations.
metadata:
  route_default: medium
  route_max: high
  route_class: skill_creator
---

<<<ROUTE default=medium max=high class=skill_creator>>>

# Skill Creator

Author a skill so it runs **predictably** — the agent takes the same process
every invocation. A skill is a folder under `.agents/skills/<skill-name>/`
(preferred in OpenWork) or `.claude/skills/<skill-name>/`, anchored by
`SKILL.md`. Follow the steps in order.

The authoring vocabulary this skill uses — **predictability**, **context load**,
**progressive disclosure**, **leading word**, **completion criterion**,
**premature completion** — is defined in `writing-great-skills`
(`~/dotfiles/.claude/skills/writing-great-skills/SKILL.md` and its
`GLOSSARY.md`). Read it before authoring anything non-trivial.

## Steps

1. **Fix invocation.** Decide model-invoked (keep `description`, agent can fire
   it) vs user-invoked (`disable-model-invocation: true`, only the human fires
   it, zero **context load**). Choose model-invocation only when the agent must
   reach it on its own. _Done when:_ the invocation choice is made and matches
   how the skill will actually be reached.

2. **Write the description** (model-invoked only). State what the skill is, then
   list one trigger per distinct case using the **leading words** you actually
   type when you want the skill. Collapse synonyms that rename one case.
   _Done when:_ the description names the skill and every genuinely distinct
   trigger, with no restated case.

3. **Draft the body as steps + reference.** Put ordered actions as numbered
   steps; put definitions, rules, and facts as reference. Each step ends on a
   **completion criterion** that is checkable (can the agent tell done from
   not-done?) and, where it matters, exhaustive ("every X accounted for"), so
   the agent does not slip into **premature completion**. _Done when:_ every
   step has a checkable completion criterion and every reference block earns its
   place.

4. **Disclose and co-locate.** Inline what every run needs; push reference only
   some runs reach behind a **context pointer** into a sibling file (named for
   what it holds). Keep a concept's definition, rules, and caveats under one
   heading. _Done when:_ `SKILL.md` reads top-to-bottom without burying the
   steps, and disclosed material is reachable by a clearly worded pointer.

5. **Prune.** Give each meaning a single home (no **duplication**). Delete any
   sentence the model already obeys by default (a **no-op**) and any line that
   no longer bears on the task. Be aggressive. _Done when:_ no sentence can be
   removed without losing behaviour.

6. **Write the file.** Use a file mutation tool (`write`, `edit`, or
   `apply_patch`) on the real path `.agents/skills/<skill-name>/SKILL.md` —
   never paste the whole skill into chat. Add supporting files (`templates/`,
   `scripts/`, disclosed `.md`) only if the steps reference them. _Done when:_
   the file exists at the real path so OpenWork shows the reload banner.

## Frontmatter template

```yaml
---
name: my-skill
description: |
  [What it does in one sentence.] Use when the user wants to
  [trigger case 1], mentions [trigger case 2], or [trigger case 3].
---
```

For a user-invoked skill, add `disable-model-invocation: true` and make the
`description` a plain one-line human summary (no trigger list).
