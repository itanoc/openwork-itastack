# How to Enable Callback on Unsuccessful Blind Transfer

> Source: https://www.3cx.com/docs/blind-transfer-callback/

3CX Phone System includes an automatic callback feature in Blind Transfer. If you perform a blind transfer and the recipient of the call is busy, then the call will automatically return back to you. This way you can inform the caller that the person they are trying to contact is busy and proceed to transfer to another destination.

## Enabling the Callback Feature

To enable the callback feature, from the 3CX Admin Console, go to "System" > "Options" > "General" > "System Settings" section.

1. Enable the option **"Enable transfer back on busy"**.
2. Set a timeout in seconds during which the caller will wait for the destination to answer before the call bounces back. For example 30 seconds.
3. Click "Save" to apply.

## Using the Callback Feature

- When you perform a blind transfer to an extension which is busy, the call returns back to you instead of following the forwarding rules of the extension.
- When an extension is configured to accept more than one call at the same time (under "Users" > "Edit user" > "Call Forwarding" > "General options" > "Accept multiple calls"), the call will not bounce back, but will instead be handled according to that extension's forwarding rules. If the recipient rejects the transferred call it will be directed to his/her voicemail.

## See Also

- Call Forwarding
- Time-based routing

*Last Updated: 2 June 2026*
