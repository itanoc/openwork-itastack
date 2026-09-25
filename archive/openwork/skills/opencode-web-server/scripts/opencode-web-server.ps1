param(
    [Parameter(Position=0)]
    [ValidateSet('bootstrap','doctor','repair-sessions','repair-project-mapping','start','stop','status')]
    [string]$Command = 'status',
    [int]$Port = 4096,
    [switch]$Lan,
    [switch]$LocalOnly,
    [switch]$PreventSleep,
    [switch]$NoPreventSleep,
    [switch]$Apply,
    [string]$HostName = ''
)

$ErrorActionPreference = 'Stop'

$Workspace = (Get-Location).Path
$RuntimeDir = Join-Path $Workspace '.opencode\runtime\opencode-web-server'
$PidFile = Join-Path $RuntimeDir 'server.pid'
$LogFile = Join-Path $RuntimeDir 'server.log'
$ErrLogFile = Join-Path $RuntimeDir 'server-err.log'
$UrlFile = Join-Path $RuntimeDir 'server.url'
$AwakePidFile = Join-Path $RuntimeDir 'keep-awake.pid'
$AwakeScriptFile = Join-Path $RuntimeDir 'keep-awake.ps1'

if ([string]::IsNullOrWhiteSpace($HostName)) {
    if ($LocalOnly) { $HostName = '127.0.0.1' } else { $HostName = '0.0.0.0' }
}
if ($PreventSleep -and $NoPreventSleep) {
    throw 'Use only one of -PreventSleep or -NoPreventSleep.'
}

function Ensure-Runtime {
    New-Item -ItemType Directory -Force -Path $RuntimeDir | Out-Null
    $ignorePath = Join-Path $Workspace '.opencode\.gitignore'
    if (Test-Path $ignorePath) {
        $content = Get-Content $ignorePath -ErrorAction SilentlyContinue
        if ($content -notcontains 'runtime/') {
            Add-Content -Path $ignorePath -Value 'runtime/'
        }
    }
}

function Require-Command($Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Missing required command: $Name"
    }
}

function SqlQuote([string]$Value) {
    return "'" + ($Value -replace "'", "''") + "'"
}

function Get-OpenCodeDataPath {
    $lines = & opencode debug paths
    foreach ($line in $lines) {
        if ($line -match '^data\s+(.+)$') {
            return $Matches[1].Trim()
        }
    }
    throw 'Could not determine OpenCode data path from opencode debug paths'
}

function Get-DbPath {
    $data = Get-OpenCodeDataPath
    return (Join-Path $data 'opencode.db')
}

function Invoke-SqliteScalar([string]$Db, [string]$Sql) {
    return (& sqlite3 $Db $Sql) -join "`n"
}

function Test-DbIntegrity([string]$Db) {
    $result = Invoke-SqliteScalar $Db 'pragma integrity_check;'
    if ($result -ne 'ok') {
        throw "Database integrity check failed: $result"
    }
}

function Get-BadCount([string]$Db) {
    $qWorkspace = SqlQuote $Workspace
    $sql = "select count(*) from session where directory=$qWorkspace and (agent is null or agent='' or model is null or model='' or json_valid(model)=0) and (select count(*) from message where message.session_id=session.id)=0;"
    return Invoke-SqliteScalar $Db $sql
}

