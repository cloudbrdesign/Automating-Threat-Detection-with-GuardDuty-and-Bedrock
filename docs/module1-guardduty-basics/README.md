

**📘** **Module 1 — Amazon GuardDuty Basics & Sample Findings**
========================================================

### **Understanding Amazon’s managed threat detection service and preparing data for downstream automation**



**🏁** **Module Overview**
-------------------

In this module, you will learn what Amazon GuardDuty is, how it works, what threats it detects, how it fits into a security and compliance program, and how to generate the **sample findings** we need for the rest of the workshop.

This module lays the foundational knowledge behind the AI-enabled pipeline we’ll build in subsequent sections.



**🎯** **Learning Objectives**
=======================

By the end of this module, you will be able to:

*   Explain what Amazon GuardDuty does
    
*   Understand GuardDuty’s data sources and detection techniques
    
*   Identify the major resource-based finding categories
    
*   Understand how GuardDuty supports security, risk, and compliance objectives
    
*   Generate sample GuardDuty findings using the AWS CLI
    
*   Inspect the raw structure of a finding
    
*   Confirm findings are being delivered to EventBridge (preparation for Module 2)
    


**🔐** **1\. What is Amazon GuardDuty?**
=================================

Amazon GuardDuty is a **threat detection service** that continuously monitors your AWS environment for malicious or unauthorized activity.

It requires:

*   **No agents**
    
*   **No infrastructure**
    
*   **No manual threat intel updates**
    

GuardDuty analyzes AWS telemetry streams and automatically generates findings when it detects:

*   Unusual API calls
    
*   Potentially compromised credentials
    
*   Port scanning, probing, or reconnaissance
    
*   Connections to malware hosts or botnets
    
*   Suspicious container or runtime behavior
    
*   Anomalous data access patterns in S3
    
*   Suspicious database activity in RDS
    
*   Unusual Lambda invocation behavior
    
*   Malware infections in EC2, EBS, S3, or AWS Backup
    

GuardDuty is designed for continuous, low-maintenance protection.



**🧠** **2\. How GuardDuty Supports Information Security & Risk Management**
=====================================================================

GuardDuty directly supports:

### **Confidentiality**

*   Detects unauthorized access attempts
    
*   Identifies suspicious S3 or IAM behavior
    
*   Alerts on credential misuse
    

### **Integrity**

*   Detects malware, data tampering attempts, privilege misuse
    
*   Identifies attempts to alter or compromise workloads
    

### **Availability**

*   Flags DDoS participation
    
*   Alerts on anomalous resource consumption (crypto-mining, persistence)
    

### **Risk Management**

GuardDuty findings feed into:

*   **Risk identification**
    
*   **Likelihood and impact assessments**
    
*   **Early-warning indicators**
    
*   **KRIs** (Key Risk Indicators)
    
*   **Incident prioritization**
    

GuardDuty helps reduce **MTTD** (Mean Time To Detect) — a core risk metric.


**📜** **3\. GuardDuty & Compliance Frameworks (ISO / NIST / SOC 2)**
==============================================================

GuardDuty helps organizations satisfy:

### **ISO 27001**

*   A.12.4 — Logging & Monitoring
    
*   A.12.6 — Technical Vulnerability Management
    
*   A.13.1 — Network Security
    
*   A.16.1 — Incident Management
    

### **NIST Cybersecurity Framework**

*   DE.CM — Continuous Monitoring
    
*   DE.AE — Detecting Anomalies & Events
    
*   RS.AN — Incident Analysis
    
*   PR.AC — Identity Access Control
    

### **SOC 2, PCI DSS, HIPAA**

*   Continuous monitoring
    
*   Threat detection
    
*   Incident-response readiness
    

GuardDuty findings provide **auditable evidence** supporting these controls.



**🛰️** **4\. GuardDuty Data Sources**
==============================

GuardDuty continuously analyzes the following AWS data streams:
| Data Source | What It Provides | 
 | ----- | ----- | 
