---
name: excalidraw-diagram
description: Create Excalidraw .excalidraw JSON diagrams plus zero-install HTML previews and optional PNG previews. Use when user asks for Excalidraw, diagram, flowchart, architecture diagram, workflow visualization, or visual explanation.
---

# Excalidraw Diagram Creator

Create workspace artifacts that OpenWork can preview and download. Assume teammates may have no `uv`, Python, Node, or other local runtime.

- Source scene: `artifacts/diagrams/<name>.excalidraw`
- Zero-install preview: `artifacts/diagrams/<name>.html`
- Optional rendered preview: `artifacts/diagrams/<name>.png`
- Optional local editor URL from `scripts/export_to_excalidraw_url.py` when Python is available

Keep chat responses concise. Lead with artifact paths and any local URL.

## Zero-install default

Always create these two files first:

- `artifacts/diagrams/<name>.excalidraw`
- `artifacts/diagrams/<name>.html`

The `.html` preview must use browser-native SVG/JS only and fetch the sibling `.excalidraw` file. No local install required. Use `references/html-preview-template.html` as the starting point.

If opened directly with `file://`, some browsers may block loading the sibling `.excalidraw` file. OpenWork preview or any static file server should work. If blocked, the `.excalidraw` file can still be opened manually in <https://excalidraw.com>.

## Optional PNG setup

PNG export is optional. Use only when local tools exist.

### Preferred: uv available

From workspace root:

macOS/Linux shell:

```bash
cd .opencode/skills/excalidraw-diagram/scripts && uv sync && uv run playwright install chromium
```

Windows PowerShell:

```powershell
cd .opencode\skills\excalidraw-diagram\scripts; uv sync; uv run playwright install chromium
```

Render:

macOS/Linux shell:

```bash
cd .opencode/skills/excalidraw-diagram/scripts && uv run python render_excalidraw.py ../../../../artifacts/diagrams/my-diagram.excalidraw
```

Windows PowerShell:

```powershell
cd .opencode\skills\excalidraw-diagram\scripts; uv run python render_excalidraw.py ..\..\..\..\artifacts\diagrams\my-diagram.excalidraw
```

### Fallback: Python available, uv missing

macOS/Linux shell:

```bash
cd .opencode/skills/excalidraw-diagram/scripts
python3 -m venv .venv
. .venv/bin/activate
python -m pip install -U pip
python -m pip install playwright
python -m playwright install chromium
```

Windows PowerShell:

```powershell
cd .opencode\skills\excalidraw-diagram\scripts
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -U pip
python -m pip install playwright
python -m playwright install chromium
```

Render:

macOS/Linux shell:

```bash
cd .opencode/skills/excalidraw-diagram/scripts
. .venv/bin/activate
python render_excalidraw.py ../../../../artifacts/diagrams/my-diagram.excalidraw
```

Windows PowerShell:

```powershell
cd .opencode\skills\excalidraw-diagram\scripts
.\.venv\Scripts\Activate.ps1
python render_excalidraw.py ..\..\..\..\artifacts\diagrams\my-diagram.excalidraw
```

Output PNG is written next to source `.excalidraw` file.

### Fallback: no Python and no uv

Skip PNG generation. Create the zero-install `.html` preview and mention that PNG export requires Python/uv or manual export from Excalidraw.

## Optional local Excalidraw editor

Requires Python. If Python is unavailable, tell user to upload/open the `.excalidraw` file at <https://excalidraw.com>.

With uv:

macOS/Linux shell:

```bash
cd .opencode/skills/excalidraw-diagram/scripts && uv run python export_to_excalidraw_url.py ../../../../artifacts/diagrams/my-diagram.excalidraw --port 0
```

Windows PowerShell:

```powershell
cd .opencode\skills\excalidraw-diagram\scripts; uv run python export_to_excalidraw_url.py ..\..\..\..\artifacts\diagrams\my-diagram.excalidraw --port 0
```

With venv:

macOS/Linux shell:

```bash
cd .opencode/skills/excalidraw-diagram/scripts
. .venv/bin/activate
python export_to_excalidraw_url.py ../../../../artifacts/diagrams/my-diagram.excalidraw --port 0
```

Windows PowerShell:

```powershell
cd .opencode\skills\excalidraw-diagram\scripts
.\.venv\Scripts\Activate.ps1
python export_to_excalidraw_url.py ..\..\..\..\artifacts\diagrams\my-diagram.excalidraw --port 0
```

Script prints `http://127.0.0.1:<port>`. Open that URL with OpenWork browser if user wants visual editing.

## Required references

Read before generating JSON:

- `references/color-palette.md` — single source of truth for colors.
- `references/element-templates.md` — copyable element shapes.
- `references/json-schema.md` — compact schema reference.
- `references/html-preview-template.html` — zero-install browser preview template.

Do not invent colors. Use palette semantics.

## Core philosophy

Diagrams should **argue visually**, not merely display labels.

Tests:

- **Isomorphism test**: If text disappeared, would structure still communicate concept?
- **Education test**: Can viewer learn something concrete from visual examples?

## Depth assessment

Before drawing, decide depth:

### Simple / conceptual

Use abstract shapes when:

- Explaining mental model or philosophy.
- Audience does not need implementation details.
- Concept itself is abstraction.

### Comprehensive / technical

Use concrete examples when:

- Diagramming real system, protocol, architecture, API, or workflow.
- Diagram teaches how something actually works.
- Audience needs real formats, names, payloads, or endpoints.

For technical diagrams, research actual specs and include evidence artifacts.

## Technical research mandate

Before drawing technical diagrams:

