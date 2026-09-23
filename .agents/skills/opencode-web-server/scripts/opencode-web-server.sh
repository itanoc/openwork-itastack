#!/usr/bin/env bash
set -euo pipefail

cmd="${1:-status}"
shift || true

port="4096"
host="0.0.0.0"
lan="1"
apply="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --port)
      port="${2:?missing --port value}"
      shift 2
      ;;
    --host)
      host="${2:?missing --host value}"
      shift 2
      ;;
    --lan)
      host="0.0.0.0"
      lan="1"
      shift
      ;;
    --local)
      host="127.0.0.1"
      lan="0"
      shift
      ;;
    --apply)
      apply="1"
      shift
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      exit 2
      ;;
  esac
done

workspace="$(pwd)"
runtime_dir="$workspace/.opencode/runtime/opencode-web-server"
pid_file="$runtime_dir/server.pid"
log_file="$runtime_dir/server.log"
err_log_file="$runtime_dir/server-err.log"
url_file="$runtime_dir/server.url"
awake_pid_file="$runtime_dir/keep-awake.pid"

sql_quote() {
  local value="$1"
  value="${value//\'/\'\'}"
  printf "'%s'" "$value"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

ensure_runtime() {
  mkdir -p "$runtime_dir"
  if [[ -f "$workspace/.opencode/.gitignore" ]]; then
    if ! grep -qx 'runtime/' "$workspace/.opencode/.gitignore"; then
      printf '\nruntime/\n' >> "$workspace/.opencode/.gitignore"
    fi
  fi
}

opencode_data_path() {
  opencode debug paths | while read -r key value _; do
    if [[ "$key" == "data" ]]; then
      printf '%s\n' "$value"
      break
    fi
  done
}

db_path() {
  local data
  data="$(opencode_data_path)"
  if [[ -z "$data" ]]; then
    printf 'Could not determine OpenCode data path from opencode debug paths\n' >&2
    exit 1
  fi
  printf '%s/opencode.db\n' "$data"
}

integrity_check() {
  local db="$1"
  local result
  result="$(sqlite3 "$db" 'pragma integrity_check;')"
  if [[ "$result" != "ok" ]]; then
    printf 'Database integrity check failed: %s\n' "$result" >&2
    exit 1
  fi
}

bad_count() {
  local db="$1"
  local q_workspace
  q_workspace="$(sql_quote "$workspace")"
  sqlite3 "$db" "select count(*) from session where directory=$q_workspace and (agent is null or agent='' or model is null or model='' or json_valid(model)=0) and (select count(*) from message where message.session_id=session.id)=0;"
}

web_base() {
  printf 'http://127.0.0.1:%s' "$port"
}

url_for_runtime() {
  local ip url
  ip="$(lan_ip)"
  if [[ "$lan" == "1" && -n "$ip" ]]; then
    url="http://$ip:$port"
  else
    url="http://127.0.0.1:$port"
  fi
  printf '%s\n' "$url"
}

listener_pids() {
  if command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP:"$port" -sTCP:LISTEN -t 2>/dev/null | sort -u || true
  elif command -v ss >/dev/null 2>&1; then
    ss -ltnp "sport = :$port" 2>/dev/null | grep -Eo 'pid=[0-9]+' | cut -d= -f2 | sort -u || true
  elif command -v netstat >/dev/null 2>&1; then
    netstat -ltnp 2>/dev/null | awk -v p=":$port" '$4 ~ p"$" {print $7}' | cut -d/ -f1 | grep -E '^[0-9]+$' | sort -u || true
  fi
}

pid_args() {
  local pid="$1"
  ps -p "$pid" -o args= 2>/dev/null || true
}

pid_running_opencode_listener() {
  local pid="$1" args
  [[ -n "$pid" ]] || return 1
  args="$(pid_args "$pid")"
  [[ "$args" =~ [Oo]pencode ]] || return 1
  if [[ "$args" =~ (^|[[:space:]])web($|[[:space:]]) ]]; then
    return 0
  fi
  [[ "$args" =~ (^|[[:space:]])--port[[:space:]]+$port($|[[:space:]]) ]] || [[ "$args" =~ (^|[[:space:]])--port=$port($|[[:space:]]) ]]
}

web_root_check() {
  curl --max-time 5 -fsS "$(web_base)/" >/dev/null 2>&1
}

project_current_check() {
  curl --max-time 5 -fsS "$(web_base)/project/current" 2>/dev/null | python3 -c 'import sys; print(sys.stdin.read()[:500])' 2>/dev/null || return 1
}

project_current_worktree() {
  curl --max-time 5 -fsS "$(web_base)/project/current" 2>/dev/null | python3 -c 'import json, sys
try:
    data=json.load(sys.stdin)
    print(data.get("worktree") or "")
except Exception:
    sys.exit(1)' 2>/dev/null
}

active_listener_pid() {
  local pid
  while read -r pid; do
    [[ -n "$pid" ]] || continue
    printf '%s\n' "$pid"
    return 0
  done < <(listener_pids)
  return 1
}

write_runtime_state() {
  local pid="$1" url
  ensure_runtime
  url="$(url_for_runtime)"
  printf '%s\n' "$pid" > "$pid_file"
  printf '%s\n' "$url" > "$url_file"
}

list_known_dbs() {
  local active data candidate
  active="$(db_path 2>/dev/null || true)"
  [[ -n "$active" ]] && printf '%s\tactive\n' "$active"
  for candidate in \
    "$HOME/.local/share/opencode/opencode.db" \
    "$HOME/.config/opencode/opencode.db" \
    "$HOME/Library/Application Support/opencode/opencode.db" \
    "$HOME/Library/Application Support/com.differentai.openwork/opencode.db"; do
    [[ -f "$candidate" && "$candidate" != "$active" ]] && printf '%s\tcandidate\n' "$candidate"
  done
}

mapping_diagnose() {
  local db="$1" mode="${2:-doctor}"
  python3 - "$db" "$workspace" "$mode" <<'PY'
import json, os, sqlite3, sys

db, workspace, mode = sys.argv[1], os.path.realpath(sys.argv[2]), sys.argv[3]

def qident(name):
    return '"' + name.replace('"', '""') + '"'

def is_related_path(value):
    if not isinstance(value, str):
        return False
    if not value.startswith('/'):
        return False
    try:
        value = os.path.realpath(value)
    except Exception:
        return False
    if value == workspace:
        return False
    return workspace.startswith(value.rstrip(os.sep) + os.sep) or value.startswith(workspace.rstrip(os.sep) + os.sep)

def is_exact_path(value):
    if not isinstance(value, str):
        return False
    if not value.startswith('/'):
        return False
    try:
        return os.path.realpath(value) == workspace
    except Exception:
        return value == workspace

def looks_path_col(col):
    c = col.lower()
    return any(token in c for token in ('directory', 'path', 'root', 'workspace', 'worktree', 'sandbox', 'cwd'))

result = {
    'session_rows': 'unknown',
    'project_exact_rows': 0,
    'directory_exact_rows': 0,
    'sandbox_conflict_rows': 0,
    'repair_candidates': [],
}

if not os.path.exists(db):
    print('Mapping diagnosis: db missing')
    sys.exit(0)

conn = sqlite3.connect(f'file:{db}?mode=ro', uri=True)
conn.row_factory = sqlite3.Row
tables = [r[0] for r in conn.execute("select name from sqlite_master where type='table' and name not like 'sqlite_%' order by name")]

if 'session' in tables:
    cols = [r[1] for r in conn.execute('pragma table_info(session)')]
    if 'directory' in cols:
        result['session_rows'] = conn.execute('select count(*) from session where directory=?', (workspace,)).fetchone()[0]

for table in tables:
    if table in ('message', 'session'):
        continue
    cols = [r[1] for r in conn.execute(f'pragma table_info({qident(table)})')]
    path_cols = [c for c in cols if looks_path_col(c)]
    if not path_cols:
        continue
    select_cols = ['rowid'] + path_cols
    try:
        rows = conn.execute('select ' + ', '.join(qident(c) for c in select_cols) + ' from ' + qident(table) + ' limit 5000').fetchall()
    except sqlite3.Error:
        continue
    for row in rows:
        exact_cols = [c for c in path_cols if is_exact_path(row[c])]
        related_cols = [c for c in path_cols if is_related_path(row[c])]
        if exact_cols:
            lname = table.lower()
            if 'project' in lname:
                result['project_exact_rows'] += 1
            if 'directory' in lname or any('directory' in c.lower() for c in exact_cols):
                result['directory_exact_rows'] += 1
        if exact_cols and related_cols:
            candidate = {
                'table': table,
                'rowid': row['rowid'],
                'exact_columns': exact_cols,
                'related_columns': related_cols,
            }
            result['sandbox_conflict_rows'] += 1
            lname = table.lower()
            if 'sandbox' in lname or 'directory' in lname or any('sandbox' in c.lower() for c in path_cols):
                result['repair_candidates'].append(candidate)

safe = len(result['repair_candidates']) > 0
if result['session_rows'] == 'unknown':
    diagnosis = 'sessions unknown'
elif result['session_rows'] == 0:
    diagnosis = 'session rows missing'
elif result['sandbox_conflict_rows']:
    diagnosis = 'project mapping broken, safe repair available' if safe else 'project mapping broken, manual review required'
else:
    diagnosis = 'project mapping OK'

print('Mapping diagnosis: ' + diagnosis)
print('Session rows for workspace: ' + str(result['session_rows']))
print('Project exact rows: ' + str(result['project_exact_rows']))
print('Project directory exact rows: ' + str(result['directory_exact_rows']))
print('Sandbox/root conflict rows: ' + str(result['sandbox_conflict_rows']))
print('Safe repair candidates: ' + str(len(result['repair_candidates'])))
if mode == 'json':
    print(json.dumps(result, sort_keys=True))
else:
    for c in result['repair_candidates'][:10]:
        print('Repair candidate: table={table} rowid={rowid} exact={exact_columns} related={related_columns}'.format(**c))
PY
}

repair_sessions() {
  require_cmd opencode
  require_cmd sqlite3
  ensure_runtime

  local db data backups backup count q_workspace derived agent model changed
  db="$(db_path)"
  data="$(dirname "$db")"
  backups="$data/backups"
  q_workspace="$(sql_quote "$workspace")"

  if [[ ! -f "$db" ]]; then
    printf 'OpenCode database not found: %s\n' "$db" >&2
    exit 1
  fi

  integrity_check "$db"
  count="$(bad_count "$db")"
  if [[ "$count" == "0" ]]; then
    printf 'Session repair: no invalid empty rows found.\n'
    return 0
  fi

  mkdir -p "$backups"
  backup="$backups/opencode-$(date +%Y%m%d-%H%M%S)-before-web-session-fix.db"
  sqlite3 "$db" ".backup '$backup'"
  integrity_check "$backup"

  derived="$(sqlite3 -separator $'\t' "$db" "select agent, model from session where directory=$q_workspace and agent is not null and agent<>'' and model is not null and model<>'' and json_valid(model)=1 order by time_updated desc limit 1;")"
  agent="${derived%%$'\t'*}"
  model="${derived#*$'\t'}"
  if [[ -z "$derived" || "$agent" == "$derived" ]]; then
    agent="openwork"
    model='{"id":"gpt-5.5","providerID":"cliproxy","variant":"default"}'
  fi

  sqlite3 "$db" "begin immediate; update session set agent=$(sql_quote "$agent"), model=$(sql_quote "$model") where directory=$q_workspace and (agent is null or agent='' or model is null or model='' or json_valid(model)=0) and (select count(*) from message where message.session_id=session.id)=0; select changes(); commit;" > "$runtime_dir/last-repair-changes.txt"
  changed="$(tr -d '\r\n' < "$runtime_dir/last-repair-changes.txt")"

  integrity_check "$db"
  count="$(bad_count "$db")"
  printf 'Session repair: patched %s empty invalid row(s). Remaining invalid empty rows: %s. Backup: %s\n' "$changed" "$count" "$backup"
}

repair_project_mapping() {
  require_cmd opencode
  require_cmd sqlite3
  require_cmd python3
  ensure_runtime

  local db
  db="$(db_path)"

  if [[ ! -f "$db" ]]; then
    printf 'OpenCode database not found: %s\n' "$db" >&2
    exit 1
  fi

  integrity_check "$db"
  printf 'Project mapping repair preflight:\n'
  mapping_diagnose "$db" doctor

  if [[ "$apply" != "1" ]]; then
    printf 'Dry run only. Re-run with --apply after reviewing candidates.\n'
    return 0
  fi

  printf 'Project mapping repair refused: no schema-specific safe repair is implemented yet. Manual review required.\n' >&2
  return 1
}

pid_running_opencode() {
  local pid="$1"
  [[ -n "$pid" ]] || return 1
  ps -p "$pid" -o args= 2>/dev/null | grep -qi 'opencode'
}

pid_running() {
  local pid="$1"
  [[ -n "$pid" ]] || return 1
  kill -0 "$pid" >/dev/null 2>&1
}

pid_running_command() {
  local pid="$1" pattern="$2"
  [[ -n "$pid" ]] || return 1
  ps -p "$pid" -o args= 2>/dev/null | grep -qi "$pattern"
}

ask_keep_awake() {
  local answer
  if [[ ! -t 0 ]]; then
    return 1
  fi
  printf 'Prevent system sleep while OpenCode web server runs? [y/N] '
  read -r answer
  [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]
}

start_keep_awake() {
  ensure_runtime
  local existing_pid os awake_pid
  if [[ -f "$awake_pid_file" ]]; then
    existing_pid="$(cat "$awake_pid_file")"
    if pid_running_command "$existing_pid" 'caffeinate'; then
      printf 'Sleep prevention already enabled with helper PID %s.\n' "$existing_pid"
      return 1
    elif pid_running "$existing_pid"; then
      printf 'Sleep prevention helper PID %s no longer looks like this script-owned helper. Leaving process untouched.\n' "$existing_pid" >&2
    fi
    rm -f "$awake_pid_file"
  fi

  os="$(uname -s 2>/dev/null || printf unknown)"
  case "$os" in
    Darwin)
      if ! command -v caffeinate >/dev/null 2>&1; then
        printf 'Sleep prevention requested, but caffeinate was not found. Continuing without sleep prevention.\n' >&2
        return 1
      fi
      caffeinate -dimsu &
      awake_pid="$!"
      printf '%s\n' "$awake_pid" > "$awake_pid_file"
      sleep 1
      if ! pid_running_command "$awake_pid" 'caffeinate'; then
        rm -f "$awake_pid_file"
        printf 'Sleep prevention requested, but caffeinate did not stay running. Continuing without sleep prevention.\n' >&2
        return 1
      fi
      printf 'Sleep prevention enabled with caffeinate PID %s.\n' "$awake_pid"
      return 0
      ;;
    *)
      printf 'Sleep prevention requested, but no scoped helper is implemented for this OS. Continuing without sleep prevention.\n' >&2
      return 1
      ;;
  esac
}

