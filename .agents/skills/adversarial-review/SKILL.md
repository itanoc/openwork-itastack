---
name: adversarial-review
description: Hostile review of a business document before it goes out — finds the gaps, unsupported numbers, and unanswered questions a friendly read misses. Use when the user says "adversarial review", "poke holes in this", "red team this", "what am I missing", "gap check", "review before I send", "tear this apart", or wants a report, proposal, scope, memo, SOP, deck, budget, pricing model, or client email stress-tested rather than proofread.
---

Review a business document as a set of hostile readers, not as a helpful assistant. A friendly read confirms what the author already believes; this one hunts for what they left out.

**Report findings; do not rewrite the document.** State each fix as a change to make in one sentence — "name the owner of step 3" — not as replacement prose. Offer the rewrite at the end; only do it if asked.

## 0. Get the document

Route by what you were given. Do not attempt to read a binary directly.

| Input | Do this |
|---|---|
| `.docx` / `.dotx` | Read the `docx` skill, extract text **and** any tracked changes or comments |
| `.pptx` / `.potx` | Read the `pptx` skill, extract slide text **and** speaker notes |
| `.xlsx` / `.csv` | Read the `xlsx` skill; see the spreadsheet branch in §2 |
| `.pdf` | Read the `pdf` skill |
| Google Doc/Sheet URL | Use the Drive connector |
| Pasted text | Confirm it is the whole document, not an excerpt |
| A file in an engagement folder | Read it directly if it's plain text or Markdown |

If extraction is partial — a scanned PDF, image-only slides, a chart whose data you can't reach — say so at the top of the review and exclude that content from the verdict. Never review around a hole silently.

## 1. Fix the audience and the ask

A gap only exists relative to a reader and a decision. Establish four things:

- **What is this?** Report, proposal, scope, memo, SOP or runbook, deck, budget or pricing model, client email.
- **Who reads it?** Be specific — "the client's CFO" reviews differently than "the client's IT manager". Note whether this is **internal** or **external**; that one call governs every confidentiality finding.
- **What should the reader do after reading?** Approve, sign, pay, follow the procedure, change something, just stay informed.
- **What stage is it at?** Finished and about to go out, or a work in progress with known gaps.

**Infer first, ask at most once.** Work these out from the document and state the inference in the review header. Ask a single question only when the inference would change the verdict — in practice, that is almost always the internal-vs-external call. If the user doesn't answer in the same turn, proceed on the inference.

Anything marked *(inferred)* in the header caps the severity of findings that depend on it — see §4.

**Work in progress:** list placeholders and known-open sections once as "known gaps — not reviewed", review what exists, and report the verdict as **N/A (draft)**. Don't tell an author their unfinished draft can't be sent.

## 2. Read the whole thing

Read the full document, not just the section the user is worried about — gaps live in what one section promises and another never delivers. If the user named a section, still review everything, and say explicitly what you found there.

Check attachments and appendices the document cites. For house conventions, check `docs/` for the template and the engagement folder for prior versions of the same document. If a cited source wasn't provided to you, don't guess — record it under **Could not verify** (§4).

**If the document is too long to read completely**, review as far as you can and put an honest coverage line in the header. A partial review presented as a complete one is worse than no review — it signals the document was checked.

**Recompute, don't eyeball.** Every total, percentage, variance, and date range gets checked arithmetically. Show the check: for each figure, note the document value, your recomputed value, and whether they match. An unchecked number is a rule violation, not a silent shortcut. Numbers that don't foot are the most common real finding and the easiest to skim past.

**Spreadsheets are different.** Recomputing a `SUM()` only proves Excel can add. Audit the formulas instead: SUM ranges that stop short of the last data row, hardcoded constants pasted into a formula column, stale or broken cross-sheet references, error cells, hidden sheets or rows feeding the summary, assumptions buried in unlabeled cells, inputs not separated from outputs. Anchor every finding to `Sheet!Cell` or a named range.

## 3. Run the personas

Always run **The Cold Reader** and **The Auditor**. For the third, pick by document type:

- Decision-seeking documents — report, proposal, scope, budget, pricing model → **The Skeptical Approver**
- Procedural documents — SOP, runbook, work instruction → **The Operator at 2am**
- Neither fits (pure FYI status memo) → run two personas and say so in the header. Do not force a third.

Work through them one at a time. Do not soften. Do not hedge. "This might possibly be a slight concern" is not a finding — either the reader trips on it or they don't.

**Tag every finding as you raise it** with its persona and severity: `[CR][WARNING]`. You need both later; reconstructing them from memory at step 4 doesn't work.

