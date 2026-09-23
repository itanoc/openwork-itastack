# Configuring the Billing Interface

> Source: https://www.3cx.com/docs/billing-interface/

**Important Note**: The billing interface needs to be configured only if using the 3CX PMS integration (which emulates Mitel) with Mitel-compatible property management systems such as Innquest roommaster and Brilliant / HotelConcepts. It is not required if using the Fidelio protocol (FIAS) with Micros-Fidelio and Protel.

## Introduction

3CX Phone System provides billing information so that you can charge your guests accordingly for each phone call. This information can be sent to a text file or to a TCP port so that you can integrate it with your PMS software.

Call costs are calculated and inserted into a CDR (Call Data Record) which is outputted to disk as a text file or sent to a particular host at a particular port. In this manner it is easy to integrate with a hotel software system or call accounting software.

## Adjusting Billing Costs

3CX Phone System calculates call costs based on destination number and call duration. You will need to enter the cost for each country, for national calls and for mobile calls. The default billing rate is 1.0.

To edit call rates:

1. In the 3CX Admin Console, go to "Reports" > "Call Costs".
2. Edit the rates and click "OK".

When calls are made to external numbers, they are checked against this prefix table. If a match is found then the cost is calculated as follows:

```
Total Cost = Talking time * Rate
```

where a rate of 1.0 means 1.0 per 60 seconds of talking time (1 minute).

## CDR Output

The CDR feature provides four output channels:

1. One CDR file for all calls.
2. One CDR file per call.
3. Active Socket output (initiates connection).
4. Passive Socket Output (waits for connection).

To Enable the CDR feature, from the 3CX Management Console go to "Admin" -> "Advanced" > "CDR".

Select the "Enable CDR" checkbox and select the type of output you prefer.

You can choose to the "Remove comma delimiters" Checkbox.

## CDR Output Location

- **Windows**: `%allusersprofile%\3CX\Instance1\Data\Logs\CDRLogs`
- **Linux**: `/var/lib/3cxpbx/Instance1/Data/Logs/CDRLogs`

In the case of Server/Passive socket or Client/Active Socket, the IP Address and port must be specified in the management console.

## Customizing CDR Output Format

If you need to alter the format with which the CDRs are outputted, press "Manage CDR output fields". This will display a dialog whereby you can enable or disable call output fields, modify the order of the fields and also choose whether the output should have a dynamic length or a fixed length. (Useful to support PMS Systems that cannot be modified).

Read more on CDR and how to manage CDR output fields here.

## See Also

- The 3CX Hotel Module
- Configuring the WakeUp/Reminder call feature
- How to use CDR - Call Data Records

**Last Updated**: 21 May 2026
