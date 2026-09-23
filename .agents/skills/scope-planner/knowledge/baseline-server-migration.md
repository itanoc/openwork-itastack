# Server Migration / Replacement — Baseline Task Plan

This baseline covers the common tasks for server replacement projects including
hypervisor deployment, domain controller promotion, VM migration, and decommission
of old hardware. Adapt to the specific project.

## Pre-Work (Remote)
- Review current server inventory in ITGlue (roles, VMs, services)
- Verify backup status of all VMs and data on existing server
- Confirm new server hardware specs meet requirements
- Verify Windows Server licensing is procured
- Confirm iDRAC/IPMI credentials and network access
- Identify all static IP assignments on current server/VMs
- Document current DNS, DHCP, and AD configuration
- Identify vendor dependencies (ISP, LOB app vendors, backup vendor)
- Confirm client point of contact and downtime approval process

## Day 1 — Hardware Setup & OS Install (Onsite or Remote)
- Travel time bi-directional (if onsite)
- Rack and cable new server hardware
- Connect to UPS and verify power redundancy
- Configure iDRAC/IPMI (static IP, alerting to help@itassurance.com)
- Install Hyper-V / Windows Server on host
- Configure host networking (management NIC, VM switch)
- Configure host storage (RAID verification, volumes)
- Install and configure APC PowerChute / UPS shutdown software
- Join host to domain (if applicable)
- Final/EOD walkthrough with client POC (if onsite)

## Day 2 — Domain Controller & Core Services (Remote)
- Create new DC virtual machine
- Install Windows Server on DC VM, assign static IP
- Promote to domain controller (AD DS role)
- Verify DNS records and health on new DC
- Update DHCP option 006 to point to new DC as primary DNS
- Update DNS settings on all servers/VMs with static IPs
- Update DNS on old DC to use new DC as preferred
- Verify AD replication (repadmin /replsummary)
- Transfer all FSMO roles from old DC to new DC
- Verify SYSVOL/DFSR replication health
- Run dcdiag on both domain controllers

## Day 3 — VM Migration (Scheduled Downtime)
- **⚠️ DEPENDENCY: Client-approved downtime window required**
- Notify client of maintenance window start
- Test migration method feasibility (live migration vs cold/export)
- If live migration fails: perform cold migration (Veeam export/import or Hyper-V export)
- **⚠️ NOTE: Cold migration of large VMs can take 2-4+ hours depending on disk size**
- Export and import each VM to new host
- Start each VM on new host and verify boot
- Verify all services are running on migrated VMs
- Test file shares, LOB applications, print services
- Notify client of maintenance window completion
- Configure static MAC addresses on all VMs (prevents NIC conflicts)

## Day 4 — Post-Migration Validation & Cleanup (Remote)
- Configure Veeam/backup software on new host
- Add new host and VMs to backup jobs
- Verify first backup completes successfully
- Configure static IPs and DNS on new host
- Activate Windows licensing on all VMs/host
- Verify monitoring agents (VSA/RMM) are reporting for new host
- Senior tech review of all configurations
- Run full dcdiag and health checks

## At Completion
- Update ITGlue documentation:
  - Network diagram
  - Server configuration pages
  - IP address assignments
  - Password entries for new systems
- Deprecate old server entries in ITGlue
- Schedule old server decommission (separate downtime if still racked)
- Update rack photos (onsite visit if needed)
- Create hardware spec sheet for client records
- Notify Project Coordinator of completion status

## Common Dependencies & Gotchas
- **DNS propagation**: Allow 24-48hrs after DNS changes before relying on them
- **Live migration**: May fail between significantly different OS versions; test first
- **UPS software licensing**: Verify PowerChute Network Shutdown license availability
- **Backup verification**: Don't close project until first successful backup completes
- **Static MACs**: Must be set to prevent DHCP reservation issues after migration
- **LOB applications**: Some may need vendor involvement for server name/IP changes
- **Client file shares**: Mapped drives may reference old server name — test from workstation
- **Antivirus/EDR**: Verify endpoint protection is deployed on new VMs
