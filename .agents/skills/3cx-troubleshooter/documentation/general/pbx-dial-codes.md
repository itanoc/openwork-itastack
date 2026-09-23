# PBX Dial Codes

> Source: https://www.3cx.com/docs/pbx-dial-codes/

## Introduction

Dial codes are key/number combinations used to access functions within the phone system directly from your phone. The administrator can change these from the Admin Console "System" > "Dial Codes". This section describes the default dial-codes.

## Parking

### To park a call

On an established call to your extension start the "blind transfer procedure" and transfer the call to `*0[0-9]`. For example, `*01` will place the call in the parking orbit 1, `*02` will place the call in the parking orbit 2, etc.

### To pick up a parked call

Dial `*10` to `*19` where the 0 – 9 is the park orbit number the call was parked in. For example, calling `*11` will pick up any calls parked in parking orbit 1.

### Parking Multiple Calls

Parking orbits support parking of multiple calls in the same orbit. When unparking, you can add the extension number from which the call was parked to be sure that you un-park the correct call.

For example, if extension 100 parked a call in park 0, this call can be picked up by another extension by keying in `*10100`. Omitting the extension number un-parks the longest parked call in that orbit.

## Pickup a call

If you hear a particular extension ringing, and the owner is not able to take the call, use Call Pickup:

- `*20*<extension number>` — Redirects the active call from the specified extension to your extension.
- `*20*` (send) — Redirects the longest ringing call to your extension.

## Change Profile Status

Change your status using: `*3[0-4]`

- `0` = "Available"
- `1` = "Away"
- `2` = "Do not Disturb"
- `3` = "Custom 1"
- `4` = "Custom 2"

Example: dialing `*31` from extension 100 changes the profile status of extension 100 to Away.

## Connect to Voicemail of extension

To leave a message in the voicemail box of a particular Extension: `*4<extension number>`

Example: `*4100` leaves a voicemail message in the voicemail box of extension 100.

## Log extension IN/OUT of queues

- `*62` — Log extensions into queues
- `*63` — Log extensions out of queues

## Paging / Intercom

The intercom feature allows you to make an announcement to another extension without requiring the other party to pick up the handset. The message will be played via the other phone's speaker.

Prefix the extension you wish to call with `*9`. Example: `*9100` to intercom extension 100.

> **Important:** Intercom dial code is disabled by default. Configure a dial code in "System" > "Dial Codes" > "Paging". Must be unique and not conflict with other dial codes.

## Billing Code

Allows you to tag specific calls with Billing codes for reports. Use `**` (default).

Format: `Destination-Number**<billing code>`

Example: `17771231233**3265`

This billing code can be used as a filter in 3CX Reports (Call Report with filter to destination: Match Billing Code).

## Mobile Transfer Agent Service

Allows users to manage forwarded calls to their mobile phones. Requires "Ring my mobile simultaneously" to be enabled in the extension's forwarding rule.

### Feature 1: HOLD

Press `*80` — Puts the current call on hold.

### Feature 2: UN-HOLD

Press `*81` — Un-holds a current held call.

### Feature 3: Blind Transfer to an Extension

Press `*82# number/extension #`

Example: `*82#105#` or `*82#099219095#` — Blind transfer of current call to extension 105 or number 099219095.

### Feature 4: Attended Transfer

1. Answer the incoming call from the PBX
2. Press `*83# number/extension #` — Puts current call on hold and calls that number
3. Press `*84` to complete transfer once the recipient answers

### Feature 5: Conference

1. Answer the incoming call from the PBX
2. Press `*83#number/extension#` — Puts current call on hold and calls that number
3. Once picked up, dial `*85` — Creates a 3-way conference

## Block Outbound Caller ID

Hide outbound caller ID on a specific call by prepending with `*5`.

Example: `*5004412345678`

## Hotdesking

### Logging In

Dial `*77*` followed by the extension number. If the call gets disconnected with "forbidden" make sure no other dial code starts with `*7`.

### Logging Out

Dial `*77*5`.

## Hotel - Maid Codes

Maid codes tell PMS systems the status of a guest room. Requires PMS integration and a Wake-up Call IVR Service.

To configure: Go to "Call Handling" → "Add Digital Receptionist" → Set "Type" to "Wake up". Only one Wake Up IVR can be configured.

Dial from the room phone: `*68<room status>`

### MITEL Protocol room status codes

- Maid Present
- Clean
- Not Clean
- Out of Service
- To be inspected
- Occupied/Clean
- Occupied/Not Clean
- Vacant/Clean
- Vacant/Not Clean

### Micros Fidelio room status codes

- Dirty/Vacant (1)
- Dirty/Occupied (2)
- Clean/Vacant (3)
- Clean/Occupied (4)
- Inspected/Vacant (5)
- Inspected/Occupied (6)

## See Also

- How to use 3CX Hot Desking

*Last Updated: 04 June 2026*
