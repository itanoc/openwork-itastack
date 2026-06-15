# Microsoft 365 Migration — Baseline Task Plan

This baseline covers migrating an organization from on-premises or competing
platform to Microsoft 365 (Exchange Online, SharePoint, OneDrive, Teams).
Adapt to the specific source environment and tenant configuration.

## Pre-Work (Remote)
- Verify M365 licensing is procured and assigned (E3, Business Premium, etc.)
- Inventory current mail environment (on-prem Exchange, Google Workspace, IMAP, POP)
- Document all mailboxes: size, shared mailboxes, distribution lists, aliases
- Document all email domains and DNS hosting provider
- Verify domain ownership in M365 admin center
- Inventory current file storage (file server shares, Google Drive, Dropbox)
- Map file share permissions to SharePoint/OneDrive structure
- Identify LOB applications that send email (copiers, ERP, CRM)
- Identify third-party integrations (email signatures, archiving, spam filter)
- Confirm client admin credentials for source environment
- Create migration project plan with batch schedule
- Set up migration tool (BitTitan, SharePoint Migration Tool, native cutover)
- Confirm client POC for user communication and testing

## Day 1 — Tenant Configuration & Pre-Migration (Remote)
- Configure M365 tenant security defaults (MFA, conditional access policies)
- Create user accounts (or sync via Azure AD Connect if hybrid)
- **⚠️ DEPENDENCY: If using Azure AD Connect, server must be domain-joined**
- Assign licenses to all users
- Add and verify all email domains in M365
- Configure spam/phishing protection (Defender for Office 365)
- Configure email signatures (if using third-party tool)
- Set up shared mailboxes and distribution groups
- Configure mail flow connectors if needed (hybrid or relay)
- Pre-stage mailbox migrations (BitTitan agent or native)
- Run first sync/pre-stage migration (copies existing mail without cutover)
- **⚠️ NOTE: Pre-staging large mailboxes can take 24-72hrs depending on size**

## Day 2 — File Migration & OneDrive/SharePoint Setup (Remote)
- Create SharePoint sites matching file share structure
- Configure permissions on SharePoint document libraries
- Begin file migration (SharePoint Migration Tool or third-party)
- **⚠️ NOTE: Large file migrations can take days — start early and monitor**
- Set up OneDrive for individual users
- Configure Known Folder Move (redirect Desktop, Documents, Pictures)
- Test file access from a pilot user workstation
- Verify file permissions transferred correctly
- Set up Teams channels matching department structure

## Day 3 — DNS Cutover & Mail Flow Switch (Scheduled, Critical)
- **⚠️ DEPENDENCY: Schedule during low-email period; client must approve timing**
- Run final delta sync on all mailboxes
- Update MX records to point to M365
- Update SPF record for M365
- Configure DKIM signing for all domains
- Configure DMARC policy (start with p=none for monitoring)
- Update autodiscover DNS records
- **⚠️ NOTE: MX record propagation takes 15min-4hrs; some mail may still route to old server during transition**
- Monitor mail flow — verify inbound and outbound working
- Test send/receive from multiple users
- Reconfigure LOB application SMTP relay to M365 (SMTP relay connector or direct send)
- **⚠️ NOTE: LOB apps using SMTP AUTH may need app passwords if MFA is enabled**
- Update copier/scanner email settings
- Decommission old mail server relay (or keep as backup for 48hrs)

## Day 4 — User Rollout & Endpoint Configuration (Remote/Onsite)
- Deploy Outlook profiles on all workstations
- Configure Outlook on mobile devices (Outlook app or native)
- Train users on Outlook web access (OWA)
- Configure OneDrive sync client on all workstations
- Map SharePoint document libraries in File Explorer
- Migrate user email signatures
- Verify calendar data migrated correctly
- Verify contacts migrated correctly
- Train users on Teams basics (if new to Teams)
- Provide quick reference guide for common tasks

## Day 5 — Post-Migration Validation (Remote)
- Verify all mailboxes fully synced (no missing emails)
- Verify all shared mailboxes accessible
- Verify distribution lists working
- Verify email forwarding rules migrated
- Verify mailbox rules and auto-replies migrated
- Test external email delivery (send from Gmail/Yahoo to verify)
- Verify spam filter is catching spam but not false-positiving
- Confirm backup solution covers M365 data (Veeam, Datto, etc.)
- Verify MFA is enabled for all users
- Run security assessment in M365 Secure Score

## At Completion
- Update ITGlue documentation:
  - M365 tenant details
  - DNS records (MX, SPF, DKIM, DMARC)
  - Admin credentials
  - License inventory
  - SharePoint site structure
  - Email domains and aliases
- Deprecate old mail server entries in ITGlue
- Schedule old mail server decommission (after 30-day monitoring period)
- Notify Project Coordinator of completion status

## Common Dependencies & Gotchas
- **MX propagation**: Allow up to 4hrs; during transition, mail may arrive at old or new server
- **SPF/DKIM/DMARC**: Misconfigured SPF causes outbound mail to be marked as spam
- **Large mailboxes**: 50GB+ mailboxes can take 24-72hrs to migrate; pre-stage early
- **Shared mailbox limits**: M365 shared mailboxes have 50GB limit and cannot have licenses
- **App passwords**: Legacy apps that don't support modern auth need app passwords
- **LOB SMTP relay**: Apps sending email must be reconfigured; test each one individually
- **Calendar permissions**: Delegate/shared calendar permissions may not migrate — verify
- **Public folders**: Must be migrated separately and have size limitations in M365
- **Retention policies**: Verify legal hold / retention requirements before decommissioning old server
- **Conditional Access**: May block user access if not configured for their devices/locations
- **OneDrive sync conflicts**: Known Folder Move can create duplicates if not properly configured
