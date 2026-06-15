# Network Refresh (Firewall + Switch + APs) — Baseline Task Plan

This baseline covers replacing firewall, managed switches, and wireless access points.
Adapt to the specific equipment and client environment.

## Pre-Work (Remote)
- Review current network topology in ITGlue (VLANs, subnets, firewall rules)
- Export current firewall configuration as backup
- Document all port mappings on existing switches (which device on which port)
- Document current VLAN configuration and trunk ports
- Document all static routes and NAT rules on firewall
- Identify all site-to-site VPNs and remote access VPNs
- Verify new hardware firmware is current; download updates if needed
- Confirm ISP circuit details (static IP, gateway, handoff type)
- Identify LOB applications requiring specific firewall rules or port forwards
- Verify wireless survey data / AP placement plan
- Confirm client POC and downtime approval
- Pre-stage firewall configuration offline if possible

## Day 1 — Firewall Replacement (Onsite, Downtime Required)
- **⚠️ DEPENDENCY: Client-approved downtime window — ALL network services down during swap**
- Travel time bi-directional
- Notify client of maintenance window start
- Photograph existing rack and cable layout
- Disconnect old firewall
- Rack and cable new firewall
- Apply pre-staged configuration (WAN, LAN, VLANs, NAT, firewall rules)
- Verify WAN connectivity (ISP handoff, public IP, gateway)
- Verify LAN connectivity from a test device
- Configure site-to-site VPNs and verify tunnel establishment
- Configure remote access VPN if applicable
- Test critical port forwards and NAT rules
- Test DNS resolution through new firewall
- **⚠️ NOTE: DNS changes may require 15-30 min propagation on client devices**
- Enable security services (IDS/IPS, content filtering, geo-blocking)
- Verify DHCP is serving addresses correctly
- Final/EOD onsite walkthrough with client POC

## Day 2 — Switch Replacement (Onsite, Downtime Per Switch)
- **⚠️ DEPENDENCY: Rolling downtime — devices on each switch lose connectivity during swap**
- Travel time bi-directional
- Replace switches one at a time to minimize downtime:
  - Document port connections on current switch
  - Disconnect old switch
  - Rack and cable new switch
  - Configure VLANs, trunk ports, PoE settings
  - Reconnect all devices to matching ports
  - Verify connectivity for all connected devices
  - Repeat for each switch
- Configure switch management IP and SNMP
- Verify inter-VLAN routing through firewall
- Verify PoE power delivery to APs, cameras, phones
- Label all switch ports
- Final/EOD onsite walkthrough with client POC

## Day 3 — Wireless AP Replacement (Onsite)
- Travel time bi-directional
- Remove old access points
- Mount new access points in planned locations
- Cable APs to PoE switch ports
- Verify APs are powered and discovered by controller/cloud management
- Configure SSIDs (corporate VLAN, guest VLAN)
- Configure wireless security (WPA3/WPA2-Enterprise or PSK)
- Set transmit power and channels (or enable auto-optimization)
- Test wireless coverage in all areas (walk test)
- Test client device connectivity on each SSID
- Test roaming between APs
- Verify guest network isolation
- Final/EOD onsite walkthrough with client POC

## Day 4 — Validation & Documentation (Remote)
- Verify all VPN tunnels stable after 24hrs
- Verify all DHCP leases renewed correctly
- Verify monitoring agents see all new network devices
- Run speed tests from multiple locations
- Verify backup of new firewall configuration
- Enable configuration backup scheduling on firewall
- Configure SNMP/syslog to monitoring platform
- Senior tech review of firewall rules and network config

## At Completion
- Update ITGlue documentation:
  - Network diagram (topology, IP scheme)
  - Firewall configuration page
  - Switch port maps
  - Wireless configuration (SSIDs, passwords, AP locations)
  - All new device credentials
- Deprecate old equipment entries in ITGlue
- Update rack photos
- Notify Project Coordinator of completion status

## Common Dependencies & Gotchas
- **ISP coordination**: May need ISP onsite or on-call for circuit handoff changes
- **VPN peers**: Remote site firewalls may need config changes to match new VPN settings
- **PoE budget**: Verify new switches provide enough PoE wattage for all APs + phones + cameras
- **VLAN pruning**: Don't forget to allow required VLANs on trunk ports
- **Printer/IoT static IPs**: Devices with static IPs may need gateway/DNS updated
- **Country blocking**: Review geo-blocking rules — may block legitimate vendor services
- **Firmware updates**: Update all new devices to latest stable firmware before deploying
- **Cable management**: Budget time for proper cable management and labeling
- **Wireless interference**: Neighboring APs or building materials affect coverage
