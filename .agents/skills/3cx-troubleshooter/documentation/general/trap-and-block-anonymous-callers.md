# How to Check for and Block "Anonymous" Callers

> Source: https://www.3cx.com/docs/trap-and-block-anonymous-callers/

If you want to block calls from "anonymous" callers, you can leverage the "CallerID Blacklist" feature. From the 3CX Admin Console:

1. Go to "Advanced" > "CID Blacklist" and click on "Add".
2. In the "Blacklist" dialog:
   - Set the "Incoming caller ID to be blocked" field to the value "Anonymous" or "anonymous". You can also set the field to `*nonymous` to match both values (The `*` will act as a wildcard).
   - Set the "Description" field for informational purposes.
   - Click "OK" to save.

At this stage, an anonymous call should be rejected correctly.

## Example: Anonymous INVITE

This is a typical INVITE from a caller whose CallerID is hidden:

```
v: SIP/2.0/UDP 169.11.192.162:5080;branch=z9hG4bK-8b2f242058b3802ce60c00f1db2b8201
f: "Anonymous" <sip:anonymous@169.193.176.35>;tag=3727603634-668969
t: <sip:1631xxxxxxx@ss.callcentric.com>
i: 40335387-3727603634-668939@msw1.telengy.net
CSeq: 1 INVITE
Max-Forwards: 13
m: <sip:d499d4130a8ff5ed6ed0238096db60f6@169.11.192.162:5080;transport=udp>
Proxy-Require: privacy
c: application/sdp
l: 268
```

Sometimes your telecom provider will deliver the call with "unknown" or some other text instead of "anonymous". Simply examine the incoming INVITE particularly the "From" field and you can then add or adjust your blacklist rule accordingly.

*Last Updated: 2 June 2026*
