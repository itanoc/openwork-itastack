# AWS RDS PostgreSQL Configuration Guide

> Source: https://www.3cx.com/docs/aws-postgresql-configuration/

Connecting 3CX to AWS RDS PostgreSQL & Grafana

## Introduction

This guide outlines the steps to connect 3CX to an AWS RDS PostgreSQL database and use Grafana to connect and visualize your data with dashboarding and reporting capabilities.

## Step 1: Create an RDS PostgreSQL Database in AWS

Navigate to AWS Console and search for RDS and click on Databases.

Create Database and select "Standard create" and under engine options, select "PostgreSQL"

Configure Database by setting a unique name for your database, followed by setting a master username and password.

In Instance Configuration, select the DB instance class (size and resources) according to your workload requirements.

In Connectivity, we will need to choose the VPC where you want to launch your DB instance and select a DB subnet group.

In Public access, if you are planning to allow Grafana, you'll likely need to set this to "Yes". However, be aware of the security implications. If possible, restrict access using security groups.

VPC security group, select an existing security group or create a new one. The security group must allow inbound traffic to the PostgreSQL port (default: 5432) from the IP address(es) of your PBX and Grafana instance.

**Important Security Note**: Instead of allowing access from "Anywhere" (0.0.0.0/0), which is a security risk, it is highly recommended to:

- Specify IP addresses of your PBX and Identify the Grafana servers IPs.
- Configure the security group to allow inbound traffic only from those specific IP addresses which will significantly improve security.

Database Authentication, select the option to allow connection using password authentication and specify Port: 5432 (You can change it if necessary.)

Database Options, give the name of the database to be created on your DB instance

Review your configuration and create a database and once the database is created and its status is "Available", go to "Databases" and click on your DB instance and copy the "Endpoint". This is the address you'll use to connect to the database.

## Step 2: Configure Data Connector on 3CX

On 3CX, navigate to Admin Console > Integrations > Data Connector

Select "PostgreSQL Database" and enter the following:

- **Host**: The RDS endpoint you copied in Step 1.
- **SSL Validation**: Whether the PBX should try to verify the remote SSL certificate.
- **CA Certificate**: Shown only if SSL Validation is selected. Upload CA certificate.
- **Port**: The database port (default: 5432).
- **Database Name**: The name of the database you created in RDS.
- **Username**: The master username you configured in RDS.
- **Password**: The master password.
- **Data Types**: Choose what data you want to have transferred.
- **Frequency**: Set the frequency for data transfer from the PBX to the RDS instance.

Save the configuration and click the "Test" button on your PBX to verify the connection to the RDS database and confirm that you receive a success message. If the test fails, double-check the endpoint, port, database name, username, and password. Also, verify the security group rules in AWS.

**Note**: You must have a 16SC+ license to use 3CX Data Connector.

## Step 3: Connect Grafana to the AWS RDS PostgreSQL Instance

Log in to your Grafana instance (e.g., grafana.com or your self-hosted Grafana).

Go to the Grafana configuration menu (gear icon) and click "Data Sources" and click "Add data source".

Search for and select "PostgreSQL".

Configure the data source under "Connection", enter the following details:

- **Host**: Enter the RDS endpoint and port in the format: `your-rds-endpoint.amazonaws.com:5432`
- **Database**: The name of your database.
- **User**: The master username.
- **Password**: The master password.

Click "Save & test" and verify that you receive a "Data source is working" message. If you encounter errors, double-check the connection details, security group rules, and SSL configuration.

## See Also

- Connecting 3CX to Google BigQuery & Grafana
- Connecting 3CX to Standalone PostgreSQL & Grafana

**Last Updated**: 28 May 2026
