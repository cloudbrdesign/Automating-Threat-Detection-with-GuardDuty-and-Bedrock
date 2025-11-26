#!/bin/bash

# --- Configuration ---
PROJECT_ROOT="."
echo "Creating project structure in: $PROJECT_ROOT"

# --- 1. Create all Directories ---
# Using mkdir -p to create all parent and subdirectories in one go.

mkdir -p "$PROJECT_ROOT/docs/module0-overview/slides" \
         "$PROJECT_ROOT/docs/module1-guardduty-basics/slides" \
         "$PROJECT_ROOT/docs/module2-eventbridge-rule" \
         "$PROJECT_ROOT/docs/module3-sns-alerting" \
         "$PROJECT_ROOT/docs/module4-bedrock-lambda" \
         "$PROJECT_ROOT/docs/module5-stepfunctions/trigger-lambda" \
         "$PROJECT_ROOT/docs/module6-end-to-end-test-and-cleanup/cleanup-scripts" \
         "$PROJECT_ROOT/docs/conceptual-slides" \
         "$PROJECT_ROOT/diagrams" \
         "$PROJECT_ROOT/code/lambda" \
         "$PROJECT_ROOT/code/iam/policies" \
         "$PROJECT_ROOT/code/scripts" \
         "$PROJECT_ROOT/workshop" \
         "$PROJECT_ROOT/videos/voiceovers" \
         "$PROJECT_ROOT/substack/weekly-breakdowns" \
         "$PROJECT_ROOT/substack/newsletter-assets"

echo "Directories created successfully."

# --- 2. Create all Root-Level Files ---
touch "$PROJECT_ROOT/README.md" \
      "$PROJECT_ROOT/LICENSE" \
      "$PROJECT_ROOT/.gitignore"

# --- 3. Create all Docs Files ---
# Module 0
touch "$PROJECT_ROOT/docs/module0-overview/INTRO.md" \
      "$PROJECT_ROOT/docs/module0-overview/architecture-diagram.png" \
      "$PROJECT_ROOT/docs/module0-overview/voiceover-script.md"

# Module 1
touch "$PROJECT_ROOT/docs/module1-guardduty-basics/README.md" \
      "$PROJECT_ROOT/docs/module1-guardduty-basics/finding-examples.json"

# Module 2
touch "$PROJECT_ROOT/docs/module2-eventbridge-rule/README.md" \
      "$PROJECT_ROOT/docs/module2-eventbridge-rule/cli-commands.md"

# Module 3
touch "$PROJECT_ROOT/docs/module3-sns-alerting/README.md"

# Module 4
touch "$PROJECT_ROOT/docs/module4-bedrock-lambda/README.md" \
      "$PROJECT_ROOT/docs/module4-bedrock-lambda/bedrock_summarizer.py" \
      "$PROJECT_ROOT/docs/module4-bedrock-lambda/lambda-role-policy.json"

# Module 5
touch "$PROJECT_ROOT/docs/module5-stepfunctions/README.md" \
      "$PROJECT_ROOT/docs/module5-stepfunctions/state-machine.json"

# Module 6
touch "$PROJECT_ROOT/docs/module6-end-to-end-test-and-cleanup/README.md"

# Conceptual Slides
touch "$PROJECT_ROOT/docs/conceptual-slides/why-guardduty-matters.md" \
      "$PROJECT_ROOT/docs/conceptual-slides/guardduty-categories.md" \
      "$PROJECT_ROOT/docs/conceptual-slides/guardduty-data-sources.md" \
      "$PROJECT_ROOT/docs/conceptual-slides/guardduty-to-nist-iso-map.png" \
      "$PROJECT_ROOT/docs/conceptual-slides/attack-lifecycle-explanations.md"

# --- 4. Create Diagrams Files ---
touch "$PROJECT_ROOT/diagrams/full-workflow.png" \
      "$PROJECT_ROOT/diagrams/stepfunctions-workflow.png" \
      "$PROJECT_ROOT/diagrams/guardduty-event-flow.png" \
      "$PROJECT_ROOT/diagrams/resource-protection-areas.png"

# --- 5. Create Code Files ---
# Lambda
touch "$PROJECT_ROOT/code/lambda/bedrock_summarizer.py" \
      "$PROJECT_ROOT/code/lambda/sfn_trigger.py"

# Scripts
touch "$PROJECT_ROOT/code/scripts/deploy-lambdas.sh" \
      "$PROJECT_ROOT/code/scripts/teardown.sh" \
      "$PROJECT_ROOT/code/scripts/create-eventbridge-rule.sh" \
      "$PROJECT_ROOT/code/scripts/run-end-to-end-test.sh"

# --- 6. Create Workshop Files ---
touch "$PROJECT_ROOT/workshop/00-setup.md" \
      "$PROJECT_ROOT/workshop/01-guardduty-basics.md" \
      "$PROJECT_ROOT/workshop/02-eventbridge-integration.md" \
      "$PROJECT_ROOT/workshop/03-sns-alerting.md" \
      "$PROJECT_ROOT/workshop/04-bedrock-integration.md" \
      "$PROJECT_ROOT/workshop/05-stepfunctions-orchestration.md" \
      "$PROJECT_ROOT/workshop/06-end-to-end-test.md" \
      "$PROJECT_ROOT/workshop/07-cleanup.md"

# --- 7. Create Videos and Substack Files ---
touch "$PROJECT_ROOT/videos/youtube-thumbnail.png" \
      "$PROJECT_ROOT/videos/intro-script.md" \
      "$PROJECT_ROOT/videos/linkedIn-video-snippets.md" \
      "$PROJECT_ROOT/substack/launch-announcement.md"

echo "Files created successfully."
echo "To run this script, save it and execute: bash create_project_structure.sh"
