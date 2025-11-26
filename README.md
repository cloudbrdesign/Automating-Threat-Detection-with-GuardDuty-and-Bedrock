**🚀** 
=======

**Automated Threat Detection on AWS with GuardDuty & Amazon Bedrock**
=====================================================================

### **An open-source, hands-on workshop for building an AI-powered cloud threat-response pipeline**

**📸 Overview Diagram**
-----------------------


![Automating Threat Detection Architecture](https://raw.githubusercontent.com/cloudbrdesign/Automating-Threat-Detection-with-GuardDuty-and-Bedrock/main/diagrams/Automating_Threat_Detection.001.png)



**🎯** **What You Will Build**
-----------------------

This open-source workshop teaches you how to build a **fully automated, AI-driven security response pipeline on AWS**, using:

*   **Amazon GuardDuty** – Detect suspicious activity
    
*   **Amazon EventBridge** – Capture findings in real time
    
*   **AWS Lambda** – Route events & call Amazon Bedrock
    
*   **AWS Step Functions** – Orchestrate the entire workflow
    
*   **Amazon Bedrock (Titan Text Express)** – Summarize findings with AI
    
*   **Amazon SNS** – Send human-readable security alerts
    
*   **CloudWatch Logs** – Trace, debug, monitor
    

In the end, you will have a **production-style architecture** that automatically:

1.  Detects a GuardDuty finding
    
2.  Routes it through EventBridge
    
3.  Invokes your Step Functions workflow
    
4.  Sends the finding to an AI model (Bedrock Titan)
    
5.  Receives a natural-language summary
    
6.  Sends an email with remediation guidance
    
7.  Logs all activity
    
8.  Cleans itself up
    

This is **real-world security automation**, built step-by-step, fully open source.

 

**🧭** **Workshop Modules**
--------------------

Each module includes:

*   Concept explanations
    
*   CLI commands
    
*   Lambda code
    
*   Architecture diagrams
    
*   Troubleshooting tips
    
*   Voiceover narration (for YouTube creators)
    


### **🔹** **Module 0 — Setup & Conceptual Overview**

*   Understanding the end-to-end architecture
    
*   Required AWS permissions
    
*   Creating a clean working environment
    
*   Testing CLI access
    
*   Exploring the full threat-detection workflow
    

📄 **Guide:** docs/module0-overview/INTRO.md


### **🔹** **Module 1 — GuardDuty Basics & Sample Findings**

*   What Amazon GuardDuty is
    
*   How it supports risk management & compliance
    
*   GuardDuty data sources
    
*   Finding categories (EC2, IAM, S3, EKS, Runtime, Malware, etc.)
    
*   Generating sample findings
    

📄 **Guide:** docs/module1-guardduty-basics/README.md


### **🔹** **Module 2 — EventBridge Rule for GuardDuty Findings**

*   Creating real-time event rules
    
*   Filtering on severity or finding type
    
*   Testing with sample events
    
*   Walking through EventBridge delivery failures
    

📄 **Guide:** docs/module2-eventbridge-rule/README.md


### **🔹** **Module 3 — SNS Topic & Email Alert Channel**

*   Creating SNS topics
    
*   Subscribing via email
    
*   Testing notifications
    
*   Understanding SNS metrics
    

📄 **Guide:** docs/module3-sns-alerting/README.md


### **🔹** **Module 4 — Lambda Function That Calls Amazon Bedrock (Titan Text Express)**

*   Writing the Bedrock summarizer Lambda
    
*   Constructing prompts
    
*   Calling Titan Text Express
    
*   Measuring model latency
    
*   Returning structured data back to Step Functions
    

📄 **Guide:** docs/module4-bedrock-lambda/README.md

📄 **Code:** code/lambda/bedrock\_summarizer.py


### **🔹** **Module 5 — Step Functions Orchestration Workflow**

*   Creating the state machine
    
*   Native integrations: Lambda + SNS
    
*   Passing data between states
    
*   Executing the workflow
    
*   Visual debugging in Step Functions
    

📄 **Guide:** docs/module5-stepfunctions/README.md

📄 **State Machine:** code/stepfunctions/state-machine.json

📄 **Trigger Lambda:** code/lambda/sfn\_trigger.py

 

### **🔹** **Module 6 — End-to-End Test & Cleanup**

*   Generate new GuardDuty findings
    
*   Watch executions flow through Step Functions
    
*   Validate Bedrock summaries
    
*   Receive your email alerts
    
*   Clean up all resources
    

📄 **Guide:** docs/module6-end-to-end-test-and-cleanup/README.md

📄 **Scripts:** scripts/teardown.sh


**🛠️** **Repository Structure**
========================
![Repository Structure Diagram](https://raw.githubusercontent.com/cloudbrdesign/Automating-Threat-Detection-with-GuardDuty-and-Bedrock/main/diagrams/repository-structure.png)

**📘** **Prerequisites**
=================

*   AWS account (personal, lab or sandbox)
    
*   IAM permissions for Lambda, SNS, Step Functions, EventBridge, GuardDuty, Bedrock
    
*   AWS CLI installed
    
*   Python 3.10+
    
*   Basic cloud + security knowledge
    

 

**🧰** **Technologies Used**
=====================

*   **Amazon GuardDuty**
    
*   **Amazon EventBridge**
    
*   **AWS Lambda**
    
*   **AWS Step Functions**
    
*   **Amazon Bedrock – Titan Text Express**
    
*   **Amazon SNS**
    
*   **CloudWatch Logs**
    
*   **AWS CLI**
    
*   **Python 3**
    



**⭐** **Learning Outcomes**
=====================

By the end of this workshop, you will be able to:

*   Build event-driven serverless architectures
    
*   Use GuardDuty as input to automated detection systems
    
*   Call Amazon Bedrock from Lambda
    
*   Summarize security findings with AI
    
*   Understand Step Functions orchestration
    
*   Create automated security alerts
    
*   Implement real-world cloud incident automation



**📣** **How to Follow Along**
=======================

1.  Clone the repository:
```
git clone https://github.com/cloudbrdesign/Automating-Threat-Detection-with-GuardDuty-and-Bedrock.git
```
2.  Navigate into the workshop directory
    
3.  Follow the modules in order
    
4.  Use the included scripts, code examples, and architecture diagrams
    
5.  Deploy and test everything live in your AWS environment



**🤝** **Contributing**
================

Contributions are welcome!

Submit a PR if you want to add:

*   New labs
    
*   Diagrams
    
*   Translations
    
*   Troubleshooting notes
    
*   Improvements to automation scripts
    

See CONTRIBUTING.md.



**📜** **License**
===========

MIT License — free for commercial and educational use.



**📣** **Stay Connected**
==================

Follow updates, new modules, and deep dives:

*   **LinkedIn:** https://linkedin.com/in/
    
*   **YouTube:** 
    
*   **Substack:** 
    
*   **GitHub:** ⭐ Star this repo to support the project!
    

 

**🙌** **Acknowledgments**
===================

This open-source workshop was created to help students, developers, and security professionals understand **modern cloud threat detection powered by AI**.

You’re encouraged to fork, build, remix, and share it widely.