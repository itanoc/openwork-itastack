# Complete Guide to Call Detail Records (CDR)

> Source: https://www.3cx.com/docs/call-detail-record-guide/

## Introduction

This guide provides an exhaustive explanation of how the Call Detail Record (CDR) is structured within the cdroutput table, enabling dashboard creation from Grafana and other BI Tools.

## Identification & Structure Fields

These fields define the overall call flow and provide unique identification for each CDR.

- **cdr_id**: A unique identifier for the specific CDR record. Example: 00000000-01db-aef6-c109-60ec0000004c
- **call_history_id**: A unique identifier for the entire call flow. A call flow comprises a set of CDRs that share the same call_history_id.
- **main_call_history_id**: Identifier for joined call flows (same as call_history_id if not joined).
- **source_participant_id** and **destination_participant_id**: Identifiers indicating call routing between participants.

Note: All these identifiers are provided in UUID format, where the first 4 bytes are 0, followed by 8 bytes of UTC timestamp, followed by 4 bytes of internal auto incrementing identifier assigned by the call manager. The internal identifier is reset to 1 on restart.

## Relationship & Routing Fields

These fields establish the relationship between CDRs, showing how new CDRs relate to previous ones in the call flow.

- **base_cdr_id**: The identifier of the previous CDR (by cdr_id) that is being modified by the current CDR.
- **originating_cdr_id**: The identifier of the CDR (by cdr_id) that initiated a new routing branch.
- **continued_in_cdr_id**: The identifier of the CDR (by cdr_id) of this record's immediate successor in the call flow.

## Creation Reason Fields

- **creation_method**: The action causing CDR creation. See Possible Values List below.
- **creation_forward_reason**: Reason for call forwarding. See Possible Values List below.

## Participant Information Fields (Source & Destination)

- **source_entity_type** and **destination_entity_type**: Type of participating entity (e.g. extension, queue, IVR, external_line).
- **source_dn_type** and **destination_dn_type**: Directory number type.
- **source_dn_number** and **destination_dn_number**: Directory Number. In the case where entity_type or dn_type is "script", this can contain the dialcode for the Call Processing Script.
- **source_dn_name** and **destination_dn_name**: Directory Name for Queues, Ring Groups, IVRs, Extensions, Trunks.
- **source_participant_name** and **destination_participant_name**: Derived from SIP Display Name headers or from contact lookup.
- **source_participant_phone_number** and **destination_participant_phone_number**: Derived from SIP User headers.
- **source_participant_trunk_did** and **destination_participant_trunk_did**: DID number for inbound trunk calls.
- **source_participant_is_incoming** and **destination_participant_is_incoming**: Boolean field indicating the direction of the call for the participant.
- **source_participant_is_already_connected** and **destination_participant_is_already_connected**: Boolean field indicating whether the participant was already connected at the beginning of the CDR.
- **source_participant_group_name** and **destination_participant_group_name**: Department name for the participant; in Multi-Company mode, this is effectively Tenant name.
- **source_participant_billing_suffix** and **destination_participant_billing_suffix**: Billing details for accounting purposes.
- **source_presentation**: Display name shown to destination.

## Termination Reason Fields

- **termination_reason**: Reason the call ended. See Possible Values List below.
- **termination_reason_details**: Additional termination reason details. See Possible Values List below.
- **terminated_by_participant_id**: Participant who terminated the call.

## Call Timestamp Fields

- **cdr_started_at**: The UTC time when the CDR was initiated.
- **cdr_ended_at**: The UTC time when the CDR was finished.
- **cdr_answered_at**: The UTC time when the connection between source and destination was established.

Note: All these timestamp fields are in UTC, provided in the format "YYYY-MM-DD HH:MM:SS.mmmmmm+00".

## System Fields

- **processed**: Flag indicating if the CDR has been processed.
- **migrated**: Flag indicating if the CDR has been migrated.
- **offload_id**: Identifier for external storage offloading.

## Possible Values Lists

### source_entity_type and destination_entity_type

- echo_test - the echo test endpoint
- endcall - entity which represents the destination reported by the call manager for farewell message
- extension - internal extension
- external_line - external line (trunk)
- fax - The participant is leaving a fax
- inbound_routing - Destination participant for the call_init CDR when a call is initiated by a trunk
- ivr - Digital Receptionists
- outbound_rule - This entity does not have an associated DN
- paging_group - Ring Group with Paging strategy
- queue - Queues
- ring_group_hunt - Ring Group with Hunt strategy
- ring_group_ring_all - Ring Group with Ring All strategy
- script - Call Processing Scripts
- service_call - Set when the call manager implements internal processing of a dialcode
- unknown - The destination does not exist or is not identified
- vmail_console - Voicemail special menu
- voicemail - The participant is leaving a voicemail

