---
name: skill-audit
description: |
  Audit, debug, and harden an OpenWork/opencode skill so it works reliably with
  smaller models — and, when asked, automatically TUNE its SKILL.md against a
  small model with a score-driven hill-climb loop (probes + verifier + mutate/
  keep/discard). Splits failures into client-side (skill text) vs server-side
  (MCP dispatcher) fixes.

  Triggers when the user wants to review, fix, or tune a skill, especially for
  smaller models, including phrases like:
  - "audit this skill" / "review my skill" / "harden the skill"
  - "tune this skill for a small model / haiku / gemma / a weaker model"
  - "make this skill work on a smaller model" / "auto-iterate my skill"
  - "this skill fails on a smaller model"
  - "the model stops / asks again / can't find the tool"
  - "output got truncated / saved to a file"
  - "should this be a server-side or client-side fix"
metadata:
  route_default: medium
  route_max: high
  route_class: skill_audit
---

<<<ROUTE default=medium max=high class=skill_audit>>>

# ===== FRONTMATTER_BOUNDARY =====

# Skill Audit & Tune

Two modes. Pick based on the request:

- **DIAGNOSE** (default) — the user reports a specific symptom and wants it
  fixed. Run the triage flow: classify client-side vs server-side vs helper-side,
  reproduce, apply the smallest fix. Start at "DIAGNOSE MODE" below.
- **TUNE** — the user wants the skill made small-model-friendly via an automated
  loop ("tune this skill for haiku", "auto-iterate", "hill-climb the SKILL.md").
  Run the score-driven loop. Start at "TUNE MODE" below.

If unsure which, ask once: "Do you want me to diagnose a specific failure, or run
the automated tuning loop against a small model?"

## DO THIS FIRST (both modes)

1. Locate the ACTUAL skill file backing the running skill, then read its
   `SKILL.md` fully before suggesting any change. Do not propose edits to text
   you have not read. Skills can live in more than one place — workspace
   `.agents/skills/<name>/`, global `~/.config/opencode/skills/`, or a
   local-only dir populated by a slash command (e.g.
   `.openwork-local/skills/<name>/`). If unsure which one is loaded, search for
   the skill name across these locations and confirm with the user; editing the
   wrong copy looks exactly like "my fix didn't load."
2. Confirm the target small model with the user (an `opencode models` selector,
   e.g. `opencode/claude-haiku-4-5`, `opencode/gemini-3-flash`).

---

# DIAGNOSE MODE

Use this to fix a skill that misbehaves on a smaller model and decide what must
change client-side (the skill's own text) versus server-side (the MCP
dispatcher/tool) versus helper-side (a bundled script).

## Triage first

1. If the user described a symptom, classify it with the Triage Table below
   BEFORE editing anything.
2. If a tool/dispatcher is involved, reproduce the exact call yourself (see the
   Triage Loop). Single fastest way to tell client-side from server-side.
3. If the symptom only shows up "in the app" or the in-app error is vague
   ("failed", "check your network", "unable to load"), reproduce it HEADLESS on
   the real target model before editing anything (see "Headless reproduction").

## Core mental model

This framework applies to ANY skill — tool-heavy MCP skills, file/artifact
skills, web/research skills, and pure-conversation skills. Only the server-side
half is sometimes N/A (a conversation-only skill has no external dependency).

A skill failing on a smaller model is almost always one of two things:

- **Client-side** — the model doesn't know *what to do* or *how to act*. Fix the
  skill prose. (Applies to every skill type.)
