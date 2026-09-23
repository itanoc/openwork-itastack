# How to Install Multi-Line TAPI

> Source: https://www.3cx.com/docs/installing-multi-line-tapi/

To install the 3CX Multi-Line TAPI for use with your 3CX Softphone App, follow the instructions below.

1. Download the installer from [here](https://downloads-global.3cx.com/downloads/3CXTAPI18.msi) or log in to your 3CX Softphone App and go to Settings >> Integration and click on 'Install TAPI Driver'.

2. Run the installer. Specify the extension numbers followed by the names of the users who have these extensions. Press Next to continue and complete the installation.

3. Start making calls from your TAPI enabled app using 3CX Softphone App.

## Adding More Lines

If you need to add more lines to your TAPI installation, edit the following configuration file:

`C:\ProgramData\3CXMultiLineTapi\3CXTapi.ini`

Editing this configuration file is very easy. Just follow the same structure, adding as many lines as you need, one line per extension:

`Extension Number, Name`

After all modifications are done, save the file and exit. Ensure that the file is saved in UTF-8 encoding so press **"Save as"** and toggle the encoding to UTF-8 before pressing Save.

For the changes to come into effect, the Windows **"Telephony"** service needs to be restarted.

Note that after this you will need to restart your 3CX Softphone App.

> Note: It is important that on Line 1 TAPI is configured to work with the matching extension number and name, and the 3CX Softphone App is provisioned with the same extension. If the 3CX Softphone App is configured with an extension number that does not match the selected TAPI line, TAPI will not work and you will get an **"an invalid TAPI handle"** error.
