---
name: openwork-prototype
description: Create throwaway office-document drafts to compare delivery mediums or narrative structures. Use when a user wants to test three artifact directions before selecting one.
metadata:
  route_default: daily
  route_max: medium
  route_class: prototype
---

<<<ROUTE default=daily max=medium class=prototype>>>

# OpenWork prototype

A prototype is a throwaway document draft that answers a question. The question decides the shape.

## Pick a branch

Identify which question is being answered from the user's prompt. Ask when it is ambiguous.

- "What delivery medium works best for this content?" → Read [MEDIUM.md](MEDIUM.md). Generate the same information as three output types: a Markdown report, PowerPoint deck, and flowchart or diagram.
- "How should I structure this narrative?" → Read [STRUCTURE.md](STRUCTURE.md). Generate three organizational approaches in the same output type: executive-summary-first, chronological, and problem-solution.

If the question remains ambiguous and the user is unavailable, use the delivery-medium branch and state that assumption.

## Rules

1. Create clearly named drafts under `prototype/` at the workspace root.
2. Use formats that open without a build step: Markdown, CSV, Excel, PowerPoint, or Excalidraw.
3. Treat drafts as session-only unless the user asks to keep working on them.
4. Skip polish; the purpose is to choose a direction quickly.
5. Present all three variants side by side with a short comparison table.
6. When the question is answered, delete the drafts or promote the selected variant to its real location.

Record the selected direction and its reason in a durable place only if the user asks or if project guidance requires it.
