

**📘** **Module 5 — Step Functions Orchestration Workflow**
====================================================

### **Coordinating GuardDuty findings through Bedrock summarization and SNS alerting**



**🏁** **Module Overview**
-------------------

By now, you have:

*   GuardDuty generating findings
    
*   EventBridge capturing them
    
*   SNS prepared to send notifications
    
*   A Bedrock Summarizer Lambda ready to generate AI summaries
    

In this module, you will build the **orchestration layer** that connects all these pieces together:

**an AWS Step Functions state machine**.

This state machine will:

1.  Receive a GuardDuty event
    
2.  Invoke the Bedrock summarizer Lambda
    
3.  Extract the AI-generated summary
    
4.  Publish the alert to SNS
    
5.  Complete the workflow end-to-end
    

This is where your system becomes a fully automated security response pipeline.



**🎯** **Learning Objectives**
=======================

By the end of this module, you will:

*   Understand how Step Functions orchestrates multi-service automation
    
*   Create an IAM role for Step Functions
    
*   Build a state machine using native AWS service integrations
    
*   Create the Router Lambda that starts workflow executions
    
*   Connect EventBridge to the Router Lambda
    
*   Test the full orchestration from GuardDuty → Step Functions
    
*   Inspect execution logs and state transitions
    


**🧠** **1\. Why Step Functions?**
===========================

Step Functions gives you:

### **✔** **Visual orchestration**

See every step — Lambda invocation, SNS publish, success/failure — in real time.


### **✔** **Native AWS integrations**

Use SNS, Lambda, and other services without writing glue code.


### **✔** **Built-in retries & error handling**

Avoids brittle, hand-rolled automation.


### **✔** **Clear audit trails**

Every execution is logged and timestamped.


### **✔** **Perfect for event-driven pipelines**

Exactly what we need for GuardDuty → AI summarization → email alerts.



**🔐** **2\. Create the Step Functions IAM Role**
==========================================

### **2.1 Create the role**

```
aws iam create-role \
  --role-name GuardDutyStepFunctionsRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "states.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'
```

### **2.2 Add permissions for Lambda invoke & SNS publish**

First create the policy file:

```
cat > sfn_permissions.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["lambda:InvokeFunction"],
      "Resource": "arn:aws:lambda:$REGION:$ACCOUNT_ID:function:GuardDutyBedrockSummarizer"
    },
    {
      "Effect": "Allow",
      "Action": ["sns:Publish"],
      "Resource": "arn:aws:sns:$REGION:$ACCOUNT_ID:GuardDutyBedrockAlerts"
    }
  ]
}
EOF
```
Apply it:
```
aws iam put-role-policy \
  --role-name GuardDutyStepFunctionsRole \
  --policy-name StepFunctionInvokeLambdaSNS \
  --policy-document file://sfn_permissions.json
```



**🧩** **3\. Define the State Machine**
================================

Create the JSON file:

```
{
  "Comment": "GuardDuty → Bedrock → SNS orchestration",
  "StartAt": "InvokeBedrockLambda",
  "States": {
    "InvokeBedrockLambda": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload.body",
      "Parameters": {
        "FunctionName": "arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:GuardDutyBedrockSummarizer",
        "Payload.$": "$"
      },
      "Next": "PublishToSNS"
    },
    "PublishToSNS": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "arn:aws:sns:${REGION}:${ACCOUNT_ID}:GuardDutyBedrockAlerts",
        "Message.$": "$.message",
        "Subject.$": "$.subject"
      },
      "End": true
    }
  }
}
```
> **Explanation:**

*   `InvokeBedrockLambda`: calls your summarizer and passes only the body output to the next state
    
*   `PublishToSNS`: publishes the AI summary using built-in SNS integration



**🚀** **4\. Create the State Machine**
================================

Get the role ARN:

```
SFN_ROLE_ARN=$(aws iam get-role \
  --role-name GuardDutyStepFunctionsRole \
  --query 'Role.Arn' \
  --output text)
```

Deploy:

```
aws stepfunctions create-state-machine \
  --name GuardDutyBedrockWorkflow \
  --definition file://code/stepfunctions/state-machine.json \
  --role-arn "$SFN_ROLE_ARN" \
  --region $REGION
```

Capture ARN:

