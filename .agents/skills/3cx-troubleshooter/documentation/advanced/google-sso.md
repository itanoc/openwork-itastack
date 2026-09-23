# Configuring Google SSO Single Sign-On

> Source: https://www.3cx.com/docs/manual/google-sso/

## Introduction

Set up Google integration to allow single sign-on (SSO) using Google email accounts.

## Step 1: Create a Google Project

1. Navigate to the [Google Console](https://console.developers.google.com/projectselector2) and log in with your organization or personal account.
2. Click on **"CREATE PROJECT"** and complete the project information:
   - Project name - enter the project's name, e.g. pbx-integration.
   - Location - select the correct organization (if applicable).
3. Click **"Create"**.

## Step 2: Setup OAuth Consent Screen App

Now set up the OAuth Consent Screen App in this project.

1. Go to **"APIs & services > OAuth consent screen"**.
2. Select the appropriate 'User Type' and click **"CREATE"**:
   - Internal - sign-on is limited to Google Workspace users within your organization.
   - External - users can use Google Accounts external to your organization.
3. Under 'App information', enter your app name (e.g PBX Integration) and use the drop-down box to select a user for the designated support email address.
4. Scroll down to 'Developer' contact information and enter an email address.
5. Click **"Save and Continue"**.
6. On the next 'Scopes' screen, scroll down and click **"Save and Continue"**.
7. On 'Test users', click **"Save and Continue"**. Click **"Back to Dashboard"**.
8. If you selected the 'User Type' as 'External', click **"PUBLISH APP"** and **"CONFIRM"**.

## Step 3: Obtain Your 3CX URI

1. Navigate to the 3CX Admin Console
2. You must have either 'System Administrator', or 'System Owner'.
3. Navigate to **"Integrations > Google"**.
4. Copy the integration URI to a notepad.

## Step 4: Complete Google URI Set Up

1. Navigate back to the Google Console and select **"Credentials"**
2. Click **"+ Create Credentials"** and select **"OAuth client ID"** from the list.
3. Use the drop-down list for the 'Application type' and select **"Web application"**.
4. Enter a name (e.g PBX Integration), scroll down to the 'Authorized redirect URIs' section, and click **"+ ADD URI"**.
5. Paste your previously copied 3CX URI and click **"CREATE"**.
6. Copy your 'Client ID' and 'Client Secret' to a notepad and click **"OK"**.

## Step 5: Finalize Your 3CX Configuration

1. Navigate back to your 3CX Admin Console and paste your 'Client ID' and 'Client Secret' into the appropriate fields.
2. Click Save.
3. Google SSO will automatically be enabled for all users.
4. If you want to disable it for certain users you can do so from the User > Options page.

## See also

- Read more about [setting up your team](https://www.3cx.com/docs/manual/create-extensions/)
- [Configure SSO for Microsoft](https://www.3cx.com/docs/manual/microsoft-365/)
