# Variables used in the IP Phone Provisioning Templates

> Source: https://www.3cx.com/docs/phone-provisioning-variables/

The 3CX Phone Provisioning Templates make use of a set of variables which are replaced by the extension's details when an extension is provisioned. There are situations where you might need to customize the Phone Provisioning Templates as explained in '[Editing the Phone Provisioning Templates](https://www.3cx.com/docs/custom-ip-phone-templates/)'.

The following table documents the variables used in the 3CX Provisioning Templates.

| VARIABLE | DESCRIPTION | COMMENTS |
|---|---|---|
| %%blf1%% | BLF followed by digit 1, 2, 3, etc. | The BLF extension placeholder used to provision a specific phone key. |
| %%blffirstname%% | First name of selected extension used for BLF. | Displayed on BLF key/sidecar LCD |
| %%blflastname%% | Last name of selected extension used for BLF. | Displayed on BLF key/sidecar LCD |
| %%blfno%% | The extension number of your BLF or Speed Dial | Target number for BLF, Speed Dial, Queue Login, Profile Status, Shared Parking |
| %%blktime%% | Backlight timeout | Timeout for phone display dimming |
| %%codec1%% - %%codec4%% | Codec value priority 1-4 | Specifies preferred codec order |
| %%datestyle%% | The date format of the IP Phone | Format of date shown on display |
| %%defringtone%% | The default ringtone of the IP Phone | Ringtone for most calls (ext-to-ext) |
| %%DESKPHONE_PASSWORD%% | Phone Web login password | Also used for CTI calls authentication |
| %%DKtype%% | Yealink specific - DSS Key type | Speed Dial, BLF, Shared Parking etc. |
| %%dstEnableDisable%% | Enable/disable DST settings | Legacy |
| %%extension_auth_id%% | Extension SIP Authentication ID | |
| %%extension_auth_pw%% | Extension SIP Authentication Password | |
| %%extension_first_name%% | Extension First Name | |
| %%extension_last_name%% | Extension Last Name | |
| %%extension_number%% | Extension Number | |
| %%firmware%% | Firmware file name | |
| %%langlcdUI%% | Language for phone LCD Screen | Yealink specific |
| %%langwebUI%% | Language for phone's web UI | Yealink specific |
| %%langwebUI2%% | Language for phone's web UI | Yealink model specific |
| %%Line%% | Yealink internal - line ID for BLF | Always set to 1 for Yealink |
| %%lldpenabled%% | Enable LLDP | Enable/disable LLDP feature |
| %%local_sbc_ip%% | Session Border Controller IP address | Proxy IP of 3CX SBC |
| %%local_sbc_port%% | Session Border Controller port | SIP port of 3CX SBC |
| %%logo_filename%% | Logo filename | Name of custom logo file |
| %%logo%% | Custom logo path | Path including folders and file name |
| %%mac_address%% | The MAC address of the phone | Used for phonebooks and device config file name |
| %%missedled%% | Power LED behavior for missed call | Flash on/off |
| %%mwiled%% | Power LED behavior for voicemail | Flash on/off |
| %%multicastenabled%% | Enable Multicast Listening | Used in Multicast Ring Groups |
| %%multicastrgip1%% | Listening address for Multicast Ring Groups | |
| %%multicastrgport1%% | Listening port for Multicast Ring Groups | |
| %%multicastrgname1%% | Multicast Ring Group Label | |
| %%multicastrgipport1%% | Listening address and port for Multicast Ring Groups | Some Snom models need combined variable |
| %%param::DIALCODEPROFILE%% | Dial Code value from 3CX config | Used to change user profile status. Default: \*3 |
| %%param::PBXPUBLICIP%% | Public IP Address/FQDN of the 3CX Phone System | |
| %%param::pickup%% | Pick up code from 3CX config | |
| %%param::sipport%% | The SIP Port of the 3CX installation | |
| %%param::time_ntp_server%% | NTP server used | |
| %%param::time_timezone_grandstream%% | Time zone format for Grandstream Phones | |
| %%param::time_timezone_grandstreamexec%% | Time zone format for Grandstream Executive phones | |
| %%param::time_timezone_aastra%% | Time zone format for Aastra phones | |
| %%param::time_timezone_cisco79x0%% | Time zone format for Cisco79X0 phones | |
| %%param::time_timezone_cisco79x1%% | Time zone format for Cisco79X1 phones | |
| %%param::time_timezone_cyberdata%% | Time zone format for CyberData devices | |
| %%param::time_timezone_fanvil%% | Time zone format for Fanvil phones | |
| %%param::time_timezone_htek%% | Time zone format for Htek phones | |
| %%param::time_timezone_linksys%% | Time zone format for Cisco Phones | |
| %%param::time_timezone_snom%% | Time zone format for SNOM phones | |
| %%param::time_timezone_yealink%% | Time zone format for Yealink phones | |
| %%payload1%% - %%payload4%% | Payload values for provisioning codecs | Can be local or external |
| %%pbx_ip%% | The IP Address/FQDN of the 3CX Phone System | |
| %%PHONE_IP%% | The IP address of the phone | |
| %%PHONE_WEB_PASSWORD%% | The Web login password of the phones | |
| %%phonesipport%% | The phone's local SIP port | Legacy - used for STUN phones |
| %%PickupValue%% | Value for PICKUP code | Default value: \*20\* |
| %%PROVLINK.HOST%% | The FQDN of the 3CX Phone System | |
| %%PROVLINK.PATH%% | The Provisioning Path of the System | |
| %%PROVLINK.PORT%% | The HTTP Port of the 3CX installation | |
| %%PROVLINK%% | Phone provisioning default URL | Contains FQDN and Provisioning port |
| %%PROVLINKLOCAL.HOST%% | Host part of phone provisioning Local URL | |
| %%PROVLINKLOCAL.PATH%% | Provisioning folder path of local non-secure URL | |
| %%PROVLINKLOCAL.PORT%% | Port part of phone provisioning local non-secure URL | |
| %%PROVLINKLOCAL.PROTOCOL%% | Provisioning protocol | |
| %%PROVLINKLOCAL%% | Phone provisioning Internal/Local URL (HTTP) | |
| %%queuecrt1%% (queuecrtX) | IF statement for custom queue ringtones | |
| %%queueid%% | Custom Queue ringtone ID | Used when custom ringtones per queue is enabled |
| %%queueringtone%% | Default Queue ringtone | Used when default ringtone for all queues is enabled |
| %%queueringtonevalue%% | "Alert-Info" text sent to IP Phone | Used with custom ringtones per queue |
| %%rtp_port_max%% | RTP port range Maximum value | Legacy - used for STUN phones |
| %%rtp_port_min%% | RTP port range Minimum value | Legacy - used for STUN phones |
| %%scrsavertime%% | Screensaver timeout | When phone shows screensaver |
| %%timestyle%% | The time format of the IP Phone | Format of time on display |
| %%TimeZoneName%% | Time zone name | Format varies per phone |
| %%userphone%% | SNOM specific - function key behavior | |
| %%value%% | Value to configure a BLF key | Documented in each template header |
| %%vlanpcenabled%% | Enable VLAN on PC port | |
| %%vlanpcportid%% | PC port VLAN ID | |
| %%vlanpcportpriority%% | PC port VLAN Priority | |
| %%vlanwanenabled%% | Enable VLAN on WAN port | |
| %%vlanwanportid%% | WAN port VLAN ID | |
| %%vlanwanportpriority%% | WAN port VLAN Priority | |
| %%vm_number%% | The Voicemail Extension number | Provisioned for VM button on phone |
| %%VMPIN%% | Extension Voicemail PIN Number | Used by some doorphones as remote unlock DTMF code |
| %%XFERmethod_Value%% | DSS transfer method | Blind or attended transfer |

Last Updated: 26 May 2026
