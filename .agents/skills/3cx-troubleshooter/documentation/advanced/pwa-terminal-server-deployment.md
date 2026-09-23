# Mass Deploy 3CX PWA App for Terminal Server Users

> Source: https://www.3cx.com/docs/pwa-terminal-server-deployment/

## Introduction

A detailed guide on how to mass deploy the 3CX progressive web app (PWA) for terminal server users covering the steps depending on whether users browse with Chrome or Microsoft Edge.

## Step 1: Add Group Admin Template

1. Install Microsoft Edge or Google Chrome for all terminal server users.
2. Add the **"Group Administrative template"** for [Edge](https://learn.microsoft.com/en-us/deployedge/configure-microsoft-edge) or [Chrome](https://support.google.com/chrome/a/answer/187202?hl=en#zippy=%2Cwindows).

## Step 2: Configure your Group Policy

### For Microsoft Edge

1. Open **Group Policy Management**
2. Create or edit a Group Policy Object (GPO)
3. Navigate to: Computer Configuration > Administrative Templates > Microsoft Edge
4. Enable **"Configure list of force-installed Web Apps"**
5. Add the 3CX Web Client PWA URL in JSON format:

```json
[
  {
    "url": "https://YOUR_3CX_FQDN/webclient/",
    "create_desktop_shortcut": true,
    "default_launch_container": "window"
  }
]
```

### For Google Chrome

1. Open **Group Policy Management**
2. Create or edit a GPO
3. Navigate to: Computer Configuration > Administrative Templates > Google Chrome > Extensions
4. Enable **"Configure list of force-installed apps and extensions"**
5. Add the 3CX PWA entry matching the 3CX Web Client URL

## Step 3: Apply your Group Policy

1. Link the GPO to the appropriate OU containing terminal servers
2. Run `gpupdate /force` on the terminal server or wait for Group Policy refresh
3. Verify the 3CX PWA appears on user desktops after login

## See also

- [3CX Softphone AutoDeployment Using InTune](https://www.3cx.com/docs/softphone-intune/)
- [Deploy 3CX Softphone App via AD Group Policy](https://www.3cx.com/docs/desktop-app-gpo/)