```
STATE_MACHINE_ARN=$(aws stepfunctions list-state-machines \
  --region $REGION \
  --query "stateMachines[?name=='GuardDutyBedrockWorkflow'].stateMachineArn" \
  --output text)

echo $STATE_MACHINE_ARN
```


**🧩** **5\. Create the Router Lambda (Starts Step Functions)**
========================================================

This Lambda is invoked by EventBridge when GuardDuty emits a finding.

Create:

```
code/lambda/sfn_trigger.py
```
Paste:

```
import json
import os
import boto3

sfn = boto3.client("stepfunctions")
STATE_MACHINE_ARN = os.environ["STATE_MACHINE_ARN"]

def lambda_handler(event, context):
    print("=== Event received from EventBridge ===")
    print(json.dumps(event, indent=2))

    response = sfn.start_execution(
        stateMachineArn=STATE_MACHINE_ARN,
        input=json.dumps(event)
    )

    execution_arn = response.get("executionArn")
    print(f"Started Step Functions execution: {execution_arn}")

    return {"status": "started", "executionArn": execution_arn}
```

**5.1 Create IAM Role for Router Lambda**
-----------------------------------------

```
aws iam create-role \
  --role-name EventBridgeLambdaRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'
```

Attach:

```
aws iam attach-role-policy \
  --role-name EventBridgeLambdaRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

Add Step Functions permission:

```
cat > trigger_sfn_policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["states:StartExecution"],
    "Resource": "$STATE_MACHINE_ARN"
  }]
}
EOF

aws iam put-role-policy \
  --role-name EventBridgeLambdaRole \
  --policy-name StartSFNExecution \
  --policy-document file://trigger_sfn_policy.json
```

**5.2 Deploy the Router Lambda**
--------------------------------

Zip:

```
cd code/lambda
zip sfn_trigger.zip sfn_trigger.py
```

Deploy:

```
aws lambda create-function \
  --function-name GuardDutySfnTrigger \
  --runtime python3.12 \
  --handler sfn_trigger.lambda_handler \
  --zip-file fileb://sfn_trigger.zip \
  --role arn:aws:iam::$ACCOUNT_ID:role/EventBridgeLambdaRole \
  --environment "Variables={STATE_MACHINE_ARN=$STATE_MACHINE_ARN}" \
  --region $REGION
```


**🔗** **6\. Connect EventBridge Rule → Router Lambda**
================================================

You already created the EventBridge rule in Module 2.

Allow invocation:

```
aws lambda add-permission \
  --function-name GuardDutySfnTrigger \
  --statement-id AllowEventBridgeInvokeSfnTrigger \
  --action "lambda:InvokeFunction" \
  --principal events.amazonaws.com \
  --source-arn arn:aws:events:$REGION:$ACCOUNT_ID:rule/GuardDutyAnyFindingRule \
  --region $REGION
```

Add target:

```
aws events put-targets \
  --rule GuardDutyAnyFindingRule \
  --targets "Id"="1","Arn"="arn:aws:lambda:$REGION:$ACCOUNT_ID:function:GuardDutySfnTrigger" \
  --region $REGION
```



**🧪** **7\. Test the Full Orchestration**
===================================

Generate sample findings again:

```
aws guardduty create-sample-findings \
  --detector-id "$DETECTOR_ID" \
  --region $REGION 
```

Then open:

**AWS Console → Step Functions → GuardDutyBedrockWorkflow → Executions**

You should see:

```
InvokeBedrockLambda → PublishToSNS → Succeeded
```

And in your inbox:

**An AI-generated GuardDuty summary.**



**🧯** **8\. Troubleshooting**
=======================

### **❌ Step Functions never triggers**

*   Check EventBridge → Router Lambda mapping
    
*   Check Trigger Lambda logs
    
*   Ensure environment variable `STATE_MACHINE_ARN` is set correctly
    

### **❌ Lambda Summarizer fails**

Tail logs:

```
aws logs tail "/aws/lambda/GuardDutyBedrockSummarizer" --follow
```

### **❌ SNS does not deliver email**

Check subscription status

Check spam folder

### **❌ Execution shows failure**

Open the failed state in Step Functions to see error details.



**👉** **Next Module**
===============

📌 **Module 6 — End-to-End Test & Cleanup**

👉 [module6-end-to-end-test-and-cleanup/README.md](https://github.com/cloudbrdesign/Automating-Threat-Detection-with-GuardDuty-and-Bedrock/blob/main/docs/module6-end-to-end-test-and-cleanup/README.md)