# Probe → Plan → Teach

## Philosophy

Use one interface and many sources. Fit the teaching path to this learner's present understanding. Trust comes from verification, not confident tone.

The learner handles the intellectual struggle. The teacher handles sequencing, source-finding, verification, diagrams, and state.

## Probe

Map every dependency strand the requested lesson will need.

1. Start broad, then narrow the strand each answer leaves ambiguous. Ask 1–3 questions per structured picker call, or one question per chat-fallback turn. Do not teach during the probe beyond a one-line correction after an answer.
2. Label each strand `known`, `edge`, `unknown`, or `blocked`:
   - `known`: correct answer with sound reasoning.
   - `edge`: correct with thin reasoning, or a near-miss.
   - `unknown`: a required foundation is missing.
   - `blocked`: the learner declines or a required tool is unavailable.
3. Update `.teach/subjects/<subject-slug>/MAP.md` after every answer batch.

The probe is complete only when every dependency strand needed by the planned lesson has a label.

For a probe-only request, show the strand table and identify the best starting edge. Do not begin teaching unless asked.

## Plan

1. Build a dependency DAG whose nodes are single reasoning steps, not chapters.
2. Start from `known`, pass through `edge`, and insert a prerequisite before any `unknown` node.
3. Verify empirical, historical, bibliographic, API, or uncertain named claims before treating them as facts. Follow [verification.md](verification.md) when verification is needed.
4. Save the Mermaid source in `.teach/subjects/<subject-slug>/sessions/<date>-<topic-slug>.md` so the plan remains editable.
5. From the same nodes and edges, automatically create `.teach/subjects/<subject-slug>/visuals/<topic-slug>-plan.svg` by following the dependency-plan rules in [visuals.md](visuals.md).
6. Inspect the SVG, show it inline to the learner with its absolute path, then ask whether its shape should change. Do not print raw Mermaid in place of the visible graph.

Planning is complete when every node has its required predecessor, the session file contains the Mermaid source and SVG path, and the learner has seen the inspected SVG.

## Teach

1. Teach exactly one node: one inference, transformation, distinction, or applied move.
2. Use a visual only when the relationship is materially easier to see than explain; then follow [visuals.md](visuals.md).
3. Quiz the taught node using [quizzes.md](quizzes.md).
4. Score the reasoning, not only the selected answer:
   - Sound application: `lock-in`; advance to the next node.
   - Thin or guessed answer: retry with a tighter application.
   - Missing foundation: insert one prerequisite node and update the graph.
5. Update the map and session log before continuing.

The node is complete only after `lock-in`. Stop the turn after the quiz or the compact result update; do not continue into the next explanation.

## Interruptions and stopping

Answer the learner's interruption directly, then resume the same node unless it revealed a missing prerequisite.

When stopping, record what locked, what remains at the edge, and the next node. The session file must be sufficient for another agent to resume without reconstructing the lesson.
