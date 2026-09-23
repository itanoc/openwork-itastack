# Medium Prototype

Generate the **same content in 3 different output formats** so the user can see which medium works best for the audience and purpose.

If the question is about structure/narrative rather than format — wrong branch. Use [STRUCTURE.md](STRUCTURE.md).

## When this is the right shape

- "Should I send this as a report, a slide deck, or a diagram?"
- "I'm not sure this client will read a long document — what else could I give them?"
- "We need to present this finding to the board, the team, and the client — different formats."
- Any time the content is known but the *delivery medium* is the open question.

## Three default variants

Default to these 3 output types unless the user specifies otherwise:

| Variant | Format | Best for |
|---|---|---|
| **A — Report** | Markdown (.md) | Reading in Teams/email; easy editing; print-to-PDF |
| **B — Slides** | PowerPoint (.pptx) | Client/internal presentation; meeting walkthrough |
| **C — Diagram** | Excalidraw (.excalidraw) | Whiteboard review; architecture/process overview; async feedback |

If the user's question involves a different set of formats (e.g. CSV vs report vs slides), adjust accordingly.

## Process

### 1. State the question and the content

Before drafting, write down (in this message or a quick note to the user):

1. What is the one piece of content being prototyped?
2. Who is the audience for each format?
3. What is the user trying to learn by comparing formats?

Example:
> "Monthly security summary for Client X. Same data in 3 formats — trying to see whether the board prefers slides while the ops team needs the report."

### 2. Draft all 3 variants

Create files under `prototype/` with names that make the variant clear:

| Variant | File |
|---|---|
| A — Report | `prototype/wip-medium-report.md` |
| B — Slides | `prototype/wip-medium-slides.pptx` |
| C — Diagram | `prototype/wip-medium-diagram.excalidraw` |

Drafting rules per format:

- **Report (.md):** Short sections, clear headings, tables where useful. One page max unless the content genuinely needs more. Bullets over paragraphs. The report is a snapshot, not a novel.
- **Slides (.pptx):** 5-7 slides max. Title, key finding, supporting detail, recommendation, next steps. One idea per slide. Use simple built-in layouts — no master slide fussing.
- **Diagram (.excalidraw):** One canvas. Main idea in the center, supporting elements branching out. Keep it to 10-15 elements max. Use the Excalidraw skill to create and preview it.

### 3. Surface a comparison

After drafting all 3, present a quick table showing what each variant prioritizes:

| Dimension | Report | Slides | Diagram |
|---|---|---|---|
| Reading time | 3-5 min | 5-7 min presented | 30 sec scan |
| Level of detail | High | Medium | Low |
| Best audience | Detail-oriented / async | Meeting attendees | Visual / exec summary |
| Easiest to edit | Yes | Medium | Medium |

### 4. Hand it over

Ask the user to compare. Key signals to listen for:

- "I want the detail from A but the format of B" — hybrid approach, promote accordingly.
- "C is the closest but needs more X" — iterate the winner.
- "None of these — let me describe what I actually need" — pivot, don't polish.

### 5. Capture the answer and clean up

When a winner is chosen:

1. Promote the winning file to its real location (e.g. `reports/client-x-monthly.md`, `slides/client-x-board.pptx`).
2. Polish it (proper formatting, images if needed, proofread).
3. Delete the `prototype/` directory.
4. Note the decision: "Client X monthly — board prefers slides, ops team gets report, diagram was too abstract."

## Anti-patterns

- **All 3 variants have the same structure.** If the report, slides, and diagram all organize information identically, the user learns nothing about format fit. Let each format play to its strength — slides shouldn't be a report in slide templates.
- **Polishing before the choice is made.** No stock photos, no slide transitions, no report cover art. The question is *which format*, not *how pretty*.
- **Choosing for the user.** Present the variants and let them pick. Your job is to make the tradeoffs visible, not to decide.
- **Making more than 3 variants.** Three is enough to explore the space. Four starts being noise. If the user hates all 3, ask what's missing and pivot.