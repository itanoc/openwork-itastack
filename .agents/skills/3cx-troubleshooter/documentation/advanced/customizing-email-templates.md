# Customizing Email Templates

> Source: https://www.3cx.com/docs/customizing-email-templates/

## Introduction

With this powerful feature, you can easily customize all of the email templates within 3CX to suit your needs and preferences.

Whether you want to add your own branding, include links to important resources, or personalize your messages with recipient names and other dynamic content, the **"Email Templates"** feature within the **"3CX Admin Console > Advanced > Templates > Email"** makes it easy.

For instance, you can customize the default Welcome Email Template (the email that is sent out when a new extension is created) with your own text, your own links and even change the From (Display Name) or the first and last name of the recipient, as configured in their extension settings.

Let's take this example and actually change the welcome email to include a from name for the sender, as well as the first and last name of the recipient.

## Step 1: Add a Display Name to your Email

1. Go to **"Advance" > "Templates" > "Email Templates"** tab in the 3CX Admin Console.
2. To add a custom **"From"** name to your email header simply type one in the **"From (display name)"** field and click **"Save"**. This name is displayed in the **"Welcome Email"** as the **"From"** field.

> Note: The 3CX SMTP server does not support alternate **"From:"** names. If using the 3CX SMTP, the **"From (Display Name)"** will always be **"3CX Communications System - %Company Name%"** where %Company Name% is the name under which the License Key is registered.

## Step 2: Customize the Welcome Email Sent to an Extension

1. Locate, in the email template's first few lines, the section that starts with **"Hi,"**. In this example we use the variables for the extension's first name and last name. You can enter in the template any combination of the available email template parameters that can be added to the **"Extension Welcome"** email template, e.g.:

- **"%%EXTFIRSTNAME%%"** - extension's first name.
- **"%%EXTLASTNAME%%"** - extension's last name.
- **"%%EXTNUMBER%%"** - extension number.
- **"%%EXTPIN%%"** - extension's PIN
- **"%%VMNUMBER%%"** - voicemail number.

2. Click on **"OK"** to save the customized template.

The Welcome Email will now include the customized message content.

This is just an example to demonstrate how easy it is to customize your 3CX Email Templates. There are many email templates that can be customized so go ahead, be as creative as you like and have fun with your brand new 3CX Phone System.

## See Also

- See how to [set up your team](https://www.3cx.com/docs/manual/setup-team/)
- More info on [Managing your Phone System](https://www.3cx.com/docs/manual/advanced/)
