# 3CX Phone System Deployment — Baseline Task Plan

<!-- Evolution: 2026-03-18 | source: ep-2026-03-18-scope-planner-live-test | skill: scope-planner -->
<!-- Updated from WHCS Phone System Expansion live test to reflect actual ITA deployment practices -->

This baseline covers deploying or migrating a 3CX phone system hosted in the
cloud, including server provisioning, backup restore or fresh configuration,
SIP trunk configuration, phone registration support, and multi-site linking.
Use the lean migration paths when an existing 3CX backup has already been
analyzed. Adapt to the specific client environment.

**Common scenarios:**
- **Greenfield**: New 3CX system for a client with no existing phone system
- **Migration**: Migrate existing on-prem or self-hosted 3CX to cloud-hosted 3CX
- **Lean cloud migration from analyzed backup**: Backup/config already reviewed; collapse discovery and prioritize restore, cutover, phone registration support, validation, monitoring, and acceptance
- **Phased provider port/switch**: Move 3CX hosting first; coordinate SIP provider port/readiness separately; configure/cut over new provider only after the carrier confirms port readiness
- **Expansion**: Add a second (or third) site to an existing 3CX system
- **Hybrid**: Migration + Expansion (e.g., move to cloud AND add a new site)

## Scenario Selection Rules

Use these rules before building the day-by-day plan:

- If a clean 3CX backup has already been received and analyzed, do **not** create a discovery-heavy Day 1. Treat the backup review as pre-work already complete and keep the migration scope lean.
- If the client is changing SIP providers and numbers must port to the new provider first, split provider work into two phases:
  1. **Provider coordination / porting readiness** — collect DID list, LOA/CSR/account/authorized contact details, SMS/caller ID/E911 requirements, and submit or validate the port request.
  2. **Provider cutover** — configure the new trunk/routes only after the new provider confirms port readiness or completion.
- Cloud migration and SIP provider migration do not have to happen in the same cutover window. Prefer cloud migration first, then provider switch after port readiness, unless the technician explicitly chooses a combined cutover.
- Do not assume onsite work is required for cloud migration. If phones can register by remote reprovisioning/reboot and the client has a local POC, schedule ITA remote assist and client/local actions instead.
- When local device actions are required, split responsibility clearly: ITA performs cloud/PBX work remotely; client or named local POC reboots phones, checks physical cabling, and reports device behavior.

## Pre-Work (Remote)

### Licensing & Planning
- Verify 3CX licensing is procured (edition, simultaneous call count)
- Review current license tier vs required (e.g., 16 SC may need upgrade for 60+ extensions)
- Collect phone planning worksheet from client (extensions, users, departments)
- Document all phone numbers (main line, direct DIDs, fax, toll-free)
- Document call routing: auto-attendant menus, ring groups, call queues, voicemail
- Document business hours and after-hours routing
- Document intercom/paging requirements (if used)

### If Migration from Existing 3CX
- **Request a full 3CX backup from client** (critical — this is the primary setup method)
- Review backup to understand current configuration (extensions, DIDs, routes, ring groups)
- Identify SIP provider and trunk credentials from backup
- ⚠️ DEPENDENCY: Do not proceed with LightSail deployment until backup is received and reviewed

### If Migration from Already-Analyzed Backup
- Confirm the backup artifact/review source and date; do not repeat full discovery unless the review is stale or incomplete
- Confirm target cloud hosting method, target FQDN, license handling, restore method, and whether the backup includes license/FQDN
- Confirm whether the existing SIP provider will remain in place for initial cloud cutover or whether provider migration is in scope later
- Confirm client/local POC availability for phone reboot/registration support during the cutover window
- Keep pre-work limited to assumptions, blockers, access, and rollback path; most environment discovery should already be complete

