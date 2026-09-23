# 3CX Events Explained

> Source: https://www.3cx.com/docs/event-log/

## Event Reference

| Event ID | Message | Level | TIPS |
|---|---|---|---|
| 102 | Callback to number %1 was requested from Queue %2 by caller %3 | Info | %1 Extension Number, %2 Queue Name, %3 Queue Extension number, %4 Incoming Caller ID Number |
| 103 | Failed Callback to number %1 failed. Queue: %2 [%3] caller: %4 | Info | Check Queue reports to understand if you need more manpower |
| 104 | SLA for this queue has been reached. Caller has been waiting too long. | Info | Queue agents not serving callers on time. Check "Queue Answered Calls By Waiting Time" |
| 105 | Lost Call in Queue %2 (%1) from Caller ID '%3' | Info | Telco issue, caller hangup, or caller ID marked as spam |
| 4097 | Service started | Info | If unexpected, check OS events |
| 4098 | Service got signal to stop: %1 | Info | If unexpected, check who has host access |
| 4099 | Emergency number (%1) is dialed from %2 | Info | Email notification also triggered |
| 4100 | Trunk %1 has changed status to %2 | Info | SIP trunk registration changed (Registered/Failed) |
| 4102 | Trunk SBC '%1' (%2/%3) has changed status to %4 | Info | Check network links between SBC and PBX |
| 8193 | License limit is reached, active calls: %1 | Error | Consider upgrading license for more simultaneous calls |
| 10008 | A new Update is available for 3CX | Info | Perform updates out of office hours |
| 10009 | 3CX was successfully updated | Info | — |
| 10010 | 3CX failed to update | Error | — |
| 10011 | Your 3CX Debian OS was successfully updated | Info | — |
| 10012 | Your 3CX Debian OS failed to update | Error | — |
| 10018 | RPS request for %1 IP Phone of %2 delivered successfully | Info | — |
| 10023 | SSL Certificate has been renewed | Info | — |
| 10025 | 3CX logs and temporary files were deleted to conserve disk space | Info | — |
| 10026 | Your public IP has changed and 3CX updated FQDN records from %1 to %2 | Info | Dynamic IP change. %1=old, %2=new |
| 10027 | Database maintenance task has been finished | Info | — |
| 10028 | Administrator password recovery has been requested | Info | — |
| 10029 | Provisioning file for MAC %2 of user %3 requested by %1 was successfully generated | Info | %1=MAC, %2=Extension, %3=Requestor IP |
| 10030 | Deleting expired PUSH subscription of extension %1, device %2%3 | Info | — |
| 10031 | A backup of your PBX has been successfully completed. Backup name: %1 | Info | — |
| 10032 | 3CX restored successfully | Info | — |
| 10033 | Your license has been successfully activated | Info | — |
| 12289 | Device %1 has reached max amount of calls - Call(%2) | Warning | Max calls reached |
| 12290 | The IP %1 has been blacklisted for %2 sec. Reason: %4 | Warning | Anti-hacking. %3=expiry time |
| 12291 | SIP request (%1) from %2 was rejected. Reason: %3 | Warning | Check message for details |
| 12292 | The IP %1 has been blacklisted for %2 sec. Reason: requests rate too high | Warning | If lawful, whitelist; otherwise permanent blacklist |
| 12293 | Registration at %1 has failed. Destination (%2) not reachable, DNS error | Warning | If multiple services failing, check network |
| 12294 | Call or Registration to %1 has failed. %2 replied: %3 | Warning | Check reply from endpoint |
| 12295 | STUN server %1:%2 could not be reached | Warning | If static IP ignore. If dynamic IP, try changing STUN server |
| 12296 | Call from [%2] to [%1] rejected by Country Blocking Feature [%3] | Warning | Check if call was legitimate. Enable country in Settings > Security > Allowed Country Codes |
| 12297 | There are no RTP ports available for media server to establish Call(%1) | Error | Restart 3CX Services, restart machine, restart firewall/edge device |
| 30006 | Hard Disk is at or near capacity | Warning | Archive recordings, purge call logs, check voicemails, disable verbose logging |
| 30013 | Maximum number of participants reached | Warning | — |
| 30018 | RPS request for %1 IP Phone of %2 NOT delivered | Warning | Phone firmware may be incompatible |
| 30024 | This backup contains a different license key or FQDN | Warning | License key mismatch |
| 30025 | Unknown variable '%1' in template %2 at position %3 | Warning | Check variable names for typos |
| 30026 | Your 3CX Subscription will expire on %1 | Warning | Renew from customer portal |
| 30030 | Failed to send message(s) to provider '%1' from '%2' to '%3' | Warning | Check exception |
| 30031 | Weak %2 detected for %1 | Warning | — |
| 30032 | System is overloaded or locked: %1 login requests skipped | Warning | — |
| 30033 | Your Recordings storage has reached %1 of %2 | Warning | Archive recordings. If quota reached, recordings stop |
| 30034 | Your Voicemail storage has reached %1 of %2 | Warning | Check voicemail quota |
| 30035 | The following service(s) were interrupted: %1 | Warning | Check services |
| 30038 | Live Chat Requests Protection triggered for user from %1 | Warning | %1=IP of user |
| 30039 | Health Report: Firewall check: %1, SIP trunks: %2, Phone Templates: %3 | Warning | Check errors for details |
| 30040 | Provisioning file %2 requested by %1 could not be generated | Warning | Check custom templates |
| 30041 | Phone %1 of extension %2 is behind SBC %3 which has no known local IP yet | Warning | — |
| 30043 | %1 RPS key %2 provided for extension %3 | Warning | Invalid or Expired RPS PIN |
| 30044 | Exception during contact creation | Warning | — |
| 30045 | Unable to parse message from provider %1. Error: %2 | Warning | Provider sending unexpected data |
| 30046 | You need to assign an extension user System/Root privileges | Warning | Assign System Owner role |
| 30047 | Your local IP %1 has been changed to %2 - Please adjust configuration | Warning | IP must be static and controlled |
| 30049 | External calls from ext.%1 is disabled by Administrator | Warning | — |
| 30051 | Unidentified Incoming Call. Review INVITE and adjust source identification: %1 | Warning | Source not trusted. SIP traffic not from expected IP |
| 30052 | There was no user or outbound rule found for the number %1 that %2 dialed | Warning | Create an outbound route for these calls |
| 30053 | A call placed by %1 was terminated due to a loop detected | Warning | Call loops detected. Simplify call flow, rebuild step by step |
| 50011 | SSL Certificate renewal has failed. Error: %1 | Error | Check error, contact support |
| 50014 | Webmeeting WMR Platform is down or not reachable | Error | Wait 30 min, if still down contact support |
| 50015 | WebMeeting has no MCU enabled in that zone | Error | Change region or try later |
| 50020 | Failed to send %1 PUSH to device %2(Ext.%3) | Error | Check exception |
| 50021 | Failed to send %1 PUSH to device %2(Ext.%3). Error from server: %4 | Error | — |
| 50022 | Your 3CX backup failed due to: %1 | Error | Check event reason |
| 50023 | Recording archiving failed due to: %1 | Error | Check event reason |
| 50024 | 3CX restored unsuccessfully. Errors: %1 | Error | Check event reason |
| 50025 | Error while activating license: %1 | Error | Check event reason |
| 50026 | Error sending email with subject '%1' to '%2': %3 | Error | Check event reason |
| 50027 | 3CX Failover is triggered. Reason: %1 | Error | Check event reason |
| 50029 | Call from %1 to %2 dropped - not acknowledged in time | Error | ACK not received. Check firewall port forwarding, dynamic IP |

## See Also

- Advanced System Features
- How to collect logs for 3CX Support

*Last Updated: 22 May 2024*
