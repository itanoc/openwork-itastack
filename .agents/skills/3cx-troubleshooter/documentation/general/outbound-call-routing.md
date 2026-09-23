# Outbound Call Routing

> Source: https://www.3cx.com/docs/manual/outbound-call-routing/

## Outbound Call Routing Logic

3CX routes calls to SIP Trunks based on criteria the administrator defines in "Outbound Rules". An outbound rule has a set of conditions which will trigger the rule, such as which user or department is calling, the dialed number, or the number length. Once the conditions are met, each rule can have up to 5 routes which 3CX will use if one route fails to process the call. For example, if a SIP trunk is down or if it is at capacity.

Outbound rules are triggered according to their priority. So if you have 5 rules, and a previous rule has been triggered because the conditions were met, any subsequent rules will not apply. You can move outbound rules up or down in the Outbound Rules page.

## Auto creation of Outbound rules

When you create a system wide SIP trunk you proceed to create an outbound rule for it. If the SIP trunk is created within a group and there is no other rule for that group, it will automatically create an outbound rule to route calls via the new SIP trunk. If there is already a SIP trunk and outbound rule configured you must create the outbound rule yourself.

## Conditions are cumulative

**IMPORTANT:** If you specify Extensions and one or more Extension Groups then the rule will trigger if the extension is in the group OR in the list of extensions (cumulative).

## Creating an Outbound rule

1. Go to "Outbound Rules", select "Add", and enter a name for the new rule.
2. Specify the conditions which should trigger this outbound rule:
   - **Calls to numbers starting with prefix** — Any numbers starting with for example "9".
   - **Calls to numbers with a length of** — For example 8 digits, to differentiate between local and national numbers.
   - **Calls from extension(s)** — Define extension(s) or extension range separated by commas and ranges using "-", e.g. `100,102-120`.
   - **Calls from departments** — Specify a whole department by clicking the Add button.
3. In **"Make outbound calls on"** set the routes on which the calls should be placed. If the first route is not available or busy, 3CX automatically tries the next route, until the call can be made or the default "Block Calls" route is reached.
4. Transform the number before routing:
   - **Strip Digits** — removes one or more digits from the called number, e.g. strip one digit to remove prefix "9".
   - **Prepend** — add one or more digits at the beginning of the number.
5. Specify an **'Outbound Caller ID'**. 3CX will set the outbound caller ID although the telecom provider might disregard it.
6. Click "Save" to add the outbound rule.

After creation the rule is added to the bottom of the list (least priority). Use "Move Up" to increase priority.

## Selecting/Skipping Routes

- 3CX selects all available SIP Trunks and Bridges in order (1 to 5).
- Unregistered SIP Trunks (red) are skipped immediately.
- Ringing (180 or 183) does not define a successful call and another SIP Trunk might be selected.
- If a SIP Trunk returns these "busy" SIP messages, the next route will NOT be selected:
  - 486 Busy Here
  - 600 Busy Everywhere
  - 1408 No Response (3CX internal error code)
- A call is "successful" when:
  - 200 OK (Called Party Answered)
  - Cancel (Calling Party ends the call before being connected)

## Notes

- **Early Media and Ringing** — When using more than one route, early media (SIP 183 Ringing) audio streams are dropped and converted to 180. IP phones will play their device ringing tone instead.
- **IP Based SIP Trunks (Peering)** — IP based providers have no registration, so 3CX cannot determine if the trunk is up or not. The status is always "green" and 3CX will try each call before skipping to the next route.

## See also

- Configuring Caller ID Reformatting
- How does 3CX handle inbound calls & call routing
- Connecting 3CX Phone Systems (Bridges)
- How to Enable Callback on Unsuccessful Blind Transfer

*Last Updated: 11 September 2024*
