# Reports (Call Reporting)

> Source: https://www.3cx.com/docs/manual/call-reports/

## Introduction

3CX includes powerful call reporting that enables you to analyze team performance and customer service levels.

Gain valuable insights into your organization's customer-facing communications. Call reports serve as a strategic tool for optimizing processes and elevating overall efficiency by allowing you to make well-informed decisions regarding your processes. Pinpoint trends, monitor performance, and implement data-driven strategies to refine your communication procedures.

## AI Summary and Sentiment

When AI is enabled, the following reports include an AI summary and sentiment score:

- **Call Log** — shows Transcription, Summary and Sentiment analysis score.
- **Inbound Calls** — A log of Incoming calls
- **Outbound Calls** — A log of Outbound calls
- **Extension Statistics** — includes average sentiment score and filters by score.
- **Ring Groups** — Aggregation of sentiment score per ring group.
- **Queue Answered Calls By Waiting Time** — Aggregation of sentiment score per call

## Report Categories

### Logs

- **Call log** — A log of all calls
- **Chat log** — A log of all chats
- **Audit log** — A log of all administrative actions

### System

- **Inbound Rules** — Shows all inbound call routes, i.e. which DIDs route to which extensions.

### Queue Statistics

- **Abandoned Queue Calls** — Number of calls that entered a queue but were not answered.
- **Queue Answered Calls by Waiting Time** — Answered calls based on hold time.
- **Queue Callbacks** — Number of callers who requested a callback.
- **Queue Failed Callbacks** — Number of callbacks that the queue serviced and failed.
- **SLA Statistics** — Total calls received and number/percentage of missed calls according to SLA.
- **SLA Breaches** — How many calls have been waiting too long per configured SLA time.
- **Queue Performance Overview** — Service level summary for queues: calls received, handled, not handled. Breaks down statistics by agent.
- **Detailed Queue Statistics** — Detailed queue performance: calls answered/abandoned/total/% serviced, talk time (overall and mean), callbacks.
- **Team Queue General Statistics** — Focuses on team performance rather than individual agent performance.

### Agent Statistics

- **Agent in Queue Statistics** — Individual agent's statistics per queue.
- **Agent Login History** — Queue login and logout history of a specific agent.

### Ring Group Statistics

- **Ring Groups** — Ring group performance: call duration, total answered/abandoned calls, talk time, wait time.

### Extension Statistics

- **User Activity** — Answered/Unanswered calls by time period.
- **Call Distribution** — Incoming/Outgoing calls by time period.
- **Call Cost by Extension Dept** — Call costs per extension in a department.
- **Extension Statistics** — Individual extension statistics: total calls, total talk time, etc.

### Chat Statistics

- **Queue Chat Performance** — Chats received, answered, lost, resolved per queue.
- **Queue Agents Chat** — Individual agent chat performance per queue.
- **Abandoned Chat** — Number of chats never answered.

## Scheduling a Report

1. Log in to your 3CX Web Client. Navigate to the Admin Console and click on the "Reports" option in the left-hand menu. (Only Managers, Supervisors, Group Owners and System Owners can see this.)
2. Click on the type of report you want to generate. Click the funnel icon.
3. Select the date range (from/to) and call type. These fields may differ depending on the report type.
4. Click "Save/Schedule".
5. Enter a name for your report and choose how often you want to receive it. The time zone of the group will be applied.
6. All scheduled reports for a single user are aggregated into one email.
7. Click "OK". Your report will be emailed with a report link and a .CSV file attached, usable as a data source for BI reporting (e.g. Power BI).

## See Also

- Call Routing: Office Hours & IVR
- Call Queues & Ring Groups
- Setting up Live Chat
- Manage Customer Queries: Live Chat, WhatsApp, Facebook & SMS/MMS
- Configuring WhatsApp

*Last Updated: 21 May 2026*
