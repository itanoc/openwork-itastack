# Linux Failover Scripts

> Source: https://www.3cx.com/docs/linux-pbx-failover/

## Introduction

The following scripts can be used when setting up Failover between Passive/Active Linux PBXs.

- DNSgoogle.sh
- Kill3CXServices.sh
- Shutdown3CXMainMachine.sh
- Stop3CXServices.sh
- StopsAndKill3CXServices.sh

In order for the scripts to work properly, you need to:

1. Exchange SSH keys for phonesystem user across active and passive PBXs for passwordless SSH authentication
2. Change permissions of uploaded script so they can be executed by the phonesystem user
3. Allow all relevant commands to be executed on Active PBX for phonesystem user in sudoers configuration
4. Only for DNSgoogle.sh script, Install gcloud cli and authenticate phonesystem user on the Passive PBX

The linux scripts for download can be found [here](https://downloads-global.3cx.com/downloads/misc/LinuxFailoverExampleScripts.zip).

## Step 1: Allow scripts to be executed by phonesystem user

Needed for: Kill3CXServices.sh, Shutdown3CXMainMachine.sh, Stop3CXServices.sh, StopsAndKill3CXServices.sh

1. Login to Management Console of the Passive PBX
2. Navigate to Backup and Restore > Failover and upload your scripts in Before/After sections
3. SSH on the Passive PBX and run the following commands (replace before.sh and after.sh with actual script names):

```bash
cd /var/lib/3cxpbx/Instance1/Scripts
chmod 700 before.sh
chmod 700 after.sh
```

## Step 2: Exchanging SSH keys for phonesystem user across Passive and Active PBX for passwordless SSH

1. SSH on Passive PBX:

```bash
su phonesystem
ssh-keygen
cat ~/.ssh/id_rsa.pub
```

Notes:
- When running ssh-keygen press enter to save to default location. Press enter with an empty passphrase.
- Note down the public_key_string for step 2.

2. SSH on Active PBX:

```bash
su phonesystem
mkdir -p ~/.ssh
echo public_key_string >> ~/.ssh/authorized_keys
chmod -R go= ~/.ssh
chown -R phonesystem:phonesystem ~/.ssh
```

3. SSH on Passive PBX to test:

```bash
su phonesystem
ssh phonesystem@activeIP
```

Replace ActiveIP with actual IP. If asked, click y and enter to accept authenticity.

## Step 3: Allow execution of commands on Active PBX for phonesystem user in sudoers

1. SSH on Active PBX
2. Edit sudoers:

```bash
nano /etc/sudoers.d/90-cloud-init-users
```

3. Append these lines and save (Ctrl-X, y, Enter):

```
phonesystem ALL=(ALL) NOPASSWD: /usr/sbin/shutdown now
phonesystem ALL=(ALL) NOPASSWD: /usr/sbin/service *
phonesystem ALL=(ALL) NOPASSWD: /usr/bin/killall *
```

## Step 4: DNS script

### Allow scripts to be executed by phonesystem user

Needed only for: DNSgoogle.sh

- Login to Management Console of the Passive PBX
- Navigate to Backup and Restore > Failover and upload scripts in Before/After sections
- SSH on Passive PBX:

```bash
cd /var/lib/3cxpbx/Instance1/Scripts
chmod 700 before.sh
chmod 700 after.sh
```

### Install and authenticate gcloud CLI for phonesystem user

1. SSH to Passive machine, install gcloud cli:

```bash
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates gnupg curl sudo
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-cli
```

2. Authenticate gcloud cli as phonesystem user:

```bash
su phonesystem
gcloud init
```

Notes:
- Follow instructions to authenticate
- gcloud init provides a URL to open in browser
- Once authenticated, Google provides a code to input back

## See also

- [Configuring Failover with 3CX](https://www.3cx.com/docs/failover/)

## Last Updated

This document was last updated on 23 June 2023
