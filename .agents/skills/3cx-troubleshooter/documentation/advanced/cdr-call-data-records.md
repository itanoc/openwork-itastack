# CDR - Call Data Records

> Source: https://www.3cx.com/docs/cdr-call-data-records/

## Introduction

3CX Phone System has an inbuilt CDR Service that is able to log phone calls including a record that can be saved to a file, or pushed to another application instantly via TCP.

The record contains various call details such as time, date, duration, source and destination numbers as well as the cost. 3CX goes a step further adding much more information such as call-types, call information, From and To names and final display names crucial when call transfers occur.

## Configuring Output Format

The CDR output format can be configured with the following options:

- **File format**: CSV, XML, or JSON
- **Delimiter**: Comma, semicolon, tab, or custom character
- **Fields**: Select which fields to include in the output

## Enable CDR

To enable CDR in 3CX:

1. Go to **"Dashboard"** > **"Call Data Records"**
2. Enable **"CDR Service"**
3. Configure the output format and delivery method

## Configuring the CDR fields

The CDR can include the following fields:

- Call History ID
- Call start/end time
- Call duration
- Ring duration
- Talk duration
- Source/Destination caller ID
- Source/Destination name
- Call type
- Call direction
- Call status
- Final number
- Final name
- Cost
- And more

## CDR Delivery Methods

3CX supports the following delivery methods for CDRs:

- **Local file**: Save CDR records to a file on the PBX server
- **TCP socket**: Push CDR records to a remote application via TCP
- **FTP/SFTP**: Upload CDR records to an FTP server

## CDR Records Documentation

The CDR table in the PostgreSQL database (cdroutput) contains detailed call records that can be queried directly for advanced reporting and analysis.