- **Server-side** — the model did the right thing but an *external dependency's
  response is unusable* (too big, wrong shape, missing a mode). "Server-side"
  here means any external producer the skill depends on: an MCP tool/dispatcher,
  a web/HTTP API, an OpenWork extension, or a file/data source. Request a change
  to that producer (or accept it's out of your control and mitigate client-side).

The common trap is treating a server-side problem as a prompt problem. Tweaking
caps/wording cannot fix a response that is structurally too large or wrong-shaped.

### The deciding rule of thumb

> If the fix requires the model to be SMART (project fields, ignore noise,
> transform data, infer a multi-step recipe), push it SERVER-SIDE.
> If it requires the model to be TOLD CLEARLY, fix it CLIENT-SIDE.

Smaller models are bad at: ignoring irrelevant data, copying nested params,
holding multi-call recipes in their head, and resisting reciting intro prose.
Good server design removes the need for all four — return small, pre-shaped,
single-call responses.

## Triage Table

| Symptom | Side | Fix |
|---|---|---|
| Model asks for input it was already given | Client | Hard "DO THIS FIRST" block at the very top |
| Model recites the intro instead of acting | Client | Move the action directive ABOVE descriptive prose |
| Model invents tool/operation names | Client | Add a concrete literal JSON call example |
| Model stops at a "stop and ask" line | Client | Consolidate and narrow stop conditions |
| Model tries to "load" a tool as a skill | Client | State plainly "X is a tool, not a skill" |
| Output truncated → saved to a file | Server | Add a slim/projection mode |
| Response has 50+ fields, ~5 useful | Server | Server-side field projection |
| Model can't transform data (concat/filter/dedupe) | Server | Move the transform into the dispatcher |
| Tool errors on a documented param | Server OR stale deploy | Verify `__describe__` matches source first |
| Two-call recipe the model gets wrong | Server | Provide a single-call composite |
| Model must copy/write a large payload and corrupts/drops it | Server/Helper | Don't make the model carry it — let a helper fetch/derive it, or pass only small scalars |
| Model reports a failure/success it never got from a tool | Client | Ban canned outcomes; require quoting a real tool result before reporting |
| Tool rejects a documented/optional arg (e.g. an explicit `null`) | Server OR stale deploy | Verify `__describe__`; if real, draft a dispatcher fix to accept/ignore it |

## Triage Loop (run in order)

1. **Reproduce the exact tool call yourself.** Call the dispatcher directly with
   the params the skill specifies.
   - Call works, returns clean bounded data → problem is CLIENT-side.
   - Call truncates / errors / returns junk → problem is SERVER-side.
2. **Always check `__describe__` before assuming a bug.** A "logic bug" is often
   a stale server still running old code. Live signatures are the source of
   truth — not the source file, not handoff notes, not your memory.
3. **Classify** the symptom with the Triage Table.
4. **Apply the smallest fix** on the correct side. Do not rewrite the whole
   skill; patch the specific failing behavior.
5. **Restart and re-run.** Skill text and MCP servers are both cached; a fix is
   not verified until reloaded. Confirm you edited the file that actually backs
   the running skill and that the session reloaded it — a fully cold restart.

When the bug only reproduces inside a model run (not in your own direct tool
call), do step 1 as a HEADLESS run on the real target model — see below.

## Headless reproduction (see what the model actually does)

Run it headless on the **same model the user runs** and read the full trace of
tool calls, shell commands, and raw errors. The in-app UI frequently collapses a
real error into a vague banner; headless does not.

Run from the workspace root:

```
opencode run --format json -m <provider/model> "Load skill <name> and follow its instructions to <do the task> now. Actually execute every step with your tools; do not summarize."
```

- Use the user's actual model, not a stronger one — the point is to reproduce the
  small-model behavior. Re-run on a stronger model only to confirm a fix is
  model-capability-bound vs skill-bound.
- `opencode models` lists available models.
- Read the trace top to bottom: which tools were called, with what params, what
  each shell command printed, and the exact error. That trace is your repro
  evidence and usually pinpoints client- vs server-side immediately.
- Prefer a `--dry-run`/read-only variant first if the skill writes or mutates
  anything, so the repro itself is safe.
- Workflow: reproduce headless → read the real error → make the smallest fix →
  re-run headless to confirm → only then have the user retry in the app.

## Client-side patterns that work

- Put the **first action at the very top** of the skill, before any description.
- Give a **literal JSON call example** (`{"tool": ..., "operation": ...,
  "params": {...}}`), not prose like "use tool X operation Y."
- Use **one** stop condition, narrowly scoped; make everything else "continue
  and note the gap." Scattered "stop and ask" lines cause early bailout.
- Say explicitly: **"this is a tool call, not a skill load — emit it now."**
- **Ban the escape hatches by name** ("never save the output to a file," "never
  hand it to the explore/Task agent," "do not re-ask for an ID you already have").
- Make **output structure deterministic** ("always output these sections").
- Normalize **straight quotes** in any literal strings the model must emit.
- Annotate **ambiguous param values** inline (e.g. `0` means "all").
- **Ban canned/fabricated outcomes.** State plainly: there is NO canned failure
  message; report a failure only by quoting the actual error a tool/command
  returned, and report success only after a tool/command actually returned it.

## Server-side changes to request

When the fix belongs server-side, write a concrete request for the dispatcher
owner. Ask for: a **slim/projection mode**; **single-call composites** over
two-call recipes; **conservative defaults** that fit the output limit (opt-in
for more); clear **docstrings in `__describe__`**; **backwards compatibility**
(new mode opt-in, old calls unchanged). Include the symptom, a reproduction (the
exact call + observed output size/shape), the proposed signature change,
acceptance criteria, and a post-deploy verification checklist.

## Helper-side fixes (the third lever)

When you can't change the server, ship a **bundled helper script** inside the
skill folder (`scripts/…`) that does the fragile work the model keeps botching,
so the model runs one command and passes a few small scalars. Reach for a helper
when the model must assemble a multi-call recipe, carry a large payload between
calls, or generate exact values (timestamps/hashes). Keep helper stdout small;
enforce the same safety checks the skill describes; fail closed with a safe
`error_class`/`message` and a non-zero exit; read secrets inside the helper
process only.

---

# TUNE MODE

Tune a `SKILL.md` so a small LLM can actually follow it, using a score-driven
loop you (the assistant) drive directly. The harness ships in this skill's
`Templates/` + `References/` and runs the small model with `opencode run`
(headless, JSON), which gives it its real tools so tool-driven, multi-file
skills are exercised for real — the model acts, it does not just narrate.
`verify.sh` installs the SUT as a real skill (in a temp `.opencode/skill/`) and
the model loads it by name — inline-pasted skill text is refused by the model.

## Core idea

- **SUT** = the target `SKILL.md`. The runner INSTALLS it as a real,
  discoverable skill in a throwaway workspace and the model loads it via the
  `skill` tool — opencode models REFUSE skill instructions pasted inline as user
  text, so the SUT must be a genuine installed skill, not injected prose.
- **Probe** = a task input that exercises one critical behavior + `expected.md`
  assertions checking the small model did it right.
- **Verifier** = deterministic: fraction of assertions satisfied
  (`+` must-contain, `-` must-not-contain, `~` regex). LLM-judge optional.
- **Runner** = `verify.sh` drives the small model via `opencode run --format
  json --pure --dir <tmp-workspace>`, loading the installed SUT by name and the
  probe input, then scores the output (assistant text + the tools it invoked).
- **Loop** = mutate SKILL.md body → run probes → keep wins, revert losses.

Each mutation that makes the small model follow the skill better raises
`passed`. The tuned SKILL.md is diffed back to its origin with explicit human
review before it lands.

> **The loop CANNOT test autonomous invocation.** Because the runner installs
> the SUT and the model loads it BY NAME, the loop never exercises whether the
> agent decides to invoke the skill on its own (e.g. an `AGENTS.md` rule saying
> "use the X skill when you detect Y"). If the symptom is "the agent never
> invokes/loads the skill" or "the skill works only when I explicitly call it,"
> that is a CLIENT-SIDE trigger problem in the calling text (`AGENTS.md`, a
> command, or the skill's own `description`/triggers) — NOT a SKILL.md body
> problem. Use DIAGNOSE MODE with a headless repro that does NOT mention the
> skill, and fix the trigger text; tuning the SKILL.md body will plateau because
> the failing step is the one the loop bypasses.

## Preconditions

- The target skill already exists (a `SKILL.md` you can point at).
- `opencode`, `jq`, `git` on `PATH`. (`opencode models` shows selectors.)

## Phase 1 — Set up the workspace

1. Identify the target: absolute path to the `SKILL.md` and a short name.
2. Identify the small model: `LLM_MODEL` (opencode selector, e.g.
   `opencode/claude-haiku-4-5`).
3. Create an isolated workspace (NOT the real skills repo — the loop commits per
   mutation and runs `git reset --hard`; never churn the real repo):

   ```bash
   WS="$HOME/.local/share/skill-audit-tune/<skill-name>"
   mkdir -p "$WS" && cd "$WS"
   git init -q && cp /path/to/original/SKILL.md ./SKILL.md
   ```
4. Insert the boundary marker immediately after the closing `---` of the copied
   SKILL.md's YAML frontmatter:

   ```text
   # ===== FRONTMATTER_BOUNDARY =====
   ```

   The loop will not cross this marker line. It anchors where tuning starts;
   frontmatter freeze otherwise relies on the MUST NOT DO rule below.

## Phase 2 — Audit the target skill

Read `SKILL.md`. Extract its **critical behaviors** — the things a correct
execution MUST do. List them as checkable facts, not vibes. For each, note what
a small model is likely to drop (ambiguous verb, buried step, missing example,
long decision chain). See `References/mutator-techniques.md`.

## Phase 3 — Generate probes

For each critical behavior, write a probe under `probes/<name>/`:

- `input.md` — a task that forces the small model to exercise that behavior.
- `expected.md` — assertions the model's output must satisfy. Author them FUZZY:
  check concepts, not exact phrasing (see `References/verifier-patterns.md`).
  `+must contain` (case-insensitive), `-must not contain`, `~regex`.
- `probe.yaml` — copy from `Templates/probe/probe.yaml`; set `failure_mode`.

**Minimum suite: ≥ 4 probes** covering the four mandatory failure modes:

| failure_mode | what it targets |
|---|---|
| `misunderstanding` | ambiguous phrasing the small model misreads |
| `missing_capability` | a step/pattern the small model silently drops |
| `silent_failure` | model claims done, skipped a critical step |
| `missing_verification` | model didn't self-check its output |

`missing_verification` / `silent_failure` probes MUST have assertions that read
the output for the critical step actually being performed — not just claimed.

## Phase 4 — Scaffold adapter + program

Copy `Templates/adapter.yaml` → `./adapter.yaml`. Fill `name`. Confirm
`runner.cmd: "SUT_PATH=./SKILL.md bash {probe}/verify.sh"` and
`verifier.emits_cost: true`.

Copy `Templates/program.md` → `./program.md`. Fill the directive with the target
model and the skill's intent.

Copy `Templates/probe/verify.sh` to a shared location the `runner.cmd`
references (simplest: one copy per probe dir). Make it executable.

Add `.gitignore`: `.autoagent/`, `results.tsv`, `probes/*/.out`,
`probes/*/.events.jsonl`, `probes/*/.err`.

Commit the scaffold so the tree is clean before the loop (the baseline refuses
on a dirty tree, and the first discard's `git reset --hard HEAD~1` needs a real
`HEAD~1`):

```bash
git add -A && git commit -q -m "baseline scaffold"
```

## Phase 5 — Smoke test

Run ONE probe by hand before the loop, exactly as the driver will:

```bash
mkdir -p .autoagent
SUT_PATH=./SKILL.md \
LLM_MODEL=opencode/claude-haiku-4-5 \
AUTOAGENT_PROBE_DIR=probes/<name> \
AUTOAGENT_SCORE_FILE=.autoagent/last_score \
AUTOAGENT_COST_FILE=.autoagent/last_cost \
bash probes/<name>/verify.sh
cat .autoagent/last_score   # a float in [0,1]
cat .autoagent/last_cost    # DOLLARS (or tokens if provider reports no cost)
```

Does the runner emit a score? If not, fix it first (check
`probes/<name>/.err`).

## Phase 6 — Run the loop

You drive the loop directly. Export `LLM_MODEL` in the shell you run from so
every probe's `verify.sh` inherits it.

### Phase 6.0 — Baseline

1. Confirm clean tree (`git status --porcelain` is empty).
2. Ensure `results.tsv` has a header (columns below).
3. For each probe, wire env vars, substitute `{probe}`, run `verify.sh`, read
   `.autoagent/last_score` and `.autoagent/last_cost`.
4. Compute `passed = count(score ≥ verifier.pass_threshold)` and `score_avg`.
5. Append a row with `status=baseline`.
6. **Sanity check the suite:** 0% passed → probes likely impossible or verifiers
   broken; fix before iterating. 100% passed → no headroom; add harder probes.
   Target 20–60% pass → room to hill-climb.

### Phase 6.1 — Iterate (repeat until a stop condition fires)

1. **Diagnose.** Read `results.tsv` and per-probe `.out`. Group failures by root
   cause, not probe name. Use `References/mutator-techniques.md`.
2. **Choose ONE mutation.** Prefer changes that fix a CLASS of failures (the
   overfitting test: "if this probe disappeared, is the edit still worth it?").
   Edit ONLY the `SKILL.md` body below the boundary marker.
3. **Mutate + commit.** `git add -A && git commit -m "tune: <description>"`. The
   commit contains ONLY the mutation (`results.tsv` and `.autoagent/` are
   gitignored).
4. **Run probes** (same as baseline).
5. **Decide.**
   - `passed` improved → `keep`.
   - `passed` unchanged AND the mutation simplified/shortened the SUT → `keep`.
   - Otherwise → `discard`: `git reset --hard HEAD~1`.
6. **Log.** Append a row to `results.tsv` with the chosen status and a short
   description of which probes newly passed / regressed / stayed flat.

### Boundary enforcement

Before committing a mutation, verify the staged diff (`git diff --name-only
--cached`) touches only `SKILL.md` and does NOT touch `adapter.yaml`,
`program.md`, `probes/**`, or any line at/between `# ===== FRONTMATTER_BOUNDARY
=====` markers. If it does, restore the worktree and redo the mutation.

### results.tsv columns (tab-separated)

```
timestamp  commit  mutation_id  score_avg  passed  probe_scores  cost  status  description
```

- `timestamp` ISO 8601 UTC (`date -u +%FT%TZ`). `commit` short git hash.
- `mutation_id` = `$(date +%s)-$(git rev-parse --short HEAD)`.
- `score_avg` float 3dp. `passed` `N/M`.
- `probe_scores` single-cell compact JSON (`jq -c`), e.g. `{"p-foo":1.0,"p-bar":0.0}`.
- `cost` float dollars (sum of the run). `status` `baseline|keep|discard|crash`.

### Probe timeout / crash handling

If a single probe exits non-zero or exceeds `runner.timeout_seconds`: record
`score=0` for that probe, mark its contribution `crash`, but do NOT abort the
suite — continue the remaining probes. If ALL probes crash, set the iteration
`status=crash` and STOP (the SUT is broken, not one probe).

`verify.sh` always exits 0 and writes `0.0` even when opencode returned NO output
(dead/deprecated model, provider error). So a `0.0` is ambiguous: real
comprehension failure vs infrastructure failure. Before treating a `0.0` as a
tuning signal, check the probe's `.err` and `.events.jsonl` — if there is no
assistant text AND no tool call, it is an infrastructure crash (model/provider),
NOT a prose problem. Fix the model selector / provider and re-run; do not mutate
prose against it. If EVERY probe is `0.0` with empty output, STOP — the model
selector is almost certainly wrong.

### Stop conditions

Stop when any of: user interrupts; budget exhausted (sum of `cost` ≥ the
`program.md` budget); no `keep` row for `loop.plateau_iterations` consecutive
iterations (default 5; a single `keep` resets the counter, discards don't);
a mutation crashes the SUT and rollback fails (STOP and surface immediately).

### Nondeterminism

Agentic turns are stochastic; the same SKILL.md can score differently
run-to-run. A borderline `keep` may be noise — re-run the suite once after a
climb to confirm the final score holds.

### Server/helper-side escape valve (DO NOT grind prose at a non-prose wall)

Prose tuning can ONLY fix client-side failures (the model not knowing what to do
or how to act). If a probe fails because a tool/dispatcher the skill calls
returns unusable data — truncated, 50+ fields, wrong shape, a two-call recipe,
or a large payload the model must carry — NO `SKILL.md` edit can fix it, and the
loop will plateau burning budget.

Detect this per stuck probe. A probe is **server/helper-bound** (not prose-bound)
when, reading its `.out` / `.events.jsonl`:
- the model called the right tool with the right params, but the response was
  truncated / saved to a file / too large / wrong-shaped, OR
- the model had to transform/dedupe/concat data or carry a big payload between
  calls and corrupted it, OR
- the tool errored on a documented/optional param.

When ≥1 stuck probe is server/helper-bound: **STOP iterating on that probe** (do
not keep mutating prose for it) and reproduce the exact tool call yourself per
DIAGNOSE MODE's Triage Loop to confirm client- vs server-side. Then record it as
a `[server]` or `[helper]` finding and, in the final report (see Output), emit a
**drafted server-side change request** (use "Server-side changes to request"
above) or a **helper-script sketch** (use "Helper-side fixes" above). Keep
tuning prose only for the genuinely client-bound probes.

This is the TUNE-mode equivalent of the beyond-ceiling rule: beyond-ceiling =
"too hard for this model, no fix here"; server/helper-bound = "wrong layer, the
fix is not in the prose." Either way: stop grinding, report the real blocker.

## Phase 7 — Land the tuned skill (TRUST BOUNDARY)

When the loop stops, first strip the boundary marker the workspace copy carries:

```bash
grep -v '^# ===== FRONTMATTER_BOUNDARY ===== *$' ./SKILL.md > ./SKILL.md.clean
```

Then:

1. `diff` `./SKILL.md.clean` against the original copy (NOT the marker-laden one).
2. SHOW the diff to the user. Summarize what changed and the score delta
   (baseline `passed` → final `passed`).
3. Require EXPLICIT confirmation.
4. Only on confirmation, copy `./SKILL.md.clean` back to the original path.

NEVER auto-overwrite a real skill. The workspace copy is scratch until the human
approves.

## Reference files

- `References/mutator-techniques.md` — catalog of SKILL.md edits that help small
  models, and the beyond-ceiling stop rule.
- `References/verifier-patterns.md` — authoring fuzzy assertions, optional
  LLM-judge, cost tracking.
- `Templates/` — `adapter.yaml`, `program.md`, `probe/` scaffold (`verify.sh`,
  `probe.yaml`, `input.md`, `expected.md`).
- `selfcheck.sh` — mocks `opencode` and runs the real `verify.sh` end to end
  (no real model, no network) to prove the runner emits a score and a cost.

## Beyond-ceiling rule

If baseline is 0/4 and no mutation in ~5 iterations cracks 1/4, OR every keep is
a trivial reformat with no comprehension gain — STOP. Report the skill likely
exceeds the target model's ceiling; recommend a stronger model or splitting the
skill. Do not grind a capability wall.

---

## Output (both modes)

When DIAGNOSING, produce:
- **Findings** — ranked high/medium impact, each tagged `[client]`/`[server]`/`[helper]`.
- **Repro evidence** — the exact call made and what it returned (size/shape).
- **Proposed fixes** — minimal patches for client-side; a drafted request for
  server-side; a helper sketch for helper-side.
- **Verification** — the headless command(s) used and whether the run on the
  user's model now succeeds end to end.
- A reminder to **restart OpenWork/opencode** so updated skill text loads.

When TUNING, produce:
- baseline `passed` → final `passed`, mutations kept vs discarded, failure modes
  resolved vs still open, cost spent, stop reason.
- the `diff` of the tuned SKILL.md against the original, awaiting confirmation.
- **Server/helper-side findings** — for every probe found server/helper-bound
  (see the escape valve), a `[server]` or `[helper]` finding with repro evidence
  (the exact tool call + observed output size/shape) and a drafted change
  request / helper sketch. State plainly that these CANNOT be fixed by tuning
  the prose and list them separately from the prose changes that were kept.

## Guardrails

- Read the skill fully before proposing edits.
- Keep edits surgical; do not refactor unrelated parts of the skill.
- Preserve genuine safety stops (write actions, destructive/tenant-wide changes,
  credential/secret handling) — never loosen those to make a flow smoother.
- When reproducing or tuning a skill that **mutates shared/production state**,
  use a non-production target first (a `beta`/staging channel, a dry-run, or a
  throwaway record) and restore it afterward. Never use production as a test bed.
- Do not invent dispatcher capabilities; verify against `__describe__`.
- If a fix needs server-side work you cannot do from the workspace, say so
  plainly and draft the request rather than forcing a fragile prompt workaround.

### TUNE MODE — MUST DO
- Run in the isolated workspace, never in the user's real repo.
- Preserve YAML frontmatter; tune only the body below the boundary marker.
- ≥ 4 probes covering the four mandatory failure modes before the loop.
- Smoke-test the runner before the loop.
- Diff + explicit confirmation before copying a tuned skill back.

### TUNE MODE — MUST NOT DO
- Overwrite the original `SKILL.md` without showing a diff and getting consent.
- Let the loop edit `adapter.yaml`, `program.md`, `probes/**`, or frontmatter.
