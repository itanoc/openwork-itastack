# Standalone PostgreSQL Configuration Guide

> Source: https://www.3cx.com/docs/postgresql-configuration/

Connecting 3CX to a Standalone PostgreSQL & Grafana

## Introduction

This guide provides a concise process to connect your 3CX phone system to a standalone PostgreSQL database for use with Grafana for data visualization and reporting.

## Step 1: Create a PostgreSQL

### Install PostgreSQL

**Windows**: Download the installer from https://www.postgresql.org/download/windows/ and follow the wizard.

**Linux (Debian)**:
```
sudo apt update && sudo apt install -y postgresql
```
Verify cluster: `pg_lsclusters`. Create if needed: `sudo pg_createcluster <major-version> main --start`.

Remember the postgres superuser password and installation details (port 5432 default).

### Create PostgreSQL User and Database

**Windows**: Open psql. Then execute SQL:
```sql
CREATE ROLE your_user WITH LOGIN PASSWORD 'your_password';
CREATE DATABASE your_db OWNER your_user;
```

**Linux (Debian)**:
```
sudo -u postgres createuser <username> -P
sudo -u postgres createdb <dbname> -O <username>
```

Replace your_user/username, your_password, and your_db/dbname as needed.

### Allow Remote Connections

Edit `postgresql.conf`:

- **Windows**: Typically at `C:\Program Files\PostgreSQL\<version>\data\postgresql.conf`. Set `listen_addresses = '*'`.
- **Linux (Debian)**: Typically at `/etc/postgresql/<version>/main/postgresql.conf`. Set `listen_addresses = '*'`.

Edit `pg_hba.conf`:

- **Windows**: Typically at `C:\Program Files\PostgreSQL\<version>\data\pg_hba.conf`. Add:
  ```
  host    your_db         your_user        <allowed_ip>/<cidr>         scram-sha-256
  ```
- **Linux (Debian)**: `/etc/postgresql/<version>/main/pg_hba.conf`. Add:
  ```
  host    <dbname>        <username>       <allowed_ip>/<cidr>         scram-sha-256
  ```

Replace `<allowed_ip>/<cidr>` to restrict access if needed, e.g., `0.0.0.0/0` for any IP.

**Restart PostgreSQL Service**:

- Windows: `net stop postgresql-x64-<version>` then `net start postgresql-x64-<version>` (as administrator).
- Linux (Debian): `sudo systemctl restart postgresql`

### Grant Database Privileges

**Windows & Linux**: Open `psql` (Windows) or `sudo -u postgres psql` (Linux) and run SQL:
```sql
GRANT ALL PRIVILEGES ON DATABASE your_db TO your_user;
```

### Alternative: Quick Configuration via script

**Linux**: As root, run:
```
sudo bash -c "$(wget -qO- https://downloads-global.3cx.com/downloads/misc/postgresql/linuxwizard.zip)"
```
follow the wizard's prompts.

**Windows**: Install PostgreSQL (see Windows installation steps), open PowerShell as Administrator and run:
```
https://downloads-global.3cx.com/downloads/misc/postgresql/windowswizard.zip
```
and follow the wizard's prompts.

**Note**: These scripts might not be actively maintained and their use is at your own responsibility. Exercise caution when running scripts with administrative privileges.

## Step 2: Configure Data Connector on 3CX

On 3CX, navigate to Admin Console > Integrations > Data Connector

Select "PostgreSQL Database" and enter the following:

- **Host**: The IP Address or FQDN (if available) of the Host you installed PostgreSQL on.
- **SSL Validation**: Whether the PBX should try to verify the remote SSL certificate.
- **CA Certificate**: Shown only if SSL Validation is selected. Upload CA certificate.
- **Port**: The database port (default: 5432).
- **Database Name**: The name of the database you created.
- **Username**: The master username you configured.
- **Password**: The master password.
- **Data Types**: Choose what data you want to have transferred.
- **Frequency**: Set the frequency for data transfer from the PBX to your PostgreSQL.

Save the configuration and click the "Test" button on your PBX to verify the connection to the PostgreSQL database and confirm that you receive a success message. If the test fails, double-check the host, port, database name, username, and password. Also, verify that any firewalls on the PostgreSQL host or network allow connections from your PBX IP.

**Note**: You must have a 16SC+ license to use 3CX Data Connector.

## Step 3: Connect Grafana to the PostgreSQL Instance

Log in to your Grafana instance (e.g., grafana.com or your self-hosted Grafana).

Go to the Grafana configuration menu (gear icon) and click "Data Sources" and click "Add data source".

Search for and select "PostgreSQL".

Configure the data source under "Connection", enter the following details:

- **Host**: Enter the IP or FQDN and port of your PostgreSQL in the format: `IP/FQDN:5432`
- **Database**: The name of the database you created on Step 1.
- **User**: The username of the new user you created on Step 1
- **Password**: The password you configured for your new user

Click "Save & test" and verify that you receive a "Data source is working" message. If you encounter errors, double-check the connection details and SSL configuration. Also, verify that any firewalls on the PostgreSQL host or network allow connections from Grafana IPs.

## See Also

- Connecting 3CX to Google BigQuery & Grafana
- Connecting 3CX to AWS RDS PostgreSQL & Grafana

**Last Updated**: 2 June 2026
