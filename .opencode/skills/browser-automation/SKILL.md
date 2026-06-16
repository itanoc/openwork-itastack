---
name: browser-automation
description: Use when the user asks for browser automation, automating a website, clicking through web app entries, using the browser to change UI state, or repeatable browser-controlled work. Do not use for normal web research or simple page reading.
---

# Browser Automation

Use this skill for browser-controlled web app work: clicking, filling forms, navigating records, changing settings, or repeating UI actions across multiple entries.

Do not use this skill for normal web research, page summarization, or documentation lookup unless the task also requires browser UI control.

## Core rule

Default to supervised automation first. Move to unattended batching only after selectors, one-item behavior, save behavior, and duplicate behavior are understood.

For live write actions, use this progression:

1. Open the page with the OpenWork browser.
2. Inspect visible UI and DOM structure.
3. Identify stable selectors and possible UI variants.
4. Run one item only.
5. Verify saved state in the UI.
6. Checkpoint with the user before batching live changes, unless they already explicitly approved batching after the one-item test.
7. Batch with progress polling and stop conditions.

## Browser tool setup

Always start external websites with `openwork_browser_open_url`. Use the returned `browser_url` and `target_id` for every later browser action.

Do not use browser tools for OpenWork app navigation. Use `openwork_ui_*` for OpenWork UI.

## Early inspection checklist

Before making changes:

- Read page text and current URL.
- Snapshot visible controls when useful.
- Inspect likely rows, buttons, forms, and modals with `browser_eval`.
- Capture record identifiers from visible UI when available.
- Check whether page is React/Vue/SPA and whether URL changes actually load records.
- Identify save layers: modal save, page save, record save, confirmation dialogs.
- Identify duplicate risk: Add/Create/Submit buttons, repeated access rows, multi-step forms.

## Prefer real browser behavior

Use real clicks, double-clicks, form fills, and full navigation when route changes matter.

Avoid relying on `history.pushState`, direct JavaScript state mutation, or internal app APIs unless the user explicitly asks for that approach. SPAs often do not react to synthetic URL changes the way they react to real navigation or row clicks.

For navigation:

- Prefer clicking visible rows/links when testing UI flow.
- Use `browser_navigate` for full page loads when stable direct URLs exist.
- After navigation, wait for page text or controls that prove the target record loaded.

## One-item test pattern

For live changes:

1. Pick one representative item.
2. Perform the full UI path exactly as a human would.
3. Save through every required layer.
4. Reopen or refresh enough to verify the saved state.
5. If anything unexpected appears, stop and report before continuing.

Checkpoint wording:

`One-item test passed. Batch will change N items. Continue?`

If the user already gave explicit approval to continue after the test, proceed without asking again.

## Duplicate-check before Add/Create/Submit

Before clicking buttons that create rows or records, check whether the target state already exists.

Examples:

- If adding an access-control row, scan existing rows for the same subject and level.
- If adding a member, check whether the member already exists.
- If creating a mapping, check whether the mapping already exists.

If present, skip and record `already set` instead of adding again.

## Batch run pattern

For more than a few items, avoid one long blocking `browser_eval` that may exceed the CDP timeout.

Preferred pattern:

1. Start a background async run inside the page.
2. Store progress on a global status object, such as `window._browserAutomationRun`.
3. Poll that object with short `browser_eval` calls.
4. Report progress briefly.
5. Keep per-item results: completed, skipped, errors, current item.

Status object shape:

- `running`: boolean
- `started`: ISO timestamp
- `current`: current item id/name
- `completed`: array
- `skipped`: array with reason
- `errors`: array with item id/name/error/tail text
- `done`: boolean
- `finished`: ISO timestamp

## Stop conditions

Stop or pause when:

- UI shape differs from expected selectors.
- Modal shows different fields than previous items.
- Save button disappears or changes meaning.
- Add/Create action could create duplicates and duplicate-check is uncertain.
- Page navigates unexpectedly.
- Authentication/session state changes.
- A run times out while live data may still be changing.

When stopped, report:

- current item
- what completed
- what skipped
- exact unexpected UI shape
- safest next action

## Modal and dynamic UI handling

Expect multiple layouts for the same task.

For each modal:

- Inspect text and controls after opening.
- Wait for spinners to finish.
- If fields are missing, close and reopen once.
- If still missing, try the visible intended control only if safe, such as an `Add` button that reveals an input row.
- Re-inspect controls after every modal transition.

Do not assume one modal layout applies to every record.

## Save behavior

Many web apps require more than one save:

- modal-level save
- page-level save
- record-level save
- post-save confirmation

After a save:

- wait for the modal to close or UI to return to read-only mode
- confirm top-level Save is gone or Edit is back
- verify saved state on at least one item before batching

## Progress reporting

Use concise progress updates for long live runs:

- `Progress: 10 added, 2 skipped, no errors.`
- `Stopped at X: modal had no expected fields.`
- `Retrying X with special modal path.`

Avoid dumping full logs unless needed for troubleshooting.

## Examples

See `examples.md` for failure patterns and browser automation lessons captured from real sessions.
