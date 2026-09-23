# ITGlue Type Mapping for Scope Interviews

Use this reference to focus interview questions on the ITGlue data that actually affects project scope. Start broad, then narrow to items that impact sequencing, risk, downtime, or dependencies.

## 1) Core Configuration Types to Pull First

| Category | Common ITGlue Entities | Why It Matters for Scoping |
|---|---|---|
| Servers & compute | Server, Managed Server, VM Host Server, Virtual Machine, NAS, SAN | Migration order, outage windows, backup/restore planning, replication dependencies |
| Network edge & routing | Firewall/Router, Router, Modem, SD-WAN appliance | Cutover sequence, ISP/vendor coordination, remote access continuity |
| LAN & wireless | Switch, Wireless Access Point, Wifi, Network Device | Port/VLAN changes, PoE constraints, on-site time estimates |
| Voice & communications | VoIP, 3CX SBC, Phone systems | Porting lead times, after-hours requirements, user impact planning |
| Endpoint context | Workstation, Managed Workstation, Laptop, Desktop | User migration waves, communication/cat-herding effort |
| Resilience & power | Backup, UPS | Rollback confidence, maintenance-window safety, shutdown constraints |

## 2) Flexible Asset Types to Prioritize

| Category | Flexible Assets | Interview Prompts |
|---|---|---|
| Identity & directory | Active Directory, AD Security Groups, Remote Access, VPN | "Any auth/domain dependencies? MFA/VPN changes in scope?" |
| Messaging & cloud | Email, SMTP Relay, Microsoft Licenses, Cloud | "Mailbox/licensing prerequisites? Cutover timing constraints?" |
| Network design | LAN, Internet/WAN, Wireless, Security | "Any VLAN, subnet, ACL, or ISP constraints to schedule around?" |
| Operations | Backups, Site Summary, Vendors, Services, Business Hours/After Hours | "What support windows and vendor handoffs affect task order?" |
| Voice-specific | Voice/PBX, 3CX Extensions, 3CX DIDs | "Porting timeline, DID mapping, and call-flow testing requirements?" |

## 3) Relevance Filter (Quick Pass)

Keep items that change any of these:
- **Task order** (must happen before/after another step)
- **Duration** (adds hours/days)
- **Risk** (rollback difficulty, outage severity)
- **Ownership** (client/vendor/ITA responsibility)
- **Timing window** (after-hours, blackout, maintenance)

De-prioritize items that are purely informational and do not influence execution.

## 4) Usage Notes During Interviews

1. Build a short environment summary before deep questioning.
2. Confirm what is **current vs stale** (ITGlue can lag reality).
3. Ask for explicit exceptions: "What is missing here that still affects this project?"
4. Convert findings into planning artifacts:
   - dependency markers (⚠️)
   - downtime flags
   - after-hours flags
   - client/vendor dependency notes
5. If critical data is missing, capture fallback facts directly from the technician before drafting.

## 5) Practical Mapping by Project Type

- **Server migration:** prioritize Servers/VMs/Backup/AD/Virtualization.
- **Network refresh:** prioritize Firewalls/Routers/Switches/Wireless/LAN/WAN.
- **M365 migration:** prioritize Email/Cloud/Licensing/Identity assets.
- **3CX/voice:** prioritize Voice assets, DIDs/extensions, WAN/vendor details.

Use this mapping to guide what you ask next—not as a rigid checklist.
