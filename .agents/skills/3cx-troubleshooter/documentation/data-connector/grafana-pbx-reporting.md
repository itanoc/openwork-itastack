# Grafana Reporting Configuration Guide

> Source: https://www.3cx.com/docs/grafana-pbx-reporting/

Deploying 3CX Grafana Visualisations from Grafana Marketplace

## Introduction

The 3CX Grafana Visualisations are available on the Grafana Marketplace, allowing you to deploy prebuilt 3CX dashboards quickly and easily. This guide applies to 3CX Version 20, Update 7 (SP7) and later.

The Data Connectors feature requires a 16SC or higher license.

## Prerequisites

Before deploying the 3CX Grafana Plugin, ensure the following are configured:

- A working Data Connector (see guides for):
  - Google Big Query
  - PostgreSQL
  - MySQL
  - Microsoft SQL Server
- Data Transfer options enabled for the metrics you intend to visualize in Grafana (e.g., Call History (CDR), System Metrics, etc.).

## Step 1: Register for Grafana

Visit Grafana and register for a new account (any tier, including the Free Plan, is supported).

If creating a new account, set up your Grafana Stack - this will be the base URL where your dashboards are hosted.

## Step 2: Add Your 3CX Data Source

In this example, we'll use MySQL. For other databases, refer to the relevant Data Connector documentation.

From Grafana "Home" expand "Connections" and choose "Add new connection". Select "MySQL Datasource" (or your chosen connector type).

Choose to "Add new data source"

Name and add all the relevant details for your Database Connection, before choosing "Save & Test" to confirm. You should use a Database User with only SELECT permission for the 3CX tables.

You might wish to further restrict access to your database by using the Allow-List IPs provided by Grafana.

## Step 3: Setup the Plugin

Navigate to the Plugin Marketplace from Grafana Home->Administration->Plugins and data->Plugins

On the 3CX Plugin page, click on Install.

When Installation completes (a few seconds to a couple of minutes) the Enable button appears. A page refresh might be needed. Once it's visible, click on it.

The page will refresh and a new 3CX (& Configuration) option will appear under "More Apps". Go to Configuration and choose the Data Source that was created earlier. If a compatible Data Source is chosen, a Green check appears and "Publish dashboards" becomes available. Click on this to proceed.

## Step 4: View the Dashboards

The page should refresh automatically and open the Dashboards list under the 3CX App.

The Dashboards will also now be available in a 3CX folder under the main Dashboards section.

Clicking on any will immediately load the available data and begin displaying it.

## Step 5: Multi-System Deployments and Customisation

If you wish to monitor multiple 3CX instances within the same Grafana Stack (domain) or make customisations to the provided templates, you can make copies of them by using the Export function. It's found at the top of each Dashboard view. You can then import them from the main Dashboards panel. You will be asked to choose a new Unique identifier for this Dashboard within your Stack, as well as which Database (of the same type as the original deployment) to connect to.

## Step 6: Alerting

Grafana allows you to set Alert triggers for all tracked metrics. As an example here is how to add an Alert for High CPU Usage.

Within the "Health and Performance" Dashboard, choose "New alert rule", found in the "+" menu.

Name your alert and define the basic parameters that will be monitored.

Follow on with the next steps configuring various meta-parameters for the Alert, such as Folders and Tags, as well as the Alert recipients and text, and Runbook URL.

## See Also

- Connecting 3CX to AWS RDS PostgreSQL & Grafana
- Visual Call Reports in MS Excel & Google Sheets
- Complete Guide to Call Detail Record (CDR)
- Complete Guide to Call Detail Record (CDR) Billing

**Last Updated**: 15 January 2026
