 

**📘** **Module 0 – Setup & Conceptual Overview**
==========================================

### **Preparing your AWS environment and understanding the end-to-end architecture**



**🏁** **Module 0 Overview**
---------------------

Welcome to **Module 0** — the foundation of this workshop.

Before we start deploying services or writing automation, we’ll:

*   Ensure your AWS environment is clean and ready
    
*   Validate IAM permissions
    
*   Verify AWS CLI credentials
    
*   Review the **end-to-end architecture** we’ll be building
    
*   Understand how GuardDuty, EventBridge, Step Functions, Lambda, SNS, and Bedrock fit together
    
*   Preview the full automation pipeline
    

This module ensures that you can complete the rest of the labs **without errors or surprises**.



**🎯** **Learning Objectives**
-----------------------

After completing Module 0, you will be able to:

*   Understand the overall workflow of the AI-powered threat detection pipeline
    
*   Confirm that GuardDuty, EventBridge, Step Functions, Lambda, SNS, and Bedrock are available in your AWS region
    
*   Validate your AWS CLI configuration
    
*   Verify that you have sufficient IAM permissions
    
*   Start from a **clean slate** before building the pipeline
    



**🧭** **Architecture Overview**
-------------------------

This workshop builds _a complete, serverless, event-driven security automation pipeline_.

Here’s the high-level flow you will implement across the following modules:
### **Step-by-step workflow:**

1.  **GuardDuty detects a suspicious event**
    
2.  **EventBridge** captures the finding
    
3.  EventBridge triggers a **Router Lambda**
    
4.  Router Lambda starts a **Step Functions state machine**
    
5.  Step Functions invokes a **Bedrock Summarizer Lambda**
    
6.  Lambda submits the finding text to **Amazon Bedrock Titan Text Express**
    
7.  Bedrock returns a natural-language summary + remediation steps
    
8.  Step Functions publishes the summary to **SNS**
    
9.  SNS sends an **email alert** to the user
    

By the end of the workshop, you will have deployed and run this entire system end-to-end.



**🧪** **Section 1 — Validate Your AWS CLI Setup**
===========================================

Before you begin, confirm the AWS CLI is installed and authenticated.

### **1.1 Check AWS CLI version**
```
aws --version
```
Should output something like:
```
aws-cli/2.x.x Python/3.x
```
### **1.2 Confirm your identity**
```
aws sts get-caller-identity
```
Expected output:
```
{
  "UserId": "...",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/your-user"
}
```
If this fails, fix your AWS credentials before continuing.

### **1.3 Set your working region**
```
export REGION=eu-west-1
```
Or modify to your preferred supported Bedrock region.



**🔐** **Section 2 — Verify IAM Permissions**
======================================

This workshop requires permissions for:

*   GuardDuty
    
*   EventBridge
    
*   Lambda
    
*   IAM Role creation
    
*   Step Functions
    
*   SNS
    
*   CloudWatch Logs
    
*   Amazon Bedrock Runtime
    

### **2.1 Quick permission test — list Lambda functions**
```
aws lambda list-functions --region $REGION
```
### **2.2 Quick permission test — list Step Functions machines**
```
aws stepfunctions list-state-machines --region $REGION
```
### **2.3 Check GuardDuty detector exists**
```
aws guardduty list-detectors --region $REGION
```
If output is empty, create a detector using:
```
aws guardduty create-detector --enable --region $REGION
```


**📚** **Section 4 — Understanding the Why**
=====================================

Before diving into the technical steps, students should understand the context.

This project supports:

### **✔ Information Security**

*   Continuous monitoring
    
*   Threat detection
    
*   Anomaly identification
    
*   Early-warning indicators
    

### **✔ Risk Management**

*   Inputs to risk identification
    
*   Event severity mapping
    
*   Actionable remediation guidance
    
*   Reduction in Mean Time To Detect (MTTD)
    

### **✔ Regulatory Compliance**

*   *   ISO 27001: A.12.4, A.12.6, A.16.1
        
    *   NIST CSF: DE.CM, DE.AE, RS.AN
        
    *   PCI DSS, SOC 2, HIPAA monitoring requirements
        

### **✔ Business Drivers**

*   Automation reduces operational cost
    
*   AI reduces analyst workload
    
*   Faster response → reduced damage
    
*   Increased scalability across accounts
    

This context explains **why** this pipeline is valuable.


**👉** **What’s Next**
===============

Proceed to:

📌 **Module 1 — GuardDuty Basics & Sample Findings**

👉 [GuardDuty Basics Module README](https://github.com/cloudbrdesign/Automating-Threat-Detection-with-GuardDuty-and-Bedrock/blob/main/docs/module1-guardduty-basics/README.md)


You will learn how GuardDuty works, its threat intelligence sources, its supported resource types, and how to generate your first findings.