stop_keep_awake() {
  local awake_pid
  [[ -f "$awake_pid_file" ]] || return 0
  awake_pid="$(cat "$awake_pid_file")"
  if pid_running_command "$awake_pid" 'caffeinate'; then
    kill "$awake_pid" 2>/dev/null || true
    printf 'Sleep prevention stopped. Helper PID: %s\n' "$awake_pid"
  elif pid_running "$awake_pid"; then
    printf 'Sleep prevention helper PID %s no longer looks like this script-owned helper. Leaving process untouched.\n' "$awake_pid" >&2
  fi
  rm -f "$awake_pid_file"
}

lan_ip() {
  local ip=""
  if command -v ipconfig >/dev/null 2>&1; then
    ip="$(ipconfig getifaddr en0 2>/dev/null || true)"
    [[ -n "$ip" ]] || ip="$(ipconfig getifaddr en1 2>/dev/null || true)"
  fi
  if [[ -z "$ip" ]] && command -v hostname >/dev/null 2>&1; then
    ip="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
  fi
  printf '%s\n' "$ip"
}

api_check() {
  local base
  base="$(web_base)"
  local encoded
  encoded="$(python3 - <<'PY' "$workspace"
import sys, urllib.parse
print(urllib.parse.quote(sys.argv[1], safe=''))
PY
)"
  curl --max-time 10 -fsS "$base/session?directory=$encoded&roots=true&limit=5" >/dev/null
}