function Repair-Sessions {
    Require-Command opencode
    Require-Command sqlite3
    Ensure-Runtime

    $db = Get-DbPath
    if (-not (Test-Path $db)) { throw "OpenCode database not found: $db" }
    Test-DbIntegrity $db
    $count = Get-BadCount $db
    if ($count -eq '0') {
        Write-Output 'Session repair: no invalid empty rows found.'
        return
    }

    $data = Split-Path $db -Parent
    $backupDir = Join-Path $data 'backups'
    New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = Join-Path $backupDir "opencode-$stamp-before-web-session-fix.db"
    & sqlite3 $db ".backup '$backup'"
    Test-DbIntegrity $backup

    $qWorkspace = SqlQuote $Workspace
    $derived = (& sqlite3 -separator "`t" $db "select agent, model from session where directory=$qWorkspace and agent is not null and agent<>'' and model is not null and model<>'' and json_valid(model)=1 order by time_updated desc limit 1;") -join ''
    if ([string]::IsNullOrWhiteSpace($derived) -or ($derived -notmatch "`t")) {
        $agent = 'openwork'
        $model = '{"id":"gpt-5.5","providerID":"cliproxy","variant":"default"}'
    } else {
        $parts = $derived -split "`t", 2
        $agent = $parts[0]
        $model = $parts[1]
    }

    $sql = "begin immediate; update session set agent=$(SqlQuote $agent), model=$(SqlQuote $model) where directory=$qWorkspace and (agent is null or agent='' or model is null or model='' or json_valid(model)=0) and (select count(*) from message where message.session_id=session.id)=0; select changes(); commit;"
    $changed = Invoke-SqliteScalar $db $sql
    Test-DbIntegrity $db
    $remaining = Get-BadCount $db
    Write-Output "Session repair: patched $changed empty invalid row(s). Remaining invalid empty rows: $remaining. Backup: $backup"
}

function Test-OpenCodeProcess([int]$ProcessId) {
    try {
        $proc = Get-Process -Id $ProcessId -ErrorAction Stop
        return ($proc.ProcessName -match 'opencode')
    } catch {
        return $false
    }
}

function Test-ProcessRunning([int]$ProcessId) {
    try {
        Get-Process -Id $ProcessId -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Read-KeepAwakePreference {
    if ($PreventSleep) { return $true }
    if ($NoPreventSleep) { return $false }
    if (-not [Environment]::UserInteractive) { return $false }
    $answer = Read-Host 'Prevent system sleep while OpenCode web server runs? [y/N]'
    return ($answer -match '^(?i:y|yes)$')
}

function Test-KeepAwakeProcess([int]$ProcessId) {
    try {
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId = $ProcessId" -ErrorAction Stop
        if (-not $proc) { return $false }
        return (($proc.Name -match '^(powershell|pwsh)(\.exe)?$') -and ($proc.CommandLine -like "*$AwakeScriptFile*"))
    } catch {
        return $false
    }
}

function Start-KeepAwake {
    Ensure-Runtime
    if (Test-Path $AwakePidFile) {
        $existingPidText = (Get-Content $AwakePidFile -Raw).Trim()
        if ($existingPidText -match '^\d+$' -and (Test-KeepAwakeProcess ([int]$existingPidText))) {
            Write-Output "Sleep prevention already enabled with helper PID $existingPidText."
            return $false
        }
        Remove-Item -Force -ErrorAction SilentlyContinue $AwakePidFile
    }

    $keepAwakeScript = @'
Add-Type -Namespace Kernel32 -Name NativeMethods -MemberDefinition @"
[System.Runtime.InteropServices.DllImport("kernel32.dll")]
public static extern uint SetThreadExecutionState(uint esFlags);
"@
$ES_CONTINUOUS = 0x80000000
$ES_SYSTEM_REQUIRED = 0x00000001
[Kernel32.NativeMethods]::SetThreadExecutionState($ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED) | Out-Null
try {
    while ($true) {
        Start-Sleep -Seconds 30
        [Kernel32.NativeMethods]::SetThreadExecutionState($ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED) | Out-Null
    }
} finally {
    [Kernel32.NativeMethods]::SetThreadExecutionState($ES_CONTINUOUS) | Out-Null
}
'@
    Set-Content -Path $AwakeScriptFile -Value $keepAwakeScript
    $psExe = if (Get-Command powershell.exe -ErrorAction SilentlyContinue) { 'powershell.exe' } elseif (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }
    $proc = Start-Process -FilePath $psExe -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $AwakeScriptFile) -WindowStyle Hidden -PassThru
    Set-Content -Path $AwakePidFile -Value $proc.Id
    Start-Sleep -Seconds 1
    if (-not (Test-KeepAwakeProcess $proc.Id)) {
        Remove-Item -Force -ErrorAction SilentlyContinue $AwakePidFile
        Write-Output 'Sleep prevention requested, but helper did not stay running. Continuing without sleep prevention.'
        return
    }
    Write-Output "Sleep prevention enabled with helper PID $($proc.Id)."
}

function Stop-KeepAwake {
    if (-not (Test-Path $AwakePidFile)) { return }
    $awakePidText = (Get-Content $AwakePidFile -Raw).Trim()
    if ($awakePidText -notmatch '^\d+$') {
        Remove-Item -Force -ErrorAction SilentlyContinue $AwakePidFile
        return
    }
    $awakePid = [int]$awakePidText
    if (Test-KeepAwakeProcess $awakePid) {
        Stop-Process -Id $awakePid
        Write-Output "Sleep prevention stopped. Helper PID: $awakePid"
    } elseif (Test-ProcessRunning $awakePid) {
        Write-Output "Sleep prevention helper PID $awakePid no longer looks like this script-owned helper. Leaving process untouched."
    }
    Remove-Item -Force -ErrorAction SilentlyContinue $AwakePidFile
}

function Get-LanIp {
    if (-not (Get-Command Get-NetIPAddress -ErrorAction SilentlyContinue)) {
        return ''
    }
    $ip = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -notmatch '^127\.' -and $_.IPAddress -notmatch '^169\.254\.' -and $_.PrefixOrigin -ne 'WellKnown' } |
        Select-Object -First 1 -ExpandProperty IPAddress
    return $ip
}

