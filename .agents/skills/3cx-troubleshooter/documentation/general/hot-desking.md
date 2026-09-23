# Hot Desking

> Source: https://www.3cx.com/docs/hot-desking/

## Introduction

Hot Desking allows local or remote (via SBC) connected IP Phones to be used by multiple users, one at a time.

A device currently not in use by a user cannot make outbound calls, unless the dialed number is defined as an "Emergency Number". Once a user has logged in to the hot desking phone (authenticating with extension number and voicemail PIN), the user will be able to make outbound calls.

Hot Desking is available for 3CX PRO Edition and upwards.

## Getting Started

To enable hot desking on an IP phone:

- The IP Phone must be added as a hot desking phone
- A user must be allowed to use hot desking devices from the "Edit User → Options" page

## Add a Hot Desking IP Phone

1. In the Admin Console, go to "Admin → Phones"
2. Click the **Hot Desking Phones** button
3. Click the **Add** button
4. In the Configure your Phone dialog:
   - Select your phone model and enter the phone's MAC address; click the **Next** button
   - Unlisted phone models can not be used for hot desking
5. Select how the phone will connect to 3CX:
   - through an existing SBC or Router Phone
   - directly (only available for router-capable phone models)
   - via the local LAN or VPN
6. Click the **Add Phone** button, followed by the **Close** button in the final dialog
7. Factory-reset your phone; once it reboots, it will automatically provision through RPS (Remote Provisioning Server)
8. If your phone does not support RPS, use manual provisioning; for more information see Supported IP Phones

## Logging In

A hot desking phone with no logged-in user will display the hot desking Dial Code on their screen as a reminder.

Logging into a hot desking device is possible in several ways:

- by pressing the first BLF button (on phone models with BLF support)
- by dialling `*77*`
- by dialling `*77*EXT*`

The hot desking IVR service will answer and prompt the user to enter an extension number (for BLF and `*77*` login) and the extension's voicemail PIN number. On successful log-in a confirmation prompt is played and the device is reprovisioned for the user's extension.

## Logging Out

To logout from a hot desking phone:

- Press the first available BLF button on the phone (all hot desking phones); OR
- Dial `*77*5*`

To prevent unauthorized usage of a hot desking phone outside office hours, you can configure automatic Logout in the Admin Console from "Admin → System → Options".

**Note:** a user can roam directly from one phone to the next without logging out in between; the user can simply use the login dialcodes (`*77*` or `*77*EXT*`) to take over the phone.

## Status

A hot desking phone shows its current status on the display; "HDxxxxx" for phones which are idle, and the user's extension number for logged-in phones.

In the 3CX Admin Console, the Hot Desking Phones page shows each hot desking phone's status with currently logged-in users or idle. An administrator can force a user logout remotely by selecting the extension and clicking the **Logout** button.

## Requirements and Limitations

- STUN is not supported for hot desking devices.
- To optimise the BLF layout with the configured settings in "Web Client → Settings → BLF" on hot desking phones:
  - any empty BLF positions are discarded
  - all displayed BLFs are shifted down by the "Logout" button

## Forbidden at Log-In

If the hot desking login call is rejected with the message "forbidden", review the configured system dial codes in "Admin → System → Dial Codes" to ensure that no other dial code starts with `*7`.

## See also

- Create & Manage Users
- Managing your Phone System
- Configuring the BLF
- Windows Softphone
- iOS app
- Android app

*Last Updated: 28 January 2026*
