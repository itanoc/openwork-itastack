# The 3CX VoIP Provider Checker

> Source: https://www.3cx.com/docs/voip-provider-checker/

## Overview

This document will guide you through the steps required to get your SIP Trunk working reliably. You will learn to:

- Create a first-step Generic SIP Trunk configuration
- Configure basic settings and authentication parameters for your SIP trunk
- Run the VoIP Provider Checker tool
- Interpret results and adjust for detected issues
- Extract results and create a custom SIP Trunk template
- Validate your work using the newly-created custom SIP Trunk template

## Basic Configuration for SIP Trunks

### Prerequisites

Before you can run your tests, make sure that you:
- Successfully configure a phone client on your 3CX system
- Can make an inbound call to your Main Trunk Number from an external device
- Can make an outbound call from your Main Trunk Number to an external device

### Configure your Test Trunk

1. Go to Admin Console > "Admin → Voice & Chat"
2. Click the **Add Trunk** button
3. In the dialog, select the Country and Provider (Generic VoIP Provider for registration-based, or Generic SIP Trunk for IP-based)
4. In the Add Trunk page:
   - Provide a **Name** for your SIP Trunk
   - Set the **Default route** to your test extension
   - Enable **Create an outbound rule**
   - Set **Main Trunk Number**, **Authentication ID**, **Authentication Password**, and **Registrar/Server**
   - Configure optional 3-way authentication or Outbound Proxy if needed
5. Click **Save**

**Authentication Types:**
- "Registration/Account based" - default, username+password
- "Do not require - IP based" - trunk bound to PBX public IP
- Some providers use both: authentication + IP binding

**DNS and Auto-Discovery:**
- Classic: A records (IPv4) or AAAA records (IPv6)
- Modern: SRV records and/or NAPTR records
- Enable Auto-discovery if classic setup doesn't work
- NAPTR+SRV commonly used for Secure SIP over TLS

## Working with the VoIP Provider Checker

Navigate to "Admin → Voice & Chat" and select **Check SIP Trunk** for your test trunk.

### Trunk Analysis

Tests DNS resolution of the Registrar/Server address and confirms successful registration. Provides details on NAPTR, SRV, and A record resolution.

### Inbound Call Test

1. Initiate an inbound call to the Main Trunk Number from outside the 3CX system
2. Answer from a web client extension
3. Run the call for at least 40 seconds
4. Review results for errors/warnings

### Outbound Call Test

1. Click **Start** and enter the destination number
2. Click the Phone icon to make the outbound call
3. Keep the call active for more than 32 seconds after answer
4. Review results

## Common Detected Issues

### Trunk Analysis Stage
- **Auto-Discovery Not Available**: Disable Auto-discovery checkbox, set port manually (5060 for UDP, 5061 for TLS)

### Incoming Call Stage
- **Inbound Call Failed**: Export trunk config, comment out Source parameter in the provider XML, re-import
- **Codec Mismatch**: Align codec order in trunk Options tab
- **Caller Name Not Visible**: Change `$CallerName` from `FromUserPart` to `FromDisplayName` in provider XML

### Outgoing Call Stage
- **Provider Cannot Support RPID Headers**: Comment out RPID header specs in provider XML
- **Provider Requires P-Asserted-Identity**: Replace RPID with P-Asserted-Identity header specs
- **Provider Requires P-Preferred-Identity**: Replace RPID with P-Preferred-Identity header specs
- **Provider Supports Anonymous Calling**: Adjust `P-AssertedIdentityUserPart` to `$LineNumber`
- **Provider Supports CLIP No Screening**: Change `$OutboundCallerId` to `$OriginatorCallerId`

## Common Registration Errors

| Error | Meaning | Resolution |
|---|---|---|
| Alternate Proxy not resolved | Hostname not found in DNS | Correct hostname or DNS |
| Proxy not resolved | Hostname not found in DNS | Correct hostname or DNS |
| Registrar not resolved | Hostname not found in DNS | Correct hostname or DNS |
| Certificate name mismatch | TLS CN/SAN mismatch | Use correct hostname or fix certificate |
| SIP Registration failed [401] | Invalid credentials | Verify Auth ID & password |
| TLS handshake failed - self-signed | Untrusted certificate | Provider must use trusted CA |
| Trunk is disabled | Inbound/outbound disabled | Enable in Trunk Options tab |

## Common Call Errors

| Direction | Error | Meaning | Resolution |
|---|---|---|---|
| Both | Codec Mismatch | Codec lists differ | Align codec order |
| Inbound | Number Format Mismatch | To/Request-URI mismatch | Provider must correct formatting |
| Both | RTP/SRTP Mismatch | Encryption mismatch | Enable/disable SRTP consistently |
| Inbound | Inbound Call failed | No inbound call received | Check provider routing & firewall |
| Outbound | Call lasted < 32 seconds | RTP/firewall issue | Verify RTP/firewall settings |
| Outbound | 404 Not Found | Invalid destination | Use valid test number |
| Outbound | Routing failure | No outbound rule matched | Fix outbound rules |

## See Also

- [Requirements for VoIP Providers](https://www.3cx.com/docs/voip-provider-requirements/)
- [SIP Trunk / VoIP Providers Configuration Guides](https://www.3cx.com/docs/sip-trunk-configuration/)
- [Supported SIP Trunk Providers](https://www.3cx.com/partners/sip-trunks/)

Last Updated: 02 June 2026
