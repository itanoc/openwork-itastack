# MySQL CDR Offload Configuration Guide

> Source: https://www.3cx.com/docs/mysql-configuration/

Connecting 3CX to a Standalone MySQL & Grafana

## Introduction

This guide is for systems running V20 Update 7 and provides a concise process to connect your 3CX phone system to a standalone MySQL database for use with Grafana for data visualization and reporting.

## Prerequisites

- A running MySQL server.
- Administrative access to your MySQL server.
- Access to the 3CX Admin Console.
- A 3CX 16SC+ license (required for Data Connector functionality).
- Basic understanding of MySQL administration and SQL.

## Step 1: Prepare your MySQL

### Configure your MySQL Database

After installing your MySQL Database, make the following changes to the configuration:

Enable `local_infile` in MySQL configuration. Make sure to enable the local_infile Global Parameter, which is crucial for 3CX to efficiently transfer data in bulk. To do this, edit your MySQL configuration file and add or modify the local_infile parameter under the `[mysqld]` section:

```ini
[mysqld]
local_infile=1
```

### Allow Remote Connections to the Database

By default MySQL will allow connections from localhost. You will need to allow remote connections so PBX can connect to the database. To do this, edit your MySQL configuration file and add or modify the bind-address parameter:

```
bind-address = 0.0.0.0
```

The location of MySQL configuration file varies by operating system:

- **Linux**: Common locations include `/etc/mysql/my.cnf`, `/etc/my.cnf`, or `/etc/mysql/mysql.conf.d/mysqld.cnf`.
- **Windows**: Typically in `C:\ProgramData\MySQL\MySQL Server X.Y\my.ini`.

### Restart your MySQL Database to Apply the Above Changes

After editing, restart your MySQL service for the changes to take effect:

- **Linux**: `sudo systemctl restart mysql`
- **Windows**: Restart the MySQL service from the Services Manager.

### Create a Dedicated MySQL User and Database

Log in to MySQL as a root or administrative user:

```
mysql -u root -p
```

Enter your root password if prompted.

#### Create the Database

Choose a descriptive name for your CDR database (e.g., 3cx_cdr_db).

```sql
CREATE DATABASE 3cx_cdr_db;
```

#### Create User

Choose a strong password for your new user:

```sql
CREATE USER 'our_3cx_user'@'host' IDENTIFIED BY 'your_3cx_user_password';
```

Replace "your_3cx_user" and "your_3cx_user_password" with your desired credentials. Replace 'host' with the IP address of your 3CX server if you want to allow connections to the database only by the PBX, or replace 'host' with '%' if you want to allow access from everywhere.

Examples:
```sql
CREATE USER 'dbuser'@'192.168.10.1' IDENTIFIED BY 'myPass'; -- allow access only an IP
CREATE USER 'dbuser'@'%' IDENTIFIED BY 'myPass'; -- allow access from any IP
```

#### Grant Permissions

Finally, run the following commands to set proper permissions of the user to the database:

```sql
GRANT INSERT, SELECT, CREATE, ALTER, DROP, INDEX, LOCK TABLES ON 3cx_cdr_db.* TO 'your_3cx_user'@'host';
FLUSH PRIVILEGES;
```

Again, replace 3cx_cdr_db, 'your_3cx_user' and 'host' according to the values given above.

### Configure Firewall (If Applicable)

Ensure that your MySQL server's firewall allows inbound connections on the MySQL port (default: 3306) from your 3CX Phone System's IP address.

**Linux** (e.g., ufw):
```
sudo ufw allow from <3CX_PBX_IP_Address> to any port 3306
sudo ufw reload
```

**Windows Firewall**: Create an inbound rule to allow TCP connections on port 3306 from your 3CX PBX's IP address.

## Step 2: Configure Data Connector on 3CX

On 3CX, navigate to Admin Console > Integrations > Data Connector

Select "MySQL" and enter the following:

- **Host**: The IP Address or FQDN (if available) of the Host you installed MySQL on.
- **Port**: The database port (default: 3306).
- **Database Name**: The name of the database you created on Step 1.
- **Username**: The username of the new user you created on Step 1.
- **Password**: The password you configured for your new user.
- **Data Types**: Choose what data you want to have transferred.
- **Frequency**: Set the frequency for data transfer from the PBX to your MySQL.

Save the configuration and click the "Test" button on your PBX to verify the connection to the MySQL database and confirm that you receive a success message. If the test fails, double-check the host, port, database name, username, and password. Also, verify that any firewalls on the MySQL host or network allow connections from your PBX IP.

## Step 3: Connect Grafana to the MySQL Instance

Log in to your Grafana instance (e.g., grafana.com or your self-hosted Grafana).

Go to the Grafana configuration menu (gear icon) and click "Data Sources" and click "Add data source".

Search for and select "MySQL".

Configure the data source under "Connection", enter the following details:

- **Host**: Enter the IP or FQDN and port of your MySQL Database in the format: `IP/FQDN:3306`
- **Database**: The name of the database you created on Step 1.
- **User**: The username of the new user you created on Step 1
- **Password**: The password you configured for your new user

Click "Save & test" and verify that you receive a "Data Connection OK" message. If you encounter errors, double-check the connection details and SSL configuration. Also, verify that any firewalls on the MySQL host or network allow connections from Grafana IPs.

**Last Updated**: 2 June 2026
