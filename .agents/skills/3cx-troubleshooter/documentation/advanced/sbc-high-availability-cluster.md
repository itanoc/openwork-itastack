# Create an SBC High Availability (HA) Cluster

> Source: https://www.3cx.com/docs/sbc-high-availability-cluster/

Connecting IP phones via an SBC (Session Border Controller) can be a single point of failure if the SBC service host goes offline. To overcome this possible risk, you can create an SBC High Availability (HA) cluster to operate in active-passive mode. With the SBC cluster in place, the SBC member nodes are behind the cluster's floating LAN IP, managed by the currently active host. Remote IP phones can then transparently connect via the activated passive SBC host when the primary SBC host goes offline and vice versa. SBC HA cluster is based on [crmsh](https://crmsh.github.io), a cluster management shell for the Pacemaker High Availability stack.

## Prerequisites

- Two or more Linux machines (Debian 12 recommended)
- Each machine must have the 3CX SBC installed and configured
- All machines must be on the same Layer 2 network segment
- A free floating IP address on the same subnet
- Root or sudo access on all machines
- Consistent hostnames and networking across nodes

## Creating the SBC HA Cluster

### Step 1: Install Cluster Packages on All Nodes

```bash
sudo apt update
sudo apt install -y pacemaker corosync crmsh
```

### Step 2: Configure Corosync

Edit `/etc/corosync/corosync.conf` on the primary node:

```
totem {
    version: 2
    cluster_name: sbc-cluster
    transport: udpu
}

nodelist {
    node {
        ring0_addr: NODE1_IP
        name: sbc-node1
        nodeid: 1
    }
    node {
        ring0_addr: NODE2_IP
        name: sbc-node2
        nodeid: 2
    }
}

quorum {
    provider: corosync_votequorum
    two_node: 1
}
```

Copy the configuration to all other nodes and start corosync:

```bash
sudo systemctl start corosync
sudo systemctl enable corosync
```

### Step 3: Start Pacemaker

```bash
sudo systemctl start pacemaker
sudo systemctl enable pacemaker
```

### Step 4: Configure Cluster Properties

```bash
sudo crm configure property stonith-enabled=false
sudo crm configure property no-quorum-policy=ignore
```

### Step 5: Configure the Floating IP Resource

```bash
sudo crm configure primitive sbc-ip ocf:heartbeat:IPaddr2 \
    params ip="FLOATING_IP" cidr_netmask="24" \
    op monitor interval="10s"
```

### Step 6: Configure the 3CX SBC Service Resource

```bash
sudo crm configure primitive sbc-service systemd:3cxsbc \
    op monitor interval="10s" \
    op start timeout="60s" \
    op stop timeout="60s"
```

### Step 7: Create a Resource Group

```bash
sudo crm configure group sbc-ha sbc-ip sbc-service
```

### Step 8: Verify Cluster Status

```bash
sudo crm status
```

## Updating the SBC Cluster Nodes

To update SBC nodes in an HA cluster:

1. Put the active node in standby: `sudo crm node standby sbc-node1`
2. Update the 3CX SBC on the standby node
3. Bring the node back online: `sudo crm node online sbc-node1`
4. Repeat for the other node

## Removing an SBC Cluster Node

1. Stop the cluster services on the node to remove
2. Remove the node from the corosync configuration
3. Update the remaining nodes

## Known Issues and Limitations

- Only two-node clusters are officially supported
- STONITH (Shoot The Other Node In The Head) is not configured by default
- The floating IP must be on the same subnet as the node IPs
- IP phones must be configured to use the floating IP as their SBC address

## Troubleshooting

- Check cluster status: `sudo crm status`
- View cluster logs: `sudo journalctl -u corosync -u pacemaker`
- Verify connectivity between nodes on the corosync ring network
- Ensure the floating IP is not already in use on the network

## See Also

- [3CX Session Border Controller (SBC) Overview](https://www.3cx.com/docs/3cx-tunnel-session-border-controller/)
- [Configuring Failover with 3CX](https://www.3cx.com/docs/failover/)
