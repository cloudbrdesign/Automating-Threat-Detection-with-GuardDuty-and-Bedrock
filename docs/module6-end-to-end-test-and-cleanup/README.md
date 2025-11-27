

**📘** **Module 6 — End-to-End Test & Cleanup**
========================================

### **Validating your complete AI-driven threat detection pipeline and removing all deployed resources**



**🏁** **Module Overview**
-------------------

You have completed all infrastructure modules:

*   GuardDuty is generating findings
    
*   EventBridge is capturing them
    
*   The Router Lambda is triggering Step Functions
    
*   The state machine is invoking the Bedrock summarizer Lambda
    
*   Titan Text Express is producing AI summaries
    
*   SNS is delivering final notifications
    

Now it’s time to:

1.  Test the **entire automated pipeline**
    
2.  Inspect the outputs at every stage
    
3.  Confirm SNS email delivery
    
4.  Validate logs for debugging
    
5.  Clean up all resources to avoid unnecessary AWS costs
    

This module ensures your system works from start to finish.



**🎯** **Learning Objectives**
=======================

After completing this module, you will:

*   Trigger a GuardDuty finding and watch it travel through the entire workflow
    
*   Analyze Step Functions execution details
    
*   Inspect Lambda logs in CloudWatch
    
*   Validate Bedrock model invocation timestamps & latency
    
*   Confirm SNS email alerts
    
*   Delete all resources created throughout the workshop
    


**🚀** **1\. Generate a New GuardDuty Finding**
========================================

Run:

```
DETECTOR_ID=$(aws guardduty list-detectors --region $REGION --query 'DetectorIds[0]' --output text)

aws guardduty create-sample-findings \
  --detector-id "$DETECTOR_ID" \
  --finding-types ALL 
```

Expected output:

```
{
  "Sample": "Created"
}
```

This sends fresh events into EventBridge.



**🔗** **2\. Check Step Functions Executions**
=======================================

Open in the AWS Console:

**Step Functions → GuardDutyBedrockWorkflow → Executions**

You should see one or more runs like:

```
Succeeded
```

Click the most recent execution.

Your graph should look like this:

```
InvokeBedrockLambda → PublishToSNS → Succeeded
```

Select the first step and expand “Input” and “Output” to inspect:

*   Incoming GuardDuty finding
    
*   AI-generated text
    
*   Timestamps and model latency



**📡** **3\. Verify Email Delivery**
=============================

Open your inbox.

You should see a message like:

### **Subject:**

```
[GuardDuty AI] Summary for UnauthorizedAccess:IAMUser/MaliciousIPCaller
```

### **Body (example):**

```
Executive Summary:
GuardDuty detected that IAM user 'developer' attempted API calls from a known malicious IP.
This behavior strongly indicates a compromised set of credentials.

Recommended Remediation:
1. Immediately revoke and rotate IAM user access keys.
2. Review API access logs and determine blast radius.
3. Enable MFA and enforce least privilege policy.
4. Evaluate the need for IAM Identity Center instead of users.
5. Consider automated key rotation policies going forward.

Model Invocation:
Start: 2025-11-05T13:21:10.247Z
End:   2025-11-05T13:21:10.981Z
Latency: 734 ms
```
If you received this email (or similar):

🎉 **Your entire pipeline works end-to-end.**


**📝** **4\. Inspect CloudWatch Logs (Advanced Debugging)**
====================================================

### **For the Bedrock Summarizer Lambda:**

```
aws logs tail "/aws/lambda/GuardDutyBedrockSummarizer" \
  --region $REGION --since 10m --follow
```

Logs include:

*   Parsed GuardDuty events
    
*   Titan start/end timestamps
    
*   Titan raw output JSON
    
*   AI summary text

### **For the Router Lambda:**

```
aws logs tail "/aws/lambda/GuardDutySfnTrigger" \
  --region $REGION --since 10m --follow
```

Logs include:

*   Full GuardDuty event
    
*   State Machine ARN
    
*   Execution ARN

### **For the Step Functions state machine**

Navigate to:

**Step Functions → Execution → Step Details**

You can inspect:

*   Inputs
    
*   Outputs
    
*   Errors
    
*   Retry attempts
    
*   Transition history
    


**🧯** **5\. Common Troubleshooting**
==============================

### **❌ No Step Functions executions appear**

Check Router Lambda logs; verify EventBridge → Router Lambda target.

### **❌ Step Functions shows error in InvokeBedrockLambda**

Check Bedrock Summarizer logs. Possible issues:

*   Missing Bedrock permissions
    
*   Wrong region
    
*   Incorrect payload structure
    

### **❌ No email from SNS**

*   Confirm subscription
    
*   Check spam folder
    
*   Verify SNS topic ARN in state machine
    
*   Re-run a test publish:

```
aws sns publish \
  --topic-arn "$TOPIC_ARN" \
  --subject "Test" \
  --message "SNS verification test" \
  --region $REGION
```

### **❌ Missing CloudWatch logs**

Wait for initial invocation — log group is created lazily.

 
=======

**🧹** **6\. Cleanup – Remove All Workshop Resources**
===============================================

To avoid unwanted AWS charges, delete everything created in Modules 2–5.

You may either:

**Option A — Use the automated cleanup script**
-----------------------------------------------

_(recommended)_

Create:

```
scripts/teardown.sh
```

Paste:

```
#!/bin/bash
set -e

echo "=== Deleting EventBridge targets and rule ==="
aws events remove-targets --rule GuardDutyAnyFindingRule --ids 1 --region $REGION || true
aws events delete-rule --name GuardDutyAnyFindingRule --region $REGION || true

echo "=== Deleting Lambda functions ==="
aws lambda delete-function --function-name GuardDutyBedrockSummarizer --region $REGION || true
aws lambda delete-function --function-name GuardDutySfnTrigger --region $REGION || true

echo "=== Deleting IAM roles ==="
aws iam delete-role-policy --role-name GuardDutyBedrockRole --policy-name BedrockInvokePolicy || true
aws iam delete-role --role-name GuardDutyBedrockRole || true

aws iam delete-role-policy --role-name EventBridgeLambdaRole --policy-name StartSFNExecution || true
aws iam delete-role --role-name EventBridgeLambdaRole || true

aws iam delete-role-policy --role-name GuardDutyStepFunctionsRole --policy-name StepFunctionInvokeLambdaSNS || true
aws iam delete-role --role-name GuardDutyStepFunctionsRole || true

echo "=== Deleting Step Functions state machine ==="
aws stepfunctions delete-state-machine --state-machine-arn "$STATE_MACHINE_ARN" --region $REGION || true

echo "=== Deleting SNS topic ==="
aws sns delete-topic --topic-arn "$TOPIC_ARN" --region $REGION || true

echo "Cleanup complete."
```

Make executable:

```
chmod +x scripts/teardown.sh
```

Run:

```
./scripts/teardown.sh
```

**Option B — Manual deletion (Console-driven)**
-----------------------------------------------

Delete:

*   EventBridge rule
    
*   Lambda functions
    
*   SNS topic
    
*   IAM roles
    
*   Step Functions state machine

 
=======

**🎉** **Congratulations — You Completed the Workshop!**
=================================================

You have built:

*   A serverless event-driven architecture
    
*   Connected GuardDuty → EventBridge → Lambda → Step Functions → Bedrock → SNS
    
*   Integrated AI to summarize cloud threats
    
*   Automated detection and notification workflows
    
*   Implemented real-time security automation
    

This open-source project can now be:

*   Improved
    
*   Extended
    
*   Deployed across multiple AWS accounts
    
*   Used as part of operational playbooks
    
*   Adapted into training or certification courses