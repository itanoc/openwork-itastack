# Quiz protocol

Use quizzes for both probing and lock-in. Every question has one best answer and tests reasoning rather than wording.

## Delivery

Prefer a native structured question picker only when it can present ungraded-looking choices without marking, recommending, preselecting, or positioning the correct answer specially.

If no safe picker exists, ask one compact multiple-choice question in chat:

    Question: <stem>
    A. <content choice>
    B. <content choice>
    C. <content choice>
    D. I don't know
    Reply with the letter and, if useful, your reasoning.

Chat fallback is the normal self-contained Codex path. Do not stop merely because a picker tool is unavailable.

## Shape

- Use three plausible content choices plus `I don't know`.
- Vary the correct answer position. Never put it first by policy.
- Do not label the correct option recommended or describe it as more credible.
- Avoid trick choices that depend on ambiguous wording.
- Prefer a short application over a definition recall.
- Accept free-text reasoning and treat it as scoring evidence.

## Cadence

- Structured picker: 1–3 questions in one call, then wait.
- Chat fallback: one question, then wait.
- Probe: start wide, then narrow the unresolved strand.
- Teaching: quiz immediately after the single reasoning step.

## Scoring

- Correct choice plus sound reasoning → `known` or `lock-in`.
- Correct choice with thin reasoning → `edge`; ask one tighter question.
- Wrong but near reasoning → `edge`; correct briefly and retry.
- Wrong because a foundation is missing → `unknown`; insert a prerequisite.
- `I don't know` → `unknown` unless a missing tool makes it `blocked`.

Update the map and session file after scoring. Scoring is complete when the relevant strand or node has an evidence-backed status.
