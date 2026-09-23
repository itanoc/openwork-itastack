# Complete Guide to Call Detail Record (CDR) Billing

> Source: https://www.3cx.com/docs/call-record-billing-guide/

## Introduction

This guide explains how the Call Detail Record (CDR) Billing record is structured within the cdrbilling table, enabling dashboard creation from Grafana and other BI Tools.

## Billing Terms and Conditions

Billing applies only to outgoing external participants. This is the cost of the external participant in the specific CDR in relation to the PBX. Billing is stored in the cdrbilling table, which is linked to the parent cdroutput table by the cdr_id field. Only answered CDRs can have billing. The **"Call Cost"** parameters (see [Setting up the Billing Interface](https://www.3cx.com/docs/billing-interface/)) must be configured correctly for billing data to be stored in the cdrbilling table.

Thus, participants with these parameters of CDR can have billing:
- source_entity_type / destination_entity_type = external_line
- source_participant_is_incoming / destination_participant_is_incoming = false
- cdr_answered_at = NOT NULL

Call Detail Record (CDR) Billing is independent of [CDR - Call Data Records](https://www.3cx.com/docs/cdr-call-data-records/) and doesn't provide the billing cost field. Instead, the billing cost can be calculated for each participant based on the billing code, billing rate, and billing duration.

## Fields

- **cdr_id**: A unique identifier for the specific CDR record. This field is related to the cdr_id field in the parent table cdroutput. Example: 00000000-01db-aef6-c109-60ec0000004c
- **source(destination)_bill_code**: Participant billing code. Value of the column "Prefix" from the "Call Costs" settings.
- **source(destination)_bill_rate_name**: Participant billing rate name. Value of the column "Country Name" from the "Call Costs" settings.
- **source(destination)_bill_rate**: Participant billing rate. Value of the column "Rate" from the "Call Costs" settings.
- **source(destination)_bill_duration**: Participant billing duration. Based on the talking duration (CDR cdr_answered_at, cdr_ended_at fields). Example: 00:00:30.000000 (30 seconds)
- **migrated**: Reserved. Not used

## Practical SQL Examples

### CDR Participant Cost

```sql
SELECT
        -- all cdr fields
        c.*,
        -- all billing fields
        b.*,
        -- source participant cost
        b.source_bill_rate * EXTRACT(EPOCH FROM b.source_bill_duration::interval)/60 AS source_participant_bill_cost,
        -- destination participant cost
        b.destination_bill_rate * EXTRACT(EPOCH FROM b.destination_bill_duration::interval)/60 AS destination_participant_bill_cost
FROM public.cdroutput AS c
LEFT JOIN public.cdrbilling AS b ON
        b.cdr_id = c.cdr_id
ORDER BY c.cdr_id;
```

Dashboard Application: This query calculates the cost of billing for both participants in each CDR.

## See Also

- How to use [CDR - Call Data Records](https://www.3cx.com/docs/cdr-call-data-records/)
- Complete [Guide to Call Detail Record (CDR)](https://www.3cx.com/docs/call-detail-record-guide/)

## Last Updated

This document was last updated 15 May 2025
