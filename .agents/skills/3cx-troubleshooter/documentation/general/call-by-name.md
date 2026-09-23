# Call By Name Functionality

> Source: https://www.3cx.com/docs/call-by-name/

## Callers Can Dial an Extension Directly

Whilst a digital receptionist prompt is playing, a caller can enter the extension number to call directly and connect to the extension without going through a receptionist. Simply instruct your callers in the voice prompt on how to use this feature, e.g. "Welcome to Company XYZ. If you know the extension number to call, you can enter it now. Otherwise, for sales press 1. For support press 2."

## Route by Name

You can also direct callers to the **Route by Name** function. This allows them to find the person they wish to speak to by entering the first letters of the person's first or last name on the phone dial pad. The route by name feature requires:

- A self-identification message for the user. Users without a self-identification message are not accessible via the route by name feature.
- Users can not have a first/last name with Unicode characters.
- All symbols except [2-9] and [A-Z] used in the first & last names are ignored for this function.
- The Route by Name option must be made available to a Digital Receptionist as one of the menu options.

### Self-identification message

To record your self-identification message through your WebClient, 3CX App or IP Phone:

1. Dial your voicemail menu (Default 999).
2. Enter your voicemail PIN number.
3. Go to the options menu ('9' key).
4. Press '5' key to record the self ID message.
5. Record your name only, i.e. "Sarah Jones."

## How it works

The Route by Name feature uses the first or last name of the users, as requested by the caller in the IVR, and compares it with the caller's input (as entered on the phone keypad).

The following translations for symbols are used (ITU E.161 standard pattern):

- Press **2** for A B C 2
- Press **3** for D E F 3
- Press **4** for G H I 4
- Press **5** for J K L 5
- Press **6** for M N O 6
- Press **7** for P Q R S 7
- Press **8** for T U V 8
- Press **9** for W X Y Z 9

The caller has to type a minimum of three digits ('0' – '9') to call a user. Digits '0' and '1' are ignored, but can be used to call users with short last names (for example, to access someone with the last name 'Li', you can type '540').

Each key press matches all the assigned letters in that slot, e.g. pressing 4 as the first input will match all first/last names starting with any of G, H, I or 4.

After the user has entered three digits, the IVR queries the phone system database for matching users. If there are no matching users, you hear "extension not found." If there is only one matching user, the IVR redirects the call to the chosen extension. If there are more than one matching user, the IVR will wait for additional digits to be entered by the caller, for 2 seconds.

If the IVR is waiting for additional digits (more than one matching user) and the caller presses any digit, the IVR will add this digit to the current input and check currently matching users. If there are no matching users, the IVR will play "extension not found."

If the user does not input any more digits (2 seconds elapsed or '#' has been pressed) and more than one user is matching, then the IVR will play: "To call Christina Roberts press 0. To call Christopher Robinson press 1. To exit press pound, (#)." In this example 'Christina Roberts' and 'Christopher Robinson' are the self-identification prompts of the matching users.

## See also

- Read more on Call Handling: Office Hours & IVR.

*Last Updated: 29 May 2026*
