# 3CX Backup & Restore Commands

> Source: https://www.3cx.com/docs/backup-restore-command-line/

## Introduction

These commands can be used to create scripts and schedule backup and restore operations, externally to the built-in 3CX Management Console functionality. This is useful when hosting on cloud for archiving in bulk PBX users, data and configuration for safekeeping.

## BackupCmd

The BackupCmd command line tool enables backups to be taken with these options:

| Option | Description |
|--------|-------------|
| `-l, --log=VALUE` | Log filename or full file path |
| `-f, --file=VALUE` | *Filename to backup in default backup location or full zip archive path |
| `-o, --options=VALUE` | Backup options (ALL, or comma-separated: CH, LIC, FQDN, PROMPTS, FW, REC, VM) |
| `--pwd=Value` | Encrypt backup files with password (V15.5 Sp2 onwards) |
| `-h, --help` | Display command help |
| `--noemail` | Do not send an email on backup completion |

*Mandatory option.

Backup options:
- ALL - include everything
- CH - Call History
- LIC - License
- FQDN - Phone System FQDN
- PROMPTS - Voice Prompts
- FW - Phone Firmware
- REC - Recordings
- VM - Voicemails

### General

Specifying a filename with the `--file` or `-f` switch:
- filename only: stored in the backup location configured in the Management Console
  ```
  BackupCmd -f=my-pbx_full_bak.zip
  ```
- full path: overrides configured location and stores in specified path
  ```
  BackupCmd -f=c:\backup\my-pbx_full_bak.zip
  ```

### Backup Command on Windows

Open a command prompt with administrative privileges:

```cmd
cd C:\Program Files\3CX Phone System\Bin
```

Display available options:
```cmd
BackupCmd.exe --help
```

Make a full PBX backup:
```cmd
BackupCmd.exe --file=full_pbx_backup.zip --options=ALL --log=backup_cmd.log
```

Make a partial backup:
```cmd
BackupCmd.exe --file=partial_pbx_backup.zip --options=CH,LIC,FQDN --log=backup_cmd.log
```

### Backup Command on Linux

Run as the phonesystem user using sudo:

```bash
sudo -u phonesystem 3CXBackupCmd --help
```

Make a full PBX backup:
```bash
sudo -u phonesystem 3CXBackupCmd --file=full_pbx_backup.zip --options=ALL --log=/var/tmp/pbx-backup_cmd.log
```

Make a partial backup:
```bash
sudo -u phonesystem 3CXBackupCmd --file=partial_pbx_backup.zip --options=CH,LIC,FQDN --log=/var/tmp/pbx_backup_cmd.log
```

## RestoreCmd

The RestoreCMD tool enables restoring backups via command line with these options:

| Option | Description |
|--------|-------------|
| `-l, --log=VALUE` | Log path or filename |
| `-f, --file=VALUE` | *Backup path or filename to restore |
| `-h, --help` | Show command help |
| `--pwd=Value` | Decrypt backup with given password |
| `--failover` | Failover mode - services are not started after restore on passive failover node |

### General

Specifying a filename with `--file` or `-f`:
- filename only: retrieves from backup location configured in Management Console
  ```
  RestoreCmd -f=my-pbx_full_bak.zip -l=c:\backup\restore_cmd.log
  ```
- full path: retrieves from the specified path
  ```
  RestoreCmd -f=c:\backup\my-pbx_full_bak.zip -l=c:\backup\restore_cmd.log
  ```

### Restore Command on Windows

```cmd
cd C:\Program Files\3CX Phone System\Bin
```

Display available options:
```cmd
RestoreCmd.exe --help
```

Restore and start services:
```cmd
RestoreCmd.exe --file=pbx_backup.zip --log=restore_cmd.log
```

Restore in failover mode:
```cmd
RestoreCmd.exe --file=pbx_backup.zip --log=restore_cmd.log --failover
```

### Restore Command on Linux

```bash
sudo -u phonesystem 3CXRestoreCmd --help
```

Restore and start services:
```bash
sudo -u phonesystem 3CXRestoreCmd --file=pbx_backup.zip --log=restore_cmd.log
```

Restore in failover mode:
```bash
sudo -u phonesystem 3CXRestoreCmd --file=pbx_backup.zip --log=restore_cmd.log --failover
```

## See Also

- Learn how to [Create and Convert OpenSSH Keys](https://www.3cx.com/docs/manual/convert-open-ssh-key/)

## Last Updated

This document was last updated on 11 June 2023
