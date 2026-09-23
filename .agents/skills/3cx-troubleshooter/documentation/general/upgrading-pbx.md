# How to Upgrade to v20

> Source: https://www.3cx.com/docs/upgrading-pbx/

# How to Upgrade to V20

On this topic:

## Prerequisites

-   Make sure you have 2 gig Ram and 2 vCPU.
-   Check you have Split DNS configured. Read how to [configure Split DNS](https://www.3cx.com/docs/creating-fqdn-split-dns/)

## Step 1 - Assign a System Owner

1.  This System Owner account will be used to login to the Admin Console!
2.  Ensure the System Owner extension has an email assigned to it
3.  Email must not be in use in other extensions
4.  Read [How to Assign your 3CX System Owner](https://www.3cx.com/docs/assign-system-owner/)

## Step 2 - Check System & Network requirements

1.  Self hosted - Make sure you have 2 gig Ram and 2 vCPU
2.  3CX v20 is tested on supported cloud providers ONLY
3.  On Premise - check you have Split DNS configured
4.  Read how to [configure Split DNS](https://www.3cx.com/docs/creating-fqdn-split-dns/)

## Step 3 - Move Queues/IVR/RG to departments

1.  Move your Queues, IVR & Ring Groups to the correct department
2.  If you don't want to use departments copy them to the DEFAULT department

## Step 4 - Setup your department office hours

1.  Old global office hours (including holidays and break times) are copied to EACH department
2.  Configure your office hours & holidays  for each department
3.  Specify the destination for in office / out office / break for each of your system extensions (Remember the hours of the department will now apply, not the global office hours)
4.  Read [Configure your Office Hours](https://www.3cx.com/docs/manual/office-hours/)
5.  All Calls will be received as in office until you configure it!

## Step 5 - Check your rights

1.  You cannot customize roles in v20
2.  All rights will be reset to the defaults for the role assigned to the user
3.  Read [User access roles explained](https://www.3cx.com/docs/manual/access-roles/)

## Step 6 - Set call visibility

1.  Users will see calls in their department only
2.  You can give them visibility to calls of other departments by going to the user node in the Admin Console, selecting the User and then **"View"** and selecting which department they can see.

## Step 7 - Check out our new Windows Softphone

1.  New Windows Softphone replaces Desktop App (aka Electron App)
2.  Can already be deployed with v18
3.  Download it [from Windows Store here](https://apps.microsoft.com/detail/9NW77489NGJ0?hl=en-us&gl=US)
4.  Alternatively use PWA (Native Web App for Chrome / Edge)

## Hosted, Self-Hosted or On-Premise

1.  Log in to the V18 Management Console.
2.  As a safety precaution take a full backup configuration by going to Backup and Restore.
3.  Download and save your backup outside of the instance.
4.  Navigate to and select **"**Upgrade**"** in the top right corner.
5.  Confirm the upgrade.
6.  You will receive an email informing you when the OS and PBX are upgraded.

Note: Before updating, ensure you have a system owner set. The system owner's email must be unique and not assigned to other extensions as this will be used to login after the V20 Upgrade.

### Deploy Linux via ISO

1.  Log in to the Management Console.
2.  Take a full backup configuration by going to Backup and Restore.
3.  Download and save your backup outside of the instance.
4.  Uninstall 3CX V18.
5.  Install 3CX V20 using this [.iso file](https://downloads-global.3cx.com/downloads/debian12iso/debian-amd64-netinst-3cx.iso). Read the [installation guide](https://www.3cx.com/docs/manual/installing-debian-linux-pbx/).
6.  Upload and restore your backup.

### Deploy Windows via Installer

1.  Log in to the Management Console.
2.  Take a full backup configuration by going to Backup and Restore.
3.  Download and save your backup outside of the instance.
4.  Uninstall 3CX V18.
5.  Install 3CX V20 using this [executable](https://downloads-global.3cx.com/downloads/3CXPhoneSystem20.exe). Read the [installation guide](https://www.3cx.com/docs/manual/phone-system-installation-windows/).
6.  Upload and restore your backup.

Note: Before taking a backup make sure you have a system owner set in the system. The system owner's email must be unique and not assigned to other extensions as this will be used to login after the V20 Upgrade.

## Expired License Keys

If your license is still within the grace period, you can renew your maintenance. Contact your 3CX Partner or our [3CX Customer Service Team](https://www.3cx.com/contact-form/) for further information.

## See Also

-   [V20 Upgrade List & FAQ](https://www.3cx.com/blog/releases/v20-upgrade-checklist-faq/)

Last Updated

This document was last updated on 28 June 2024
