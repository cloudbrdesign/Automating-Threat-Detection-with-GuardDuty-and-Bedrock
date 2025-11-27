

**📘** **Module 3 — SNS Topic & Email Alert Channel**
==============================================

### **Setting up the notification layer for AI-generated security alerts**



**🏁** **Module Overview**
-------------------

In the previous module, you connected GuardDuty to EventBridge.

Now it’s time to set up the **notification channel** that will deliver AI-generated summaries to your inbox.

This module focuses on:

*   Creating an **SNS topic**
    
*   Adding an **email subscription**
    
*   Confirming delivery
    
*   Understanding how SNS fits into the final Step Functions workflow
    

SNS (Simple Notification Service) will serve as the **final output stage** of your automated security pipeline — where the human-readable summary from the Bedrock Lambda is delivered directly to you.



**🎯** **Learning Objectives**
=======================

By the end of this module, you will be able to:

*   Create an SNS topic
    
*   Subscribe email addresses to alerts
    
*   Confirm and test SNS delivery
    
*   Understand SNS integration with Step Functions
    
*   Troubleshoot common SNS issues
    

SNS is simple, reliable, and widely used in security automation — making it a perfect fit for this workshop.



**🧠** **1\. Why SNS for Alerting?**
=============================

SNS gives us:
 

### **✔** **Instant, push-based notifications**

*   Emails
    
*   SMS
    
*   HTTP endpoints
    
*   Lambda targets
    
*   Mobile messaging
    


### **✔** **Low-latency delivery**

Alerts are delivered in _seconds_.


### **✔** **Built-in retries & durability**

SNS automatically retries failed deliveries.


### **✔** **Seamless Step Functions integration**

In Module 5, Step Functions will publish directly to SNS using:
```
"Resource": "arn:aws:states:::sns:publish"
```


### **✔** **Fan-out**

One AI summary can notify many recipients across email, SMS, or Slack (via HTTPS endpoints).

SNS is the simplest and most popular “communication layer” for cloud security monitoring.

 
=======

**📣** **2\. Create an SNS Topic**
===========================

Let’s create a dedicated topic for our AI-generated security alerts.

### **2.1 Create a topic**
```aws sns create-topic \
  --name GuardDutyBedrockAlerts \
  --region $REGION
```
Expected output:
```
{
  "TopicArn": "arn:aws:sns:eu-west-1:123456789012:GuardDutyBedrockAlerts"
}
```
Save it:
```
TOPIC_ARN=$(aws sns list-topics \
  --region $REGION \
  --query "Topics[?contains(TopicArn, 'GuardDutyBedrockAlerts')].TopicArn" \
  --output text)

echo $TOPIC_ARN
```


**📧** **3\. Subscribe Your Email Address**
====================================
```
aws sns subscribe \
  --topic-arn "$TOPIC_ARN" \
  --protocol email \
  --notification-endpoint "your-email@example.com" \
  --region $REGION
```
You will receive an email:

**“AWS Notification – Subscription Confirmation”**

Click **Confirm subscription**.

### **3.1 Check subscription status**
```
aws sns list-subscriptions-by-topic \
  --topic-arn "$TOPIC_ARN" \
  --region $REGION \
  --output table
```
Look for:
```
SubscriptionArn: PendingConfirmation
```
then:
```
SubscriptionArn: arn:aws:sns:...
```



**🧪** **4\. Test the SNS Topic**
==========================

Before wiring SNS into the Step Functions workflow, let’s send ourselves a test message.
```
aws sns publish \
  --topic-arn "$TOPIC_ARN" \
  --subject "SNS Test Message: GuardDuty AI Pipeline" \
  --message "This is a test message from Module 3." \
  --region $REGION
```
Check your inbox — you should receive the message within seconds.



**📡** **5\. How SNS Fits Into the Final Workflow**
============================================

Here is how SNS will be used in Module 5:
```
GuardDuty → EventBridge → Step Functions → Bedrock Summarizer Lambda → Step Functions → SNS → Email
```
Step Functions will publish:

*   `"Subject"` → AI-generated subject
    
*   `"Message"` → AI-generated body text
    

Your `state-machine.json` will include:
```
"PublishToSNS": {
  "Type": "Task",
  "Resource": "arn:aws:states:::sns:publish",
  "Parameters": {
    "TopicArn": "$TOPIC_ARN",
    "Message.$": "$.message",
    "Subject.$": "$.subject"
  },
  "End": true
}
```
You’ll implement this in Module 5.



**🧯** **6\. Common Issues & Fixes**
=============================

### **❌ Email never arrives**

*   Check spam/junk
    
*   Confirm subscription
    
*   Use a different email provider (Gmail, Outlook, Yahoo)
    


### **❌** AuthorizationError **on publish**

Your IAM identity needs:
```
sns:Publish
sns:Subscribe
sns:ListTopics
```
### **❌ Subscription stuck in PendingConfirmation** 


*   Check if corporate mail filters block AWS notifications
    
*   Resend confirmation email by re-running the subscribe command
    
*   Use a personal address for testing
    

### **❌ SNS region mismatch**

Make sure SNS, Step Functions, and Lambda share the **same region**.

 
=======

**👉** **Next Module**
===============

📌 **Module 4 — Lambda Function That Calls Amazon Bedrock**

👉 [module4-bedrock-lambda/README.md](https://github.com/cloudbrdesign/Automating-Threat-Detection-with-GuardDuty-and-Bedrock/blob/main/docs/module4-bedrock-lambda/README.md)