function Test-SessionApi {
    $encoded = [System.Uri]::EscapeDataString($Workspace)
    $url = "http://127.0.0.1:$Port/session?directory=$encoded&roots=true&limit=5"
    try {
        Invoke-WebRequest -Uri $url -TimeoutSec 10 -UseBasicParsing | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Get-WebBase {
    return "http://127.0.0.1:$Port"
}

function Test-WebRoot {
    try {
        Invoke-WebRequest -Uri "$(Get-WebBase)/" -TimeoutSec 5 -UseBasicParsing | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Get-ProjectCurrentSample {
    try {
        $response = Invoke-WebRequest -Uri "$(Get-WebBase)/project/current" -TimeoutSec 5 -UseBasicParsing
        $text = [string]$response.Content
        if ($text.Length -gt 500) { return $text.Substring(0, 500) }
        return $text
    } catch {
        return $null
    }
}

function Get-ProjectCurrentWorktree {
    try {
        $response = Invoke-WebRequest -Uri "$(Get-WebBase)/project/current" -TimeoutSec 5 -UseBasicParsing
        $data = $response.Content | ConvertFrom-Json
        return [string]$data.worktree
    } catch {
        return ''
    }
}

function Get-ListenerProcessId {
    if (-not (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue)) { return $null }
    $listener = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($listener) { return [int]$listener.OwningProcess }
    return $null
}

function Get-ProcessCommandLine([int]$ProcessId) {
    try {
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId = $ProcessId" -ErrorAction Stop
        if ($proc) { return [string]$proc.CommandLine }
    } catch {
        try { return (Get-Process -Id $ProcessId -ErrorAction Stop).Path } catch { return '' }
    }
    return ''
}

function Test-OpenCodeWebListenerProcess([int]$ProcessId) {
    $cmd = Get-ProcessCommandLine $ProcessId
    if ($cmd -notmatch '(?i)opencode') { return $false }
    if ($cmd -match '(^|\s)web($|\s)') { return $true }
    return ($cmd -match "(^|\s)--port\s+$Port($|\s)" -or $cmd -match "(^|\s)--port=$Port($|\s)")
}

function Get-RuntimeUrl {
    $ip = Get-LanIp
    if (-not $LocalOnly -and $ip) { return "http://$ip`:$Port" }
    return "http://127.0.0.1:$Port"
}

function Write-RuntimeState([int]$ProcessId) {
    Ensure-Runtime
    Set-Content -Path $PidFile -Value $ProcessId
    Set-Content -Path $UrlFile -Value (Get-RuntimeUrl)
}

function Get-KnownDbLocations {
    $items = @()
    try { $items += [pscustomobject]@{ Path = (Get-DbPath); Type = 'active' } } catch {}
    $candidates = @()
    if ($env:LOCALAPPDATA) { $candidates += (Join-Path $env:LOCALAPPDATA 'opencode\opencode.db') }
    if ($env:APPDATA) { $candidates += (Join-Path $env:APPDATA 'opencode\opencode.db') }
    if ($HOME) {
        $candidates += (Join-Path $HOME '.local\share\opencode\opencode.db')
        $candidates += (Join-Path $HOME 'AppData\Roaming\opencode\opencode.db')
    }
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate) -and ($items.Path -notcontains $candidate)) {
            $items += [pscustomobject]@{ Path = $candidate; Type = 'candidate' }
        }
    }
    return $items
}

function Get-PythonRunner {
    foreach ($name in @('python', 'python3')) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) { return [pscustomobject]@{ FilePath = $cmd.Source; PrefixArgs = @() } }
    }
    $py = Get-Command py -ErrorAction SilentlyContinue
    if ($py) { return [pscustomobject]@{ FilePath = $py.Source; PrefixArgs = @('-3') } }
    throw 'Missing required command: python, python3, or py -3'
}

