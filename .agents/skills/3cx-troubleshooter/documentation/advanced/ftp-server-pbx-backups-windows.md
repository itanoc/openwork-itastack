# Using an FTP Server for 3CX Backups - Windows

> Source: https://www.3cx.com/docs/ftp-server-pbx-backups-windows/

This guide presents the supported FTP solutions available for 3CX Backup and Restore on Windows.

**Important Note**: The FTP servers tested by 3CX on Windows are [FileZilla](https://filezilla-project.org/) and [Synology FTP](https://kb.synology.com/en-global/DSM/tutorial/How_to_access_files_on_Synology_NAS_via_FTP). An FTP server runs independently of your 3CX PBX and is not required to be installed on the same machine. The FTP server software mentioned in this guide is [FileZilla](https://filezilla-project.org/).

## Install FileZilla FTP Server for Windows

1. Use an account with administrative privileges to log on to your Windows Server and download [FileZilla Server](https://filezilla-project.org/download.php?show_all=1&type=server).
2. If needed, allow the installer to run.
3. Follow the installation wizard with default options.

## Configure the FileZilla FTP Service

1. Open FileZilla Server Interface
2. Click on **"Server"** > **"Configure"**
3. Under **"General settings"**:
   - Set the listening port (default 21)
   - Set the admin interface port
4. Under **"FTP over TLS settings"** (optional):
   - Generate a new certificate or import an existing one
   - Enable FTP over TLS if secure transfers are required

## FileZilla Passive Mode Options

Configure passive mode for compatibility with firewalls:

1. In FileZilla Server settings, go to **"Passive mode settings"**
2. Select **"Use the following IP"** and enter the server's external IP
3. Set the passive mode port range (e.g. 50000-51000)
4. Ensure these ports are open in the firewall

## Add an FTP User account

1. In FileZilla Server Interface, go to **"Edit"** > **"Users"**
2. Click **"Add"** and enter a username (e.g. 3cxbackup)
3. Set a password for the user
4. Under **"Shared folders"**, add the backup directory and set permissions (Read + Write + Delete + List)
5. Set the home directory for the user

## Configure 3CX to Use the FTP Server

In the 3CX Management Console:

1. Go to **"Backup & Restore"**
2. Under **"FTP Server"**, configure:
   - Server: IP address or hostname of the FTP server
   - Port: 21 (default FTP)
   - Username: (the FTP user created above)
   - Password: (the FTP user password)
   - Path: (the backup directory, e.g. / or /backups)
3. Click **"Test Connection"** to verify

## See More

- [Using an FTP Server for 3CX Backups - Linux](https://www.3cx.com/docs/ftp-server-pbx-backups-linux/)
- [3CX Backup & Restore Commands](https://www.3cx.com/docs/backup-restore-command-line/)