### source_dn_type and destination_dn_type

- bridge - Bridges (Master & Slave Bridges)
- callback_test - Call Back Test
- conference - Conference Server
- echo_test - Echo Test Call
- extension - Internal Extension
- specialmenu - System Extension Voicemail
- fax - Fax includes 3CX Main Fax and other FAX
- group - Departments
- ivr - Digital Receptionists
- paging_group - Ring Group with Paging strategy
- parking_orbit - Parking Orbits
- provider - Trunks (Providers & Gateways)
- queue - Queues
- ring_group_hunt - Ring Group with strategy hunt
- ring_group_ring_all - Ring Group with strategy all
- script - Call Processing Scripts
- shared_parking - Shared Parking
- unknown - The destination does not exist or is not identified
- vmail_console - Voicemail special menu

### creation_method

- call_init - The initial CDR for a new call
- pickup - A participant picked up a call
- divert - A call was diverted (redirected)
- route_to - A call was routed to a new destination
- transfer - A call was transferred
- join - A participant was joined into an existing call (attended transfer)
- barge_in - A participant barged into a call
- fork - A new call flow was created based on base_cdr_id

### creation_forward_reason

- none, no_answer, busy, holiday, office_time, out_of_office, break_time, polling, by_caller_id, by_did, no_destinations, user_requested, forward_all, not_registered, callback_requested, callback

### termination_reason

- continued_in, redirected, rejected, cancelled, src_participant_terminated, dst_participant_terminated

### termination_reason_details

- timeout, deflected, not_found, not_available, target_disabled, caller_disabled, line_busy, busy, no_answer, terminated_by_originator, license_limit_reached, server_error, forwarding_loop, no_destinations, external_call_disabled, no_route, destination_prohibited, caller_blacklisted, feature_disabled, pin_is_required, invalid_dialcode, by_caller_id, by_did, invalid_destination, source_line_busy, disabled, no_access, declined

## Practical SQL Examples

### Agent Performance

**1. Average Call Handling Time by Agent in "Marketing" Department**

```sql
SELECT
    source_participant_name AS agent_name,
    AVG(EXTRACT(EPOCH FROM (cdr_ended_at - cdr_answered_at))) AS average_handling_time_seconds
FROM cdroutput
WHERE (source_entity_type = 'extension' OR destination_entity_type = 'extension')
    AND cdr_answered_at IS NOT NULL
    AND cdr_ended_at IS NOT NULL
    AND (source_participant_group_name = 'Marketing' OR destination_participant_group_name = 'Marketing')
GROUP BY agent_name
ORDER BY average_handling_time_seconds;
```

**2. Calls Handled per Agent**

```sql
SELECT
    source_participant_name AS agent_name,
    COUNT(DISTINCT call_history_id) AS calls_handled
FROM cdroutput
WHERE (source_entity_type = 'extension' OR destination_entity_type = 'extension')
    AND cdr_answered_at IS NOT NULL
GROUP BY agent_name
ORDER BY calls_handled DESC;
```

**3. Agent Utilization Rate**

```sql
WITH AgentCalls AS (
    SELECT
        source_participant_name AS agent_name,
        cdr_started_at,
        cdr_ended_at,
        cdr_answered_at,
        CASE WHEN cdr_answered_at IS NOT NULL THEN 1 ELSE 0 END AS was_answered
    FROM cdroutput
    WHERE (source_entity_type = 'extension' OR destination_entity_type = 'extension')
)
SELECT
    agent_name,
    SUM(EXTRACT(EPOCH FROM (cdr_ended_at - cdr_started_at))) AS total_call_time_seconds,
    SUM(CASE WHEN was_answered = 1 THEN EXTRACT(EPOCH FROM (cdr_ended_at - cdr_answered_at)) ELSE 0 END) AS total_talk_time_seconds,
    (SUM(CASE WHEN was_answered = 1 THEN EXTRACT(EPOCH FROM (cdr_ended_at - cdr_answered_at)) ELSE 0 END) / SUM(EXTRACT(EPOCH FROM (cdr_ended_at - cdr_started_at)))) AS utilization_rate
FROM AgentCalls
GROUP BY agent_name
ORDER BY utilization_rate DESC;
```

