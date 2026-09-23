# Connecting 3CX Phone Systems (Bridges)

> Source: https://www.3cx.com/docs/manual/connecting-pbx-bridges/

## Introduction

You can connect two remote 3CX Systems together, enabling calls between branch offices for free just by utilizing your existing internet connection. Assign a prefix to the "Bridge", which you will dial to access the other 3CX Phone System. This prefix must be followed by the extension number you wish to reach on the other 3CX Phone System.

Alternatively, you can assign the extensions in Office 1 to start with one number (e.g. 100, 101, 102 where all extensions start with 1), and the extensions in Office 2 to start with a different number (e.g. 200, 201, 202 where all extensions start with 2). This way, users from one office can directly dial the extension number without using a prefix making calling between offices or branches seamless. In this case, when the outbound rule is created, you must ensure that the prefix corresponds to the numbering plan selected and that no digits are stripped.

**New: Both systems must have a fully qualified secure domain name. You cannot use an IP to refer to the master or slave!**

## Creating a Bridge

A bridge must be either a "Master" or a "Slave". First, you create a Master bridge on the 3CX master system, and then a Slave bridge on the 3CX slave system.

### Step 1: Create a Bridge on the Master Phone System

1. In the 3CX Admin Console on the Master phone system, go to the "Voice & Chat" function and click "+Add Bridge" > "Master bridge".
2. Enter a name for the new Master bridge and take note of the virtual extension number. (You will need this number when you create the "Slave" bridge connection so ensure that the virtual extension number generated is not in use on the other 3CX System which will host the "Slave" bridge endpoint.)
3. Specify an "Outbound rule prefix" to be used for this bridge. If for example, you specify "3", then you must dial "3100" to reach extension "100" on the other 3CX Phone System. This prefix is added to the caller number in case the call is not answered, so the called party can easily redial missed calls. (An outbound rule is also required as described in step 8 below)
4. Specify the maximum number of simultaneous calls you want to allow through this bridge.
5. Specify the Authentication password to be used for "Authentication" by the Slave bridge or make a note of the default generated password.
6. The "Remote PBX uses Tunnel" option allows all SIP and RTP traffic to be sent via a single TCP port via the 3CX Tunnel. If enabled, specify the FQDN of the Slave 3CX Phone System, for example "office2.3cx.com" and the remote 3CX Tunnel port. By default this port is 5090.
7. Click "OK" to create the Master bridge.
8. Go to the "Outbound Rules" function and click "+Add" to create a new rule. Enter the rule name and then in "Calls to numbers starting with prefix", specify the same prefix as the "Outbound rule prefix" in point 3 above. In the "Make outbound calls on" section, select the Master bridge you created above in the specified backup route dropdown, select "1" in the "Strip Digits" field (to remove the specified prefix from the dialed number) and press "OK".

> **Note:** Make sure that the specified Master 3CX system settings in "Settings > Security > Allowed Country Codes" are not in conflict with the remote extension number. For example, dialing the remote office extension "3001" (prefix + remote extension) fails due to the 3CX Country Blocking Feature, since calls to the United States (1) are not allowed.

### Step 2: Create a Bridge on the Slave Phone System

1. In the 3CX Admin Console of the Slave 3CX Phone System, go to the "Voice & Chat" function and click "+Add Bridge" > "Slave bridge".
2. Enter a name for the new Slave bridge and assign the same virtual extension number as the one configured on the Master 3CX Phone System bridge.
3. Specify the "Outbound rule prefix" used for the slave bridge to be the same as the one specified for the Master bridge.
4. Specify the "Authentication Password" configured on the Master 3CX Phone System.
5. In the "Remote PBX" section enter the FQDN of the Master 3CX Phone System and the remote port (default 5060).
6. If the remote Master PBX uses a tunnel connection, enable the "Remote PBX uses SBC/Tunnel Connection" option and verify the port (default 5090).
7. Click "OK" to create the Slave bridge.
8. Go to the "Outbound Rules" function and click on "+Add" to create a new rule. Enter the rule name and then in "Calls to numbers starting with prefix", specify the same prefix as the "Outbound rule prefix" in point 3 above. In the "Make outbound calls on" section, select the Slave bridge you created above in the specified backup route dropdown, select "1" in the "Strip Digits" field (to remove the specified prefix from the dialed number) and press "OK".

> **Note:** Make sure that the specified Slave 3CX system settings in "Settings" > "Security" > "Allowed Country Codes" are not in conflict with the remote extension number. For example, dialing the remote office extension "3001" (prefix + remote extension) fails due to the 3CX Country Blocking Feature, since calls to the United States (1) are not allowed.

### Step 3: Configure Presence Across the Bridges

To configure sending and receiving the local extension / user Presence to a remote 3CX system via a specified bridge, go to the "Voice & Chat" function in the 3CX Admin Console and edit the bridge:

- On the "Advanced" tab enable "Publish Information" to broadcast presence to the remote 3CX system.
- You can enable the "Receive Information" option so that local 3CX users can see the Presence of remote office users.
- Now configure the FQDN of the remote 3CX system. (If a tunneled connection is configured, this will be automatically populated). If the webserver of the other 3CX Phone System is running on a non default HTTP/HTTPS port, for example 5001, then you need to specify the port after the FQDN, i.e. "office2.3cx.com:5001".

## See Also

- Find a full guide on the 3CX Tunnel / 3CX Session Border Controller

*Last Updated: 28 May 2026*