function Invoke-PythonStdin([string]$Script, [string[]]$Arguments) {
    $runner = Get-PythonRunner
    $invokeArgs = @($runner.PrefixArgs) + @('-') + $Arguments
    return ($Script | & $runner.FilePath @invokeArgs)
}

function Invoke-MappingDiagnose([string]$Db, [string]$Mode = 'doctor') {
    $script = @'
import json, os, sqlite3, sys
db, workspace, mode = sys.argv[1], os.path.realpath(sys.argv[2]), sys.argv[3]
def qident(name): return '"' + name.replace('"', '""') + '"'
def looks_path_col(col):
    c = col.lower()
    return any(token in c for token in ('directory', 'path', 'root', 'workspace', 'worktree', 'sandbox', 'cwd'))
def exact(value):
    return isinstance(value, str) and os.path.isabs(value) and os.path.realpath(value) == workspace
def related(value):
    if not isinstance(value, str) or not os.path.isabs(value): return False
    value = os.path.realpath(value)
    if value == workspace: return False
    return workspace.startswith(value.rstrip(os.sep) + os.sep) or value.startswith(workspace.rstrip(os.sep) + os.sep)
result = {'session_rows':'unknown','project_exact_rows':0,'directory_exact_rows':0,'sandbox_conflict_rows':0,'repair_candidates':[]}
if not os.path.exists(db):
    print('Mapping diagnosis: db missing')
    sys.exit(0)
conn = sqlite3.connect('file:' + db + '?mode=ro', uri=True)
conn.row_factory = sqlite3.Row
tables = [r[0] for r in conn.execute("select name from sqlite_master where type='table' and name not like 'sqlite_%' order by name")]
if 'session' in tables:
    cols = [r[1] for r in conn.execute('pragma table_info(session)')]
    if 'directory' in cols:
        result['session_rows'] = conn.execute('select count(*) from session where directory=?', (workspace,)).fetchone()[0]
for table in tables:
    if table in ('message', 'session'): continue
    cols = [r[1] for r in conn.execute(f'pragma table_info({qident(table)})')]
    path_cols = [c for c in cols if looks_path_col(c)]
    if not path_cols: continue
    try:
        rows = conn.execute('select ' + ', '.join(qident(c) for c in ['rowid'] + path_cols) + ' from ' + qident(table) + ' limit 5000').fetchall()
    except sqlite3.Error:
        continue
    for row in rows:
        exact_cols = [c for c in path_cols if exact(row[c])]
        related_cols = [c for c in path_cols if related(row[c])]
        if exact_cols:
            lname = table.lower()
            if 'project' in lname: result['project_exact_rows'] += 1
            if 'directory' in lname or any('directory' in c.lower() for c in exact_cols): result['directory_exact_rows'] += 1
        if exact_cols and related_cols:
            result['sandbox_conflict_rows'] += 1
            lname = table.lower()
            if 'sandbox' in lname or 'directory' in lname or any('sandbox' in c.lower() for c in path_cols):
                result['repair_candidates'].append({'table':table,'rowid':row['rowid'],'exact_columns':exact_cols,'related_columns':related_cols})
safe = len(result['repair_candidates']) > 0
if result['session_rows'] == 'unknown': diagnosis = 'sessions unknown'
elif result['session_rows'] == 0: diagnosis = 'session rows missing'
elif result['sandbox_conflict_rows']: diagnosis = 'project mapping broken, safe repair available' if safe else 'project mapping broken, manual review required'
else: diagnosis = 'project mapping OK'
print('Mapping diagnosis: ' + diagnosis)
print('Session rows for workspace: ' + str(result['session_rows']))
print('Project exact rows: ' + str(result['project_exact_rows']))
print('Project directory exact rows: ' + str(result['directory_exact_rows']))
print('Sandbox/root conflict rows: ' + str(result['sandbox_conflict_rows']))
print('Safe repair candidates: ' + str(len(result['repair_candidates'])))
if mode == 'json': print(json.dumps(result, sort_keys=True))
else:
    for c in result['repair_candidates'][:10]:
        print('Repair candidate: table={table} rowid={rowid} exact={exact_columns} related={related_columns}'.format(**c))
'@
    Invoke-PythonStdin $script @($Db, $Workspace, $Mode)
}