### If SIP Provider Port / Provider Switch Is In Scope
- Document all numbers: main line, DIDs, toll-free, fax, SMS-enabled numbers, and E911 addresses
- Confirm current carrier, target carrier, account number, billing telephone number, service address, authorized signer/contact, CSR availability, and LOA requirements
- Confirm whether SMS, caller ID/CNAM, E911, fax/T.38, and toll-free services must move with the numbers
- ⚠️ DEPENDENCY: Numbers often cannot be configured or tested on the new provider trunk until the provider confirms port readiness/completion
- ⚠️ DEPENDENCY: Incorrect LOA/CSR/account details can reject the port and reset the timeline
- Preserve the existing SIP provider until all numbers and critical call flows are confirmed on the new provider

### If Greenfield / New Setup
- Inventory current phone system if replacing (provider, phone count, extensions, DIDs)
- Collect number porting information (current carrier, account #, authorized contact)
- **⚠️ DEPENDENCY: Number porting takes 5-15 business days — initiate early**
- Confirm SIP trunk provider and credentials

### Network & Infrastructure
- Verify network readiness at each site (QoS, VLAN for voice, bandwidth assessment)
- Verify firewall will support SIP/RTP traffic (ports 5060, 5090, 9000-10999)
- **⚠️ CRITICAL: DISABLE SIP ALG on the firewall — it breaks 3CX**
- Identify PoE switch ports available for desk phones at each site
- If multi-site: verify each site has reliable internet for cloud PBX connectivity
- Order desk phones and confirm shipping timeline
- Confirm ITA AWS account access

### Phone Hardware
- **Standard phone: Yealink T46U** (preferred — acts as Router Phone / built-in SBC in 3CX V20)
- One T46U per site will be designated as the **Router Phone (SBC)**
- Router Phone bundles all SIP traffic over a single TCP port — no separate SBC hardware needed
- If MAC addresses are available, phones can be **pre-configured in 3CX console** before on-site visit
- ⚠️ GOTCHA: Certificate issues can occur when provisioning remote Yealink phones — ensure 3CX uses standard certs the phones support by default

## Lean Scenario — Cloud Migration from Already-Analyzed Backup (Remote)

Use this scenario when the backup/config has already been reviewed and the goal is to move 3CX hosting to cloud with minimal rediscovery. Typical shape: **Day 1 — 6.5hrs max**.

### Day 1 — Cloud Provision, Restore, Cutover & Validation
- Confirm final target cloud/FQDN/license assumptions, access, maintenance window, client/local POC availability, and rollback trigger
- Create/provision the target cloud 3CX instance using the approved hosting method
- Restore the already-analyzed backup and verify expected restored objects:
  - extensions/users
  - groups/queues/ring groups
  - IVR/auto-attendant
  - business hours/holiday schedules
  - inbound/outbound rules
  - existing SIP trunk settings if provider remains unchanged for this phase
- Validate DNS/FQDN, certificate, firewall/security settings, and admin access
- Perform cloud cutover during the approved window; mark downtime only for call-flow/device registration impact
- Assist client/local POC remotely with phone registrations/reboots and spot-check devices
- Test key call flows: inbound main number, representative DIDs, outbound, internal extension dialing, voicemail/email, queue/ring group, paging/intercom if used, and emergency/SMS/fax where applicable
- Configure or verify backup schedule, basic monitoring/alerting, and acceptance notes
- Document final cloud state and unresolved follow-ups

### Lean cloud migration task-hour guidance
- Assumption/access/window confirmation: 0.5 hr
- Cloud instance provision/setup: 1.0 hr
- Backup restore and restored-config validation: 1.5 hr
- DNS/FQDN/cert/security/cutover prep: 0.75 hr
- Cutover execution and phone registration/reboot assist: 1.25 hr
- Call-flow/device validation: 1.0 hr
- Backup/monitoring/documentation/acceptance: 0.5 hr
- Total target: 6.5 hrs max; increase only for stale backup review, many sites/devices, missing access, or combined provider cutover

### Scope-plan field guidance for lean migrations
- **Location**: use `remote` for ITA PBX/cloud work, `client` for local phone reboot/physical checks by the client POC, and `vendor` for SIP provider coordination
- **Downtime**: mark `Yes` for the cloud cutover and provider cutover windows when inbound/outbound calling or phone registration may be impacted; most prep, restore validation, and documentation tasks are `No`
- **After-hours**: mark `Yes` only when the approved cutover/testing window is outside business hours
- **Client dependencies**: client POC availability, phone reboot/local checks, acceptance testing, and timely approval of maintenance window/rollback criteria
- **Vendor dependencies**: target cloud/license access if externally owned; SIP provider port readiness/FOC, trunk credentials, E911/SMS/fax provisioning, and support availability during provider cutover
- **Parts**: usually none for cloud-only migrations unless phones, router phones/SBCs, PoE switches, or UPS hardware are being added
- **Comments**: note that backup analysis was already completed, old provider remains active until provider switch validation passes, and onsite work is intentionally excluded when a local POC handles device actions

## Phased Scenario — Cloud First, Provider Port/Switch Second (Remote)

Use this scenario when the cloud migration can proceed before a SIP provider change, but the new provider requires number porting/readiness before trunk cutover. Do not combine these phases unless the technician explicitly approves the added risk.

### Day 1 — Cloud Migration from Existing Backup (6.5hrs max)
- Follow the lean cloud migration day above
- Keep the existing SIP provider active if provider port/readiness is not complete
- Document provider-switch prerequisites as follow-up dependencies, not blockers for cloud hosting migration unless current trunk credentials will not work in cloud

### Day 2 — Provider Port Coordination / Readiness (2.5hrs max)
- Confirm final DID inventory and which services move: voice, SMS, fax, toll-free, caller ID/CNAM, E911
- Collect or validate LOA, CSR, current carrier account details, authorized signer/contact, service address, BTN, and losing-carrier requirements
- Submit the port request or validate an already-submitted request with the target provider
- Confirm target provider provisioning prerequisites, expected FOC/port date, test-number options, and cutover support path
- Communicate waiting period, readiness blockers, and who owns each open item
- Do **not** configure final production trunk cutover tasks until provider confirms port readiness/completion

### Day 3 — New SIP Provider Trunk Cutover (4hrs max)
- ⚠️ DEPENDENCY: Start only after target provider confirms port readiness/completion or scheduled FOC window
- Configure target provider trunk credentials, inbound rules, outbound rules, caller ID, emergency routing, and SMS/fax settings if applicable
- Perform provider cutover in the approved window
- Validate inbound main number, sample DIDs, outbound caller ID, emergency/E911 policy, SMS/fax if in scope, and failover/rollback behavior
- Confirm old provider remains active until all ported numbers and critical call flows pass validation
- Document final provider/trunk/routing state and update acceptance notes

## Standard Scenario — AWS LightSail Deployment & 3CX Setup (Remote)

### Server Provisioning
- Deploy 3CX instance on **AWS LightSail via Marketplace** (~30 min process)
  - LightSail is the standard ITA deployment method (not EC2)
  - Select appropriate instance size based on extension count
  - Assign static IP to instance

### If Migration — Backup Restore
- Restore 3CX backup on new LightSail instance during setup wizard
  - The installer asks for the backup file as part of setup — feed it the file
  - Recommended: backup WITHOUT license and FQDN, use PBX Express to install
- Verify restored configuration — extensions, call routes, ring groups, auto-attendant
- Configure SSL certificate and verify FQDN resolves to LightSail IP
- ⚠️ DEPENDENCY: Identify SIP provider from backup — confirm trunk credentials work on cloud instance
- Test inbound/outbound calls on new cloud PBX using a test extension

### If Greenfield — Fresh Install
- Complete 3CX initial setup wizard:
  - Set admin credentials
  - Configure FQDN and SSL certificate (Letâs Encrypt)
  - Select SIP port and tunnel settings
  - Configure extension digit length
- Apply 3CX license key
- Configure SIP trunk with provider:
  - Add trunk credentials
  - Configure inbound/outbound rules
  - Set codec priority (G.711, G.729)
  - Test inbound and outbound calls with temporary number

### Common Setup Tasks
- Configure backup schedule (daily, to S3 or local)
- Set up PBX Monitor integration for monitoring
- Designate one Yealink T46U at the primary site as the **Router Phone (SBC)** — configure in 3CX console

## Day 2 — PBX Configuration & Cutover (Remote)

### If Migration — DNS Cutover
- **Best practice sequence (from 3CX community):**
  1. Set up Router Phone (SBC) on primary site first, pointed at on-prem PBX
  2. Change all extensions to use the Router Phone/SBC in 3CX console
  3. Reprovision all phones from 3CX console
  4. Update DNS to point FQDN to LightSail IP
  5. FQDN auto-updates to new WAN IP (~6 min propagation)
  6. Phones behind the Router Phone donât need individual reconfiguration
- Coordinate with client: have client POC reboot phones in sequence (5-15 min per phone)
  - Only the phone being rebooted is affected — no bulk outage
- Verify each phone registers to cloud PBX — test inbound/outbound on 3-5 extensions
- Verify intercom/paging functionality works through cloud PBX
- Shut down old on-prem 3CX VM — monitor for any calls still routing to old system
- Verify all SIP trunk traffic flowing through cloud PBX
- Use Cloudflare/Google DNS on the Router Phone for fast FQDN resolution

### If Greenfield — Extension & Routing Setup
- Create all extensions per phone planning worksheet
- Set extension passwords and voicemail PINs
- Configure ring groups (e.g., Sales, Support, Front Desk)
- Configure call queues (if needed)
- Build auto-attendant / IVR menus
- Configure business hours and holiday schedule
- Set up after-hours routing (voicemail, forwarding)
- Configure inbound routing rules (DID to extension/group mapping)
- Configure outbound calling rules (dial plan, emergency 911)
- **⚠️ DEPENDENCY: E911 registration must be completed before go-live**
- Set up voicemail-to-email for all users
- Configure call recording (if required)
- Configure music on hold
- Test all routing scenarios internally (extension to extension)

## Day 3 — Site 2 Configuration (Remote) [Multi-Site Only]

*Skip this day if single-site deployment.*

- ⚠️ DEPENDENCY: Site 2 network assessment — confirm internet connection, PoE switch availability
- Create Site 2 extensions in 3CX console (per phone planning worksheet from client)
- Configure ring groups, call routing, and shared DIDs for Site 2
- Configure auto-attendant / IVR updates to include Site 2 options (if applicable)
- Set up extension-to-extension dialing between Site 1 and Site 2
- Designate one Yealink T46U as Site 2 Router Phone (SBC) — configure in 3CX console
- Pre-configure all Site 2 phones in 3CX console using MAC addresses (if available from client)
- ⚠️ NOTE: If MAC list not available, phones will need manual provisioning on-site (add 1-2 hours to Day 4)

## Day 4 — Phone Provisioning & On-Site Installation (Onsite)

- Travel time bi-directional
- ⚠️ DEPENDENCY: Verify PoE switch is installed and internet is active at site
- Connect and power on **Router Phone (SBC) first** — verify registration to cloud PBX
- Unbox and connect remaining phones to PoE switch ports
- Provision each phone:
  - If MAC pre-configured: auto-provision (plug in, phone pulls config automatically)
  - If not pre-configured: manual provision (point phone to 3CX provisioning URL, assign extension)
  - Verify registration and dial tone on each phone
  - Label each phone with extension number
- Install 3CX apps on mobile devices (key users)
- Install 3CX web client shortcut on workstations
- Coordinate with teachers/staff — deliver phones to desks, explain basic operation
- Test calls from each provisioned phone:
  - Internal call (extension to extension, cross-site if multi-site)
  - Outbound call (to cell phone)
  - Inbound call (from cell phone to DID)
- Test ring groups and auto-attendant from external number
- Test intercom/paging at the site
- Final/EOD onsite walkthrough with client POC

## Day 5 — Number Porting, Validation & Documentation (Remote)

### If Number Porting Required
- **⚠️ DEPENDENCY: Port completion date must be confirmed with carrier**
- For phased provider switches, schedule a separate provider coordination/readiness day before this cutover day; do not treat carrier paperwork and trunk cutover as the same task
- If the target provider cannot stage numbers before port readiness, keep the old provider active and postpone production trunk/routing changes until the FOC/port window
- Monitor porting status with carrier
- Verify numbers appear on SIP trunk after port completes
- Update inbound routing rules for ported numbers
- Test all ported DIDs (call each number, verify correct routing)
- Test fax line (if applicable — may need T.38 or fax-to-email)
- Test toll-free numbers routing
- Test emergency dialing (911 — verify E911 address registration)

### Post-Go-Live Validation
- Verify all phones at all sites registered and functional (full audit)
- Test cross-site calling scenarios (Site 1 → Site 2, external → shared DID routing)
- Verify intercom/paging works at all sites
- Monitor call quality metrics (jitter, latency, packet loss)
- Review CDR for failed calls or routing errors
- Verify voicemail-to-email working for all users
- Address any user-reported issues
- Fine-tune auto-attendant based on client feedback
- ⚠️ DEPENDENCY: 3CX license upgrade verified — confirm SC count covers all sites
- Configure 3CX backup schedule (daily, to S3 or local)
- Provide client admin with updated documentation — cloud console access, basic management
- Confirm old phone system is disconnected (after porting confirmed)
- Verify PBX Monitor alerts are working

## At Completion
- Update ITGlue documentation:
  - 3CX server details (AWS LightSail instance, IP, FQDN)
  - Admin credentials
  - SIP trunk provider and credentials
  - Extension list with DID mappings
  - Ring group and queue configuration
  - Auto-attendant menu tree
  - Network configuration (VLAN, QoS, Router Phone/SBC designations)
  - Phone hardware inventory (model, MAC, extension, location)
  - Multi-site topology (which Router Phone serves which site)
- Deprecate old phone system entries in ITGlue
- Notify Project Coordinator of completion status

## Common Dependencies & Gotchas

### Critical
- **SIP ALG**: DISABLE SIP ALG on the firewall — it breaks 3CX. This causes one-way audio, dropped calls, registration failures.
- **Number porting**: 5-15 business days; incorrect LOA causes rejection and restarts the process
- **Provider sequencing**: If changing SIP providers, numbers may need to port to the new provider before production trunk configuration/cutover is possible; split coordination/readiness from cutover
- **E911**: Must be registered BEFORE go-live — legal requirement
- **Old carrier**: Donât cancel old carrier account until ALL numbers are confirmed ported
- **3CX backup for migration**: Without the backup, the entire timeline is blocked

### Network
- **NAT traversal**: If phones are behind NAT, 3CX tunnel or STUN must be configured
- **Codec mismatch**: Ensure SIP trunk and phones agree on codec (G.711 preferred for quality)
- **QoS**: Without QoS, voice quality degrades under network load
- **Bandwidth**: Each concurrent call needs ~100kbps; verify bandwidth supports peak call volume

### Phone Hardware
- **Router Phone designation**: One Yealink T46U per site acts as Router Phone (built-in SBC) — must be configured first
- **Certificate issues**: Remote Yealink provisioning can fail on custom certs — use standard certs
- **MAC pre-configuration**: Getting MAC addresses from client before on-site visit saves 1-2 hours
- **Headsets**: Some USB headsets need firmware updates for 3CX compatibility

### Operational
- **Fax**: T.38 fax over SIP is unreliable; recommend fax-to-email service instead
- **Power outage**: Phones on PoE switch need UPS backup; AWS LightSail server is unaffected
- **Time zones**: 3CX server time zone affects business hours routing — set correctly
- **DNS propagation**: FQDN updates take ~6 min; use Cloudflare/Google DNS on Router Phone for fast resolution
- **Intercom/paging**: Verify multicast paging works through cloud PBX — may need per-site configuration

### Multi-Site Specific
- All sites connect over internet to the single AWS LightSail PBX
- Each site needs its own Router Phone (SBC) — Yealink T46U
- Extension-to-extension dialing works across sites automatically once configured
- Shared DIDs can route to any siteâs extensions
- If a siteâs internet goes down, only that siteâs phones are affected
