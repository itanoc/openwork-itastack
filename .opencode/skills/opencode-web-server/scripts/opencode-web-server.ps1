param(
    [Parameter(Position=0)]
    [ValidateSet('bootstrap','repair-sessions','start','stop','status')]
    [string]$Command = 'status',
    [int]$Port = 4096,
    [switch]$Lan,
    [switch]$LocalOnly,
    [switch]$PreventSleep,
    [switch]$NoPreventSleep,
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

    $listener = $null
    if (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue) {
        $listener = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
    }
    if ($listener) {
        Write-Output "Port $Port is already in use. Refusing to start duplicate server."
        $listener | Format-Table -AutoSize | Out-String | Write-Output
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

    $ip = Get-LanIp
    if (-not $LocalOnly -and $ip) { $url = "http://$ip`:$Port" } else { $url = "http://127.0.0.1:$Port" }
    Set-Content -Path $UrlFile -Value $url

    if (Test-SessionApi) { Write-Output 'Session API: ok' } else { Write-Output 'Session API: not verified. Check server logs.' }
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
    'bootstrap' { Repair-Sessions }
    'repair-sessions' { Repair-Sessions }
    'start' { Start-Server }
    'stop' { Stop-Server }
    'status' { Show-Status }
}
