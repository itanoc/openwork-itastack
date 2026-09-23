# Configuring and Using the WakeUp/Reminder Call Feature

> Source: https://www.3cx.com/docs/installing-hotel-pbx/

## Introduction

An important feature for a hotel is the ability to configure and launch wake up calls. 3CX has an IVR that allows customers to create their own wake up calls.

## Creating a Wake Up Call Digital Receptionist

This Digital Receptionist (DR) is required to perform Wake-Up calls and manage room status dial codes. To configure a Wake Up DR:

1. From the Admin section go to → "Call Handling" → Select "Add Digital Receptionist".
2. Configure a name for this Digital Receptionist. For example: Wake-Up IVR.
3. In the "Type" box select "Wake-Up".
4. Record an audio prompt that says, for example, "Dear Guest, This is your wake up call". You can also use the "Record on Phone" button to quickly record an audio prompt using an extension.
5. Click "OK" to save.

**Note**: Only 1 Wake-up DR service is allowed.

## Setting a Wake-Up Call / Reminder

### Via Phone (Guest-driven)

A wake up call can be created by the guest of the room without the intervention of the receptionist. In the above example the Wake up call IVR Service was set to IVR 8108. Guests can call the Wake-up Call IVR Service extension and will be greeted with the Wake-up call configuration menu to set the date and time of the wake up call.

If the Wake up call is not answered, the call can be configured to be sent to the receptionist:

1. Go to "Admin > Integrations > Hotel Services"
2. Scroll down to the section "Unanswered Wakeup Calls"
3. Configure where you want the call to be routed in the event that the guest does not answer the wakeup call.

### Via 3CX Web Client (Receptionist Driven)

A wake up call can be scheduled for any room/extension given that the operating extension has the group right to "perform operations" enabled for the group where rooms are located in. With this right the extension can do the following from the web client:

1. Click on any room/extension and select "Set Reminder"
2. Define Time and Date for the wake up call.

## Manage Wake Up Calls / Reminders

From within the 3CX Web Client under the "Panel" node, the receptionists can review all the set or requested reminders for extensions/rooms which are visible to them in the 3CX Web Client. From there they can be edited or deleted.

Per extension maximum 1 wakeup call / reminder can be set and if a new reminder is set existing records will be updated to the new time and date.

## Customizing Language Prompts for Wake Up Calls

The Wake up calls uses prompts that are played to create and schedule wake up calls. 3CX Ships these prompts in English Only. Hoteliers will definitely need to play prompts in their native language. You can simply record the prompts in your native language and replace the existing prompts making sure to keep the format and the file names identical.

The Hotel Prompts are located in the following locations:

- **Windows**: `%programdata%\3CX\Instance1\Data\Ivr\Prompts\Hotel`
- **Linux**: `/var/lib/3cxpbx/Instance1/Data/Ivr/Prompts/Hotel`

Some tips when recording prompts:

- The supported audio file format is: WAV, PCM, 8 KHz, 16 bit.
- Try and keep the size of the .wav files as small as possible.
- Remove silence (more than 10-20 ms) at the beginning and at the end of prompts where possible.
- Avoid abrupt clipping of audio at the end of prompts to avoid audio artefacts (clicks) at the end of prompts.
- Try to create prompts with similar audio characteristics, such as volume, pitch, voice timbre – so that combined phrases sound smooth.
- Keep the file names the same and replace each file with your recorded file.

## See Also

- Configuring the Billing Interface
- The 3CX Hotel Module

**Last Updated**: 21 May 2026
