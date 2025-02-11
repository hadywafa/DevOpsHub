# AWS Developer Courses

## AWS Lambda

- [Paulo Dichone](https://www.udemy.com/course/aws-lambda-serverless)

## AWS SAM

- [Paulo Dichone](https://www.udemy.com/course/aws-sam-framework-and-aws-lambda)

## AWS CDK

- [Paulo Dichone](https://www.udemy.com/course/aws-cdk-masterclass-build-aws-cloud-infrastructures/learn/lecture/33197188#overview)

## AWS SDK

- [Emre Yilmaz](https://www.udemy.com/course/aws-cdk-with-python-step-by-step/learn/)

## AWS Amplify

- [Paulo Dichone](https://www.udemy.com/course/aws-amplify-studio-masterclass)

## AWS AppSync

- [Paulo Dichone](https://www.udemy.com/course/aws-appsync-amplify-with-react-graphql-course)

## AWS Step Functions

- [Paulo Dichone](https://www.udemy.com/course/aws-step-functions-guide-workflow-automation-in-minutes)

## AWS DynamoDB

- [Paulo Dichone](https://www.udemy.com/course/aws-dynamodb)

## AWS Pipelines

- [Emre Yilmaz](https://www.udemy.com/course/aws-codepipeline-step-by-step/learn/lecture/17536446#overview)
- [Metwally](https://cloudnativebasecamp.com/courses/aws-devops-90/)

## AWS ECS & Fargate

- [Paulo Dichone](https://www.udemy.com/course/aws-ecs-fargate)

## AWS EKS

- [Paulo Dichone](https://www.udemy.com/course/amazon-eks-starter-kubernetes-on-aws)

## Notes

### 🤔 AWS CDK vs AWS SDK ?

Great question! While both AWS CDK and AWS SDK are powerful tools for interacting with AWS, they serve different purposes and are used in different contexts:

#### 1️⃣ AWS CDK (Cloud Development Kit)

- **Purpose**: Used to define cloud infrastructure using high-level programming languages.
- **Usage**: Instead of writing raw CloudFormation templates in JSON or YAML, you can define your AWS infrastructure using familiar programming languages like TypeScript, JavaScript, Python, C#, and Java.
- **Functionality**: Provides constructs, which are reusable components of cloud infrastructure. These constructs simplify the process of defining complex infrastructure setups.
- **Example**: You can use AWS CDK to define an entire stack of resources, such as an S3 bucket, Lambda function, and DynamoDB table, all within your code.

#### 2️⃣ AWS SDK (Software Development Kit)

- **Purpose**: Used to interact with AWS services programmatically.
- **Usage**: Allows developers to write code that communicates with AWS services using various programming languages (e.g., Python, JavaScript, Java, etc.).
- **Functionality**: Provides APIs to interact with AWS services, such as uploading a file to S3, invoking a Lambda function, or querying a DynamoDB table.
- **Example**: You can use the AWS SDK to upload a file to an S3 bucket or retrieve data from a DynamoDB table within your application code.

#### 🆚 Key Differences

1. **Purpose**:

   - AWS CDK is primarily for defining and provisioning infrastructure.
   - AWS SDK is for interacting with and managing AWS services programmatically.

2. **Usage**:

   - AWS CDK uses high-level programming languages to define cloud resources.
   - AWS SDK provides APIs for programmatically interacting with AWS services.

3. **Scope**:
   - AWS CDK focuses on infrastructure as code (IaC).
   - AWS SDK is used for building applications that interact with AWS services.
