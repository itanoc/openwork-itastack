# How to Configure Secure SIP – TLS

> Source: https://www.3cx.com/docs/secure-sip/

## Introduction

Secure SIP protects SIP messages by encrypting them over a TLS (Transport Layer Security) channel using a security certificate. Secure RTP (Real-time Transport Protocol) provides encryption, message authentication, integrity, and attack protection to the RTP data stream.

This guide provides detailed information on how to:

- Enable Secure SIP via TLS on your PBX with a 3CX-provided FQDN.
- Setup 3CX Phone System for Secure SIP (TLS) with a certificate and a custom FQDN, to encrypt SIP messaging.
- Configure Yealink and Snom phones to communicate securely via Secure SIP over TLS and/or Secure RTP.

## Configuring Secure SIP (TLS) for 3CX-provided FQDNs

To enable Secure SIP – TLS for a 3CX-provided domain, 3CX comes with a Let's Encrypt certificate pre-configured.

Tips:
- 3CX v16 SP3 and later, updates its SSL certificate on the fly with no need to restart services.
- 3CX mobile apps for Android and iOS use tunnel encryption by default, so configuring TLS and SRTP is not possible, nor needed.
- Secure communication via the trunk for supporting VoIP providers, by selecting **"TLS"** in SIP trunk > **"Options"** tab > **"Transport Protocol"**.
- Supported IP Phones - Trust by default Let's Encrypt certificates.
- Let's Encrypt certificates are auto-renewed every 3 months.

## Configuring Secure SIP (TLS) for 3CX on a Custom FQDN

You can obtain Let's Encrypt certificates via SSL For Free or get a certificate from a commercial provider, e.g. GoDaddy. To use a trusted certificate for your custom FQDN you need:

- A static public IP address assigned to your 3CX Phone System.
- A registered domain name and the ability to manage its DNS records.
- To ensure that the certificate provider is included in the device vendor's list of trusted authorities, to avoid importing certificates in IP phones and client machines.

### Enabling Secure SIP for a Custom FQDN in 3CX PBX

After obtaining a certificate for your custom FQDN, you need to add it in the 3CX phone system:

1. Verify your certificate-related files and store these in a safe location:
   - Certificate, e.g. **"mypbx.example.com.crt"**.
   - Private key, e.g. **"mypbx.example.com.key"**.
   - CA bundle, e.g. **"mypbx.example.com.ca"**.
2. Go to **"Advanced"** > **"Secure SIP"** tab in the 3CX Admin Console and enable secure SIP.
3. Open the .crt file with a text editor, copy all content and paste it into the **"Certificate"** field.
4. Open the .key file with a text editor, copy all content and paste into the **"Key"** field.
5. Click **"OK"** and then **"OK"** to confirm. Follow the link and ensure you restart the PBX services.
6. After restarting, the 3CX Phone System is configured and ready to accept incoming TLS connections.

⚠ Important: Installing 3CX with a custom FQDN and a self-signed or untrusted certificate from an unknown root authority, requires that you import the certificate to all endpoints / devices.

## Provisioning Local IP Phones with TLS

3CX does not officially support IP phones using TLS. If you want to provision your phones via TLS you will need to create a custom template. Only locally provisioned phones can use TLS.

For further information on how to configure your IP phones to accept SIP TLS please consult your phone manufacturer.

## Configuring IP Phones with Secure RTP

Following are instructions on how to manually configure SRTP for Preferred phone vendors. SRTP can also be configured via custom template.

### Configuring the 3CX Extension to Use Secure RTP

Go to **"Extensions"** in the 3CX Admin Console and:

1. Edit the extension and navigate to **"Options"** > **"SRTP Mode"**
2. Set **"SRTP Mode"** to either:
   - **"Enabled - allow secure RTP and non-secure RTP.**
   - **"Enforced"** - allow exclusively secure RTP connections.
3. Click on **"OK"** to save the extension settings.

### Configuring Yealink Phones to Use Secure RTP

1. Open Yealink's web interface.
2. Go to **"Account"** > **"Advanced"** and set the **"RTP Encryption (SRTP)"** option to either **"Optional"** or **"Compulsory"**.
3. Click on **"Confirm"** to configure your Yealink phone for secure RTP.

### Configuring Snom Phones to Use Secure RTP

1. Open the Snom phone's web interface.
2. Go to **"Setup"** > **"Identity 1"** and click on **"RTP"** to set:
   - **"RTP Encryption"** option to **"ON"**.
   - **"RTP/SAVP"** to **"mandatory"** or **"optional"**
3. Click on **"Save"** to configure your Snom phone for Secure RTP.

### Configuring Fanvil Phones to Use Secure RTP

1. Open Fanvil's web interface.
2. Go to **"Line"** > **"SIP"** > **"Advanced Settings"** and set the **"RTP Encryption (SRTP)"** option to either **"Optional"** or **"Compulsory"**.
3. Click on **"Apply"** to configure your Fanvil phone for secure RTP

## See Also

- See how to use the Activity Log to identify why a call is not reaching its destination.
- Supported IP Phones.

Last Updated: 25 July 2024
