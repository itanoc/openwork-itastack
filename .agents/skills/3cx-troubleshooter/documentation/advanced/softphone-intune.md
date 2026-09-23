# 3CX Softphone AutoDeployment Using InTune

> Source: https://www.3cx.com/docs/softphone-intune/

## Overview

Deploying the 3CX Softphone via Microsoft Intune allows IT admins to install the application on many devices simultaneously without manual intervention.

## Configure the InTune Portal

To configure the InTune Portal for automatic distribution of the 3CX Softphone:

- Login to [Microsoft InTune Portal](https://intune.microsoft.com) with an InTune Administrator account
- Navigate to "Apps → All Apps"

### Add the 3CX Softphone

1. Click **"+ Add"** and select **"Windows app (Win32)"** as the app type
2. Upload the 3CX Softphone MSIX package (download from the 3CX website)
3. Configure the app information:
   - Name: 3CX Softphone
   - Publisher: 3CX
   - Description: 3CX Softphone for Windows
4. Configure the installation command:
   - Install command: `powershell.exe -ExecutionPolicy Bypass -File install.ps1`
   - Uninstall command: `powershell.exe -ExecutionPolicy Bypass -File uninstall.ps1`
5. Set detection rules to verify successful installation
6. Assign the app to the appropriate device or user groups
7. Review and create the deployment

### Deployment Best Practices

- Test the deployment with a pilot group before broad rollout
- Ensure devices meet the minimum system requirements for the 3CX Softphone
- Configure the 3CX provisioning URL via Intune configuration profile for automatic setup

## See also

- [Deploy 3CX Softphone App via AD Group Policy](https://www.3cx.com/docs/desktop-app-gpo/)
- [Mass Deploy 3CX PWA App for Terminal Server Users](https://www.3cx.com/docs/pwa-terminal-server-deployment/)
