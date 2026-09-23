# The 3CX Hotel Module

> Source: https://www.3cx.com/docs/hotel-pbx/

## Introduction

The hotel PBX features are specific for hospitality environments. The following functions can be achieved:

- Check in and Check out of guests (via PMS or 3CX WebClient).
- Setting guest extensions to Do not Disturb.
- Blocking of external calls when a room is not occupied.
- Schedule wake up calls.
- Allows billing of calls to rooms (via Fidelio PMS)
- Allows housekeeping to set room status via the phone

The 3CX Hotel Module can integrate with Hotel software systems / Property Management Systems (PMS) such as Micros Fidelio, roommaster, Hilton and more. This can be done either via a Fidelio or a Mitel compatible interface.

To configure 3CX Hotel services, login to the "3CX Admin console > Integrations > Hotel Services". The 3CX Hotel features are part of the Pro and Enterprise/AI Editions. It operates in the background and allows for integration with the Property Management System. With the integration, many of the functions can be triggered from within the PMS software.

## Check In / Out Operations

The 3CX Hotel module performs the following functions at check in / out:

### Check In Operations

- Sets Extension Name.
- Enables the extension to allow outbound calls.
- Deletes all voicemail messages.
- Clears Do Not Disturb (DND) status.
- Updates phonebook files for IP Phones.
- Re-provisions supported IP Phones.

### Check Out Operations

- Sets name to blank to show that there is no one in the room.
- Disables outbound calls on extension.
- Deletes all voice mail messages and recordings.
- Clears the Do Not Disturb (DND) status.
- Updates phonebook files for IP Phones.
- Re-provisions supported IP Phones.

## Wake-up Calls

The system allows for wake up calls to be scheduled. This can be set by the guest from the room without the receptionist's intervention. The guest calls a Wake-Up call service IVR, and follows the prompts to set a wake-up call. At the scheduled time, the system will call the guest and play a predefined message when the guest answers the call. Wake up calls can also be scheduled via PMS.

## Billing

The system will log calls from each room and show call costs based on the costs configured in the 3CX Admin Console.

The system can output a configurable Call Data Record (CDR) for each call. The CDR can be sent to a separate text file (one call per text file), to a text file containing all calls, or to a TCP port. For each case, the exact format can be customized.

## Set Room Status

This function allows cleaners to set the status of the room via the phone. The maid status message is triggered by a call from the room in question and by entering the special feature code, followed by the appropriate code to specify the status of the room.

**Note**: The codes are different depending on the PMS system used. 3CX PMS supports 9 Maid code states whilst Fidelio supports 6.

For example: Dialling `*682` from room 101 will trigger a maid status message to the PMS that will set the status of room 101 to clean. In this example `*68` is the special feature code (configurable) and `2` is the status code "Clean".

Further information on how to use the dial codes to set a room status can be found in the Dial Code documentation.

## Mini Bar

This function allows hotel staff to record mini-bar consumption via the phone. The mini-bar message is triggered by a call from the room in question and by entering the special Maid Code feature code, followed by the item code and count of each consumed item.

**Note**: Hotels define their own item codes (up to 4 digits) based on their needs.

For example: Dialing `*68*1*2*2*3` from room 101 will trigger a mini-bar message to the PMS, indicating that the guest in room 101 consumed 2 items with code 1 and 3 items with code 2. In this example, `*68` is the Maid Code feature code (configurable), `1` and `2` are item codes, and `2` and `3` are the respective counts.

## See Also

- Configuring the Billing Interface
- Configuring the WakeUp/Reminder call feature
- PBX Dial Codes

**Last Updated**: 11 November 2025