### Queue Performance

**1. List all lost queue calls**

```sql
SELECT c.*
FROM public.cdroutput AS c
WHERE c.destination_entity_type = 'queue'
AND c.termination_reason IN ('src_participant_terminated', 'dst_participant_terminated')
ORDER BY c.main_call_history_id DESC, c.cdr_id DESC
```

**2. List all queue failed callbacks**

```sql
SELECT agent.*
FROM public.cdroutput AS callback
INNER JOIN public.cdroutput AS agent ON agent.cdr_id = callback.continued_in_cdr_id
WHERE callback.destination_entity_type = 'ivr'
AND callback.destination_dn_number = 'QCB'
AND callback.termination_reason_details = 'polling'
AND agent.termination_reason != 'continued_in'
ORDER BY agent.main_call_history_id DESC, agent.cdr_id DESC
```

### Call Duration & Analysis

**1. Calculate the average call duration for answered external calls**

```sql
SELECT AVG(EXTRACT(EPOCH FROM (cdr_ended_at - cdr_answered_at))) AS average_duration_seconds
FROM cdroutput
WHERE source_entity_type != 'external_line'
    AND destination_entity_type = 'external_line'
    AND cdr_answered_at IS NOT NULL
    AND cdr_ended_at IS NOT NULL;
```

**2. Find the longest internal calls**

```sql
SELECT call_history_id, source_dn_number, destination_dn_number,
    (cdr_ended_at - cdr_answered_at) AS duration
FROM cdroutput
WHERE source_entity_type != 'external_line'
    AND destination_entity_type != 'external_line'
    AND cdr_answered_at IS NOT NULL
    AND cdr_ended_at IS NOT NULL
ORDER BY duration DESC
LIMIT 10;
```

### Call Flow & Routing Analysis

**Identify call transfers and the participants involved**

```sql
SELECT c1.call_history_id,
    c1.source_participant_name AS original_caller,
    c1.destination_participant_name AS original_destination,
    c2.destination_participant_name AS transferred_to
FROM cdroutput c1
JOIN cdroutput c2 ON c1.call_history_id = c2.call_history_id
WHERE c1.creation_method = 'call_init'
    AND c2.creation_method = 'transfer'
    AND c2.base_cdr_id = c1.cdr_id;
```

### Specific Agent/Queue Performance

**1. Calculate the number of calls handled by each queue**

```sql
SELECT destination_dn_name AS queue_name, COUNT(DISTINCT call_history_id) AS calls_handled
FROM cdroutput
WHERE destination_entity_type = 'queue'
    AND cdr_answered_at IS NOT NULL
GROUP BY destination_dn_name
ORDER BY calls_handled DESC;
```

**2. Identify calls where a specific extension was the source and the call was not answered**

```sql
SELECT call_history_id, destination_dn_name, termination_reason
FROM cdroutput
WHERE source_dn_number = 'YOUR_EXTENSION_NUMBER'
    AND termination_reason IN ('no_answer', 'timeout');
```

**3. Count the number of inbound calls to queues that were abandoned**

```sql
SELECT
    destination_dn_name AS queue_name,
    COUNT(DISTINCT call_history_id) AS abandoned_calls
FROM cdroutput
WHERE destination_entity_type = 'queue'
    AND source_entity_type = 'external_line'
    AND termination_reason = 'src_participant_terminated'
GROUP BY destination_dn_name
ORDER BY abandoned_calls DESC;
```

### Error and Failure Analysis

**1. List calls that failed due to "no route"**

```sql
SELECT call_history_id, source_participant_name, destination_participant_name
FROM cdroutput
WHERE termination_reason_details = 'no_route';
```

**2. Count calls terminated due to license limits**

```sql
SELECT COUNT(*) AS license_limit_terminations
FROM cdroutput
WHERE termination_reason_details = 'license_limit_reached';
```

### Call Termination Analysis

**1. Count the different termination reasons for all calls**

```sql
SELECT
    termination_reason,
    COUNT(*) AS termination_count
FROM cdroutput
GROUP BY termination_reason
ORDER BY termination_count DESC;
```

**2. Drill down into specific termination reason details**

```sql
SELECT
    call_history_id,
    source_participant_name,
    destination_participant_name
FROM cdroutput
WHERE termination_reason_details = 'timeout';
```

## See Also

- CDR - [Call Data Records](https://www.3cx.com/docs/cdr-call-data-records/)

## Last Updated

This document was last updated 27 May 2026
