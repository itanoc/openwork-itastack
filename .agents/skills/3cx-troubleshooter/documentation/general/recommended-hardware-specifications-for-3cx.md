# Recommended Hardware Specifications for 3CX

> Source: https://www.3cx.com/docs/recommended-hardware-specifications-for-3cx/

## Introduction

Refer to these suggested 3CX Phone System usage scenarios based on the extensions used, to assist you to size the minimum required hardware to run 3CX.

A user (extension) is typically defined to use the 3CX Web Client/3CX Windows Softphone App and a 3CX Mobile Apps for communication while being part of one Department and one queue. In addition to this, the user may use an IP phone connected to their extension. These suggested hardware specifications are provided as a baseline and may change based on your business needs and usage.

## General Requirements

**CPU:**
- Using Call Queues and group calls taxes the CPU more than 1-on-1 calls, depending on the number of the call end-points.
- Refer to the CPU hierarchy to assist you in selecting a suitable processor, based on the suggested processor family. AMD CPUs are supported based on their equivalence to the suggested Intel CPUs.

**Memory:**
- Allocating users in more extension groups or queues increases the need for additional RAM.

**Network:**
- 3CX requires at least a 1Gb LAN network connectivity, depending on the number of simultaneous calls and usage of other network applications.
- 10Gb is required for 1000+ extensions.
- Link Aggregation (LAG, LACP) can be used on HyperVisor platforms to further expand available throughput but is not available for Bare Metal machines.
- To ensure voice quality, especially in busy or mixed-use network environments, it is recommended that Quality of Service (QoS) be implemented on network equipment to prioritize VoIP traffic over less time-sensitive data.

**Storage:**
- Allocate at least 40GB for the 3CX base system installation.
- Add extra drive/partition/space for backup, voicemail, recordings or logging.
- Recording and voicemail: 1 minute of recorded audio consumes ~1MB.
- Logging: Verbose logs on a busy system can consume up to ~1GB per day or per 2500 calls.
- Offload (archive) unneeded recordings / voicemails / faxes / chat attachments / backups to cold storage regularly to keep optimal free space available to your PBX.
- Regularly offload old call history (CDR) to a remote database or BigQuery to maintain optimal 3CX database size and performance.

| Size | Extensions (up to) |
|------|-------------------|
| Small | 10 |
| Medium | 50 |
| Large | 250 |
| Enterprise | 1000 |

*For usage cases of more than 1000 extensions please contact us to assist you in planning.

## x86-Based

x86-based CPU installs require compatibility to 64-bit architecture and can be used as "Bare Metal" or "Virtual Machine" deployments. 3CX verified the usage for the following HyperVisors:

- VMware vSphere Hypervisor (ESXi) 6.5u1 and above, with VMWare tools package installed
- Microsoft Hyper-V Server (6.2) and above capable of running Debian 12, Windows 11, or the latest Windows Server editions.
- Citrix XenServer 7.0 and above
- KVM 2.8 and up

*Additional configuration may be needed for the virtual machine, depending on the HyperVisor used.

### 3CX PBX

**Small**

| | Linux Debian-based | Windows-based |
|---|---|---|
| CPU Family | Intel Core i3 (13th Gen+) or equivalent | |
| vCPUs | 2 | 2 |
| Memory | 4 | 4 |
| Storage | 80 GB SSD based storage | |

**Medium**

| | Linux Debian-based | Windows-based |
|---|---|---|
| CPU Family | Intel Core i5 (13th Gen+) or equivalent | |
| vCPUs | 4 | 6 |
| Memory | 4 | 6 |
| Storage | 160 GB SSD based storage | |

**Large**

| | Linux Debian-based | Windows-based |
|---|---|---|
| CPU Family | Intel Core i7 (13th Gen+) or equivalent | |
| vCPUs | 6 | 8 |
| Memory | 8 | 10 |
| Storage | 320 GB SSD based storage | |

**Enterprise**

| | Linux Debian-based | Windows-based |
|---|---|---|
| CPU Family | Intel Xeon Silver/Gold (4th Gen+) or equivalent | |
| vCPUs | 8 | 10 |
| Memory | 16 | 18 |
| Storage | 640 GB SSD based storage | |

**Enterprise+**

| | Linux Debian-based | Windows-based |
|---|---|---|
| CPU Family | Intel Xeon Gold (4th Gen+) or equivalent | |
| vCPUs | 8+ | 10+ |
| Memory | 32+ | 34+ |
| Storage | 640+ GB SSD based storage | |

### 3CX SBC

If the 3CX PBX is located in the cloud and IP phone should be routed to the instance, these SBC specifications are recommended:

| Devices | Up to 50 (10 BLFs per device) | Up to 100 (10 BLFs per device) |
|---|---|---|
| Platform | Linux Debian-based / Windows-based | Linux Debian-based / Windows-based |
| CPU Family | Intel Core i3 (13th Gen+) or equivalent | Intel Core i7 (13th Gen+) or equivalent |
| vCPUs | 2 / 4 | 4 / 6 |
| Memory | 2 / 4 | 2 / 4 |
| Storage | 30 GB available storage space | |

### Cloud Provider

Suggested virtual machine / instance specifications for Google Cloud Platform (GCP), MS Azure and Amazon Web Services (AWS) / Lightsail, based on the use cases outlined in the bare metal configurations.

| | Google (GCP) | Microsoft (Azure) | Amazon EC2 | Amazon Lightsail |
|---|---|---|---|---|
| Small (up to 10 ext) | e2-medium | Standard_B2ls_v2 | t3.medium | medium_3_x |
| Medium (up to 50 ext) | e2-medium | Standard_B2ls_v2 | t3.medium | medium_3_x |
| Large (up to 250 ext) | e2-standard-4 | Standard_B4as_v2 | t3.xlarge | xlarge_3_x |

Adjust storage size and swap space accordingly, based on your needs and usage.

*Last Updated: 23 April 2026*
