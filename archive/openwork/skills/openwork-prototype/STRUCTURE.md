# Structure Prototype

Generate **3 different organizational approaches** in the same output format so the user can see which narrative structure works best for the audience.

If the question is about format/medium rather than structure — wrong branch. Use [MEDIUM.md](MEDIUM.md).

## When this is the right shape

- "I know it should be a report, but I'm stuck on how to organize it."
- "Should I lead with the problem or the solution?"
- "This client has seen 5 of these reports — I need a fresh narrative."
- "My draft is dense and I can't tell if it flows."
- Any time the output format is settled but the *organization and narrative* is the open question.

## Three default structures

Default to these 3 narrative structures unless the user specifies otherwise:

| Variant | Structure | Best for |
|---|---|---|
| **A — Executive Summary First** | Bottom-line up top → supporting detail → appendix | Busy stakeholders who want the answer before the reasoning |
| **B — Chronological / Story Arc** | Context → what happened → what we did → outcome → next steps | Walkthroughs, incident post-mortems, project recaps |
| **C — Problem-Solution (Consulting)** | Problem statement → analysis → options → recommendation → action plan | Recommendations, proposals, decision memos |

If the user's content calls for a different set (e.g. FAQ, comparison, tutorial), adjust accordingly.

## Process

### 1. State the question and pick the format

Before drafting, confirm:

1. What output format is settled? (Markdown, PPTX, etc.)
2. Who is the audience and what do they care about most?
3. What is the user trying to learn by comparing structures?

Example:
> "Monthly security posture report as Markdown. Same data, 3 structures. Ops team needs quick answers; client wants the story; CISO needs a recommendation. Trying to see which serves all three."

### 2. Draft all 3 variants

Create files under `prototype/` with names that make the variant clear:

| Variant | File |
|---|---|
| A — Executive Summary | `prototype/wip-structure-exec-summary.md` |
| B — Chronological | `prototype/wip-structure-chronological.md` |
| C — Problem-Solution | `prototype/wip-structure-problem-solution.md` |

(Adjust the extension if the settled format is PPTX, Excalidraw, etc.)

Drafting rules per variant:

- **Same source content** in all 3 — don't add or omit information. The question is *arrangement*, not completeness.
- **Each variant is self-contained** — someone opening just that file should understand it.
- **Use real headings, real section breaks, real sentences** — not placeholder lorem ipsum. The user needs to feel the reading experience.
- **Keep each draft to roughly the same length** — don't accidentally make one variant longer by adding detail.

### 3. Surface a comparison

After drafting all 3, present a quick table:

| Dimension | Exec Summary | Chronological | Problem-Solution |
|---|---|---|---|
| First thing reader sees | The conclusion | The context | The problem |
| Reading experience | Skimmable | Narrative | Analytical |
| Best for | Decisions | Understanding | Recommendations |
| Risk | Reader skips the reasoning | Lose impatient readers | Feels cold |

### 4. Hand it over

Ask the user to compare. Key signals:

- "A is closest but I want the recommendation section from C" — hybridize.
- "B but cut the timeline table and lead with the outcome" — tweak the winner.
- "None of these — the real audience is X, not Y" — pivot.

### 5. Capture the answer and clean up

When a winner is chosen:

1. Promote the winning structure to the real deliverable path (e.g. `reports/client-q2-security.md`).
2. Polish it (expand sections, proofread, add formatting).
3. Delete the `prototype/` directory.
4. Note the decision: "Client Q2 security report — exec summary structure won because the ops team needs quick answers; kept the recommendation section from C."

## Anti-patterns

- **Variants that differ only in wording, not structure.** Moving paragraphs around is structure. Using synonyms is not. If two variants have the same section order and heading hierarchy, they're the same structure.
- **Accidentally omitting content.** All 3 variants must contain the same facts and data. Removing information from one variant makes the comparison unfair.
- **Choosing novelty over clarity.** A clever structure that confuses the audience is not an improvement. The point is to find what works, not what's surprising.
- **Polishing layout before structure is settled.** Bold, italic, colours, spacing — that's post-decision work. Keep all 3 in plain, readable text until one wins.