function Invoke-Doctor {
    Require-Command opencode
    $db = $null
    try { $db = Get-DbPath } catch {}
    $listenerPid = Get-ListenerProcessId
    $listenerState = 'server not running'
    $rootState = 'not checked'
    $sessionState = 'not checked'
    $currentState = 'not checked'
    $currentSample = $null
    $currentWorktree = ''
    if ($listenerPid) {
        if (Test-OpenCodeWebListenerProcess $listenerPid) {
            $listenerState = 'expected OpenCode server already running'
            $rootState = if (Test-WebRoot) { 'ok' } else { 'failed' }
            $sessionState = if (Test-SessionApi) { 'ok' } else { 'failed' }
            $currentSample = Get-ProjectCurrentSample
            $currentState = if ($null -ne $currentSample) { 'ok' } else { 'failed' }
            if ($currentState -eq 'ok') { $currentWorktree = Get-ProjectCurrentWorktree }
        } else {
            $listenerState = 'unrelated process on port'
        }
    }
    $mappingState = 'unknown'
    $pythonAvailable = $true
    try { Get-PythonRunner | Out-Null } catch { $pythonAvailable = $false }
    if ($db -and (Test-Path $db) -and (Get-Command sqlite3 -ErrorAction SilentlyContinue) -and $pythonAvailable) {
        $first = (Invoke-MappingDiagnose $db 'doctor' | Select-Object -First 1)
        $mappingState = $first -replace '^Mapping diagnosis: ', ''
    }
    $mappingPhrase = $mappingState
    if ($mappingPhrase -like 'project mapping *') { $mappingPhrase = $mappingPhrase -replace '^project mapping ', '' }
    if ($listenerState -eq 'server not running') {
        Write-Output "Diagnosis: server not running, sessions $sessionState, project mapping $mappingPhrase"
    } elseif ($listenerState -eq 'unrelated process on port') {
        Write-Output "Diagnosis: unrelated process on port, sessions not checked, project mapping $mappingPhrase"
    } elseif ($sessionState -eq 'ok' -and $mappingState -eq 'project mapping OK') {
        if ($currentWorktree -and $currentWorktree -ne $Workspace) {
            Write-Output 'Diagnosis: server OK, sessions OK, browser current-project issue likely'
        } else {
            Write-Output 'Diagnosis: server OK, sessions OK, project mapping OK'
        }
    } elseif ($sessionState -eq 'ok' -and $mappingState -like 'project mapping broken*') {
        Write-Output "Diagnosis: server OK, sessions OK, $mappingState"
    } elseif ($sessionState -ne 'ok') {
        Write-Output "Diagnosis: server reachable, session-row issue possible, project mapping $mappingPhrase"
    } else {
        Write-Output "Diagnosis: server $rootState, sessions $sessionState, project mapping $mappingPhrase"
    }
    Write-Output "Workspace: $Workspace"
    Write-Output "Port: $Port"
    Write-Output "Listener: $listenerState"
    if ($listenerPid) {
        Write-Output "Listener PID: $listenerPid"
        Write-Output "Listener command: $(Get-ProcessCommandLine $listenerPid)"
    }
    Write-Output "Root HTTP: $rootState"
    Write-Output "Session API: $sessionState"
    Write-Output "Project current API: $currentState"
    if ($currentWorktree) { Write-Output "Project current worktree: $currentWorktree" }
    if ($currentSample) { Write-Output "Project current API sample: $currentSample" }
    if ($db) { Write-Output "Active OpenCode DB: $db" }
    Write-Output 'Known OpenCode DB locations:'
    Get-KnownDbLocations | ForEach-Object { Write-Output "$($_.Path)`t$($_.Type)" }
    if ($db -and (Test-Path $db) -and (Get-Command sqlite3 -ErrorAction SilentlyContinue) -and $pythonAvailable) {
        Invoke-MappingDiagnose $db 'doctor'
        Write-Output "Invalid empty session rows: $(Get-BadCount $db)"
    }
}