doctor_cmd() {
  require_cmd opencode
  require_cmd python3
  ensure_runtime

  local db pid listener_state root_state session_state current_state current_worktree mapping_state mapping_phrase line
  db="$(db_path 2>/dev/null || true)"
  pid="$(active_listener_pid || true)"
  listener_state="server not running"
  root_state="not checked"
  session_state="not checked"
  current_state="not checked"
  mapping_state="unknown"

  if [[ -n "$pid" ]]; then
    if pid_running_opencode_listener "$pid"; then
      listener_state="expected OpenCode server already running"
      if web_root_check; then root_state="ok"; else root_state="failed"; fi
      if api_check; then session_state="ok"; else session_state="failed"; fi
      if project_current_check >/dev/null; then current_state="ok"; else current_state="failed"; fi
      if [[ "$current_state" == "ok" ]]; then current_worktree="$(project_current_worktree || true)"; else current_worktree=""; fi
    else
      listener_state="unrelated process on port"
    fi
  fi

  if [[ -n "$db" && -f "$db" ]] && command -v sqlite3 >/dev/null 2>&1; then
    line="$(mapping_diagnose "$db" doctor | sed -n '1p')"
    mapping_state="${line#Mapping diagnosis: }"
  fi
  mapping_phrase="$mapping_state"
  if [[ "$mapping_phrase" == project\ mapping\ * ]]; then
    mapping_phrase="${mapping_phrase#project mapping }"
  fi

  if [[ "$listener_state" == "server not running" ]]; then
    printf 'Diagnosis: server not running, sessions %s, project mapping %s\n' "$session_state" "$mapping_phrase"
  elif [[ "$listener_state" == "unrelated process on port" ]]; then
    printf 'Diagnosis: unrelated process on port, sessions not checked, project mapping %s\n' "$mapping_phrase"
  elif [[ "$session_state" == "ok" && "$mapping_state" == "project mapping OK" ]]; then
    if [[ -n "$current_worktree" && "$current_worktree" != "$workspace" ]]; then
      printf 'Diagnosis: server OK, sessions OK, browser current-project issue likely\n'
    else
      printf 'Diagnosis: server OK, sessions OK, project mapping OK\n'
    fi
  elif [[ "$session_state" == "ok" && "$mapping_state" == project\ mapping\ broken* ]]; then
    printf 'Diagnosis: server OK, sessions OK, %s\n' "$mapping_state"
  elif [[ "$session_state" != "ok" ]]; then
    printf 'Diagnosis: server reachable, session-row issue possible, project mapping %s\n' "$mapping_phrase"
  else
    printf 'Diagnosis: server %s, sessions %s, project mapping %s\n' "$root_state" "$session_state" "$mapping_phrase"
  fi

  printf 'Workspace: %s\n' "$workspace"
  printf 'Port: %s\n' "$port"
  printf 'Listener: %s\n' "$listener_state"
  if [[ -n "$pid" ]]; then
    printf 'Listener PID: %s\n' "$pid"
    printf 'Listener command: %s\n' "$(pid_args "$pid")"
  fi
  printf 'Root HTTP: %s\n' "$root_state"
  printf 'Session API: %s\n' "$session_state"
  printf 'Project current API: %s\n' "$current_state"
  if [[ -n "${current_worktree:-}" ]]; then
    printf 'Project current worktree: %s\n' "$current_worktree"
  fi
  if [[ "$current_state" == "ok" ]]; then
    printf 'Project current API sample: '
    project_current_check | tr '\n' ' ' | cut -c1-500
    printf '\n'
  fi
  if [[ -n "$db" ]]; then
    printf 'Active OpenCode DB: %s\n' "$db"
  fi
  printf 'Known OpenCode DB locations:\n'
  list_known_dbs || true
  if [[ -n "$db" && -f "$db" ]] && command -v sqlite3 >/dev/null 2>&1; then
    mapping_diagnose "$db" doctor
    printf 'Invalid empty session rows: %s\n' "$(bad_count "$db" 2>/dev/null || printf unknown)"
  fi
}

