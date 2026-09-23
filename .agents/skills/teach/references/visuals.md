# Teaching visual

Create one picture that makes one teaching claim visible. The visual is evidence for the current reasoning step, not decoration.

## Loop

1. State the exact claim the picture must show in one sentence.
2. Write the smallest useful visual to `.teach/subjects/<subject-slug>/visuals/<topic-slug>-<n>.svg`. Use another format only when SVG cannot represent or preview the idea adequately.
3. Inspect the rendered file with an available image-viewing capability. If none exists, audit the SVG as text and disclose that limitation.
4. Fix wrong arrows, inconsistent symbols, overlap, cropped text, missing units, and any mismatch between picture and claim.
5. Inspect once more.

The visual is complete only after the second inspection finds no material defect.

## Dependency-plan rendering

For every lesson plan, Mermaid is the editable source and SVG is the learner-visible rendering.

1. Derive both files from the same node and edge list. Save the Mermaid source in the active session file and the rendering at `.teach/subjects/<subject-slug>/visuals/<topic-slug>-plan.svg`.
2. Lay out prerequisites before dependents. Make branches, joins, the current edge, and inserted prerequisites visually unambiguous.
3. Inspect and correct the SVG using the loop above.
4. In the learner-facing reply, embed the inspected SVG with Markdown image syntax and an absolute filesystem path: `![Dependency graph](/absolute/path/to/.teach/subjects/<subject-slug>/visuals/<topic-slug>-plan.svg)`.
5. If the interface cannot display the SVG inline, provide a clickable absolute file link and state the limitation. Never fall back to dumping raw Mermaid source into the reply.

## Design rules

- One claim, not a course collage.
- Large labels, strong contrast, and direct annotations.
- Show objects and relationships for algebraic ideas, not a screenshot of an equation.
- Avoid decorative gradients, watermarks, 3D that hides the relation, and irrelevant backgrounds.

Embed or link the visual in the active session file. Show it inline in the learner-facing reply when the interface supports local images. Tell the learner what to inspect first without reteaching the whole node.
