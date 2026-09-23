# Call Control API for Linux

> Source: https://www.3cx.com/docs/call-api-linux/

## Introduction

The Call Control API for V20 can be downloaded [here](https://downloads-global.3cx.com/downloads/misc/callcontrolapi/3CXCallControlAPI_v20.zip).

The zip file includes:
- A Help folder with HTML documentation for the API.
- An OMSamples folder with C# samples demonstrating how to use the API.

## Prerequisites

**IMPORTANT**: The following is meant to be run in a development environment, not on a production 3CX machine.

### Linux

As a prerequisite, you will need to install a self-hosted or on-premise [3CX v20 for Debian 12](https://downloads-global.3cx.com/downloads/debian12iso/debian-amd64-netinst-3cx.iso).

Login to SSH as root and install the .NET core 8.0 SDK:

```bash
wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt-get update && apt-get install -y dotnet-sdk-8.0
```

Download the Call Control API locally:

```bash
wget https://downloads-global.3cx.com/downloads/misc/callcontrolapi/3CXCallControlAPI_v20.zip
```

Extract it via:

```bash
apt install unzip
unzip 3CX*
```

Go in the OMSample folder:

```bash
cd OMSamples
```

Compile:

```bash
dotnet build OMSamplesCore.csproj
```

If successful it will say: Build succeeded. 0 Warning(s) 0 Error(s)

Copy folder Scripts into the output folder:

```bash
cp Scripts bin/Debug/net8.0 -r
```

Go in the output folder and run the sample executable:

```bash
cd bin/Debug/net8.0
./OMSamplesCore
```

## Deploying the Sample Scripts

Once the sample executable has run, you are in an interactive shell allowing you to deploy sample scripts to your local 3CX.

### Sample 1 - Extension Status

Deploy the ExtensionStatus sample:

```
>scriptdev deployall folder=Scripts/ExtensionStatus
```

It should say that #0 to #4 have been updated. Log into your Web Client as the System Owner and go to Admin > Advanced > Call Flow Apps. You will see that 5 CFDs have been created and registered.

Usage:
- Dial #0 to set status to Available
- Dial #1 to set status to Away
- Dial #2 to set status to Do not Disturb
- Dial #3 to set status to Lunch (Custom 1)
- Dial #4 to set status to Business Trip (Custom 2)

NOTE: Temporary status override will not be reset.

### Sample 2 - ForcePBXHours

Available in V20 Update 1 or 2.

```
>scriptdev deployall folder=Scripts/ForcePBXHours
```

It should say that #60 to #64 have been updated.

Usage:
- Dial #60 to reset all departments to default hours
- Dial #61 to force In-office hours
- Dial #62 to force Out-of-office hours
- Dial #63 to force Break-time
- Dial #64 to force Holiday-time

### Sample 3 - Personal Parking with Auto Return

```
>scriptdev deployall folder=Scripts/PersonalParkingWithAutoReturn
```

Parked calls are put on hold with parking music and will try to return to the extension when available / no longer in a call and not in DND.

### Sample 4 - Queue Agent Status

```
>scriptdev deployall folder=Scripts/QueueAgentStatus
```

It should say that #30 and #31 have been updated.

Usage:
- Dial #31 to log out from all queues
- Dial #30 to log in to all queues

### Sample 5 - User Input IVR

Available in V20 Update 1 or 2.

```
>scriptdev deployall folder=Scripts/UserInputIVR
```

Simulates a DTMF Input IVR where a list of predefined PINs are associated with a list of routes.

## See also

- [Call Control API for Windows](https://www.3cx.com/docs/call-api-windows/)
- [Google Cloud Storage & Speech API](https://www.3cx.com/docs/manual/google-speech-api-v2/)
- [Creating a Call Processing Script](https://www.3cx.com/docs/manual/call-processing-script/)
- [Call Processing Script for DTMF Input](https://www.3cx.com/docs/call-processing-script-dtmf/)
- [How to use 3CX configuration rest API](http://www.3cx.com/docs/configuration-rest-api/)
