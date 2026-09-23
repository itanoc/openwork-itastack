# How to Migrate to 3CX Hosted

> Source: https://www.3cx.com/docs/switch-hosted-pbx/

## Introduction

Customers running 3CX on-premise or in the cloud (e.g Google or Amazon etc) can switch to 3CX Hosted and have us host your installation. Why should you do this:

- We deploy your instance and automatically configure the firewall rules.
- We manage the 3CX operating system, including security patches and version upgrades
- We keep your 3CX on the latest non-beta update.
- We monitor your 3CX system 24/7.

## Requirements for 3CX-hosted instances

- You must use a supported SIP trunk.
- You must use a 3CX FQDN.
- IP phones must be run behind the 3CX SBC.
- FXO and ISDN gateways are not supported.
- No remote system-level (e.g. SSH) or web terminal access to the machine.
- Failover mode and Scriptable IVRs are not available.
- Path for Recordings and local Backups cannot be changed.

## Preparing for the Switch

### From On-premise to 3CX Hosted

To transfer an on-premise installation into the cloud, complete the below checklist to ensure a smooth transition and minimize downtime and device re-provisioning.

1. **Move to a SIP trunk** (if you have a PSTN gateway) - If you are running PSTN lines in combination with PSTN gateways, first you need to move to a 3CX supported SIP trunk provider. Configure and test run the SIP Trunk on your current (on-premise) installation.
2. **Install an SBC** (if you are using IP phones) - If you are using IP phones, you must deploy a 3CX SBC using your 3CX FQDN. The IP phones need to be re-configured to use the 3CX SBC. Installing the 3CX SBC is easy and free. You can use an existing Windows or Linux PC/VM or even a Raspberry Pi 5 and run the SBC as a standalone or failover cluster service. During the setup of the SBC, the PBX's FQDN should be used to connect. Alternatively you can also use a Router Phone.
3. **Test run your system** to ensure your SBC and SIP Trunk are working correctly with your on-premise installation. When you switch to "Hosted", both your SIP trunks and your IP Phones will connect automatically.

### From Self-Hosted to 3CX Hosted

You must make sure that your current SIP Trunk Provider is supported for "Hosted".

## Completing the Switch

1. Download a configuration backup of your existing system and save it locally. **Note:** The 3CX backup must include the "License Key Information, FQDN & Conference" option.
2. From your 3CX Customer Account, go to "Systems" and find the instance you want to migrate.
3. Select "Switch to Hosted"
4. Click "Yes" to upload your configuration backup
5. Your 3CX-hosted instance will be up within 15 minutes (restore time depends on size and content).

**Note:** DNS Change Delay - After migration is completed, it can take up to 10 minutes for the DNS changes to propagate. If this takes longer it may be due to client-side caching.

### Migration Support

Please note that this service does not include technical support and does not replace the need for a partner if you require support to configure 3CX.

## See Also

- Which SIP trunks are supported by "Hosted".

*Last Updated: 18 June 2025*
