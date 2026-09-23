# Android: Not getting your calls?

> Source: https://www.3cx.com/docs/android-push-troubleshooting/

On smartphones, notifications of new messages and calls are sent by sending a PUSH notification to the phone, upon which the phone wakes up and receives the call or message. Like other apps, the 3CX Android App relies on receiving these PUSH notifications. These PUSH notifications are generally sent out by Google. 3CX supports Google PUSH only for the moment.

If you are receiving the calls but it's not ringing when your phone is in sleep mode, then you are not receiving PUSH notifications. There are several checks you can do to try and fix this.

It's obvious, but check first that the 3CX App has network connectivity. You can switch off mobile data for some apps, obviously it needs to be on for 3CX to work.

## Check 1: Are You Using the Right Phone, Latest Android and 3CX?

To have good results, you will need to use a quality phone with a recent version of Android:

- Android 10+ - Android 10 or above. Should really be at least Android 11.
- Recent quality phone - Ensure you have a quality phone from Google, Samsung, Oppo, Motorola, Oneplus. No-name China phones can cause problems.
- 3CX V18 - Upgrade to v18 to get significant improvements for mobile phones with 3CX.

Please note: 3CX only supports the latest versions of phones, Android and 3CX. The app can be installed on Android 8 or 9, but will not be supported or troubleshooted.

## Check 2: Switch Off Battery Optimization (REQUIRED for Android 14 & 15)

Some versions of Android have battery optimization settings turned on that terminate background apps, including 3CX. Switch that off:

1. Go to Android Settings > Apps > 3CX
2. Tap on "Battery" or "App battery usage"
3. Set to "Unrestricted" or "Don't optimize"

## Check 3: Switch on Background Data for the 3CX App

Ensure background data is enabled:
1. Go to Android Settings > Apps > 3CX
2. Tap on "Mobile data & Wi-Fi" or "Data usage"
3. Enable "Background data"

## Check 4: Using Android 13 or 14? Give the App Full Permissions

On Android 13+:
1. Go to Android Settings > Apps > 3CX
2. Tap "Permissions"
3. Ensure "Notifications" and "Phone" are allowed
4. On Android 14, also grant "Full Screen Notifications"

## Check 5: Is 'Do Not Disturb' Enabled?

### In-App DND
Check that DND is not enabled within the 3CX app itself.

### Android OS DND
Check that Android's Do Not Disturb mode is not active or that 3CX is allowed to bypass DND.

## Check 6: Pre-installed or Third-party Cleaner Apps

Third-party "cleaner" or "battery saver" apps may kill background processes. Disable or uninstall such apps, or add 3CX to their exception lists.

## Check 7: Got a Firewall in Front of 3CX? Open The Ports!

Ensure the following ports are open for PUSH notifications to work:
- TCP 443 (HTTPS)
- TCP 5001 (3CX Tunnel)
- UDP 5090 (3CX Tunnel)

The PUSH server (Google FCM) must be reachable from the 3CX server.

## Check 8: Grant Permission for Full Screen Notifications

On newer Android versions:
1. Go to Settings > Apps > 3CX > Notifications
2. Enable "Full screen notifications" or "Show as pop-up"

## Check 9: Accurate Time Synchronisation

Ensure the Android device's date and time are set to automatic (network-provided). Time mismatches can break PUSH notification delivery.

## If All Else Fails - Enable the "Keep Active" Feature

In the 3CX App:
1. Go to Settings > Advanced
2. Enable "Keep Active" - this keeps a partial wake lock to maintain connectivity

Note: This may increase battery consumption.

## Send Us Technical Feedback

If the issue persists, send logs from the 3CX App:
1. Go to Settings > Advanced > Send Logs
2. Describe the issue and include the time of the missed call
3. Send the diagnostic report to 3CX Support

## See Also

- [3CX iOS App Installation Guide](https://www.3cx.com/user-manual/installation-iphone/)
- [3CX Android App Installation Guide](https://www.3cx.com/user-manual/installation-android/)
