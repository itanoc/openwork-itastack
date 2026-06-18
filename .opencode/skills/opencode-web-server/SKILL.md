---
name: opencode-web-server
description: |
  Bootstrap, start, stop, repair, or check a background OpenCode web server for the current workspace, reachable on the local network, with OpenWork session compatibility checks.

  Triggers when user mentions:
  - "start OpenCode web server"
  - "stop OpenCode web server"
  - "OpenCode server on local network"
  - "opencode web background"
  - "make OpenWork sessions visible in OpenCode web"
---

# OpenCode Web Server

Use this skill to manage a background `opencode web` server for the current workspace and make OpenWork-created sessions visible in the OpenCode web UI when possible.

## Purpose

- Run first-time setup checks for the current machine.
- Find the OpenCode data path with `opencode debug paths`.
- Verify `opencode.db` exists and is healthy.
- Repair only empty, invalid OpenWork/OpenCode session rows that crash the web session list.
- Start OpenCode web UI in the background for the active workspace.
- Bind to `0.0.0.0` so LAN devices can connect.
- Ask whether to prevent system sleep while the server runs, using a scoped helper when enabled.
- Save local runtime state outside shared repo content.
- Report LAN URL and log paths.
- Stop the server safely using saved PID.
- Check status without changing server state.

## Preferred helpers

Use helper scripts from this skill instead of long inline commands.

macOS/Linux:

- `.opencode/skills/opencode-web-server/scripts/opencode-web-server.sh bootstrap`
- `.opencode/skills/opencode-web-server/scripts/opencode-web-server.sh start --port 4096 --lan`
- `.opencode/skills/opencode-web-server/scripts/opencode-web-server.sh status --port 4096`
- `.opencode/skills/opencode-web-server/scripts/opencode-web-server.sh stop`

The macOS/Linux helper prompts for sleep prevention only when stdin is interactive. macOS uses `caffeinate` when approved; Linux currently continues without sleep prevention.

Windows PowerShell:

- `powershell -ExecutionPolicy Bypass -File .opencode\skills\opencode-web-server\scripts\opencode-web-server.ps1 bootstrap`
- `powershell -ExecutionPolicy Bypass -File .opencode\skills\opencode-web-server\scripts\opencode-web-server.ps1 start -Port 4096 -Lan`
- `powershell -ExecutionPolicy Bypass -File .opencode\skills\opencode-web-server\scripts\opencode-web-server.ps1 status -Port 4096`
- `powershell -ExecutionPolicy Bypass -File .opencode\skills\opencode-web-server\scripts\opencode-web-server.ps1 stop`

Windows PowerShell options:

- Add `-PreventSleep` to skip the prompt and enable scoped sleep prevention.
- Add `-NoPreventSleep` to skip the prompt and leave sleep behavior unchanged.

## Commands

- `bootstrap`: run first-time checks, repair safe empty invalid session rows, and verify session API if a server is running.
- `repair-sessions`: run only database compatibility repair.
- `start`: run bootstrap, start server if not already running, verify server and session API.
- `stop`: stop only the saved server PID after verifying it belongs to `opencode`.
- `status`: report PID, port, LAN URL, DB path, invalid row count, and session API state.

## Safety rules

- Local-network exposure is intentional but sensitive. Warn that anyone on the same trusted network who can reach the port may reach the OpenCode web server, depending on OpenCode auth/session behavior.
- Do not suggest internet exposure, port forwarding, tunnels, reverse proxies, or firewall opening unless the user explicitly asks and accepts risk.
- Bind to `0.0.0.0` only for LAN use. Use `127.0.0.1` for local-only use.
- Never patch sessions with messages.
- Never delete sessions.
- Always back up `opencode.db` before any database mutation.
- Stop before mutation if `sqlite3` is missing.
- Stop if database integrity check fails.
- Before stopping, verify saved PID still belongs to an `opencode` process.
- Never kill broad process matches such as all `opencode` processes unless the user explicitly approves after seeing candidates.
- Store runtime state under `.opencode/runtime/opencode-web-server/`; do not commit runtime files.
- Use current workspace path, not hardcoded local paths.
- Do not permanently change OS power plans. Keep sleep prevention scoped to a helper process saved under runtime state.
- On stop, terminate only the saved keep-awake helper if it still looks script-owned. Never kill broad `caffeinate`, `powershell`, or `pwsh` matches.

## Runtime paths

Use workspace-relative runtime path:

