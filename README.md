# Automated Cloud SOC & Incident Response Lab
Built by Satnam Singh

## 📌 Project Overview
This project demonstrates the deployment of a functional Security Operations Center (SOC) within Microsoft Azure. I utilized Infrastructure as Code (Terraform) to provision a global environment and integrated Microsoft Sentinel to monitor and investigate security threats in real-time.



## 🛠️ Technologies Used
* **Cloud Provider:** Microsoft Azure
* **SIEM/SOAR:** Microsoft Sentinel
* **Infrastructure as Code:** Terraform (v1.15.2)
* **Monitoring Agent:** Azure Monitor Agent (AMA) via Data Collection Rules (DCR)
* **Log Analysis:** Kusto Query Language (KQL)
* **OS:** Ubuntu 24.04 LTS (Linux)

## 🏗️ Architecture
1. **Infrastructure Deployment:** Used Terraform to deploy a Virtual Machine in **Central India** to navigate regional capacity constraints.
2. **Hardened Networking:** Configured a Virtual Network (VNet) and Network Security Groups (NSG) to allow only specific SSH traffic.
3. **Centralized Monitoring:** Connected the remote VM to a Log Analytics Workspace in **Canada Central** for cross-region security auditing.
4. **Agent Configuration:** Successfully bypassed legacy agent compatibility issues with Ubuntu 24.04 by implementing modern Data Collection Rules.

## 🔍 Security Investigation (KQL)
Once the pipeline was live, I simulated a brute-force SSH attack. I used the following KQL queries within Microsoft Sentinel to investigate the logs:

### 1. Heartbeat Verification
*Confirms the server is actively sending logs.*
```kusto
Heartbeat
| where TimeGenerated > ago(1h)
| summarize LastHeartbeat = max(TimeGenerated) by Computer, OSType
