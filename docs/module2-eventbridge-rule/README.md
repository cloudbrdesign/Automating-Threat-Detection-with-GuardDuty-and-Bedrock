 


**📘** **Module 2 — EventBridge Rule for GuardDuty Findings**
======================================================

### **Capturing GuardDuty events in real time and routing them into your automation pipeline**



**🏁** **Module Overview**
-------------------

In Module 1, you generated GuardDuty findings.

In this module, you will configure **Amazon EventBridge** to capture those findings the moment they occur.

EventBridge acts as the “event router” in your threat-detection pipeline.

Any time GuardDuty reports something suspicious, EventBridge forwards the finding to your **Router Lambda** (created later in Module 5), which will start the Step Functions workflow.

Before we build the full workflow, we must first:

*   Create an EventBridge rule
    
*   Filter GuardDuty events
    
*   Test the rule with sample findings
    
*   Confirm the rule is triggering correctly
    

This module ensures your event-driven architecture is functioning before adding Bedrock and Step Functions.



**🎯** **Learning Objectives**
=======================

After completing this module, you will be able to:

*   Explain how EventBridge integrates with GuardDuty
    
*   Create rules to capture GuardDuty findings
    
*   Use both CLI and Console to confirm event delivery
    
*   Test the rule using sample GuardDuty events
    
*   Troubleshoot common permission and delivery issues
    


**🧠** **1\. How EventBridge Works With GuardDuty**
============================================

GuardDuty publishes findings to EventBridge automatically.

EventBridge then:

1.  **Matches findings** based on event patterns
    
2.  **Routes findings** to configured targets (Lambda, Step Functions, SNS, etc.)
    
3.  **Delivers findings** in near real time
    
4.  **Handles retries** if a target fails
    

For our pipeline:

*   GuardDuty → EventBridge rule → Lambda Router → Step Functions → Bedrock → SNS
    

This module focuses entirely on creating and testing the EventBridge rule.



**🧩** **2\. Create the EventBridge Rule**
===================================

### **2.1 Choose a rule name**
```
export RULE_NAME="GuardDutyAnyFindingRule"
```
We capture **all** GuardDuty findings for now.

### **2.2 Create the rule**
```
aws events put-rule \
  --name $RULE_NAME \
  --event-pattern '{
    "source": ["aws.guardduty"],
    "detail-type": ["GuardDuty Finding"]
  }' \
  --region $REGION
```
This pattern matches **any** GuardDuty finding.

Expected output:
```
{
    "RuleArn": "arn:aws:events:eu-west-1:123456789012:rule/GuardDutyAnyFindingRule"
}
```


**📥** **3\. Add a Temporary Logging Target (Recommended For Verification)**
=====================================================================

Before wiring this rule to our actual Step Functions trigger Lambda (Module 5), it’s best to **confirm the rule fires correctly**.

We do this by attaching a **temporary Lambda** that writes the incoming event to CloudWatch Logs.

### **3.1 Create a temporary Lambda role**
```
aws iam create-role \
  --role-name GuardDutyTempLogRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'
```
Attach logging permission:
```
aws iam attach-role-policy \
  --role-name GuardDutyTempLogRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```
### **3.2 Create the temporary test Lambda**
```
cat << 'EOF' > gd_temp_logger.py
import json

def lambda_handler(event, context):
    print("=== EventBridge received event ===")
    print(json.dumps(event, indent=2))
EOF
```
Package and deploy:
```
zip gd_temp_logger.zip gd_temp_logger.py

aws lambda create-function \
  --function-name GuardDutyTempLogger \
  --runtime python3.12 \
  --handler gd_temp_logger.lambda_handler \
  --zip-file fileb://gd_temp_logger.zip \
  --role arn:aws:iam::$ACCOUNT_ID:role/GuardDutyTempLogRole \
  --region $REGION
  ```
### **3.3 Allow EventBridge to invoke this Lambda**
```
aws events put-targets \
  --rule $RULE_NAME \
  --targets "Id"="1","Arn"="arn:aws:lambda:$REGION:$ACCOUNT_ID:function:GuardDutyTempLogger" \
  --region $REGION
  ```

### **3.4 Attach the Lambda as a rule target**
```
aws events put-targets \
  --rule $RULE_NAME \
  --targets "Id"="1","Arn"="arn:aws:lambda:$REGION:$ACCOUNT_ID:function:GuardDutyTempLogger" \
  --region $REGION
  ```

Now EventBridge routes **every GuardDuty finding** to our temporary logger.



**🧪** **4\. Test the EventBridge Rule**
=================================

Trigger sample findings again:
```
DETECTOR_ID=$(aws guardduty list-detectors --region $REGION --query 'DetectorIds[0]' --output text)

aws guardduty create-sample-findings \
  --region $REGION \
  --detector-id "$DETECTOR_ID" 
```
### **Check CloudWatch Logs:**
```
aws logs tail "/aws/lambda/GuardDutyTempLogger" \
  --since 10m \
  --region $REGION \
  --follow
```
You should now see:
```
=== EventBridge received event ===
{
  "version": "0",
  "id": "...",
  "detail-type": "GuardDuty Finding",
  "source": "aws.guardduty",
  "detail": {
    ...
  }
}
```
If you see this: **EventBridge is working perfectly.**


**🧯** **5\. Common Issues & Fixes**
=============================

### **❌ Rule never fires**

*   Ensure GuardDuty is enabled
    
*   Ensure sample findings exist
    
*   Ensure rule pattern is correct
    
*   Check that region is consistent
    

### **❌ Lambda never invoked**

Run:
```
aws events test-event-pattern \
  --event-pattern file://your-pattern.json \
  --event file://test-event.json

```
### **❌ Permission denied**

Ensure Lambda allows invocation from:
```
events.amazonaws.com
```
### **❌ CloudWatch Log Group missing**

Log group appears only after first invocation.


**🧹** **6\. Clean Up Temporary Test Lambda (Optional)**
=================================================

In Module 5, we replace this target with the real Step Functions trigger Lambda.

Remove the temporary Lambda:
```
aws events remove-targets \
  --rule $RULE_NAME \
  --ids "1" \
  --region $REGION

aws lambda delete-function \
  --function-name GuardDutyTempLogger \
  --region $REGION

aws iam delete-role \
  --role-name GuardDutyTempLogRole
```


**👉** **Next Module**
===============

📌 **Module 3 — SNS Topic & Email Alert Channel**

👉 [module3-sns-alerting/README.md](https://github.com/cloudbrdesign/Automating-Threat-Detection-with-GuardDuty-and-Bedrock/blob/main/docs/module3-sns-alerting/README.md)