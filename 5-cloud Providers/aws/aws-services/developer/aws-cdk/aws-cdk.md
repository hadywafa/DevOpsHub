# 🚀 **AWS CDK (Cloud Development Kit) – The Ultimate Guide for Beginners**

## 📌 **Introduction**

AWS **Cloud Development Kit (CDK)** is a powerful tool that allows you to define **cloud infrastructure using programming languages** like TypeScript, Python, Java, and C#. Instead of writing complex **YAML or JSON** files for CloudFormation, you can use **real programming code** to create AWS resources like **S3 buckets, Lambda functions, EC2 instances, and more**.

👉 If you’re tired of writing long **CloudFormation templates**, AWS CDK is here to make your life easier!

### 🎯 **Why Use AWS CDK?**

✅ Define infrastructure using familiar programming languages  
✅ Easier to manage than CloudFormation or Terraform  
✅ Supports **best practices** out-of-the-box  
✅ Provides **reusable constructs** to simplify deployments  
✅ Integrates **natively with AWS services**

---

## 🔧 **Step 1: Install & Setup AWS CDK**

### 🛠 **Prerequisites**

Before using AWS CDK, ensure you have the following installed:

✔ **AWS CLI** (Configured with access keys)  
✔ **Node.js** (Version 14 or later)  
✔ **npm** (Comes with Node.js)  
✔ **TypeScript** (Optional but recommended)

### 📥 **1. Install AWS CDK**

Run the following command to install AWS CDK globally:

```sh
npm install -g aws-cdk
```

To check if CDK is installed, run:

```sh
cdk --version
```

---

## 📂 **Step 2: Create a New AWS CDK Project**

### 1️⃣ **Create a new directory for your project**

```sh
mkdir my-cdk-app && cd my-cdk-app
```

### 2️⃣ **Initialize a new CDK project** (Choose your programming language)

For **TypeScript**:

```sh
cdk init app --language=typescript
```

For **Python**:

```sh
cdk init app --language=python
```

For **Java**:

```sh
cdk init app --language=java
```

### 3️⃣ **Install dependencies (Optional but recommended)**

```sh
npm install
```

For Python:

```sh
pip install -r requirements.txt
```

### 4️⃣ **Check the project structure**

Once the project is initialized, you'll see files like:

```ini
my-cdk-app/
│── bin/              # Entry point
│── lib/              # Define AWS resources here
│── cdk.json          # CDK project configuration
│── package.json      # Node.js dependencies
│── README.md         # Documentation
```

---

## 🌍 **Step 3: Define AWS Resources Using CDK**

CDK uses **Constructs** to define AWS resources in code. Let's create an **S3 bucket**.

### 📝 **Modify `lib/my-cdk-app-stack.ts` (for TypeScript)**

```typescript
import * as cdk from "aws-cdk-lib";
import * as s3 from "aws-cdk-lib/aws-s3";

export class MyCdkAppStack extends cdk.Stack {
  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create an S3 Bucket
    new s3.Bucket(this, "MyBucket", {
      versioned: true, // Enable versioning
      removalPolicy: cdk.RemovalPolicy.DESTROY, // Delete bucket when stack is destroyed
    });
  }
}
```

For **Python**, modify `lib/my_cdk_app_stack.py`:

```python
from aws_cdk import core
import aws_cdk.aws_s3 as s3

class MyCdkAppStack(core.Stack):
    def __init__(self, scope: core.Construct, id: str, **kwargs):
        super().__init__(scope, id, **kwargs)

        # Create an S3 Bucket
        s3.Bucket(self, "MyBucket",
                  versioned=True,
                  removal_policy=core.RemovalPolicy.DESTROY)
```

---

## 🚀 **Step 4: Deploy to AWS**

Before deploying, run **CDK synthesize** to generate a CloudFormation template:

```sh
cdk synth
```

Now, deploy the stack to AWS:

```sh
cdk deploy
```

🎉 Your S3 bucket is now created in AWS!

---

## 📌 **Step 5: Manage AWS CDK Stacks**

### 🔍 **Check deployed resources**

```sh
cdk list
```

### 🛑 **Destroy the stack (Deletes all resources!)**

```sh
cdk destroy
```

### 🆕 **Add More AWS Resources**

You can easily add more resources like **Lambda, DynamoDB, EC2, API Gateway**, etc.

#### 🏗 **Example: Adding an AWS Lambda Function**

Modify `lib/my-cdk-app-stack.ts`:

```typescript
import * as lambda from "aws-cdk-lib/aws-lambda";

const myFunction = new lambda.Function(this, "MyLambdaFunction", {
  runtime: lambda.Runtime.NODEJS_14_X,
  handler: "index.handler",
  code: lambda.Code.fromAsset("lambda"), // Folder containing Lambda code
});
```

Create a **lambda/index.js** file:

```javascript
exports.handler = async function (event) {
  console.log("Lambda function invoked!");
  return { statusCode: 200, body: "Hello from AWS CDK Lambda!" };
};
```

---

## 🔥 **Step 6: CDK Best Practices**

✅ **Use version control (Git)** – Keep track of infrastructure changes.  
✅ **Write reusable constructs** – Make components modular for reusability.  
✅ **Use environment variables** – Avoid hardcoding sensitive values.  
✅ **Follow security best practices** – Apply least privilege policies in IAM roles.

---

## 🎯 **Conclusion**

AWS CDK is a **game-changer** for cloud infrastructure as code (IaC). It simplifies AWS resource management with programming languages instead of manually editing CloudFormation YAML files.

### **What You Learned Today:**

✅ Installed and set up AWS CDK  
✅ Created a CDK project  
✅ Defined an **S3 Bucket**  
✅ Deployed to AWS  
✅ Managed CDK stacks  
✅ Added **Lambda function**

💡 **Next Steps:**  
🔹 Experiment with **DynamoDB, EC2, VPC, and API Gateway**  
🔹 Explore **CDK Constructs** for reusable components  
🔹 Learn **advanced topics** like CI/CD with CDK Pipelines