**Each persona must produce at least one item.** If it genuinely finds nothing, re-read once. If the second pass is still clean, record its **weakest point** as an OBSERVATION and move on — one retry, then stop. An OBSERVATION is not a defect and does not affect the verdict. Never invent a defect to fill the quota; a real "the whole case rests on assumption X" beats a fabricated one.

### The Skeptical Approver `[SA]`

*"I'm looking for a reason to say no."*

- A number with no source behind it
- Cost, effort, or timeline omitted — or a range so wide it means nothing
- No clear ask; the reader finishes not knowing what they're being asked to do
- The recommendation buried under the analysis that produced it
- Benefit asserted rather than sized ("this will improve efficiency")
- Risks listed but not sized, or the obvious objection never addressed
- Alternatives not considered, so the recommendation looks unexamined
- An average that hides a trend

Ask of each claim: *would I sign off, and if not, what would I ask for first?* Every question the reader would have to email back is a finding.

### The Operator at 2am `[OP]`

*"I'm following this under pressure, alone, and I've never done it before."*

- Prerequisites, access, or permissions not stated up front
- A destructive or irreversible step with no warning before it
- No rollback — what do I do if this makes it worse?
- No verification step: how do I know it worked?
- No escalation path, no named owner of the procedure
- A step that assumes a decision the operator isn't equipped to make
- Branching that goes unhandled — "if the service doesn't restart", then what?
- Screenshots or UI paths that have drifted from the current version
- No revision date, so I can't tell if this is still true

Walk the procedure literally, in order, doing only what it says. The first step where you'd have to guess is a finding.

### The Cold Reader `[CR]`

*"This landed in my inbox. I was in none of the meetings."*

- Acronyms, internal shorthand, and system names used without expansion
- "As discussed", "per our conversation", "the usual process" — context the reader doesn't have
- References to tickets, docs, or threads the reader can't open
- Background missing: why does this exist, what happened before
- Structure that forces a second read to understand the first
- Who does what by when, left ambiguous or written in passive voice
- A term used two different ways in the same document
- A table or chart that needs the surrounding paragraph to be legible

Read the summary or opening alone and ask: *could someone act on this without reading the rest?* Then find the first sentence where a reader without context would stop and reread.

### The Auditor `[AUD]`

*"I have to defend every line of this in six months."*

- Claims with no evidence; evidence with no date or source
- Data accurate when pulled but not labeled with when it was pulled
- Arithmetic that doesn't reconcile; figures that contradict another section or a prior report
- Confidential material in the wrong audience's copy — client names, PII, internal costs, margins, credentials, staff performance detail
- Language creating a commitment or liability: "guarantee", "ensure", "fully compliant", "always", an implied SLA, scope promised beyond what was sold
- Absolute claims a single counterexample would break
- Something asserted as fact that is actually an estimate or an opinion
- Deviates from the house template or the prior version of the same document

For each significant claim, ask: *what document do I produce if someone challenges this?* If you need a source you weren't given — the contract, the prior report, a ticket, a data export — try to retrieve it. If you can't, it goes under **Could not verify**, not into a finding.

## 4. Score and decide

**Assign severity from this table only.**

| Class | Meaning | Counts toward verdict |
|---|---|---|
| **CRITICAL** | Factually wrong, an unsupported number driving the decision, a confidentiality exposure, or the ask is missing entirely. | Yes |
| **WARNING** | Costs credibility, invites a round of follow-up questions, or will be misread. | Yes |
| **NOTE** | Clarity, polish, structure. Author's call. | No |
| **OBSERVATION** | Not a defect — a persona's weakest-point note on sound work. | No |
| **COULD NOT VERIFY** | A claim you had no way to check, and what you'd need to check it. | No |

A number **drives the decision** if it appears in the ask, the price, or the recommendation, or if changing it would plausibly change the reader's answer. Every other unsourced number is a WARNING. Test the tiers in order; first match wins.

**Merge duplicates.** These persona checklists overlap on purpose, so the same defect will surface more than once — keep one finding carrying all contributing tags (`[SA][AUD]`). A merged finding satisfies the minimum for every persona that contributed to it; don't go hunting for a replacement.

**Promotion, capped.** A finding raised independently by two or more personas moves up **one level, maximum, regardless of how many caught it — and never into CRITICAL.** Because the checklists overlap, convergence is a weak signal, not proof of severity; CRITICAL is reserved for the objectively checkable criteria above and doesn't need a vote. Use convergence to rank findings within a level.

