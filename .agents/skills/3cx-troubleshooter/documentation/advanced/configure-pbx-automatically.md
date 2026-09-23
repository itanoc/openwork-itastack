# Deploying 3CX and Provisioning Settings via setupconfig.xml

> Source: https://www.3cx.com/docs/configure-pbx-automatically/

## Introduction

Launch and automatically configure 3CX by creating a pre-populated XML file. Simply input the answers to the questions that the 3CX command-line tool asks you into the XML and store the file either in the host or in cloud-init. 3CX parses it automatically and auto-configures your PBX. It's also possible to include extensions, SIP Trunks and DIDs during installation.

## Overview

The deployment process with setupconfig.xml works by placing the XML file on the machine to automatically configure 3CX during install:

- Download this [sample Setup Template XML](https://downloads-global.3cx.com/downloads/misc/setupconfig_v20.xml) file.
- Modify the configuration in the XML file manually and fill in all required details.
- Place the setupconfig.xml file on the host machine:
  - For Linux in: /etc/3cxpbx/setupconfig.xml .
  - For Windows in: C:\ProgramData\3CX\Data\setupconfig.xml .
- Install 3CX. When 3CX is installed, the command line wizard checks the above locations for the XML file and if found, it automatically processes them.

> Tip: Instead of copying the file you can also use cloud-init by copying the contents of the XML and pasting them in the Advanced / User data section.

## Example of Cloud-init

To include setupconfig.xml in cloud-init, download and use this [cloud-init](https://downloads-global.3cx.com/downloads/misc/cloudinit.txt) sample:

```bash
#!/bin/bash -e
mkdir -p /etc/3cxpbx
cat > /etc/3cxpbx/setupconfig.xml << "<EOF>"
<!--PUT CONTENTS OF SETUPCONFIG.XML HERE-->
<EOF>
apt-get update
dpkg-query -W -f='${Status}' sudo 2>/dev/null | grep -qF "ok installed" || apt-get -y install sudo
dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -qF "ok installed" || apt-get -y install wget
dpkg-query -W -f='${Status}' gnupg2 2>/dev/null | grep -qF "ok installed" || apt-get -y install gnupg2
wget -O- https://repo.3cx.com/key.pub | gpg --dearmor | sudo tee /usr/share/keyrings/3cx-archive-keyring.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) by-hash=yes signed-by=/usr/share/keyrings/3cx-archive-keyring.gpg] http://repo.3cx.com/3cx bookworm main" | sudo tee /etc/apt/sources.list.d/3cxpbx.list
apt-get update
apt-get -y install nginx
rm -f /etc/nginx/sites-enabled/default
systemctl reload nginx
apt-get -y install 3cxpbx
```

## setupconfig.xml Explained

The setupconfig.xml is split in these sections:

- `<tcxinit>` - Parameters for the initial phase of the PBX Configuration tool, e.g. license, backup file path, network settings, public IP, FQDN (3CX FQDN or Custom FQDN), hostname, local DNS, HTTP(S) ports, extension length, mail server, timezone, country and license info.
- `<extensions>` - Add the extensions to create in this section.
- `<siptrunk>` - Define SIP trunks and DIDs to deploy and add a subnode in `<inboundrules>` to create inbound routing associated with the DID of that SIP trunk.
- `<OutboundRules>` - Add outbound rules to create in this section.

## Configuring the Wizard

This is an example XML subset that corresponds to the questions asked in the First-time Configuration wizard:

```xml
<option> <code>NumberOfExtensions</code> <answer>3</answer> </option>
<option> <code>MailServerType</code> <answer>3CX</answer> </option>
<option> <code>MailServerAddress</code> <answer>smtp.example.com</answer> </option>
<option> <code>MailServerReplyTo</code> <answer>email@example.com</answer> </option>
<option> <code>MailServerUserName</code> <answer>username</answer> </option>
<option> <code>MailServerPassword</code> <answer>password</answer> </option>
<option> <code>MailServerEnableSslTls</code> <answer>yes</answer> </option>
<option> <code>Continent</code> <answer>North America</answer> </option>
<option> <code>Country</code> <answer>United States</answer> </option>
<option> <code>Timezone</code> <answer>9</answer> </option>
<option> <code>OperatorVoicemail</code> <answer>999</answer> </option>
<option> <code>Promptset</code> <answer>English</answer> </option>
<option> <code>LicenseContactName</code> <answer>John L. Doe</answer> </option>
<option> <code>LicenseCompanyName</code> <answer>My Company Ltd.</answer> </option>
<option> <code>LicenseEmail</code> <answer>email@example.com</answer> </option>
<option> <code>LicensePhone</code> <answer>+357 987654321</answer> </option>
<option> <code>ResellerId</code><answer></answer> </option>
```

To populate Country and Timezone refer to the TimeZone Reference document and select values from the appropriate columns.

## Adding Extensions, SIP Trunks, DIDs and Outbound Rules

Use the `<extensions>` section to:
- Add extensions, SIP trunks, inbound and outbound rules to the setup configuration file.
- Provision an IP phone to an extension by configuring the relevant XML node with the appropriate info, from the [Available Codec Values and Phone Templates for Supported IP Phones](https://www.3cx.com/sip-phones/codecs/) guide.

## Creating an Extension

To automatically create and configure a new extension, add the info in an `<extension>` node under the `<extensions>` section:

```xml
<extension>
   <Number>000</Number>
   <FirstName>John</FirstName>
   <LastName>Smith</LastName>
   <EmailAddress>email@example.com</EmailAddress>
   <MobileNumber>801123456</MobileNumber>
   <OutboundCallerId>801123456</OutboundCallerId>
   <AuthPassword>extensionPassword</AuthPassword>
   <AuthID>000</AuthID>
   <AllowLanOnly>false</AllowLanOnly>
   <RecordCalls>false</RecordCalls>
   <TemplateFilename>snom.ph.xml</TemplateFilename>
   <ProvisioningFilename2>Snom 720</ProvisioningFilename2>
   <MAC>121212ABABAB</MAC>
   <Codecs>
      <codec>G711u</codec>
      <codec>G711a</codec>
      <codec>G722</codec>
      <codec>G729</codec>
   </Codecs>
   <Language>English</Language>
   <ProvisionType>LocalLan</ProvisionType>
   <AllowOwnRecordings>false</AllowOwnRecordings>
</extension>
```

## Creating a SIP Trunk, DIDs and Inbound rules

To automatically create a SIP trunk, as well as its DIDs and inbound rules, add the relevant info in a `<siptrunk>` node.

## Creating Outbound Rules with Backup Routes

In the `<OutboundRules>` section, you can add `<OutboundRule>` nodes to automatically create outbound rules and backup routes via your setupconfig.xml.

## Importing SSL Certificates

To include SSL certificate information in your setupconfig.xml, configure the parts relevant to SSL. Different types of certificates require different XML nodes to be configured.

## New Installation vs Restoring a Backup

To create a fresh 3CX installation, set `InstallationType=new` and provide your Licence Key. To restore an existing backup, set `InstallationType=restore` and provide the path to your backup file.

## Setting Up the System Owner and Credentials

The first extension you configure will be assigned the System Owner Role.

## Configuring your PBX Ports

Specify the ports that your PBX will use for HTTPS, HTTP, SIP and the 3CX tunnel.

## Setting Up your Mail Server

Configure your PBX to use the 3CX SMTP server or your own SMTP server.

## Public IP Configuration

Control the configuration of the public IP of your PBX. Set to `auto` for auto-detection or `manual` with `StaticOrDynamicIP` set accordingly.

## Local IP Configuration

Control your local interface/IP configuration. Set to `auto` or `manual` with the appropriate local IP address.

## Using 3CX FQDNs

Configure with `NeedFqdn=yes` to use 3CX FQDNs. Available Domain Groups: Africa, Asia, Cities, Continent, Europe, Oceania, Other, South America, United States.

## Configuring a Different Local FQDN

In case you have a managed DNS, there is also the option to configure a different local FQDN by setting `HasLocalDns=yes` and specifying `InternalFqdn`.

## Setting Up your PBX Language, Country, Time Zone and Prompt Sets

Available languages: EN (English US), UK (English UK), DE (German), FR (French), ES (Spanish), IT (Italian), PT (Portuguese), RU (Russian), PL (Polish), ZH (Chinese).

## Whitelist/Blacklist of IPs

Use `<IpBlackList>` entries to whitelist/blacklist a single IP or a range of IPs/subnet.

## Configuring Countries for Outbound Calls

Use `NOTALLOWED_COUNTRYCODES` custom parameter to specify which countries the PBX should allow outbound calls to.

## See also

- [Installing 3CX](https://www.3cx.com/docs/manual/install/)
- [Installing 3CX using 3CX Debian ISO](https://www.3cx.com/docs/manual/installing-debian-linux-pbx/)
- [Configuring "Split DNS", "NAT Loopback" or "Hairpin Nat" for On-Premise Installs](https://www.3cx.com/docs/creating-fqdn-split-dns/)
