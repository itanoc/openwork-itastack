# Troubleshooting DID Number Routing

> Source: https://www.3cx.com/docs/manual/inbound-did-call-routing/

If calls to the DIDs you configured are not forwarded as expected:

1. Click on the "Activity Logs" option in the "Dashboard" of the 3CX Admin Console to see server activity and log entries for received calls and their destination number.
2. Call a configured DID number and refresh the "Activity Log", in Medium or Verbose logging level, looking for lines similar to:

In Medium logging level "called=XXXXX" indicates the DID as received from the Trunk, whereas "121" is the internal Destination Number (e.g. extension) configured to receive calls for the incoming DID.

## Common Issues

### DID Not Recognized

If the DID number received from the provider does not match any configured DID in 3CX:
- Check the format of the DID as configured in 3CX (with/without country code, leading +, etc.)
- Compare against the "called=" value in the Activity Log
- The DID must match exactly as presented by the SIP trunk

### Call Routing to Wrong Destination

- Go to "SIP Trunks" > Select the trunk > "DIDs" tab
- Verify each DID is assigned to the correct destination (extension, queue, IVR, ring group)
- Check that office hours routing is configured correctly if you have different day/night routing

### No Route Found

If the Activity Log shows "No route found" or similar:
- The DID may not be assigned to any destination
- The destination (extension, queue, etc.) may have been deleted
- Check inbound rules for the SIP trunk

### Provider Sending Wrong DID Format

Some providers send DIDs in different formats:
- With country code: 1234567890
- Without country code: 234567890
- With + prefix: +1234567890
- With leading 0: 0234567890

Configure the DID in 3CX to match the exact format the provider sends. You can also use the "DID number matching" option in the SIP trunk settings to adjust how 3CX matches incoming DIDs.

## Troubleshooting Steps

1. **Enable Verbose Logging**: Dashboard > Activity Log > Settings > Verbose
2. **Make a test call** to the DID
3. **Check the Activity Log** for the "called=" value
4. **Verify DID assignment**: SIP Trunks > [Your Trunk] > DIDs
5. **Check destination configuration**: Ensure the destination (extension, IVR, queue) is properly configured and registered
6. **Test with different DID formats**: Add the DID in multiple formats if the provider format is unknown
7. **Return logging to Low** after troubleshooting

## See Also

- [SIP Trunk Configuration](https://www.3cx.com/docs/manual/sip-trunks/)
- [Call Routing with IVR](https://www.3cx.com/docs/manual/ivr/)
- [3CX Log Viewer](https://www.3cx.com/docs/3cx-log-viewer/)
