# Azure Network Watcher

**Azure Network Watcher** is like having a smart security camera and a control center for all your network activities in the cloud. It helps you monitor, diagnose, and gain insights into your network traffic, ensuring everything runs smoothly and securely. Whether you're managing virtual networks, diagnosing connectivity issues, or analyzing traffic patterns, Azure Network Watcher provides the tools you need to keep your network healthy and efficient.

![Azure Network Watcher](images/azure-network-watcher.png)

## Introduction

Azure Network Watcher is a comprehensive tool provided by Microsoft Azure to monitor, diagnose, and gain insights into your network infrastructure. It is designed to help administrators and engineers manage their Azure network effectively by offering a suite of diagnostic, monitoring, and logging features.

## Key Benefits

Azure Network Watcher offers a variety of tools to help you monitor and troubleshoot your network. Below is a simplified explanation of its features and how they differ, aimed at making the distinctions clear and easy to understand.

1. **Monitoring:** Ensures the health and performance of your Azure network.

2. **Diagnostics:** Identifies and resolves connectivity, routing, and security issues.

3. **Logging:** Tracks network activity for analysis and compliance.

## **1. Monitor Features**

These features help you keep an eye on your network's status and connections.

![alt text](images/az-nw-monitor-features.png)

### **1.1. Topology**

- **What it does:** Creates a visual map of your Azure network.
- **Why it’s useful:** Helps you understand how your resources (like VMs, subnets, and network interfaces) are connected.
- **Example:** You can quickly see which VM is connected to which subnet and if the connections are properly configured.

### **1.2. Connection Monitor**

- **What it does:** Continuously checks connectivity between two points (e.g., your VM and a database).
- **Why it’s useful:** Identifies issues like packet loss or high latency.
- **Example:** Monitor the connection between your web app and the database to ensure there’s no downtime.

## **2. Diagnostic Features**

These tools identify and fix specific issues in your network.

![alt text](images/az-nw-diagnostic-features-1.png)
![alt text](images/az-nw-diagnostic-features-2.png)

### **2.1. IP Flow Verify (NSG)**

- **What it does:** Checks if traffic between two points is allowed or blocked by security rules.
- **Why it’s useful:** Helps debug network security rules (NSGs).
- **Example:** Verify why a VM cannot communicate with a database by testing if the NSG is blocking traffic.

### **2.2. Effective Security Rules (NSG)**

- **What it does:** Shows you all the active security rules applied to a specific network interface.
- **Why it’s useful:** Helps find conflicts in NSG rules.
- **Example:** See why traffic is blocked, even when you think your rules allow it.

### **2.3. Next Hop**

- **What it does:** Tells you where traffic from a VM will go next (e.g., a gateway, another VM, or the internet).
- **Why it’s useful:** Helps debug routing issues.
- **Example:** If traffic is going to the wrong gateway, use this tool to find and fix the problem.

### **2.4. Packet Capture**

- **What it does:** Records the actual data packets flowing through your network for analysis.
- **Why it’s useful:** Debugs complex network issues by letting you see raw traffic data.
- **Example:** Capture packets to investigate slow communication between your app and a third-party service.

### **2.5. Connection Troubleshooting**

- **What it does:** Tests if two points can communicate and identifies issues like blocked ports or unreachable destinations.
- **Why it’s useful:** Finds problems like blocked ports or unreachable destinations.
- **Example:** Diagnose why your web app cannot connect to the internet.

### **2.6. VPN Troubleshooting**

- **What it does:** Diagnoses issues with your VPN gateway and its connections.
- **Why it’s useful:** Fixes VPN issues like failed connections.
- **Example:** Diagnose why your users cannot access Azure resources through the VPN.

## **3. Logging Features**

These features help you keep a record of network activities for analysis and troubleshooting.

![alt text](images/az-nw-logging-features.png)

### **3.1. NSG Flow Logs**

- **What it does:** Logs information about all the traffic that is allowed or denied by a network security group.
- **Why it’s useful:** Tracks network activity for security and troubleshooting.
- **Example:** Use these logs to detect unusual traffic patterns or blocked connections.

### **3.2. Traffic Analysis**

- **What it does:** Processes the data from NSG Flow Logs to provide insights like bandwidth usage and unusual traffic.
- **Why it’s useful:** Helps you understand bandwidth usage and security risks.
- **Example:** Find out which VMs are consuming the most bandwidth or generating suspicious traffic.

## Implementation Overview

Setting up Azure Network Watcher is like installing a comprehensive security and monitoring system for your home network. You set up sensors (diagnostic tools), create visual maps (topology), and receive alerts when something unusual happens. Here's a simple way to understand how it works:

1. **Enable Network Watcher:** Start by turning on Network Watcher in your Azure subscription.
2. **Configure Diagnostic Tools:** Set up the tools you need to monitor and diagnose your network.
3. **Connect Data Sources:** Link your virtual networks and resources to Network Watcher for continuous monitoring.
4. **Analyze and Visualize:** Use the tools to visualize your network topology and analyze traffic patterns.
5. **Set Up Alerts:** Define alert rules to get notified about important network events.
6. **Respond to Issues:** Use the diagnostic tools to troubleshoot and resolve any network problems.

## **Summary**

- **Monitor Features:** Help you visualize and keep an eye on your network connections.
- **Diagnostic Features:** Help you troubleshoot specific issues with security, routing, or connectivity.
- **Logging Features:** Capture and analyze traffic data for monitoring and security.
