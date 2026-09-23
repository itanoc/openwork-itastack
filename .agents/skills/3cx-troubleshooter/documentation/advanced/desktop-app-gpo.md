# Deploy 3CX Softphone App via AD Group Policy

> Source: https://www.3cx.com/docs/desktop-app-gpo/

## Introduction

The new 3CX Softphone for Windows can be centrally deployed to domain-joined PCs using Active Directory Group Policy (GPO). This guide shows how to host the MSIX package on a network share, create and link a computer-based GP, and use a startup PowerShell script (sample provided by 3CX) to install the application automatically on your Windows 11 clients.

## Prerequisites

- Windows Server 2025, fully updated.
- Client PCs on Windows 11, fully updated.
- Download the latest 3CX Softphone MSIX from the provided link [here](https://downloads-global.3cx.com/downloads/3cxsoftphone/3CX.msix).
- A PowerShell deployment script is required. 3CX provides a sample [script](https://downloads-global.3cx.com/downloads/misc/ad_softphonesample.ps1) you can use or modify.

## Create a Distribution Point

1. Log on to the server as an Administrator
2. Create a shared network folder that will be used for the distribution of the application
3. Set read access for the users or computers that package will be distributed to
4. Copy the 3CX Softphone MSIX and PowerShell script in the shared folder

## Create a Group Policy Object

1. Open **Group Policy Management Console** (GPMC)
2. Right-click the domain or OU and select **"Create a GPO in this domain, and Link it here"**
3. Name the GPO (e.g. "Deploy 3CX Softphone")
4. Edit the GPO and navigate to: Computer Configuration > Policies > Windows Settings > Scripts (Startup/Shutdown)
5. Double-click **"Startup"**, then click **"Add"**
6. Browse to the shared folder and select the PowerShell deployment script
7. Set script parameters if needed
8. Apply and close

## Assign an MSIX Package

The PowerShell sample script performs the following:
1. Copies the MSIX package locally
2. Installs the MSIX using Add-AppxPackage
3. Verifies installation

## Install Application to Domain Computers

1. Link the GPO to the appropriate OU containing target computers
2. Force Group Policy update: `gpupdate /force` on client machines
3. Restart client machines to trigger the startup script
4. Verify 3CX Softphone appears in the Start Menu

## See also

- [3CX Softphone AutoDeployment Using InTune](https://www.3cx.com/docs/softphone-intune/)
- [Mass Deploy 3CX PWA App for Terminal Server Users](https://www.3cx.com/docs/pwa-terminal-server-deployment/)
