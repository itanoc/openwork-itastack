# Using an FTP Server for 3CX Backups - Linux

> Source: https://www.3cx.com/docs/ftp-server-pbx-backups-linux/

This guide presents the supported FTP solutions available for 3CX Backup and Restore on Linux.

**Important Note**: The FTP servers tested by 3CX on Linux are [vsftpd](https://security.appspot.com/vsftpd.html) and [Pro-FTPd](http://www.proftpd.org). An FTP server runs independently of your 3CX PBX and is not required to be installed on the same machine. The FTP server mentioned in this guide is [vsftpd](https://security.appspot.com/vsftpd.html).

## FTP Server for Linux

This guide describes the installation of the **"vsftpd"** (very secure file transfer protocol daemon) FTP server on Debian 9/ Debian 10.

## Configure the vsftpd FTP Service

1. Use an account with administrative privileges to log on to your Linux system via SSH or local terminal.
2. Update the APT repository information:

```bash
sudo apt update
```

3. Install vsftpd:

```bash
sudo apt install -y vsftpd
```

4. Configure vsftpd by editing the configuration file:

```bash
sudo nano /etc/vsftpd.conf
```

5. Set or modify the following parameters:

```
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=50000
```

6. Restart vsftpd:

```bash
sudo systemctl restart vsftpd
sudo systemctl enable vsftpd
```

## Add an FTP User to vsftpd

1. Create a system user for FTP access:

```bash
sudo useradd -m ftpuser
sudo passwd ftpuser
```

2. Create a directory for backups and set permissions:

```bash
sudo mkdir -p /home/ftpuser/3cxbackups
sudo chown ftpuser:ftpuser /home/ftpuser/3cxbackups
```

3. For the 3CX Backup configuration, set:
   - FTP Server: IP address of the FTP server
   - Port: 21
   - Username: ftpuser
   - Password: (the password set above)
   - Path: /3cxbackups

## See More

- [Using an FTP Server for 3CX Backups - Windows](https://www.3cx.com/docs/ftp-server-pbx-backups-windows/)
- [3CX Backup & Restore Commands](https://www.3cx.com/docs/backup-restore-command-line/)
