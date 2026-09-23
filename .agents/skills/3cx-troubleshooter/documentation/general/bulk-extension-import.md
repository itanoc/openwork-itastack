# Importing Extensions in Bulk - CSV File Structure

> Source: https://www.3cx.com/docs/bulk-extension-import/

You can import extensions in bulk by creating a CSV (Comma Separated Values) file specifying all the options to be imported:

1. Download the 3CX Phone System CSV sample file.
2. The position of the column must remain as is. The comma-delimited file provides the structure of the columns and their names in the first row. The subsequent rows contain example entries that you need to modify to create extensions with provisioning.
3. When you have created the CSV, log in to the 3CX Admin Console and go to "Users" > "Import".
4. Browse and select your extension CSV file and click on "Open" to import your extension(s) into 3CX.

## CSV Field Reference

| FIELD NAME | DESCRIPTION | VALUE |
|---|---|---|
| Number | Extension Number | Optional - numeric values only |
| FirstName | First Name | Alphanumeric |
| LastName | Last Name | Alphanumeric |
| EmailAddress | Email Address | Alphanumeric |
| MobileNumber | Mobile Number | Numeric values, + - ( ) and spaces are also accepted. |
| OutboundCallerID | Outbound Caller ID | Alphanumeric – Configures the Outbound Caller ID for the extension |
| DID | List of DIDs assigned to the extension, separated by colon (:) | Example: 36912:*123963321:*961235469 |
| Role | The user's access role | `"<role name=""ROLE"" />"` where ROLE is: users, managers, receptionists, group_admins, group_owners, system_admins, system_owners |
| Department | User's Main Department only | Alphanumeric (Must be an existing Department) |
| ClickToCallAuth | What to ask the customer for the Talk URL | 0 – Name & Email, 1 – Name, 2 – Email, 3 – None |
| WMApprove | Approve participants before they join your meeting | 0 – Disable, 1 – Enable |
| WebMeetingFriendlyName | Your Talk and Meet URL name | Unique alphanumeric string, without spaces. If empty, 3CX Talk is disabled. |
| MAC | MAC Address of the first provisioned phone | Hexadecimal string without spaces or dashes |
| Template | Template used by the IP phone for provisioning | Template file name ie. yealinkT4x.ph.xml |
| Model | Phone Model name | Model of the first provisioned phone. Values taken from the `<model>` in the phone templates |
| Router | Routing device used | Empty for local phones. For remote: MAC of parent router phone or SBC ID. For router phones: own MAC. |
| Language | The language used for the phone | Phone language name is dependent on the phone template used |
| Ringtone | The ringtone used by the phone | Ringtone name is dependent on the phone template used |
| QRingtone | The ringtone used for a queue call | Ringtone name is dependent on the phone template used |
| VMEnable | Enable Voice Mail Box for this extension | 0 – Voicemail is disabled, 1 – Voicemail is enabled |
| VMLanguage | Voicemail language | Promptset GUID or Promptset Folder name |
| VMPlayMsgDateTime | Read out date/time of message | 0 – Do not read, 1 – Read in AM/PM Format, 2 – Read in 24hr format |
| VMPIN | PIN number used to access voicemail box | Numeric |
| VMEmailOptions | Email options | 0 – No email notification, 1 – Send Email notification only, 2 – Send Email Notification with voicemail attached, 3 – Send Email notification with voicemail attached, and delete from mailbox |
| VMNoPin | Disable Voicemail PIN authentication | 0 – Disable PIN, 1 – Enable PIN Authentication |
| VMPlayCallerID | Play Caller ID | 0 – Do not play Caller ID, 1 – Play Caller ID |
| RecordCalls | Record all calls | 0 – Do not record, 1 – Record all calls for this extension |
| RecordExternal | Limits recording to external calls only | 0 – Disable, 1 – Enable external calls only recording |
| RecordCanSee | Show Call Recordings | 0 – Not shown to user, 1 – Shown to user |
| RecordCanDelete | Allow deletion of recordings | 0 – Does not allow, 1 – Allows deletion |
| RecordStartStop | Enables user to start/stop call recording | 0 – Disallow, 1 – Allow |
| RecordNotify | Notify user when call recording is made | 0 – No email, 1 – Receive email with link |
| Disabled | Disable Extension | 0 – Enabled, 1 – Disabled |
| HideFWrules | Hide Call Forwarding Rules | 0 – Tab enabled in apps, 1 – Tab disabled |
| DisableExternalCalls | Disable External Calls | 0 – Enabled, 1 – Disabled |
| HideInPhonebook | Do not show in Company phonebook | 0 – Shown, 1 – Not shown |
| CallScreening | Call Screening IVR | 0 – Disable, 1 – Enable |
| PinProtected | Outbound Call PIN Protection | 0 - Disabled, 1 - Enabled (user calls 777 IVR and enters VM PIN) |
| PinTimeout | PIN Protect Timeout | Seconds allowed after entering PIN to start outbound call |
| Transcription | User's transcription settings | Empty = use dept settings; 0 – None, 1 – Voicemails only, 2 – Recordings only, 3 – Voicemails & Recordings |
| AllowLanOnly | Block remote non-tunnel connections | 0 – Do not block (insecure!), 1 – Block connections (recommended) |
| SIPID | SIP ID | Alphanumeric – Must be unique per extension |
| DeliverAudio | PBX delivers Audio | 0 – Does not deliver, 1 – Delivers audio |
| HotDesk | Enables Hot Desking | 0 - Disabled, 1 - Enabled |
| SRTPMode | Secure RTP (SRTP) | 0 – Disabled, 1 – SRTP Enabled, 2 – SRTP Enforced |
| EmailMissedCalls | Send email notification on missed call | 0 – Do not send, 1 – Send |
| MS365SignInDisabled | Disables Microsoft SSO | Leave empty to enable, 1 - Disable |
| MS365CalendarDisabled | Disables Sync calendars and Teams Presence | Leave empty to enable, 1 - Disable |
| MS365ContactsDisabled | Disables Sync personal contacts from M365 | Leave empty to enable, 1 - Disable |
| MS365TeamsDisabled | Disables MS Teams Integration | Leave empty to enable, 1 - Disable |
| GoogleSignInDisabled | Disables Google SSO | Leave empty to enable, 1 - Disable |
| GoogleContactsDisabled | Disables sync personal contacts from Google | Leave empty to enable, 1 - Disable |
| GoogleCalendarDisabled | Disables Sync Calendars from Google | Leave empty to enable, 1 - Disable |
| BLF | Defines the BLF mapping for phones and apps | XML string (see below) |

### BLF Field XML Structure

| BLFType | typeid | text |
|---|---|---|
| BLF | 0 | Target internal extension number |
| SpeedDial | 1 | Target internal extension number |
| CustomSpeedDial | 2 | 3 lines: Number, First name, Last name |
| SharedParking | 3 | SPX (where X = SP0, SP1 ... SP999) |
| QueueLogin | 4 | DEFINED BY ID (LOGGEDINQUEUE / LOGGEDOUTQUEUE) |
| ProfileStatus | 5 | 0=Available, 1=Away, 2=Do Not Disturb, 3=Lunch, 4=Business Trip |
| Line | 6 | Empty |

Example with no BLFs: `<PhoneDevice><BLFS/></PhoneDevice>`

> **Important:** If using Microsoft Office to open CSV files, ensure the MAC address column is NOT presented as a number. Right-click the MAC address column, select "Format Cells..." and choose text.
>
> Alternatively, create at least one example extension with the settings you want, then export your extension to a CSV file containing the columns required. Populate this .csv file with your users, and import it.
>
> **Notes:** Rows describing existing 3CX extensions are skipped. Provisioning information is generated if the phone model matches, otherwise the device will not be added.

*Last Updated: 02 June 2026*