function Repair-ProjectMapping {
    Require-Command opencode
    Require-Command sqlite3
    Get-PythonRunner | Out-Null
    Ensure-Runtime
    $db = Get-DbPath
    if (-not (Test-Path $db)) { throw "OpenCode database not found: $db" }
    Test-DbIntegrity $db
    Write-Output 'Project mapping repair preflight:'
    Invoke-MappingDiagnose $db 'doctor'
    if (-not $Apply) {
        Write-Output 'Dry run only. Re-run with -Apply after reviewing candidates.'
        return
    }

    Write-Output 'Project mapping repair refused: no schema-specific safe repair is implemented yet. Manual review required.'
    exit 1
}

function Show-Status {
    Ensure-Runtime
    Write-Output "Workspace: $Workspace"
    try {
        $db = Get-DbPath
        Write-Output "OpenCode DB: $db"
        if ((Test-Path $db) -and (Get-Command sqlite3 -ErrorAction SilentlyContinue)) {
            Write-Output "Invalid empty session rows: $(Get-BadCount $db)"
        }
    } catch {
        Write-Output "OpenCode DB: unknown ($($_.Exception.Message))"
    }
    if (Test-Path $PidFile) {
        $pidValue = [int](Get-Content $PidFile -Raw)
        $state = if (Test-OpenCodeProcess $pidValue) { 'running' } else { 'stale' }
        Write-Output "PID: $pidValue ($state)"
    } else {
        Write-Output 'PID: none'
    }
    if (Test-Path $UrlFile) {
        Write-Output "URL: $(Get-Content $UrlFile -Raw)"
    }
    if (Test-Path $AwakePidFile) {
        $awakePidText = (Get-Content $AwakePidFile -Raw).Trim()
        $awakeState = if ($awakePidText -match '^\d+$' -and (Test-KeepAwakeProcess ([int]$awakePidText))) { 'running' } else { 'stale' }
        Write-Output "Sleep prevention: $awakePidText ($awakeState)"
    } else {
        Write-Output 'Sleep prevention: none'
    }
    if (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue) {
        Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Format-Table -AutoSize | Out-String | Write-Output
    } else {
        Write-Output 'Port listener check skipped: Get-NetTCPConnection unavailable on this platform.'
    }
}

