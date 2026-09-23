# Collecting Logs for 3CX Support

> Source: https://www.3cx.com/docs/collecting-logs-for-3cx-support/

When troubleshooting an issue, the 3CX Support Team may ask you to generate the support files. These files contain information about the environment 3CX Phone System is operating in, and other information which would help 3CX Support troubleshoot further.

The following procedure explains all the steps required to generate the support files that the 3CX Support Team requires to troubleshoot issues.

## Generating Support Info Files

### Method 1: Via the Admin Console (V20)

1. Log in to the 3CX Admin Console.
2. Navigate to **"Dashboard"** > **"Activity Log"** > **"Support"** (or **"Settings"** > **"Support"**).
3. Click the **"Generate Support Info"** button.
4. Select the services/options to include in the log bundle.
5. Set the logging level to **"Verbose"** if requested by support.
6. Choose the time range for which to collect logs.
7. Click **"Generate"** and wait for the process to complete.
8. Download the generated support info file (.zip).

### Method 2: Via SSH / Console (Linux)

For on-premise or self-hosted Linux installations:

```
# Navigate to the 3CX script directory
cd /usr/lib/3cxpbx

# Generate support info
sudo ./PbxConfigTool --generate-support-info

# Or use the direct script
sudo /usr/sbin/3cx-support-package
```

The support file will be saved to a location displayed in the terminal output. Download it via SCP/SFTP.

### Method 3: Via SSH / Console (Windows)

For Windows installations:

1. Open an elevated PowerShell or Command Prompt.
2. Navigate to the 3CX installation directory (typically `C:\Program Files\3CX Phone System\Bin`).
3. Run the support package generator tool.
4. The resulting ZIP file will be saved to a known location.

## What's Included in the Support Info File

The support info bundle typically includes:
- PBX configuration and settings
- System logs and event logs
- Service status information
- Network configuration
- Database information
- Installed version and update history
- SIP trunk and provider configuration
- Extension and user settings (anonymized where possible)

## Uploading to 3CX Support

After generating the support info file:
1. Upload the file via the 3CX Support ticket portal
2. Reference your support ticket number
3. Provide a brief description of the issue and what troubleshooting steps have already been taken

## Increasing Logging Level

For detailed troubleshooting, you may be asked to increase the logging level:

1. Go to **"Dashboard"** > **"Activity Log"** > **"Settings"**
2. Change the logging level from "Low" to **"Medium"** or **"Verbose"**
3. Reproduce the issue
4. Generate the support info file with the increased logging level
5. Return the logging level to "Low" after collecting logs to avoid excessive disk usage

Last Updated: This document is updated periodically.