status_cmd() {
  ensure_runtime
  local db count pid url state
  db="$(db_path 2>/dev/null || true)"
  printf 'Workspace: %s\n' "$workspace"
  printf 'Runtime: %s\n' "$runtime_dir"
  if [[ -n "$db" ]]; then
    printf 'OpenCode DB: %s\n' "$db"
    if [[ -f "$db" ]] && command -v sqlite3 >/dev/null 2>&1; then
      count="$(bad_count "$db" 2>/dev/null || printf 'unknown')"
      printf 'Invalid empty session rows: %s\n' "$count"
    fi
  fi
  if [[ -f "$pid_file" ]]; then
    pid="$(cat "$pid_file")"
    if pid_running_opencode "$pid"; then
      state="running"
    else
      state="stale"
    fi
    printf 'PID: %s (%s)\n' "$pid" "$state"
  else
    printf 'PID: none\n'
  fi
  if [[ -f "$url_file" ]]; then
    url="$(cat "$url_file")"
    printf 'URL: %s\n' "$url"
  fi
  if [[ -f "$awake_pid_file" ]]; then
    local awake_pid awake_state
    awake_pid="$(cat "$awake_pid_file")"
    if pid_running_command "$awake_pid" 'caffeinate'; then
      awake_state="running"
    else
      awake_state="stale"
    fi
    printf 'Sleep prevention: %s (%s)\n' "$awake_pid" "$awake_state"
  else
    printf 'Sleep prevention: none\n'
  fi
  if command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP:"$port" -sTCP:LISTEN 2>/dev/null || true
  fi
}

