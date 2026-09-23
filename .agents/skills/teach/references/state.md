# Learner state

Store all state in the learner's current working directory:

    .teach/
      LEARNER.md
      subjects/
        <subject-slug>/
          MAP.md
          sessions/<date>-<topic-slug>.md
          visuals/<topic-slug>-plan.svg
          visuals/<topic-slug>-<n>.svg

Create directories only when first needed. Do not write state inside the installed skill folder.

Choose one stable `<subject-slug>` for the umbrella subject and a narrower `<topic-slug>` for the current lesson goal. They may match for a single-topic subject. Never place subject files directly in `.teach/maps/`, `.teach/sessions/`, or `.teach/visuals/`.

If legacy flat subject files exist, move them into the matching `.teach/subjects/<subject-slug>/` tree before resuming. Preserve their contents and filenames; ask only when the subject cannot be inferred safely.

## Start or resume

1. Read `.teach/LEARNER.md` when it exists.
2. Select the exact subject, then find its `MAP.md` and newest session for the goal. Reuse them only when the goal still matches and the user agrees they remain current.
3. If `LEARNER.md` is missing, copy [the learner template](../assets/LEARNER.md) and fill only facts the learner supplied. Ask 3–5 profile questions across small batches; do not invent a persona.

State is ready when the profile exists and the exact goal has either a current map/session or a clearly initialized replacement.

## Map format

    # Map — <goal>

    Updated: <ISO date>
    Goal: <one sentence>

    ## Strands
    | strand | status | evidence |
    | --- | --- | --- |
    | <dependency> | known | Q2 plus sound reason |

    ## Quiz log
    - Q1 [strand] <answer> — correct | wrong | idk — <short evidence>

Allowed statuses: `known`, `edge`, `unknown`, `blocked`.

## Session format

    # Session — <goal>

    Date: <ISO date>
    Goal: <one sentence>

    ## Plan
    <Mermaid dependency graph>
    Rendered: <path to inspected SVG>

    ## Log
    ### Node: <name>
    - taught: <single reasoning step>
    - visual: <path or none>
    - quiz: <short identifier>
    - result: lock-in | retry | insert-prereq

Keep entries compact. Persist demonstrated understanding, not a transcript.

## Privacy

Store no secrets, credentials, private client records, raw emails, screenshots, or sensitive logs. Use redacted examples and stable source pointers.
