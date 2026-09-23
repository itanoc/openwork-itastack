# Configuring Failover with 3CX

> Source: https://www.3cx.com/docs/failover/

## Introduction

The Failover feature in 3CX allows you to create a standby replica of your PBX. In the event that your PBX fails, your replica PBX becomes active minimizing downtime and data loss. An Enterprise/AI (ENT/AI) license key is required.

### How it works

3CX uses an active - passive approach using built-in configuration replication with a maximum offset of 24h. The active host processes calls and presence information, while the passive host monitors the active host. In case of a failure of the active host (independent of application, OS or hardware failure), the passive host stops its monitoring role and takes over as the active host. The passive host's configuration determines in which state the active host is declared failed in order to initiate the failover switch.

## Pre-requisites

- Two 3CX installations with matching versions
- Enterprise or AI license key
- Both servers must be on the same local network (or reachable via VPN)
- The passive server must have no trunks/phones configured initially

## Step 1: Configuring the Active Server

1. Login to the Management Console of the primary (active) PBX
2. Navigate to **"Backup & Restore"** > **"Failover"**
3. Enable **"Failover"** and select the role **"Active"**
4. Configure the Passive server IP address
5. Set the replication interval (default 5 minutes)
6. Save the configuration

## Step 2: Configuring the Passive Server (#2)

1. Login to the Management Console of the secondary (passive) PBX
2. Navigate to **"Backup & Restore"** > **"Failover"**
3. Enable **"Failover"** and select the role **"Passive"**
4. Configure the Active server IP address
5. Configure failover detection parameters (heartbeat interval, failure count threshold)
6. Optionally configure scripts to run before/after failover
7. Save the configuration

## Important Notes

- The passive server must have the same 3CX version as the active server
- Configuration changes on the active server are replicated to the passive server
- The passive server's local configuration is overwritten when replication occurs
- During failover, IP phones and SBCs must be reconfigured or use split DNS to connect to the new active server
- After a failover, the previously active server should be treated as a new passive server

## See also

- [Linux Failover Scripts](https://www.3cx.com/docs/linux-pbx-failover/)
- [3CX Backup & Restore Commands](https://www.3cx.com/docs/backup-restore-command-line/)