function Start-Server {
    Require-Command opencode
    Ensure-Runtime
    Repair-Sessions

    if (Test-Path $PidFile) {
        $pidValue = [int](Get-Content $PidFile -Raw)
        if (Test-OpenCodeProcess $pidValue) {
            Write-Output "OpenCode web server already running with PID $pidValue."
            Show-Status
            return
        }
        Remove-Item -Force -ErrorAction SilentlyContinue $PidFile, $UrlFile
    }

    $listenerPid = Get-ListenerProcessId
    if ($listenerPid) {
        if ((Test-OpenCodeWebListenerProcess $listenerPid) -and (Test-WebRoot)) {
            Write-Output "Expected OpenCode web listener already running on port $Port. Adopting PID $listenerPid."
            Write-RuntimeState $listenerPid
            if (Read-KeepAwakePreference) { Start-KeepAwake | Out-Null }
            Invoke-Doctor
            return
        }
        Write-Output "Port $Port is already in use by an unrelated or unverifiable process. Refusing to start duplicate server."
        if (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue) {
            Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Format-Table -AutoSize | Out-String | Write-Output
        }
        throw 'Port already in use'
    }

    $keepAwakeStarted = $false
    if (Read-KeepAwakePreference) {
        $hadKeepAwake = Test-Path $AwakePidFile
        Start-KeepAwake
        $keepAwakeStarted = (-not $hadKeepAwake) -and (Test-Path $AwakePidFile)
    }

    $args = @('web', '--hostname', $HostName, '--port', [string]$Port)
    $savedUser = $env:OPENCODE_SERVER_USERNAME
    $savedPassword = $env:OPENCODE_SERVER_PASSWORD
    Remove-Item Env:OPENCODE_SERVER_USERNAME -ErrorAction SilentlyContinue
    Remove-Item Env:OPENCODE_SERVER_PASSWORD -ErrorAction SilentlyContinue
    try {
        $proc = Start-Process -FilePath 'opencode' -ArgumentList $args -RedirectStandardOutput $LogFile -RedirectStandardError $ErrLogFile -PassThru -WindowStyle Hidden
    } finally {
        if ($null -eq $savedUser) { Remove-Item Env:OPENCODE_SERVER_USERNAME -ErrorAction SilentlyContinue } else { $env:OPENCODE_SERVER_USERNAME = $savedUser }
        if ($null -eq $savedPassword) { Remove-Item Env:OPENCODE_SERVER_PASSWORD -ErrorAction SilentlyContinue } else { $env:OPENCODE_SERVER_PASSWORD = $savedPassword }
    }
    Set-Content -Path $PidFile -Value $proc.Id
    Start-Sleep -Seconds 2
    if (-not (Test-OpenCodeProcess $proc.Id)) {
        if ($keepAwakeStarted) { Stop-KeepAwake }
        throw "OpenCode web server failed to stay running. Logs: $LogFile $ErrLogFile"
    }

    $url = Get-RuntimeUrl
    Set-Content -Path $UrlFile -Value $url

    if (Test-SessionApi) { Write-Output 'Session API: ok' } else { Write-Output 'Session API: not verified. Check server logs.' }
    try { Invoke-Doctor } catch { Write-Output "Doctor check failed: $($_.Exception.Message)" }
    Write-Output "OpenCode web server started. Local: http://127.0.0.1:$Port LAN: $url PID: $($proc.Id) Logs: $LogFile $ErrLogFile"
}

function Stop-Server {
    Ensure-Runtime
    if (-not (Test-Path $PidFile)) {
        Write-Output 'No saved PID file. Nothing stopped.'
        Stop-KeepAwake
        Show-Status
        return
    }
    $pidValue = [int](Get-Content $PidFile -Raw)
    if (-not (Test-OpenCodeProcess $pidValue)) {
        Write-Output "Saved PID $pidValue is not a running opencode process. Removing stale state."
        Remove-Item -Force -ErrorAction SilentlyContinue $PidFile, $UrlFile
        Stop-KeepAwake
        return
    }
    Stop-Process -Id $pidValue
    Start-Sleep -Seconds 2
    if (Test-OpenCodeProcess $pidValue) {
        throw "Process $pidValue still running after graceful stop. Refusing force kill without confirmation."
    }
    Remove-Item -Force -ErrorAction SilentlyContinue $PidFile, $UrlFile
    Stop-KeepAwake
    Write-Output "OpenCode web server stopped. Logs preserved: $LogFile $ErrLogFile"
}

switch ($Command) {
    'bootstrap' { Repair-Sessions; try { Invoke-Doctor } catch { Write-Output "Doctor check failed: $($_.Exception.Message)" } }
    'doctor' { Invoke-Doctor }
    'repair-sessions' { Repair-Sessions }
    'repair-project-mapping' { Repair-ProjectMapping }
    'start' { Start-Server }
    'stop' { Stop-Server }
    'status' { Show-Status }
}
