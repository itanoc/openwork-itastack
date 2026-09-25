---
name: sync-cowork-skills
description: |
  Regenerate the Claude Code desktop skill zips (.claude/skills) from the
  OpenWork source (.agents/skills). OpenWork is the source of truth. Run after
  adding, editing, renaming, or deleting any skill so the desktop-importable
  zips stay in sync.

  Triggers when the user mentions:
  - "sync cowork skills" / "sync claude skills"
  - "bridge the skills" / "regenerate .claude/skills"
  - "zip the skills for claude desktop" / "rebuild the skill zips"
  - "I changed a skill, update the claude copy"
  - after creating or editing a skill in .agents/skills
metadata:
  route_default: daily
  route_max: daily
  route_class: sync_cowork_skills
---

<<<ROUTE default=daily max=daily class=sync_cowork_skills>>>

# Sync Cowork Skills

## Goal

Keep `.claude/skills` a correct, up-to-date set of **Claude Code desktop skill
zips** generated from `.agents/skills` (the OpenWork authoring source, which is
the source of truth). After a sync, `.claude/skills` contains **only** one
`<skill>.zip` per skill — no loose folders. The zips are generated, not
hand-edited.

The Claude Code desktop app only imports skills as `.zip` bundles, so the sync's
job is: transform each OpenWork skill for Claude Code, bundle it (with all its
supporting files) into `<skill>.zip`, and drop it in `.claude/skills`.

## When to run

Run the sync whenever skills change: a new skill is added, an existing SKILL.md
or its reference/script files are edited, a skill is renamed, or a skill is
deleted. If unsure whether the zips are stale, run the dry-run first.

## What the zips look like

- One zip per skill: `.claude/skills/<skill>.zip`.
- The skill folder is **nested inside** the zip, so unzipping yields
  `<skill>/SKILL.md` (+ supporting files), which is what the desktop app expects.
- Zips are rebuilt fresh from source every run — never unzipped and patched.
- Zips are deterministic (sorted entries + fixed timestamps), so an unchanged
  skill produces a byte-identical zip and a clean git diff.

## Transforms applied to bundled files

- Tool names differ per runtime. OpenCode exposes MCP tools as
  `itastack_<tool>` / `testytech_<tool>`; Claude Code exposes them as
  `mcp__itastack__<tool>` / `mcp__testytech__<tool>`. The script rewrites them.
- OpenWork's `<<<ROUTE ...>>>` tier-routing sentinel is meaningless in Claude
  Code; the script strips it.
- Each markdown file gets an "AUTO-GENERATED — do not edit" header pointing back
  at the `.agents/skills` source.

## Steps

1. Preview what will change (writes nothing):
   `python3 .agents/skills/sync-cowork-skills/scripts/bridge_skills.py --dry-run`
2. Apply the sync:
   `python3 .agents/skills/sync-cowork-skills/scripts/bridge_skills.py`
3. Report the counts it prints (skill zips, files bundled, tool-name rewrites,
   sentinels stripped) **and any warnings**.
4. Act on warnings: the sync skips loose files at the skills root and any
   directory without a `SKILL.md` (they aren't valid skills, so they never
   become zips). If a warning names something that *should* be a skill, add a
   `SKILL.md` to it (or move the stray file) and re-run.
5. If skills were deleted, confirm their zips are gone from `.claude/skills` (the
   sync fully rebuilds the directory and removes stale zips).
6. Commit `.claude/skills` so teammates get the updated zips on pull.
7. In the Claude Code desktop app, import the changed `<skill>.zip` file(s).

## Notes

- Author skills only in `.agents/skills`. `.claude/skills` holds only
  auto-generated zips; never hand-edit them (edit the source and re-run).
- The tool-name map lives at the top of `bridge_skills.py`
  (`TOOL_PREFIX_MAP`). If a new MCP server is added, add its prefix there.
- Validate the rewritten names against the live tool list once the MCP servers
  load in Claude Code (list `mcp__itastack__*` tools) and adjust the map if any
  exact name differs.
- The script excludes build junk: `.venv`, `__pycache__`, `node_modules`,
  `.DS_Store`, `*.pyc`.