1. Look up actual JSON/data formats, event names, method names, API endpoints, or config fields.
2. Understand how pieces connect.
3. Use real terminology, not generic placeholders.
4. Include concrete snippets or examples where useful.

Bad: `Protocol → Frontend`

Good: `AG-UI streams RUN_STARTED + STATE_DELTA → frontend handler renders state`

## Evidence artifacts

Evidence artifacts prove accuracy and teach concrete shape of system.

Use relevant types:

| Artifact type | When to use | Rendering style |
| --- | --- | --- |
| Code snippets | APIs, integrations, implementation | Dark rectangle + syntax-colored text |
| JSON/data examples | Payloads, schemas, config | Dark rectangle + green text `#22c55e` |
| Event sequences | Protocols, lifecycles | Timeline line + dots + labels |
| UI mockups | Visible user output | Nested rectangles mimicking UI |
| Real input content | System input | Rectangle with sample content |
| API/method names | Interfaces | Actual names from docs |

## Multi-zoom architecture

Comprehensive diagrams should show:

1. **Summary flow** — pipeline at glance.
2. **Section boundaries** — grouped regions.
3. **Detail inside sections** — evidence artifacts and concrete examples.

## Container discipline

Default to free-floating text. Use containers only when shape carries meaning or grouping is needed.

Aim for less than 30% of text inside containers.

Use container when:

- Focal point of section.
- Visual grouping needed.
- Arrows connect to it.
- Shape itself carries meaning.

Use free-floating text when:

- Label, annotation, metadata, section title.
- Typography alone creates hierarchy.

## Design process

Do this before JSON:

1. **Assess depth** — simple/conceptual or comprehensive/technical.
2. **Research if technical** — actual specs, names, formats.
3. **Understand concepts** — what each concept does, relationships, transformation, what viewer must see.
4. **Map concepts to visual patterns**.
5. **Sketch eye flow** — left-to-right, top-to-bottom, radial, or cycle.
6. **Generate JSON** — section by section for large diagrams.
7. **Preview and validate** — use HTML preview first; PNG if available.

## Pattern library

| Concept behavior | Use pattern |
| --- | --- |
| Spawns multiple outputs | Fan-out, radial arrows from center |
| Combines inputs | Convergence/funnel |
| Has hierarchy | Tree lines + free-floating labels |
| Is sequence | Timeline line + dots |
| Loops/improves | Cycle/spiral |
| Is fuzzy context | Overlapping ellipses/cloud |
| Transforms input to output | Assembly line |
| Compares | Side-by-side contrast |
| Separates phases | Visual gap or divider |

Each major concept in multi-concept diagram should use distinct visual pattern.

## Shape meaning

| Concept type | Shape |
| --- | --- |
| Labels/descriptions/details | Text only |
| Section titles/annotations | Text only |
| Timeline markers/bullets | Small ellipse |
| Start/trigger/input | Ellipse |
| End/output/result | Ellipse |
| Decision/condition | Diamond |
| Process/action/step | Rectangle |
| Abstract state/context | Overlapping ellipses |

## Style rules

- `roughness: 0` for clean technical diagrams.
- `opacity: 100` for all elements.
- `strokeWidth: 1` thin, `2` standard, `3` bold sparingly.
- Use whitespace as hierarchy; important elements get 200px+ breathing room.
- Connections required: if A relates to B, add arrow or structural line.
- Text `fontFamily: 3`.
- Text `text` and `originalText` contain readable words only.
- Use `appState.viewBackgroundColor: "#ffffff"`.

Base JSON:

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "https://excalidraw.com",
  "elements": [],
  "appState": {
    "viewBackgroundColor": "#ffffff",
    "gridSize": 20
  },
  "files": {}
}
```

## Large diagram strategy

Build section-by-section:

1. Create wrapper and first section.
2. Add one section per step.
3. Use descriptive IDs: `intake_rect`, `risk_arrow`, `summary_text`.
4. Namespace seeds by section: `100001`, `200001`, etc.
5. Verify bindings reference existing elements.

Do not write generator scripts for one-off diagrams. Hand-authored JSON is easier to adjust.

## Preview-view-fix loop

Visual validation is required after creating or editing diagram JSON. Do not require Python.

1. Create or update `.html` zero-install preview from `references/html-preview-template.html`.
2. If Python/uv is available, also render `.excalidraw` to `.png`.
3. View HTML preview or PNG preview.
4. Audit concept:
   - Structure matches intended argument?
   - Eye flows in designed order?
   - Visual hierarchy clear?
5. Audit defects:
   - Text clipped or overflowing.
   - Text/shapes overlap.
   - Arrows cross through elements unnecessarily.
   - Arrows land on wrong targets or empty space.
   - Labels float ambiguously.
   - Spacing uneven.
   - Text too small.
   - Composition lopsided.
6. Fix JSON.
7. Re-preview.
8. Repeat until diagram can be shown without caveats.

## Quality checklist

- Technical research done when needed.
- Evidence artifacts included for technical diagrams.
- Multi-zoom structure present for comprehensive diagrams.
- Visual structure mirrors concept behavior.
- Each major concept has suitable pattern.
- No uniform card grid unless grid itself is point.
- Minimal containers; typography carries labels.
- Every relationship has arrow/line.
- Text readable and unclipped.
- Arrows connect to intended elements.
- Spacing balanced.
- HTML preview created and inspected.
- PNG rendered when local runtime exists.

## Final response

Mention exact workspace-relative paths:

- `artifacts/diagrams/<name>.excalidraw`
- `artifacts/diagrams/<name>.html`
- `artifacts/diagrams/<name>.png` if generated

If editor server started, include local URL.
