# Inbound Rules - Routing Incoming Calls (Troubleshooting DID Numbers)

> Source: https://www.3cx.com/docs/manual/inbound-did-call-routing/

## Troubleshooting DID Number Routing

If calls to the DIDs you configured are not forwarded as expected:

1. Click on the **"Activity Logs"** option in the "Dashboard" of the 3CX Admin Console to see server activity and log entries for received calls and their destination number.
2. Call a configured DID number and refresh the "Activity Log", in Medium or Verbose logging level, looking for lines similar to:

In Medium logging level `"called=XXXXX"` indicates the DID as received from the Trunk, whereas "121" is the internal Destination Number (e.g. extension) configured to receive calls for the incoming DID.

In Verbose logging level the DID received can be seen in the `"To: <sip:XXXXX@YYYYYY>"` INVITE header.

3. Analyze the "To" header carefully to ensure that the configured DID number is present in the header, e.g. `"<sip:35712000000@3CXPhone System>"`. Some providers use the "Request Line URI" field.
4. Reconfigure the number if needed.

## See Also

- Configuring a VoIP Provider / SIP Trunk for more information on source identification.
- IVR/Digital Receptionist Configuration
- How to Reformat your Caller ID

*Last Updated: 02 June 2026*