**Inferred-audience cap.** A finding whose severity depends on an audience you inferred rather than confirmed is capped at WARNING and labeled *(depends on inferred audience — confirm)*. Confidentiality findings require a **confirmed** audience to reach CRITICAL; otherwise phrase them conditionally: "if this copy goes to the client, the internal cost table is an exposure."

**Verdict** — exhaustive, first match wins:

- **HOLD** — one or more CRITICAL. Don't send it.
- **REVISE** — no criticals, one or more WARNINGs. Fix first.
- **SEND** — no criticals, no warnings.
- **N/A (draft)** — work in progress; findings stand, verdict withheld.

## Match the output to the size

| Document | Output |
|---|---|
| Under ~300 words (short email, brief memo) | 3–6 plain bullets and a one-line verdict. No headings, no bottom-line paragraph. Waive the per-persona minimum. |
| 1–10 pages | The full format below. |
| Over 10 pages or 20 slides | Cap at 5 items per severity band, ranked by impact. Collapse a repeated issue into one finding with a count and up to three examples — "12 unexpanded acronyms (EDR, RMM, VSA…)" — never one bullet each. Say what you truncated. |

## Output format

```markdown
## Adversarial Review: [document]

**Read as:** [audience] deciding whether to [action] — *(inferred)* if not confirmed
**Coverage:** full | sections 1–6 of 14, remainder not reviewed
**Personas:** Skeptical Approver, Cold Reader, Auditor
**Verdict:** HOLD / REVISE / SEND / N/A (draft)

### Critical
- **[Finding]** — [where]. [Why it fails.] [The change to make.] *(Approver + Auditor)*

### Warnings
- ...

### Notes
- ...

### Observations
- [Weakest point on work that's otherwise sound. Does not affect the verdict.]

### Could not verify
- [Claim] — needs [document], held by [who]. Not checked.

### Bottom line
[2–3 sentences: overall risk, and the single most important thing to fix.]
```

Every finding names its location (`Sheet!D14`, "slide 12", "Recommendation, para 2"), states the problem in one direct sentence, gives the change to make, and carries its persona tag so the author can tell an approval risk from a comprehension risk from a defensibility risk. Show the arithmetic check for any figure you recomputed.

## After the review

1. **Offer the fix pass** — "want me to draft fixes for the two criticals?" Don't assume it.
2. **Save it where it belongs.** For client work, `clients/<client>/notes/`; otherwise the engagement's `notes/` folder. Never at workspace root. Cite the path.
3. **Re-review on v2** checks the prior CRITICAL and WARNING items plus anything that changed — not a fresh full pass. Carry forward anything the author consciously declined as *accepted — author's call* and don't raise it again.

## Anti-patterns

| Don't | Why |
|---|---|
| "Looks good, just some minor polish" | If you found nothing substantive, you reviewed the prose and not the argument. |
| Copy-edit only | Flagging comma splices while an unsourced $40k figure sits untouched is worse than no review — it signals the document was checked. |
| Restate the document | "This section covers the Q3 budget" is a summary, not a finding. |
| Hedge | "You may possibly want to consider clarifying..." — no. "The reader can't tell who owns step 3." |
| Skip the numbers | Prose gets reviewed because it's easy. Check the math and show it. |
| Invent problems to hit a quota | The minimum means look harder, not fabricate. That's what OBSERVATION is for. |
| Force an irrelevant persona | Asking an SOP what its ROI is produces noise and buries the real findings. |
| Rewrite it | Findings only, unless asked. |

## The self-review trap

**Run this only if you drafted or edited the document in this session** — and before §2, not after. If you wrote it, you built the mental model that produced it, and it will look complete because it matches what you expect.

1. **From the title and headings alone**, state what you expect the document to conclude. Then check whether it delivers that.
2. **Read the last section first**, then work backward. *(Sectioned documents and decks; skip for anything under a page.)*
3. **Read the summary or opening slide in isolation.** Most readers won't get past it.
4. **Assume every number is wrong** until you've traced it to a source.
5. **Assume the reader stops after page one.** What did they miss that they needed?
6. **Ask of each section: if I deleted this, what would break?** If nothing, it may be padding — and padding hides the parts that matter.

For decks, read the appendix first, then the slide titles alone as a storyline, then check the speaker notes against what each slide actually claims.

## When this is worth running

Before anything goes to a client or an executive. On anything with money, dates, or commitments in it. After a long drafting session, when fatigue has flattened your judgment. When a document got easy approval and that felt too easy. When something feels off and you can't name it — that instinct is usually the Cold Reader trying to speak.
