
**📘** **Module 4 — Lambda Function That Calls Amazon Bedrock (Titan Text Express)**
=============================================================================

### **Building the AI-powered summarizer for GuardDuty findings**


**🏁** **Module Overview**
-------------------

In this module, you will build the **Bedrock Summarizer Lambda** — a function that receives a GuardDuty finding, extracts important fields, sends them to **Amazon Bedrock Titan Text Express**, and returns a **human-readable AI summary**.

This Lambda sits at the analytical heart of your threat-detection pipeline.

Every GuardDuty finding that flows through Step Functions will pass through this function to be translated into:

*   A clear English summary
    
*   Suggested remediation steps
    
*   Helpful context for your security team
    

Let’s build it step by step.



**🎯** **Learning Objectives**
=======================

By the end of this module, you will:

*   Understand how Lambda integrates with Amazon Bedrock
    
*   Create an IAM role with Bedrock invoke permissions
    
*   Deploy the GuardDutyBedrockSummarizer Lambda function
    
*   Construct a prompt for Titan Text Express
    
*   Parse Titan’s response structure
    
*   Return structured output to Step Functions
    
*   Test the Lambda using a sample GuardDuty finding
    
*   Measure AI inference latency


**🧠** **1\. Why Titan Text Express?**
===============================

Amazon Bedrock offers several foundation models, but **Titan Text Express** is ideal for this workshop because:

*   It requires **no additional approval**
    
*   It supports summarization, analysis, transformation
    
*   It is fast and cost-effective
    
*   Its request/response schema is simple
    
*   It works consistently across major Bedrock-enabled regions
    

We use Titan to convert raw GuardDuty JSON into:

*   🎯 Executive summaries
    
*   🛠️ Practical remediation steps
    
*   🧠 Analyst-ready interpretation
    

This drastically reduces triage time in real security operations.


**🔐** **2\. Create the IAM Role for the Summarizer Lambda**
=====================================================

### **2.1 Trust policy**

```
aws iam create-role \
  --role-name GuardDutyBedrockRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

```
### **2.2 Attach CloudWatch logging**

```
aws iam attach-role-policy \
  --role-name GuardDutyBedrockRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

### **2.3 Add permission to invoke Bedrock Titan and Step Functions**

Create policy JSON:
```
cat > bedrock_invoke_policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream",
        "states:StartExecution"
      ],
      "Resource": "*"
    }
  ]
}
EOF
```
Attach it:

```
aws iam put-role-policy \
  --role-name GuardDutyBedrockRole \
  --policy-name BedrockInvokePolicy \
  --policy-document file://bedrock_invoke_policy.json
```
Your role is now ready.



**🧩** **3\. Create the Summarizer Lambda Function**
=============================================

Place the following file into:

```
code/lambda/bedrock_summarizer.py
```
### **bedrock\_summarizer.py (Titan Text Express Version)**

```
import json
import boto3
from datetime import datetime, timezone

bedrock = boto3.client("bedrock-runtime")

def utc_now_iso():
    return datetime.now(timezone.utc).isoformat()

