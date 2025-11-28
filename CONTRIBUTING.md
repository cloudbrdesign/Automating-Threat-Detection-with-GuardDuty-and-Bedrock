# Contributing to the Automated AWS Threat Detection with Bedrock Project

First off — thank you for considering contributing!  
This project exists because of the community, and we welcome improvements, fixes, documentation
updates, new modules, and feature proposals.

Whether you’re reporting a bug, improving documentation, fixing a typo, or building a new
integration, your contribution is valued.

---

## 📌 How to Contribute

### 1. Fork the Repository
Click “Fork” on the top right of the GitHub page and create your own copy of this repository.

### 2. Create a Branch
Create a feature or fix branch with a descriptive name:

```bash
git checkout -b feature/sfn-error-handling
```

### **3\. Make Your Changes**

*   Follow the project folder structure
    
*   Keep code clean and commented
    
*   Update or create new Markdown docs when needed
    
*   Test any AWS code in your own account before submitting
    

### **4\. Write Clear Commit Messages**

Use descriptive, meaningful commit messages:

```
Add improved error handling for SNS publish state
Fix IAM policy example for Bedrock invocation
Update Module 4 docs with Titan response format
```

### **5\. Push Your Branch**

```
git push origin feature/sfn-error-handling
```

### **6\. Submit a Pull Request**

Open a PR to the main branch.

Please ensure your PR includes:

*   A description of what was changed
    
*   Why the change is useful
    
*   Any screenshots, logs, or sample output (if applicable)
    

**🧪 Testing Guidelines**
-------------------------

Before submitting:

*   Test all AWS CLI commands in your own account
    
*   Validate JSON and YAML syntax
    
*   Confirm IAM policy examples work as expected
    
*   For Lambda changes, check CloudWatch logs after execution
    
*   Ensure Step Functions definitions pass validation
    

**📝 Documentation Standards**
------------------------------

When updating or adding modules:

*   Use Markdown format
    
*   Follow the workshop tone (clear, detailed, student-friendly)
    
*   Include code blocks for all examples
    
*   Add diagrams if the change introduces new architecture
    
*   Update navigation links to other modules
    

**⭐ What You Can Contribute**
-----------------------------

*   Fixes to AWS CLI scripts
    
*   Improvements to Lambda functions
    
*   Adding more modules (e.g., Security Hub integration)
    
*   Adding multi-region support
    
*   Step Functions visualizations
    
*   Real-world threat detection patterns
    
*   Architecture diagrams (PNG/SVG)
    
*   Voiceover scripts / educational materials
    
*   YouTube demo scripts
    

**🛡 Reporting Security Issues**
--------------------------------

If you discover a security vulnerability related to the project:

**Do not open a public issue.**

Instead, email:

**security@yourdomain.com**

We will coordinate responsibly with you.

**❤️ Code of Conduct**
----------------------

This project follows a respectful, inclusive, zero-tolerance policy for harassment or discrimination.

We welcome contributions from everyone.

**🙌 Thank You**
----------------

Your contributions make the community stronger and help students, engineers, and security professionals learn real-world cloud security automation.

We appreciate your time, skills, and ideas.

Happy contributing!