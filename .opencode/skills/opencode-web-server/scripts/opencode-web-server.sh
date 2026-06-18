#!/usr/bin/env bash
set -euo pipefail

cmd="${1:-status}"
shift || true

port="4096"
host="0.0.0.0"
lan="1"

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
  local base="http://127.0.0.1:$port"
  local encoded
  encoded="$(python3 - <<'PY' "$workspace"
import sys, urllib.parse
print(urllib.parse.quote(sys.argv[1], safe=''))
PY
)"
  curl --max-time 10 -fsS "$base/session?directory=$encoded&roots=true&limit=5" >/dev/null
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
    lsof -nP -iTCP:"$port" -sTCP:LISTEN || true
  fi
}

start_cmd() {
  require_cmd opencode
  require_cmd python3
  ensure_runtime
  repair_sessions

  local pid ip url keep_awake_started
  if [[ -f "$pid_file" ]]; then
    pid="$(cat "$pid_file")"
    if pid_running_opencode "$pid"; then
      printf 'OpenCode web server already running with PID %s.\n' "$pid"
      status_cmd
      return 0
    fi
    rm -f "$pid_file" "$url_file"
  fi

  if command -v lsof >/dev/null 2>&1 && lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
    printf 'Port %s is already in use. Refusing to start duplicate server.\n' "$port" >&2
    lsof -nP -iTCP:"$port" -sTCP:LISTEN || true
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
  if [[ "$lan" == "1" && -n "$ip" ]]; then
    url="http://$ip:$port"
  else
    url="http://127.0.0.1:$port"
  fi
  printf '%s\n' "$url" > "$url_file"

  if api_check; then
    printf 'Session API: ok\n'
  else
    printf 'Session API: not verified. Check server logs.\n'
  fi
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
    printf 'Usage: %s {bootstrap|repair-sessions|start|stop|status} [--port N] [--lan|--local] [--host HOST]\n' "$0" >&2
    exit 2
    ;;
esac
