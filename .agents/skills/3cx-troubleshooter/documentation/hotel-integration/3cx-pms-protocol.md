# 3CX PMS Protocol Specification

> Source: https://www.3cx.com/docs/3cx-pms-protocol/

## Introduction

This chapter details the 3CX PMS protocol, which integrates with PMS hotel software. The 3CX PMS protocol closely resembles the Mitel PMS protocol or Oracle Micros-Fidelio, and therefore it's possible to specify the Mitel PMS (SX2000) or FIAS protocol in the PMS system. The Mitel protocol is further detailed in this chapter whereby the Micros-Fidelio protocol is standardized by Oracle Micros.

## Micros FIAS Vendor Record Specification Form

3CX holds a certification from Micros-Fidelio after completing the interoperability program.

## Mitel General Protocol Information

The PMS/System bi-directional (through half-duplex) link uses the ENQ/ACK/STX-text-ETX/ACK protocol.

The PMS to system transmission sequence is:

The transmission of the message is complete.

There are timing restrictions imposed on the transmission sequences: The maximum time to wait for the ACK after a STX + msg + ETX transmission is 3 seconds.

### PMS to System Transmission

After receiving an ENQ character from the PMS, the system responds within three seconds with either an ACK or an NAK. The ACK indicates the transmission was successful. The NAK indicates there was a transmission error, or that the system is busy. The system generates a hotel log indicating such an error occurred.

After sending the ACK, the system is immediately ready to receive the STX, message text, and ETX. Within three seconds of receiving the ETX, it responds with either:

- **ACK** indicating the transmission was successful, and all of the message fields are valid.
- **NAK** indicating there was an error in either the transmission itself, in one of the message fields, or in the syntax of the message (specifically STX, ETX, function code and status code. For example, CHK3 is sent instead of CHK1). The system generates a hotel log indicating this error occurred.

The PMS is able to retry sending only the message txn (STX, message text and ETX) three more times without prefacing it with an ENQ message first. The PMS then discards the transaction.

## PMS Format Specification

The messages have the following general format:

## Check In/Out Messages

The message has the following format:

- **X**: Is the Check In/Out status code
  - ASCII character `1` for Check In
  - ASCII character `0` for Check Out
- **SP**: Is the ASCII blank character.
- **n**: is an extension number digit.

**Note**: Extension numbers less than five digits long are filled with space characters (ASCII 32, HEX 20), not zeros (ASCII 48, HEX 30). If the message received from the PMS is invalid, the system returns an NAK (an ASCII character for Negative Acknowledge).

**Example - Check In** (for extension 100):
```
STX CHK1   100 ETX
```
Where STX = 2, ETX = 3, resulting the following message `2CHK1   1003`

## Name Message

This message is sent from the PMS and is used to display the Guest name on the phone.

The Name message has the following input format:

- **NAM**: Is the name function code.
- **NAME**: Is a character of the name (maximum 21 characters).
- **n**: Is an extension number digit.

The length of the name (up to 21 characters) is left-justified, with blanks used for padding. The characters can be upper or lower case, and may also include numeric characters. First and last names may be given (separated by a comma placed anywhere but the 1st and 21st location), but if only one name appears it is recorded as the surname by default. The first name in the string must be the last name or surname, followed by the first name. If only one name is given, the 21st character is a blank (the maximum size of a name is 20).

Use of the string operation code allows for addition and deletion of a specific name against an extension. The system allows more than one name to be added against a station. Most situations usually have just one name associated with a station number.

The String Operation code is the first byte of the status code, and may be one of these options:

- **Addition**: The name is ADDED to the current list of names against this station. If there is no name against this number, a new telephone directory entry is created.
- **Replacement**: The name is used to REPLACE the first alphabetical name against this number. All other names against this number are not altered.

If an invalid message is received from the PMS, the system returns an NAK.

## Wake Up Messages

The PMS system can inform the system when to set a wake up call for a particular guest station.

The wake up message has the following output format:

- **t**: Is the wake-up time.
- **n**: Is an extension number digit.

The wake up time is specified in 24 hour time. All four characters, filled with ASCII blanks, represent a deletion of the wake up time (time format: HHmm).

**Example**: wake up call at 23:30 to extension 100:
```
2MW 2330 1003
```

## DND Message

The PMS system can inform the PBX when to set the DND status for a particular guest station by sending the following message.

The DND message has the following format:

**STATUS CODE**:
- `1` - DND ON
- `0` - DND OFF
- **SP** is the ASCII blank character.

**Example**: set DND ON for extension 302:
```
2DND1   3023
```
- STX Value = 2
- ETX Value = 3
- ENQ = 5
- ACK = 6
- NACK = 21

## Message Registration Message

Each time a hotel extension makes a trunk call, the system sends a message to the PMS to update the total count of outside calls made against the guest room. No distinction is made between local and long-distance calls. Message Registration works by counting the number of meter pulses made over the duration of the call.

The Message Registration message has the following output format:

- **SP**: Is the ASCII blank character.
- **n**: is an extension number digit.

The status code in this case is a fee. This is the one exception to the length of the status code, being 4 bytes instead of 2.

## Station Restriction Message

A Station Restriction message can be used to establish call restrictions. When this message is sent from the PMS to the system, it brings previously programmed Call Restrictions into effect.

**Note**: Emergency Services (911/999) and internal calls are never restricted.

The Station Restriction message has the following format:

- **RST**: Is the Station Restriction function code.
- **X**: Is an extension or suite number digit.
- **S**: Is one of the following status codes:
  - `0` - Internal
  - `1` - Local
  - `2` - Long Distance

- STX Value = 2
- ETX Value = 3
- ENQ = 5
- ACK = 6
- NACK = 21

## Maid Status Message

The maid status message is used to allow cleaners to set the status of the room via the phone. The maid status message is triggered by a call from the room in question and by entering the special feature code, followed by the appropriate code to specify the status of the room.

For example, dialing `*682` from the room will trigger a maid status message to the PMS that will set the status of the room to clean.

The Maid Status Message has the following format:

```
STX STS X SP n N nnn ETX
```

- **X**: Is the maid status code.
- **SP**: Is the ASCII blank character.
- **n**: Is the station number digit (up to 5 digits).

When a Feature code is dialled, the system sends both a Function and Status code to the PMS, and the PMS interprets the codes in the following way:

| Message Occupancy Condition | Code |
|----------------------------|------|
| Maid Present               | STS1 |
| Clean                      | STS2 |
| Not Clean                  | STS3 |
| Out of Service             | STS4 |
| To be Inspected            | STS5 |
| Occupied/Clean             | STS6 |
| Occupied/Not Clean         | STS7 |
| Vacant/Clean               | STS8 |
| Vacant/Not Clean           | STS9 |

**Last Updated**: 18 July 2022
