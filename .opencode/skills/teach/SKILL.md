---
name: teach
description: Teach the user a new skill or concept in this OpenWork workspace. Use when the user asks to learn, be taught, practice, take a lesson, or build a learning path for a topic.
argument-hint: "What would you like to learn about?"
---

# Teach

The user has asked you to teach them something. This is a stateful request: they intend to learn the topic over multiple sessions.

## OpenWork Teaching Asset Root

Do not treat the repository root as the teaching workspace. Create and use a topic-specific teaching workspace under:

```text
teaching/<topic-slug>/
```

Examples:

- `teaching/excel-power-query/`
- `teaching/python-automation/`
- `teaching/halo-dispatch/`

If the user names a topic, derive a short lowercase dash-case `<topic-slug>` and create that folder before saving teaching assets. If the topic is unclear, ask one targeted question before creating files.

When first creating `teaching/`, also create `teaching/README.md` by copying the text from this skill asset:

```text
.opencode/skills/teach/assets/TEACHING-README.md
```

The `teaching/` folder is personal local learning state and should not be committed or tracked. If `teaching/README.md` already exists, leave it alone unless the user asks to refresh it.

Never store secrets, credentials, private client records, raw emails, screenshots, or sensitive logs in teaching assets. Use redacted examples and stable pointers instead.

## Teaching Workspace Layout

Each topic workspace stores learning state and teaching outputs:

- `MISSION.md`: Captures why the user is learning the topic. Use the format in [MISSION-FORMAT.md](./MISSION-FORMAT.md).
- `RESOURCES.md`: Curated resources for the topic. Use the format in [RESOURCES-FORMAT.md](./RESOURCES-FORMAT.md).
- `NOTES.md`: Scratchpad for teaching preferences, constraints, and working notes.
- `reference/*.html`: Beautiful quick-reference materials: cheat sheets, reference algorithms, syntax, workflows, poses, glossaries, or other compressed learning assets.
- `learning-records/*.md`: Learning records that capture what the user has demonstrated or established. Use sequential names like `0001-<dash-case-name>.md`. Use the format in [LEARNING-RECORD-FORMAT.md](./LEARNING-RECORD-FORMAT.md).
- `lessons/*.html`: Self-contained lessons. A lesson is one HTML output that teaches one tightly scoped thing tied to the mission. Use sequential names like `0001-<dash-case-name>.html`.

Create subdirectories lazily when first needed, except `teaching/<topic-slug>/` itself. When creating a new topic workspace, start with:

```text
teaching/<topic-slug>/MISSION.md
teaching/<topic-slug>/RESOURCES.md
teaching/<topic-slug>/NOTES.md
```

After creating or updating a lesson, reference document, resource list, mission, or learning record, mention the exact workspace-relative file path in your final answer.

## Philosophy

To learn at a deep level, the user needs three things:

- **Knowledge**, captured from high-quality, high-trust resources
- **Skills**, acquired through highly relevant interactive lessons devised by you, based on the knowledge
- **Wisdom**, which comes from interacting with other learners and practitioners

Before `RESOURCES.md` is well-populated, focus on finding high-quality resources that help the user acquire knowledge. Never trust parametric knowledge for important claims when reliable sources are needed.

Some topics require more skills than knowledge. Theoretical physics may be more knowledge-based. Yoga may be more skills-based. Most workplace topics need both.

## Lessons

A lesson is the main thing you produce: the unit in which knowledge and skills reach the user. Each lesson is one self-contained HTML file, saved to `teaching/<topic-slug>/lessons/` and titled `0001-<dash-case-name>.html`, where the number increments each time.

A lesson should be beautiful: clean, readable typography and layout. The user should want to return to it later.

Teach one thing only. Make it completable quickly, but give the user a tangible win that builds toward the mission. Tie it directly to the mission and the user's zone of proximal development.

Make opening a lesson easy. When possible, include a simple command such as:

macOS:

```bash
open teaching/<topic-slug>/lessons/0001-<dash-case-name>.html
```

Windows PowerShell:

```powershell
Start-Process teaching\<topic-slug>\lessons\0001-<dash-case-name>.html
```

Linux:

```bash
xdg-open teaching/<topic-slug>/lessons/0001-<dash-case-name>.html
```

## Mission

Every lesson should tie back to the mission: the reason the user is learning the topic.

If the user is unclear about the mission, or `MISSION.md` is not populated, first ask why they want to learn this topic. Failing to understand the mission makes lessons too abstract and removes your basis for choosing what to teach next.

## Zone of Proximal Development

Each lesson should challenge the learner just enough.

If the user specifies exactly what they want to learn, teach that thing if it fits the mission. If they do not, determine their zone of proximal development by:

- Reading `teaching/<topic-slug>/learning-records/`
- Reading `teaching/<topic-slug>/MISSION.md`
- Identifying the most relevant next skill that is neither too easy nor too hard

If the user says they already know something, record it in `learning-records/` when it affects future lesson selection.

## Acquiring Knowledge and Skills

Lessons should be designed around a skill the user will learn. Include only the knowledge required to acquire that skill. Teach the knowledge first, then have the user practice through an interactive feedback loop.

Gather knowledge from trusted resources. Use `RESOURCES.md` to track them. Lessons should include citations and links for important claims, so the user can go deeper later.

Each lesson should remind the user to ask follow-up questions. The agent is their teacher and can assist with anything unclear.

### Skill Practice

Teach skills through feedback loops. Options include:

- Interactive HTML lessons with quizzes and light in-browser tasks
- Lessons that guide the user through real-world steps
- In-agent quizzes with scenario-based questions

Feedback should be tight and immediate. Prefer automatic feedback when practical.

## Acquiring Wisdom

Wisdom comes from real-world interaction: testing skills outside the learning environment.

When a question appears to require wisdom, answer what you can, then recommend a suitable community or real-world feedback source when appropriate.

A community is a place where the user can test skills in the real world: a forum, subreddit, professional group, local class, coworker review loop, or interest group. Try to find high-reputation communities. Respect the user if they prefer not to join communities.

## Reference Documents

While creating lessons, also create reference documents when useful. Lessons can link to these documents. Reference documents track reusable units of knowledge across lessons.

Lessons may not be revisited often; references will be. References should be compressed, accurate, and designed for quick review.

Useful reference types include:

- Syntax and code snippets for programming
- Algorithms and flowcharts for processes
- Workflow checklists for office or support work
- Yoga poses and sequences
- Exercises and routines for fitness
- Glossaries for topics with specialized terms

Glossaries are especially important. Once a glossary exists, use its terminology consistently in every lesson.

## NOTES.md

Use `NOTES.md` for teaching preferences, constraints, and working notes the user wants preserved within this topic workspace. Do not put private memory, secrets, or sensitive client data here.