start_cmd() {
  require_cmd opencode
  require_cmd python3
  ensure_runtime
  repair_sessions

  local pid ip url keep_awake_started listener_pid
  if [[ -f "$pid_file" ]]; then
    pid="$(cat "$pid_file")"
    if pid_running_opencode "$pid"; then
      printf 'OpenCode web server already running with PID %s.\n' "$pid"
      status_cmd
      return 0
    fi
    rm -f "$pid_file" "$url_file"
  fi

  listener_pid="$(active_listener_pid || true)"
  if [[ -n "$listener_pid" ]]; then
    if pid_running_opencode_listener "$listener_pid" && web_root_check; then
      printf 'Expected OpenCode web listener already running on port %s. Adopting PID %s.\n' "$port" "$listener_pid"
      write_runtime_state "$listener_pid"
      if ask_keep_awake; then
        start_keep_awake || true
      fi
      doctor_cmd || true
      return 0
    fi
    printf 'Port %s is already in use by an unrelated or unverifiable process. Refusing to start duplicate server.\n' "$port" >&2
    if command -v lsof >/dev/null 2>&1; then
      lsof -nP -iTCP:"$port" -sTCP:LISTEN || true
    fi
    exit 1
  fi

  keep_awake_started="0"
  if ask_keep_awake; then
    if start_keep_awake; then
      keep_awake_started="1"
    fi
  fi

  (unset OPENCODE_SERVER_USERNAME OPENCODE_SERVER_PASSWORD; exec opencode web --hostname "$host" --port "$port") > "$log_file" 2> "$err_log_file" &
  pid="$!"
  printf '%s\n' "$pid" > "$pid_file"
  sleep 2
  if ! pid_running_opencode "$pid"; then
    if [[ "$keep_awake_started" == "1" ]]; then
      stop_keep_awake
    fi
    printf 'OpenCode web server failed to stay running. Logs: %s %s\n' "$log_file" "$err_log_file" >&2
    exit 1
  fi

  ip="$(lan_ip)"
  url="$(url_for_runtime)"
  printf '%s\n' "$url" > "$url_file"

  if api_check; then
    printf 'Session API: ok\n'
  else
    printf 'Session API: not verified. Check server logs.\n'
  fi
  doctor_cmd || true
  printf 'OpenCode web server started. Local: http://127.0.0.1:%s LAN: %s PID: %s Logs: %s %s\n' "$port" "$url" "$pid" "$log_file" "$err_log_file"
}