- Directory: `.opencode/runtime/opencode-web-server/`
- PID file: `.opencode/runtime/opencode-web-server/server.pid`
- Log files: `.opencode/runtime/opencode-web-server/server.log` and `.opencode/runtime/opencode-web-server/server-err.log`
- URL file: `.opencode/runtime/opencode-web-server/server.url`
- Keep-awake PID file: `.opencode/runtime/opencode-web-server/keep-awake.pid`
- Windows keep-awake helper script: `.opencode/runtime/opencode-web-server/keep-awake.ps1`

If `.opencode/runtime/` is not ignored, add it to `.opencode/.gitignore` before starting the server.

## First-time setup workflow

1. Detect operating system.
2. Confirm `opencode` exists.
3. Confirm `sqlite3` exists before database repair.
4. Run `opencode debug paths` and parse the `data` path.
5. Confirm `<data>/opencode.db` exists.
6. Run `pragma integrity_check;` on the database.
7. Count bad session rows in the current workspace.
8. If bad rows exist, back up database using SQLite `.backup`.
9. Repair only rows that match all conditions:
   - `directory` equals current workspace path.
   - row has zero messages.
   - `agent` is null/empty, or `model` is null/empty, or `model` is invalid JSON.
10. Derive repair values from newest valid session in the same workspace.
11. If no valid session exists, use fallback values:
   - `agent='openwork'`
   - `model='{"id":"gpt-5.5","providerID":"cliproxy","variant":"default"}'`
12. Verify integrity again.
13. Verify invalid empty row count is zero.

## Start workflow

1. Run bootstrap first.
2. Check saved PID; if running and process is `opencode`, report existing server.
3. Check target port. If occupied by an untracked process, report and stop unless user approves next action.
4. Get LAN IP.
5. Ask whether to prevent system sleep while the server runs.
6. If approved, start scoped sleep-prevention helper:
   - Windows: hidden PowerShell helper using `SetThreadExecutionState`; save helper PID. `-PreventSleep` enables this without prompting. `-NoPreventSleep` skips the prompt.
   - macOS: `caffeinate`; save helper PID.
   - Other OS: report unsupported and continue without sleep prevention.
7. Start `opencode web` in background.
8. Save PID, URL, and log paths.
9. Verify process is alive and port is listening.
10. Verify web root returns HTTP success.
11. Verify session API without Basic auth; start clears inherited `OPENCODE_SERVER_USERNAME` and `OPENCODE_SERVER_PASSWORD` only for the child process.
12. Report local URL, LAN URL, PID file, log files, sleep-prevention state, and backup path if repair occurred.

## Stop workflow

1. Read PID file.
2. If missing, report no saved server state and offer status scan if useful.
3. Verify process exists and command/args include `opencode`.
4. Send graceful stop.
5. Wait briefly.
6. If still running, ask before force kill. Do not force-kill without confirmation.
7. Remove PID and URL files only after process stops or PID was stale.
8. Stop saved keep-awake helper only if it still looks script-owned.
9. Keep log files for troubleshooting unless user asks to remove them.

## Status workflow

1. Verify saved PID if present.
2. Check port listener.
3. Read URL file if present.
4. Check OpenCode data path and database presence.
5. Count invalid empty session rows for current workspace.
6. Check session API if server is running.
7. Report one of:
   - Running: include PID, URL, log paths, sleep-prevention state, session API status.
   - Stale PID: include stale PID and recommend cleanup.
   - Not running: include whether port is free or occupied by another process.

## OpenWork session compatibility notes

OpenWork sessions can already live in OpenCode's `opencode.db`. OpenCode web may fail to list sessions if old empty rows have missing `agent` or `model` values. This skill repairs only empty invalid rows, after backup, so real chat history is not modified.

If session API still fails after repair, stop and report:

- DB integrity result.
- invalid empty row count.
- API HTTP status and body reference.
- server log paths.

## Success criteria

- Bootstrap: database path found, integrity `ok`, invalid empty rows fixed or none found.
- Start: `opencode web` process is alive, port is listening, URL file exists, LAN URL reported, and any requested sleep-prevention helper is running with a saved PID.
- Session list: OpenCode web UI/API lists OpenWork-created sessions for the current workspace.
- Stop: saved PID no longer running, PID and URL files removed or marked stale, any script-owned sleep-prevention helper stopped, log files preserved.
- Status: process, port, database, and API state reported without modifying running server.
