# Caller ID Reformatting

> Source: https://www.3cx.com/docs/cid-reformatting/

## Introduction

In 3CX, each port/trunk/PSTN gateway or VoIP Provider can format the incoming Caller ID number as specified by the administrator, to have a prefix added, or present a unified number format in inbound and outbound calls.

## CID Building rules

The configuration for inbound and outbound Caller ID formatting is the same. Due to the complexity of this task, basic string operations need to be understood.

- ( ) Brackets - These are used to encapsulate variables and numbers. Each bracket will contain a variable.
- (.*) - This means any sequence or number in a string. This should always be in the last position. Any variables added after this will be ignored.
- 0-9,+ - Digits 0-9 and '+'  - These are used to match a corresponding symbol in a given CID.
- (XXX) - Where X can be any digit from 0-9. Example if a number is 02031234567 and you put (0203) this means that the PBX will search for a string that matches 0203 exactly.
- 1, 2 - 9 - This will be replaced with the content of variable 1, 2, ..9.
- (.) - A dot is a placeholder for any symbol. Example (...) means 3CX matches any 3 digits. If you know that the area code starts with 3 followed by three digits, you can enter (3)(...)

## Configuring Caller ID Reformatting

To configure Caller ID reformatting:

1. Go to **"Voice & Chat"** in the 3CX Admin Console and edit the Port/Trunk that you want to configure.
2. Click on **"Options"** and expand the **"Reformat incoming or outgoing caller ID"** section.
3. In the section **"Inbound"** and **"Outbound"**, create and apply your rules for incoming or outgoing Caller IDs.
4. You can apply more than one rule per direction. Rules have priority, as the first matched rule is applied.

## Examples

### Scenario 1

Company ABC wants all USA international numbers to be formatted to a local number format instead of the international format that is received through the VoIP provider. We want to reformat +12021234567 as 1234567. In this case, we can make a simple inbound Caller ID reformatting rule that states the following:

- Source CID Pattern: +(1)(...)(.*)
- Replace CID Pattern: 3

In this example:
- + will be removed,
- (1) refers to the country code for USA and is considered the first variable - 1
- (...) refers to a 3 digit area code and is the second variable - 2
- (.*) The remaining number and therefore this is the third variable - 3

This means that we are keeping only the 3rd variable - the local number only. So an incoming number that is presented like this: +18135910130 will be shown as 5910130.

### Scenario 2

Company ABC wants to add a 0 to the incoming caller ID number for quick redial purposes. The incoming number looks like this: +18135910130. Plus they would like to format the number to be in national format.

- Source CID Pattern: +(1)(...)(.*)
- New Source CID Pattern: 023

In this example:
- The number ZERO (0) will be prepended to the result
- The PBX will take variable 2 (813) and variable 3 (5910130) to create the result: 08135910130.

## Additional Notes

- Outbound Caller ID reformatting requires the use of the **"OriginatorCallerID"** to be active in the SIP Trunk **"Outbound Parameters"** settings.
- You can specify several re-formatting rules per trunk.
- The re-formatting rule will apply in top-down order.
- These rules will not rewrite the incoming **"From:Display"** value, i.e. if the call has been received with +18135910130, the display will still show this number, while the **"core part"** of the number to be dialed has been updated.

## See also

- [Create outbound rules](https://www.3cx.com/docs/manual/sip-trunks/)
- [Inbound Rules - Routing incoming calls](https://www.3cx.com/docs/manual/inbound-did-call-routing/)
- [Troubleshooting DID numbers](https://www.3cx.com/docs/cid-reformatting/)
- How to configure your [digital receptionist/IVR](https://www.3cx.com/docs/manual/ivr/)

## Last Updated

This document was last updated on 11 September 2024
