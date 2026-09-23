# Managing SSL Certificates for Multiple 3CX Systems

> Source: https://www.3cx.com/blog/docs/multiple-systems-ssl-setup/

### Deploying multiple 3CX MCUs and AI transcriber engines in a single LAN.

When running multiple instances of services that require public-facing FQDNs and SSL certificates, managing the certificates can be a challenge.

To provide meaningful examples of what can and what cannot be achieved, we will use a common scenario as a starting point, and then expand on how variations impact your SSL certificate management strategy.

## The Common Example Setup

To better explain things, we shall consider a setup with 3 machines inside the same local LAN:

- 3CX PhoneSystem - IP Address 192.168.0.10
- 3CX On-Board MCU - IP Address 192.168.0.20
- 3CX On-Board AI - IP Address 192.168.0.30

## 3CX-Provided FQDNs

The standard 3CX deployment uses a custom ACME client to automatically provision and renew Let's Encrypt certificates. This method ties the certificate directly to the 3CX installation and FQDN. There are 3 requirements as outlined below:

### 1. Dedicated Public IP Addresses

For this setup to work, each of these 3 machines will require a dedicated public IP Address:

| FQDN | System | LAN IP Address | Public IP Address |
|------|--------|----------------|-------------------|
| mypbx.3cx.com.cy | 3CX PhoneSystem | 192.168.0.10 | 20.20.20.20 |
| mymcu.my3cx.net (auto-assigned) | 3CX On-Board MCU | 192.168.0.20 | 20.20.20.21 |
| myai.my3cx.net (auto-assigned) | 3CX On-Board AI | 192.168.0.30 | 20.20.20.22 |

### 2. Split DNS

Your LAN DNS Server must be configured to ensure that:

- Inside the LAN, your FQDNs resolve to their LAN IP Addresses
- Outside the LAN, your FQDNs resolve to their PUBLIC IP Addresses

These setups are referred to with different names, including: Pinpoint DNS Zones, Response Policy Zone (RPZ), Split-Horizon DNS or Views, Shadow Zones.

### 3. Port Forwarding for Certificate Auto-Update

You will need to configure your firewall or edge router to forward all traffic for the MCU and AI machines to port 80. This will allow Let's Encrypt to reach your machine for Certificate Updates.

3CX PhoneSystem does not require this port forwarding because it leverages the 3CX Cloud Infrastructure to update its 3CX FQDN certificates.

**NOTE**: If you are unable to provide distinct Public IP Addresses to all of your in-LAN MCU and/or AI machines, then you MUST use your own custom FQDNs.

## Custom FQDNs Using Let's Encrypt with DNS Automation

This approach is suitable if you have all three 3CX machines in the LAN and all are not directly reachable from the public internet. This requires a manual setup outside the standard 3CX configuration. For this example, we assume FQDNs: mypbx.example.com, mymcu.example.com, myai.example.com.

### 1. Automation Script

You will need to create an automation script on some machine in the LAN that:

- Uses the Let's Encrypt DNS-01 challenge mechanism
- Runs periodically to ensure that you renew certificates ahead of time
- Communicates with Let's Encrypt to request certificate renewal
- Communicates with your DNS provider's API to create records as required for Let's Encrypt verification
- Saves the downloaded certificate PEM file and KEY file to a folder; for example:
  `/etc/letsencrypt/live/mymcu.example.com/fullchain.pem`
  `/etc/letsencrypt/live/mymcu.example.com/privkey.pem`

### 2. Certificate Update Script

Next, you will need to create a certificate update script that checks for new certificate files, copies them to the correct destinations, and deletes the source files.

Here is an example script for the ***mymcu.example.com*** machine which you could save in ***"/root/certupdate.sh"***:

```bash
#!/bin/bash
cp /etc/letsencrypt/live/mymcu.example.com/fullchain.pem /opt/3cxwm/cert/server.crt
cp /etc/letsencrypt/live/mymcu.example.com/privkey.pem /opt/3cxwm/cert/server.key
chown www-data:www-data /opt/3cxwm/cert/server.*
chmod 600 /opt/3cxwm/cert/server.*
```

Set the correct permissions for the script:

```bash
chmod +x /root/certupdate.sh
```

...and add it to your crontab to run, for example, every morning at 3am.

## Custom FQDN - Manual Certificate Renewal

If you are limited to manual certificate renewal, for example because your DNS provider does not have APIs for automation, and also possibly because you are using wildcard certificates, the procedure is essentially the same as above, except that you have to perform the changes yourself without the benefits of automation.

### Alternative Certificate Authority

For CAs other than Let's Encrypt, 3CX provides a general guide with advice on how to select which one to use [here](https://www.3cx.com/docs/fqdn-ssl-certificate/).
