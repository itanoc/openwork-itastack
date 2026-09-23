# Installing 3CX Phone System on a Hyper-V VM

> Source: https://www.3cx.com/docs/installing-microsoft-hyper-v/

When running Microsoft Hyper-V, it is important to have the following settings configured on the 3CX Virtual Machine (VM) for optimal performance.

## General Settings

### Configuring a Static MAC address

It is very important for licensing that the MAC address of the hosted VM is a constant value.

To find your current MAC Address for your Windows VM:
- Open a command prompt on the 3CX virtual machine.
- Click **"Start"**, type **"cmd"** and press <Enter>.
- Type **"ipconfig /all"** and press the <Enter> key.
- Note down the value in the **"Physical Address"** field to use for the 3CX VM in Hyper-V Manager.

To find your current MAC Address for your Debian VM:
- Start an SSH session on your Debian 3CX VM
- Run the "ip link show" command
- Note down the value for the virtual network adapter

To set a static MAC address for the 3CX VM running in Hyper-V:
- Start Hyper-V Manager with administrative privileges.
- In the **"Virtual Machines"** section, right-click on the 3CX VM to configure and choose **"Settings"**.
- In the **"Settings for <VM_name>"** window, select **"Network Adapter" > "Advanced Features"**.
- Set the **"MAC address"** field to **"Static"** and use the **"Physical Address"** value you noted earlier.
- Click **"OK"** to save settings.

### Broadcom NetXtreme 1-Gigabit

If the HyperV server uses the above-defined network adapter(s), the driver must be updated to the latest version and/or VMq needs to be disabled. More information can be found [here](https://learn.microsoft.com/en-US/troubleshoot/windows-server/networking/vm-lose-network-connectivity-broadcom).

## Windows on Hyper-V

### Hyper-V Integration Services

Hyper-V Integration Services are automatically installed via Windows Update and can solve some issues related to NTP and network card performance.

### Verify Installed Network Drivers

To verify that Integration Services are installed open an administrative command prompt and:
1. Type "ipconfig /all" and press "Enter".
2. If the result shows "Microsoft Virtual Machine Bus Network Adapter", you need to install the Integration Services.
3. If the result shows "Hyper-V Network Adapter", your Integration Services are already installed.

### Check if NTP Source is Set to the Hyper-V Server

Keeping the system time synchronized is essential to the normal operation of a 3CX PBX. To verify the Windows time synchronization status:
1. Enter the command **"w32tm /query /source"**
2. The command's result should be **"VM IC Time Synchronization Provider"**
3. If you read **"Local CMOS Clock"** or the name of an NTP host you need to install Integration Services on the VM.

## Debian on Microsoft Hyper-V

### Prerequisites

- Standard Network Adapter: 3CX on Debian explicitly requires a standard **"Network Adapter"**, i.e. the **"Legacy Network Adapter"** type is **not** supported.

### Time Synchronization on Debian VM

To install and configure the NTP (Network Time Protocol) client after creating a Debian VM instance, run these commands as **"root"** or via **"sudo"**:

```bash
apt update
apt install ntp
```

> Note: [Supported versions of Debian Linux](https://learn.microsoft.com/en-gb/windows-server/virtualization/hyper-v/Supported-Debian-virtual-machines-on-Hyper-V) have built-in support for Hyper-V Integration Services.

## See Also

- How to [Install from ISO: Debian for 3CX](https://www.3cx.com/docs/manual/installing-debian-linux-pbx/).
- How to [Install 3CX on Windows](https://www.3cx.com/docs/manual/phone-system-installation-windows/)
