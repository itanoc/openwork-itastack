# Microsoft SQL Server Configuration Guide

> Source: https://www.3cx.com/docs/microsoft-sql-server-configuration/

Connecting 3CX to a Microsoft SQL Database & Grafana

## Introduction

This guide is for systems running V20 Update 7 and provides a concise process to connect your 3CX phone system to a Microsoft SQL database for use with Grafana for data visualization and reporting.

## Prerequisites

- A running Microsoft SQL Server. On Premise or on Azure
- Administrative access to your Microsoft SQL Server
- Access to the 3CX Admin Console
- A 3CX 16SC+ license (required for Data Connector functionality)

## Step 1: Create your SQL Database on Azure or On Premise

### Creating an SQL Database on Azure

1. Login to your Azure Portal at https://portal.azure.com/
2. Search and Navigate to SQL Servers and click on Create
3. Select or create a new resource group
4. Set a unique Server Name and select a location near your PBX
5. Select Use SQL Authentication and set your admin login and a strong password
6. Note down these credentials as you will need them later to configure your Data Connector in 3CX Admin Console.
7. Click Review + Create and then Create
8. Navigate to SQL Servers, open the above server you just created and note down the Server Name as you will need it later.
9. Click on Create Database
10. Set a unique database name
11. Select the specs and size of the database as needed in the Compute and Storage Sections
12. Click on Review + Create and then Create
13. Once the Database is created, navigate to SQL Databases and open the above database you just created. Click on Set Server Firewall
14. Switch Public network access to "Selected Networks" and click on "Add a firewall rule"
15. Add the Public IP address of your PBX that will be accessing this database and click on Save.

### Creating an on Premise SQL Database

1. Download the on-premises Microsoft SQL Server and run the installer from: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
2. Once Installation is successful, proceed to download and install SQL Server Management Studio
3. Follow the wizard to install and launch SQL Server Management Studio (SSMS)
4. By default, Microsoft SQL Server could be listening to no ports or listening on dynamic ports. To use a specific port (e.g., 1433 default) go to Windows Start Menu, search and open `SQLServerManager16.msc`
5. In the left panel, go to **SQL Server Network Configuration** → **Protocols for SQLEXPRESS**
6. Right-click on TCP/IP and Click Enable
7. Still in Protocols for SQLEXPRESS: Double-click on TCP/IP and Go to the **IP Addresses** tab
8. Scroll to the bottom and look for the IPAll section
9. Set **TCP Port = 1433** and leave TCP Dynamic Ports empty and click OK
10. Back in SQL Server Configuration Manager In the left panel, go to **SQL Server Services**
11. Right-click your instance (e.g., MSSQLSERVER) and click Restart
12. Open SQL Server Management Studio that you installed above
13. You can connect on localhost as an administrator to the new SQL Server using Windows Authentication
14. Once connected to SSMS right-click on **Databases** > **New Database**
15. Give a unique name to the database and click OK
16. To enable SQL Server Authentication for the PBX to be able to connect to the database, right-click on your SQL Server on the left panel and click on **Properties**
17. Navigate to Security, select the option for "SQL Server and Windows Authentication mode" and click OK
18. Once again, restart your SQL Server either from SQL Server Manager as shown above or via the task manager
19. To create a user for the PBX to connect to this Database, right-click on **Logins** > **New Login**
20. Set your username in Login Name
21. Select SQL Authentication and set a strong password
22. Uncheck Enforce password policy if you don't want complexity rules
23. Default database: select your new database created above (e.g., cdr_db)
24. Still in the same "Login" window Click **User Mapping** on the left
25. Select your new database (e.g., cdr_db)
26. In the "Database role membership", check the options for db_datareader, db_datawriter, db_ddladmin
27. Click OK

## Step 2: Configure Data Connector on 3CX

Navigate to 3CX Admin Console > Integrations > Data Connector

Select "Microsoft SQL Server" and enter the following:

- **Host**: The IP Address or FQDN (if available) of the Host you installed Microsoft SQL Server on. Or the Server Name given by Azure
- **Port**: The database port (default: 1433).
- **Database Name**: The name of the database you created on Step 1.
- **Username**: The username of the new user you created on Step 1.
- **Password**: The password you configured for your new user.
- **Data Types**: Choose what data you want to have transferred.
- **Frequency**: Set the frequency for data transfer from the PBX to your Azure SQL Database.

Save the configuration and click the "Test" button on your PBX to verify the connection to the Microsoft SQL database and confirm that you receive a success message. If the test fails, double-check the host, port, database name, username, and password. Also, verify that any firewalls allow connections from your PBX IP.

## Step 3: Connect Grafana to the Microsoft SQL Database

Log in to your Grafana instance (e.g., grafana.com or your self-hosted Grafana).

Go to the Grafana configuration menu (gear icon) and click "Data Sources" and click "Add data source".

Search for and select "Microsoft SQL Server"

Configure the data source under "Connection", enter the following details:

- **Host**: Enter the IP or FQDN and port of your Microsoft SQL Server in the format: `IP/FQDN:1433`
- **Database**: The name of the database you created on Step 1.
- **User**: The username of the new user you created on Step 1
- **Password**: The password you configured for your new user
- **Authentication Type**: SQL Server Authentication

Click "Save & test" and verify that you receive a "Database Connection OK" message. If you encounter errors, double-check the connection details and SSL configuration. Also, verify that any firewalls on the Microsoft SQL host or network allow connections from Grafana IPs.

**Last Updated**: 2 June 2026
