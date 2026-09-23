# Call Control API for Windows

> Source: https://www.3cx.com/docs/call-api-windows/

## Introduction

The Call Control API for V20 can be downloaded [here](https://downloads-global.3cx.com/downloads/misc/callcontrolapi/3CXCallControlAPI_v20.zip).

This zip file includes:
- A Help folder with HTML documentation of the API.
- An OMSamples folder with C# samples demonstrating how to use the API.

## Prerequisites

**IMPORTANT**: The following is meant to be run in a development environment, not on a production 3CX machine.

### Windows

Install [3CX v20](https://downloads-global.3cx.com/downloads/3CXPhoneSystem20.exe). On the same machine ensure you have the latest Visual Studio 2022 Community or Enterprise edition, which comes with .NET core 8.0 SDK.

From your Start menu, run Command Prompt, go in the OMSample folder:

```cmd
cd "xxx\3CXConfigurationAndCallControlAPIV20\OMSamples"
```

Compile:

```cmd
dotnet build OMSamplesCore.csproj
```

If successful it will say: Build succeeded. 0 Warning(s) 0 Error(s)

Copy folder Scripts into the output folder:

```cmd
xcopy Scripts bin\Debug\net8.0\Scripts /E/H
```

Type D when asked if that is a directory.

Go in the output folder and run the sample executable:

```cmd
cd bin\Debug\net8.0
OMSamplesCore
```

## Deploying the Sample Scripts

Once the sample executable is run, you are now in an interactive shell which allows you to deploy sample scripts to your local 3CX system.

### Sample 1 - Extension Status

```
>scriptdev deployall folder=Scripts/ExtensionStatus
```

It should say that #0 to #4 have been updated. Log into your Web Client as the System Owner. Go to Admin > Advanced > Call Flow Apps. You will see that 5 CFDs have been created and are registered.

Usage:
- Dial #0 to set status to Available
- Dial #1 to set status to Away
- Dial #2 to set status to Do not disturb
- Dial #3 to set status to Lunch (Custom 1)
- Dial #4 to set status to Business Trip (Custom 2)

NOTE: Temporary status override will not be reset.

### Sample 2 - Force PBX Hours

Available in V20 Update 1 or 2.

```
>scriptdev deployall folder=Scripts/ForcePBXHours
```

It should say that #60 to #64 have been updated.

Usage:
- Dial #60 to reset all departments to default hours
- Dial #61 to force all departments to In-office hours
- Dial #62 to force all departments to Out-of-office hours
- Dial #63 to force all departments to Break time
- Dial #64 to force all departments to Holiday time

### Sample 3 - Personal Parking with Auto Return

```
>scriptdev deployall folder=Scripts/PersonalParkingWithAutoReturn
```

It should say that # has been updated. This dial code can now be called from any dialer to park calls.

### Sample 4 - Queue Agent Status

```
>scriptdev deployall folder=Scripts/QueueAgentStatus
```

It should say that #30 and #31 have been updated.

Usage:
- Dial #31 to log out from all queues
- Dial #30 to log in all queues

### Sample 5 - User Input IVR

Available in V20 Update 1 or 2.

```
>scriptdev deployall folder=Scripts/UserInputIVR
```

It should say that #8877 has been updated. Simulates a DTMF Input IVR.

## See also

- [Call Control API for Linux](https://www.3cx.com/docs/call-api-linux/)
- [Google Cloud Storage & Speech API](https://www.3cx.com/docs/manual/google-speech-api-v2/)
- [Creating a Call Processing Script](https://www.3cx.com/docs/manual/call-processing-script/)
- [Call Processing Script for DTMF Input](https://www.3cx.com/docs/call-processing-script-dtmf/)
- [How to use 3CX configuration API](http://www.3cx.com/docs/configuration-rest-api/)
