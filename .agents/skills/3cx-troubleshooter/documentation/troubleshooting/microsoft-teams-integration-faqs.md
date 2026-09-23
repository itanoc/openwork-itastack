# Microsoft 3CX Teams Integration Configuration Troubleshooting

> Source: https://www.3cx.com/docs/microsoft-teams-integration-faqs/

## What 3CX license do I need?

3CX AI 16SC+.

## I'm currently using another product to connect my 3CX to Teams, how do I clear the old configuration?

If you are currently using other services to connect Teams to 3CX, wipe them out and bring the direct routing config back to default:

1. Revert Teams users' policies back to the default **"Global (Org-wide default)"**. This is commonly set for: Calling policy, Dial plan and Voice routing policy.
2. Clean up existing dial plans by calling `Get-CsTenantDialPlan` and then remove all where the **"Identity"** is not **"Global"** with `Remove-CsTenantDialPlan`.
3. Repeat for `Get-CsOnlineVoiceRoutingPolicy`, `Get-CsOnlineVoiceRoute`, `Get-CsOnlinePstnUsage` and `Get-CsOnlinePSTNGateway` to find and remove unnecessary configuration.

## When I run the 3CX scripts, I'm getting an error saying 'The term 'set-XYZ' is not recognized'

This can result from two common sources:
- If you don't run the scripts via an elevated PowerShell prompt, which then fails to install the necessary PowerShell Teams module.
- If you have already installed the PowerShell module for Skype for Business or Teams, but they are outdated.

Check the version by running `Get-InstalledModule` in PowerShell. Version 2.3.1 or higher is expected.

If you don't see an installed version, or an older version is displayed, run:
```
Install-Module -Name MicrosoftTeams -Force
```
from an elevated PowerShell terminal to install/update to the latest version.

## When I run the 2nd 3CX script (User Script), I get an error 'Cannot modify the parameter: "OnPremLineURI" because it is restricted for the user service plan'

This is a strong indicator that the user is not licensed, not yet provisioned by Microsoft or you have a calling plan enabled on the user.

### Case 1: Microsoft 365 Phone System

Log in to [https://admin.microsoft.com/#/users](https://admin.microsoft.com/#/users) and check if the **"Microsoft 365 Phone System"** addon was assigned to the user. Without this, you cannot proceed.

### Case 2: Microsoft 365 Business Voice

If the user has Microsoft 365 Business Voice (which includes a Calling Plan), remove the Calling Plan or switch to a Phone System-only license.

## After generating the 2nd 3CX script (User Script), my user list appears empty

Verify:
1. Users are licensed for Microsoft 365 Phone System
2. Users are synced from on-prem AD (if hybrid)
3. Users have a valid SIP address (User Principal Name)

## What DNS Records do I need to update?

For Teams Direct Routing, you need:
- An SRV record: `_sipfederationtls._tcp.<domain>` pointing to `sipfed.online.lync.com`
- A TXT record for domain verification (provided during setup)

## Which provider can I purchase my SSL certificate from?

Any public Certificate Authority trusted by Microsoft, such as:
- DigiCert
- GoDaddy
- GlobalSign
- Let's Encrypt (not recommended for Teams Direct Routing)

## Can I use my existing or a new Wildcard SSL Certificate?

Yes, wildcard certificates are supported as long as they are from a trusted public CA and cover the FQDN used for the SBC.

## My 3CX is using a Custom Domain, what additional steps are needed?

If using a custom FQDN (not a 3CX-provided one):
1. Purchase a certificate from a public CA
2. Import the certificate into 3CX
3. Ensure the certificate includes the full chain (root + intermediate)
4. Configure the SBC in Teams with the same FQDN

## Why is my Team's SBC showing "Trunk Down"?

Possible causes:
- DNS resolution failure for the SBC FQDN
- Certificate issues (expired, untrusted, name mismatch)
- Network/firewall blocking SIP traffic
- Incorrect SBC configuration in Teams admin center
- IP address of the SBC not added to the Teams trusted IP list

## Why are my Outbound Calls failing?

Check:
- Voice routes are configured correctly in Teams
- PSTN usage records are assigned to the voice route
- Voice routing policy is assigned to the user
- Number format matches the expected pattern in the voice route

## Why does my Teams client not work immediately?

After provisioning, it can take up to 24 hours for Teams Direct Routing changes to propagate. If it still doesn't work after 24 hours, sign out and sign back into the Teams client.

## How do I disable Teams Voicemail?

1. Go to Teams Admin Center > Voice > Voicemail policies
2. Create or modify a policy with voicemail disabled
3. Assign the policy to users who should use 3CX voicemail instead

## My Teams Room cannot be integrated

Teams Rooms (MTR) may require specific licensing and configuration. Ensure the room account has the appropriate Microsoft 365 Phone System license and is enabled for Direct Routing.

## Only one App on my iOS device rings

This is expected behavior - iOS allows only one VoIP app to receive incoming calls at a time. Close the other app or adjust notification settings.

## My SIP carrier needs the FROM and TO number format changed

Use 3CX outbound rules to manipulate caller ID and number formats to match your SIP carrier's requirements.

## What are the exact rules I need to set on my firewall?

### Inbound (from Teams to 3CX)
- Source: Microsoft Teams IP ranges (52.112.0.0/14, 52.120.0.0/14)
- Destination: 3CX SBC public IP
- Protocol: TCP 5061 (SIP TLS)

### Outbound (from 3CX to Teams)
- Source: 3CX SBC IP
- Destination: Microsoft Teams IP ranges
- Protocol: TCP 5061 (SIP TLS)

## Is Microsoft DoD and GCC high environment supported?

No, 3CX Teams Direct Routing is only supported in Microsoft's commercial cloud. DoD and GCC High environments are not supported.

## My outbound calls are blocked, how can I fix it?

### Option 1
Check that the number format in the voice route matches the dialed number pattern.

### Option 2
Verify that the PSTN usage and voice route are correctly associated with the user's voice routing policy.

Last Updated: This document is updated periodically.
