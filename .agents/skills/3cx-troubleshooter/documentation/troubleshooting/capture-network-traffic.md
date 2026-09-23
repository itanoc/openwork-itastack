# Network Capture from Web Interface

> Source: https://www.3cx.com/docs/capture-network-traffic/

## Introduction

In the 3CX network, captures can be triggered directly from the Management Console. This allows for live packet captures that are saved in PCAP format which can then be attached to a generated SupportInfo file or can be directly downloaded.

## Prerequisites

For Windows-based installs, it remains the administrator's obligation to install Wireshark on the OS running 3CX.

If Wireshark cannot be detected, an error message will be shown.

For Linux-based setups, tcpdump is automatically installed while installing or updating 3CX.

## Start a Capture

1. Go to your 3CX Web Client > Admin Console and navigate to "Dashboard" > Click on "Capture".
2. Select the network interface to capture traffic on.
3. Optionally set capture filters (e.g. host, port, protocol).
4. Set the capture duration or leave it unbounded for manual stop.
5. Click "Start" to begin the packet capture.
6. Reproduce the issue you are troubleshooting.
7. Click "Stop" to end the capture.

## Retrieve the Capture

After stopping the capture:
1. The capture file will be saved in PCAP format.
2. Download it directly from the Management Console.
3. You can also attach it to a Support Info bundle via Dashboard > Activity Log > Support > Generate Support Info.
4. Open the .pcap file with Wireshark for analysis.

## Limitations

- Captures only packets passing through the 3CX server's network interfaces.
- Large captures may consume significant disk space.
- Performance impact is minimal but may be noticeable on high-traffic systems.
- Encrypted SIP/TLS traffic cannot be decrypted unless you have the private key.
- For remote phones behind SBC, capture on the SBC side may be needed.

## Useful Capture Filters

- SIP traffic: `port 5060 or port 5061`
- Specific host: `host <IP address>`
- RTP traffic: `udp portrange 9000-10999`
- Exclude non-VoIP traffic: `!port 443 and !port 80`

Last Updated: This document is updated periodically.
