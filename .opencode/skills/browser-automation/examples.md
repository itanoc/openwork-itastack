# Browser Automation Examples

This file captures common browser automation failure patterns and recommended responses.

## Long `browser_eval` timeout while work may continue

Problem:

- A long async script starts changing live UI state.
- CDP returns a timeout.
- Browser may keep running the script after the tool call fails.
- Re-running the same script can duplicate work.

Better pattern:

- Put progress on `window._browserAutomationRun`.
- Poll status with short `browser_eval` calls.
- If a timeout happens, inspect current URL, modal state, and status object before retrying.

## Duplicate Add risk

Problem:

- Automation clicks Add, then times out before confirming save.
- Re-running clicks Add again and creates duplicate rows.

Better pattern:

- Before Add, scan existing rows for the target value.
- After timeout, close/reopen modal and check persisted state before clicking Add again.
- Use `skipped: already set` when the target row exists.

## SPA route changes do not load record state

Problem:

- Script uses `history.pushState('/record?id=123')`.
- URL changes but React/Vue app keeps current list or detail state.
- Wait for target text fails.

Better pattern:

- Use real row click/double-click, link click, or `browser_navigate` for full load.
- Wait for target record text plus a stable control, not URL alone.

## Same modal has multiple layouts

Problem:

- Most records show full fields immediately.
- Some records show only instructions and an Add button.
- Other records show Add first, then a partial first dropdown, then remaining fields after choosing a type.

Better pattern:

- Inspect modal controls per item.
- Handle known variants as separate branches.
- Stop if a new variant appears.

Example variants:

- Full layout: Type, Assign To, Level, Add, Save.
- Add-first layout: Add reveals Type/Assign/Level row.
- Type-first layout: Add reveals Type only; choosing `Agent` reveals Assign To and Level.

## Save happens in layers

Problem:

- Modal Save closes modal but record remains in edit mode.
- A top-level Save is still required.
- Automation reports success too early.

Better pattern:

- After modal Save, wait for modal close.
- Look for top-level Save.
- Click it when present.
- Wait for read-only mode or Edit button to return.

## Hidden input values can verify UI selections

Problem:

- React Select visible text is hard to read or duplicated.

Better pattern:

- Inspect hidden form inputs after selecting values.
- Example: selection row may expose `agent_id=-9999` and `level=3`.
- Still use visible UI actions to make changes unless user approves API/state mutation.

## Browser-only means no API writes

Problem:

- Internal API is discoverable and easier to call.
- User specifically says browser-only.

Better pattern:

- Use API/resource inspection only to understand UI shape if appropriate.
- Do not write through API.
- Prefer visible clicks and form actions.

## When to pause and ask

Pause when:

- Write action is irreversible or business-impacting.
- UI changed from tested path.
- Duplicate risk exists.
- The tool timed out during a live write.
- A field maps ambiguously to user instruction.

Ask one targeted question, or report the stop condition and safest next action.