stop_cmd() {
  ensure_runtime
  if [[ ! -f "$pid_file" ]]; then
    printf 'No saved PID file. Nothing stopped.\n'
    stop_keep_awake
    status_cmd
    return 0
  fi
  local pid
  pid="$(cat "$pid_file")"
  if ! pid_running_opencode "$pid"; then
    printf 'Saved PID %s is not a running opencode process. Removing stale state.\n' "$pid"
    rm -f "$pid_file" "$url_file"
    stop_keep_awake
    return 0
  fi
  kill "$pid"
  sleep 2
  if pid_running_opencode "$pid"; then
    printf 'Process %s still running after graceful stop. Refusing force kill without confirmation.\n' "$pid" >&2
    exit 1
  fi
  rm -f "$pid_file" "$url_file"
  stop_keep_awake
  printf 'OpenCode web server stopped. Logs preserved: %s %s\n' "$log_file" "$err_log_file"
}

case "$cmd" in
  bootstrap|repair-sessions)
    repair_sessions
    if [[ "$cmd" == "bootstrap" ]]; then
      doctor_cmd || true
    fi
    ;;
  doctor)
    doctor_cmd
    ;;
  repair-project-mapping)
    repair_project_mapping
    ;;
  start)
    start_cmd
    ;;
  stop)
    stop_cmd
    ;;
  status)
    status_cmd
    ;;
  *)
    printf 'Usage: %s {bootstrap|doctor|repair-sessions|repair-project-mapping|start|stop|status} [--port N] [--lan|--local] [--host HOST] [--apply]\n' "$0" >&2
    exit 2
    ;;
esac
