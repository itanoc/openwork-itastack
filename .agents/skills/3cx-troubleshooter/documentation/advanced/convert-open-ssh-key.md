# Creating and Converting OpenSSH Keys

> Source: https://www.3cx.com/docs/manual/convert-open-ssh-key/

## Introduction

Connecting to an SSH (Secure SHell) or SFTP (Secure File Transfer Protocol) service can be done by specifying a username and OpenSSH-compliant key, instead of username and password. This guide presents how to create an OpenSSH key or convert an existing key to the OpenSSH format.

## Creating OpenSSH Keys

To create a new OpenSSH key in Linux or Windows:

1. Run this command in a Linux terminal or Windows command prompt, substituting your email as a label:

```bash
ssh-keygen -m pem -t rsa -b 4096 -C "your_email@example.com"
```

2. When you're prompted to enter a file for storing the key, press Enter to accept the default file location or specify your own.
3. Enter and confirm a secure passphrase to add an extra layer of security to your SSH key.
4. Verify that your SSH public and private keys have been created and ensure that you store them safely.

The key pair consists of:
- Private key: `~/.ssh/id_rsa` (Linux) or `%USERPROFILE%\.ssh\id_rsa` (Windows)
- Public key: `~/.ssh/id_rsa.pub` (Linux) or `%USERPROFILE%\.ssh\id_rsa.pub` (Windows)

## Converting PPK Keys to OpenSSH

If you need to convert your private and/or public key to an OpenSSH key, you can use PuTTYgen on:

### Linux

Run these commands as the root user or via sudo:

1. Install putty-tools:

```bash
apt install putty-tools
```

2. Convert PPK key to OpenSSH format:

```bash
puttygen ppk_key_id.ppk -O private-openssh -o openssh_rsa_id.key
```

### Windows

1. Download and install [PuTTY for Windows](https://www.puttygen.com/download-putty).
2. Open PuTTYgen
3. Click **"Load"** and select your PPK private key file
4. Enter the passphrase if prompted
5. Go to **"Conversions"** > **"Export OpenSSH key"**
6. Save the file with a `.key` extension
7. Set appropriate permissions on the exported key file:

```cmd
icacls openssh_rsa_id.key /inheritance:r /grant:r "%USERNAME%:R"
```

### Setting Permissions

**Linux:**
```bash
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

**Windows:** Use the icacls command (as shown above) or set permissions through File Explorer properties.

## Using Keys with 3CX

OpenSSH keys are used in 3CX for:
- SFTP backup destinations
- Failover script SSH authentication between active/passive servers
- Secure remote management connections

When configuring 3CX to use SSH keys, provide the private key file path and the corresponding passphrase if one was set.
