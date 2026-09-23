# 3CX Security - Reset Credentials/Passwords

> Source: https://www.3cx.com/docs/pbx-security-credentials/

Actions to take to increase the security of your PBX.

## Introduction

This article takes you through some recommended actions which will increase the security of your PBX to avoid attacks and potential data breaches.

## Action 1: Change Account Credentials

To change any account's password:

1. Log into the 3CX Admin Console
2. Navigate to the user/extension you want to modify
3. Go to the **"General"** tab
4. Enter the new password in the appropriate field
5. Click **"OK"** to save

Also change:
- The **Admin Console** password
- The **System Owner** password
- The **SSH/root** password (for on-premise installations)
- The **Web Client** passwords for all users

## Action 2: Reset Forgotten Credentials

If you forget the Admin Console password:
1. Access the server via SSH/console
2. Run the 3CX configuration tool
3. Use the password reset option

For forgotten Web Client passwords:
- An admin can reset them via the Admin Console
- Users can use the "Forgot Password" link on the Web Client login page (if email is configured)

## Action 3: Limit Access to the 3CX Admin section by IP

Restrict which IP addresses can access the Admin Console:
1. Go to **"Settings"** > **"Security"**
2. Enable **"Restrict Admin Console access to specific IP addresses"**
3. Add the allowed IP addresses or ranges
4. Click **"OK"** to save

## Action 4: Reset User Credentials via Web Client

### Reset Credentials for all Users

To force all users to change their passwords:
1. Go to **"Settings"** > **"Security"**
2. Enable **"Force password change on next login"**
3. All users will be prompted to change their password on next Web Client login

### Allow Users to Change Their Own Credentials

Users can change their own credentials by:
1. Logging into the Web Client
2. Going to **"Settings"** > **"General"**
3. Clicking **"Change Password"**
4. Entering old and new passwords

## Action 5: Use SSO - Google or Microsoft 365

Integrate Single Sign-On for better security:
1. Go to **"Settings"** > **"Microsoft 365"** or **"Google Workspace"**
2. Configure the integration
3. Enable SSO for user authentication
4. This eliminates the need for separate 3CX passwords

## See Also

- [3CX Phone System Anti Hacking – Whitelist/Blacklist](https://www.3cx.com/docs/allow-deny-ip-addresses/)
- [Secure SIP - TLS](https://www.3cx.com/docs/secure-sip/)