| **VPC Flow Logs** | Traffic behavior, possible scanning/exfiltration | 
| **DNS Query Logs** | Detects malware callbacks, suspicious hosts | 
| **CloudTrail Management Events** | IAM misuse, anomalous API calls | 
| **CloudTrail S3 Data Events** | Suspicious reads/copies/deletes | 
| **EKS Audit Logs** | Pod-level & API server anomalies | 
| **Lambda Network Activity** | Unusual outbound connections | 
| **EBS Malware Scans** | Malware detections inside EC2 volumes | 
| **S3 Malware Scans** | Infected or malicious objects | 
| **AWS Backup Malware Scans** | Infected backups or snapshots |

This multi-layered telemetry is what makes GuardDuty effective with **no agents** or manual setup.



**📦** **5\. GuardDuty Finding Categories (Current AWS Classification)**
=================================================================

AWS categorizes GuardDuty findings based on the **impacted resource type**.

### **EC2 Findings**

*   Unusual traffic
    
*   Port scanning
    
*   C2 communications
    
*   Malware behavior
    

### **IAM Findings**

*   Compromised credentials
    
*   Privilege escalation
    
*   Suspicious API patterns
    

### **Attack Sequence Findings**

*   Multi-stage attack progression
    
*   Recon → compromise → persistence
    

### **S3 Protection Findings**

*   Unusual S3 access patterns
    
*   Potential exfiltration
    
*   Unusual read/write operations
    

### **EKS Protection Findings**

*   Pod compromise behavior
    
*   Abnormal API calls
    
*   Runtime misuse
    

### **Runtime Monitoring Findings**

*   Code injection
    
*   File tampering
    
*   Suspicious processes
    

### **Malware Protection (EC2 / EBS / S3 / Backup)**

*   Malware scanning detections across storage services
    

### **RDS Protection Findings**

*   Suspicious SQL activity
    
*   Credential misuse
    

### **Lambda Protection Findings**

*   Abnormal invocation patterns
    
*   Attempted exploitation of runtime behavior
    



**🧪** **6\. Enable GuardDuty (if needed)**
====================================

You only need to do this once:
```
aws guardduty create-detector --enable --region $REGION
```
To check if it’s already enabled:
```
aws guardduty list-detectors --region $REGION
```
You should see a detector ID.



**🧪** **7\. Generate Sample GuardDuty Findings**
==========================================

Now generate findings we can use in upcoming modules:
```
DETECTOR_ID=$(aws guardduty list-detectors --region $REGION --query 'DetectorIds[0]' --output text)

aws guardduty create-sample-findings \
  --detector-id "$DETECTOR_ID" \
  --region $REGION
  ```

Output:
```
{
  "Sample": "Created"
}
```
This gives us real, structured GuardDuty events to use for EventBridge, Step Functions, and Bedrock later.



**🔍** **8\. Inspect a Raw Finding (Optional — Recommended)**
======================================================

List findings:
```
aws guardduty list-findings \
  --detector-id "$DETECTOR_ID" \
  --region $REGION
```
Then get details:
```
aws guardduty get-findings \
  --detector-id "$DETECTOR_ID" \
  --finding-ids <ID_FROM_LIST> \
  --region $REGION
  ```

This will output:

*   Resource affected
    
*   IP addresses
    
*   AWS principal
    
*   Severity
    
*   Evidence
    
*   Remediation
    

This raw JSON is what your Bedrock summarizer will later transform into human-readable text.



**🧯** **9\. Troubleshooting**
=======================
 

### **❌** **AccessDeniedException**

You need permissions for:

*   guardduty:\*
    
*   sts:GetCallerIdentity
    
*   events:\*
    
*   lambda:\*
    
*   states:\*
    
*   sns:\*
    
*   bedrock:InvokeModel
    

### **❌ Detector ID empty**
Run:
```
aws guardduty create-detector --enable --region $REGION
```
### **❌ No findings found**

Ensure sample findings were created.



**👉** **Next Module**
===============

Proceed to:

📌 **Module 2 — EventBridge Rule for GuardDuty Findings**

👉 [module2-eventbridge-rule/README.md](https://github.com/cloudbrdesign/Automating-Threat-Detection-with-GuardDuty-and-Bedrock/blob/main/docs/module2-eventbridge-rule/README.md)