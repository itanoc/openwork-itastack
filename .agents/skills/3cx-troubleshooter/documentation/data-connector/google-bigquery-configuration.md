# Google BigQuery Configuration Guide

> Source: https://www.3cx.com/docs/google-bigquery-configuration/

Connecting 3CX to Google BigQuery & Grafana

## Introduction

This guide outlines the steps to connect 3CX to a Google BigQuery database and use Grafana to visualize your data with dashboarding and reporting capabilities.

## Step 1: Configure Google Workspace to Enable Google BigQuery

Navigate to 3CX Admin Console > Integrations > Google and select "Configure"

The following screen will appear, where you will need to enable "Integrate with Google BigQuery for Data Export" and connect. You will be asked to enter your Google login credentials and once ready follow the instructions to go back, which will take you back to the 3CX Google Workspace configuration.

## Step 2: Configure Data Connector on 3CX

On 3CX, navigate to Admin Console > Integrations > Data Connector

Select "Google BigQuery"

Choose the Data Types to transfer

Set the frequency for data transfer from the PBX to the Google BigQuery

Save the configuration and click the "Test" button on your PBX to verify the connection to the Google Big Query database and confirm that you receive a success message. If the test fails, review the error message thrown and login to Google BigQuery console to ensure that the instance is created correctly and there are no error messages on Google side.

**Note**: You must have a 16SC+ license to use 3CX Data Connector.

## Step 3: Enable Google APIs for Grafana

The following Google APIs need to be enabled for the plugin to work:

- BigQuery API
- Cloud Resource Manager API

In your Google Console, navigate to API & Services > Credentials, click on Create Credentials and select Service Account.

Give a unique name for your service account and click on Create and Continue.

Add the BigQuery Data Viewer and BigQuery Job User roles and click on Done.

Back in Credentials, under Service Accounts click on the newly created Grafana service account.

Navigate to Keys Tab and click on Add Key, select the JSON key type and click on create. The key will be created and saved on your PC, which you will later use in Grafana to authenticate to Google BigQuery.

## Step 4: Connect Grafana to Google BigQuery

From your Grafana console navigate to Administration > Plugins, search for and click on the Google BigQuery Plugin.

Click to Install the plugin.

Create a BigQuery Data Source and authenticate:

- Log in to your Grafana instance (e.g., Grafana.com or your self-hosted Grafana).
- Go to the Grafana configuration menu (gear icon) and click "Data Sources" and click "Add data source".
- Search for and select "Google BigQuery".
- In Google BigQuery Configuration, under authentication select Google JWT File in Authentication type, click on Upload JWT token and select the Google service account key that you downloaded on step before.
- Click "Save & test" and verify that you receive a "Data source is working" message.

## See Also

- Connecting 3CX to AWS RDS PostgreSQL & Grafana

**Last Updated**: 28 May 2026