def lambda_handler(event, context):
    print("=== GuardDuty event received ===")
    print(json.dumps(event, indent=2))

    # Extract finding details safely
    detail = event.get("detail", {})
    title = detail.get("title", "GuardDuty Finding")
    description = detail.get("description", "No description provided.")
    severity = detail.get("severity", "N/A")

    # Build prompt for Titan Text Express
    prompt = f"""
You are a cybersecurity assistant.
Summarize the following GuardDuty finding in clear, concise language.
Then provide 3–5 practical remediation steps.

Title: {title}
Severity: {severity}
Description: {description}
"""

    body = {
        "inputText": prompt,
        "textGenerationConfig": {
            "maxTokenCount": 500,
            "temperature": 0.2,
            "topP": 0.9
        }
    }

    # 🔎 Record time just before calling Bedrock
    model_start_utc = utc_now_iso()
    print(f"=== Calling Titan Text Express at {model_start_utc} ===")

    response = bedrock.invoke_model(
        modelId="amazon.titan-text-express-v1",
        contentType="application/json",
        accept="application/json",
        body=json.dumps(body)
    )

    # 🔎 Record time immediately after we have the response
    model_end_utc = utc_now_iso()
    print(f"=== Titan Text Express responded at {model_end_utc} ===")

    raw_body = response["body"].read()
    result = json.loads(raw_body)

    print("=== Bedrock raw result ===")
    print(json.dumps(result, indent=2))

    text = ""
    results = result.get("results", [])
    if results and isinstance(results, list):
        text = results[0].get("outputText", "").strip()

    if not text:
        text = "No summary text generated by Titan Text Express."

    # Calculate latency in milliseconds (best-effort)
    # We can approximate by parsing the ISO timestamps back into datetimes
    try:
        start_dt = datetime.fromisoformat(model_start_utc)
        end_dt = datetime.fromisoformat(model_end_utc)
        latency_ms = int((end_dt - start_dt).total_seconds() * 1000)
    except Exception:
        latency_ms = None

    message = {
        "subject": f"[GuardDuty AI] Summary for {title}",
        "message": text,
        "model_start_utc": model_start_utc,
        "model_end_utc": model_end_utc,
        "model_latency_ms": latency_ms
    }

    print("=== AI Summary (Titan Text Express) ===")
    print(text)
    print(f"Model call latency (ms): {latency_ms}")

    return {
        "statusCode": 200,
        "body": message
    }
```


**📦** **4\. Deploy the Lambda**
=========================

Zip the file:

```
cd code/lambda
zip bedrock_summarizer.zip bedrock_summarizer.py
```
Deploy:

```
aws lambda create-function \
  --function-name GuardDutyBedrockSummarizer \
  --runtime python3.12 \
  --handler bedrock_summarizer.lambda_handler \
  --zip-file fileb://bedrock_summarizer.zip \
  --role arn:aws:iam::$ACCOUNT_ID:role/GuardDutyBedrockRole \
  --region $REGION

```


**🧪** **5\. Test the Lambda With a Sample Event**
===========================================

Create a mock GuardDuty event:

```
cat > sample_guardduty_event.json <<EOF
{
  "detail": {
    "title": "EC2 instance communicating with known malicious IP",
    "severity": 7.0,
    "description": "EC2 instance i-123456789 attempted connection to IP 185.71.0.123"
  }
}
EOF
```
Run test:

```
aws lambda invoke \
  --function-name GuardDutyBedrockSummarizer \
  --payload fileb://sample_guardduty_event.json \
  --region $REGION \
  response.json

cat response.json | jq
```
You should see fields for:

*   `subject`
    
*   `message`
    
*   `model_start_utc`
    
*   `model_end_utc`
    
*   `model_latency_ms`



**📊** **6\. View Logs (Recommended)**
===============================

```
aws logs tail "/aws/lambda/GuardDutyBedrockSummarizer" \
  --region $REGION \
  --since 15m \
  --follow
```
Look for:

*   Titan model call timestamps
    
*   Titan raw output
    
*   The AI summary text



**🧯** **7\. Common Issues & Fixes**
=============================
 

### **❌** **"AccessDeniedException" for bedrock:InvokeModel**

Ensure role has:
```
bedrock:InvokeModel
```


### **❌** **"The JSON object must be str/bytes"**

Remember to call:
```
response["body"].read()
```

### **❌ No outputText returned**

Check:

*   prompt length
    
*   region supports Titan Text Express
    

### **❌ Model approval required**

This does NOT apply to Titan — but Anthropic models require approval, which is why Titan is used.


**👉** **Next Module**
===============

📌 **Module 5 — Step Functions Orchestration Workflow**

👉 [module5-stepfunctions/README.md](https://github.com/cloudbrdesign/Automating-Threat-Detection-with-GuardDuty-and-Bedrock/blob/main/docs/module5-stepfunctions/README.md)