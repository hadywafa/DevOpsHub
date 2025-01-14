# Azure Network Watcher: Feature Demos

This document provides practical demos for each feature of Azure Network Watcher. Each demo includes the use case, step-by-step instructions, and example outputs to help you better understand how to use these tools effectively.

## **1. Monitor Features**

### **1.1. Topology Demo**

#### **Use Case:**

Visualize the network structure to identify connectivity issues or confirm resource configurations.

#### **Steps:**

1. Open the Azure Portal.
2. Navigate to **Network Watcher**.
3. Select **Topology** under the Monitoring section.
4. Choose the subscription, resource group, and virtual network you want to visualize.
5. Click **View Topology**.

#### **Example Output:**

- A diagram showing:
  - VMs connected to subnets.
  - Subnets connected to a virtual network.
  - Network interfaces and their security groups.

### **1.2. Connection Monitor Demo**

#### **Use Case:**

Verify and monitor connectivity between a web app and a database.

#### **Steps:**

1. In **Network Watcher**, select **Connection Monitor**.
2. Click **+ Add** to create a new monitor.
3. Provide a name and region.
4. Set the source as the web app’s VM and the destination as the database’s IP or hostname.
5. Configure the protocol (e.g., TCP) and port (e.g., 1433 for SQL).
6. Save and start the monitor.

#### **Example Output:**

- **Latency:** 10ms
- **Packet Loss:** 0%
- **Status:** Healthy

## **2. Diagnostic Features**

### **2.1. IP Flow Verify Demo**

#### **Use Case:**

Test if a VM can connect to a database over port 1433.

#### **Steps:**

1. In **Network Watcher**, select **IP Flow Verify**.
2. Choose the subscription and VM.
3. Specify:
   - **Direction:** Outbound
   - **Protocol:** TCP
   - **Local Port:** 1433
   - **Remote IP:** The database’s IP
4. Click **Check**.

#### **Example Output:**

- **Access:** Allowed
- **NSG Rule:** Allow_SQL_1433

### **2.2. Effective Security Rules Demo**

#### **Use Case:**

View all active security rules affecting a VM to debug blocked traffic.

#### **Steps:**

1. Navigate to **Network Watcher** > **Effective Security Rules**.
2. Select the subscription and network interface of the VM.
3. Click **View Effective Security Rules**.

#### **Example Output:**

| Priority | Name           | Access | Direction |
| -------- | -------------- | ------ | --------- |
| 100      | Allow_SQL_1433 | Allow  | Inbound   |
| 200      | Deny_All       | Deny   | Inbound   |

### **2.3. Next Hop Demo**

#### **Use Case:**

Determine where traffic from a VM is being routed.

#### **Steps:**

1. Go to **Next Hop** in **Network Watcher**.
2. Select the subscription and VM.
3. Provide the destination IP (e.g., database IP).
4. Click **Check**.

#### **Example Output:**

- **Next Hop Type:** Virtual Network Gateway
- **Next Hop IP:** 10.1.0.1

### **2.4. Packet Capture Demo**

#### **Use Case:**

Capture traffic between a web app and a database for detailed analysis.

#### **Steps:**

1. Select **Packet Capture** in **Network Watcher**.
2. Click **+ Add** to create a capture.
3. Specify:
   - **Target:** VM running the web app.
   - **Filters:** Source or destination IP, port (e.g., 1433).
   - **Storage Location:** Azure Storage or local download.
4. Start the capture and let it run for a few minutes.
5. Stop the capture and analyze the file using tools like Wireshark.

#### **Example Output:**

Captured traffic shows:

- TCP packets between the web app and the database.
- Latency and retransmissions.

### **2.5. Connection Troubleshooting Demo**

#### **Use Case:**

Debug why a web app cannot connect to a database.

#### **Steps:**

1. In **Network Watcher**, select **Connection Troubleshooting**.
2. Specify:
   - **Source:** VM hosting the web app.
   - **Destination:** Database IP.
   - **Protocol and Port:** TCP, 1433.
3. Click **Check**.

#### **Example Output:**

- **Status:** Failed
- **Reason:** NSG rule blocking traffic.
- **Suggested Fix:** Allow inbound traffic on port 1433.

### **2.6. VPN Troubleshooting Demo**

#### **Use Case:**

Fix connectivity issues in a VPN connection.

#### **Steps:**

1. Select **VPN Troubleshooting** in **Network Watcher**.
2. Choose the VPN gateway and connection.
3. Click **Start Troubleshooting**.

#### **Example Output:**

- **Status:** Failed
- **Error:** Incorrect pre-shared key.
- **Fix:** Update the pre-shared key on both ends.

## **3. Logging Features**

### **3.1. NSG Flow Logs Demo**

#### **Use Case:**

Analyze traffic patterns to detect anomalies.

#### **Steps:**

1. Enable NSG flow logs in **Network Watcher**.
2. Set the storage account for logs.
3. Use Azure Log Analytics to query the data:

   ```kql
   AzureDiagnostics
   | where TimeGenerated > ago(1h)
   | summarize Count = count() by DestinationIP, DestinationPort
   ```

#### **Example Output:**

| DestinationIP | DestinationPort | Count |
| ------------- | --------------- | ----- |
| 10.1.0.5      | 1433            | 150   |
| 10.1.0.6      | 80              | 300   |

### **3.2. Traffic Analysis Demo**

#### **Use Case:**

Identify bandwidth-heavy resources and unusual traffic.

#### **Steps:**

1. Enable **Traffic Analytics** in **Network Watcher**.
2. Access insights via Azure Log Analytics.
3. Query traffic data for analysis.

#### **Example Output:**

- **Top Bandwidth Users:** VM1 (1 GB), VM2 (800 MB)
- **Unusual Traffic:** High outbound traffic to unknown IP.
