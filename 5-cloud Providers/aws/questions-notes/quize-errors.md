# Quiz Errors

<div align="center">

<h1>EC2, EBS</h1>

<h2>Error 1</h2>

<div align="center">
    <img src="images/ebs-ec2-q1.png" alt="ebs-ec2-q1" style="border-radius: 10px;">
</div>

<h1>S3</h1>

<h2>Error 1</h2>
<div align="center">
    <img src="images/s3-q6.png" alt="s3-q6" style="border-radius: 10px;">
</div>

<h2>Error 2</h2>
<div align="center">
    <img src="images/s3-q7.png" alt="s3-q7" style="border-radius: 10px;">
</div>

<h2>Error 3</h2>
<div align="center">
    <img src="images/s3-q10.png" alt="s3-q10" style="border-radius: 10px;">
</div>

<h1>Security</h1>

<h2>Error 1</h2>
<div align="center">
    <img src="images/security-q6.png" alt="security-q6" style="border-radius: 10px;">
</div>

<h1>No SQL</h1>

<h2>Error 1</h2>
<div align="center">
    <img src="images/no-sql-q1.png" alt="no-sql-q1" style="border-radius: 10px;">
</div>

<h1>Analytics</h1>

<h2>Error 1</h2>
<div align="center">
    <img src="images/analysis-q5.png" alt="analysis-q5" style="border-radius: 10px;">
</div>

<h1>Other</h1>

<h2>Error 1</h2>
<div align="center">
    <img src="images/other-q1.png" alt="other-q1" style="border-radius: 10px;">
</div>

<h2>Error 2</h2>
<div align="center">
    <img src="images/other-q2.png" alt="other-q2" style="border-radius: 10px;">
</div>

<div>

<h2>Error 3</h2>
<div align="center">
    <img src="images/other-q3.png" alt="other-q3" style="border-radius: 10px;">
</div>

- When a user assumes a role in another account and uploads objects to an S3 bucket, the objects are owned by the bucket owner (Account B in this case) by default.

</div>

<h2>Error 4</h2>
<div align="center">
    <img src="images/other-q4.png" alt="other-q4" style="border-radius: 10px;">
</div>

<h2>Error 5</h2>
<div align="center">
    <img src="images/other-q5.png" alt="other-q5" style="border-radius: 10px;">
</div>

- SCP's only impact identities in the account they are attached to in this case the SCP is on account B, and bob's identity is in account A .. so the SCP doesn't apply this leaves the identity policy and the resource policy together which allow bobs access.

</div>

<div>

<h2>Error 6</h2>
<div align="center">
    <img src="images/other-q6.png" alt="other-q6" style="border-radius: 10px;">
</div>

- SAML 2.0 is designed for enterprise scenarios, while Web Identity Federation allows users to log in with social media accounts for consumer-facing applications. They serve different purposes and contexts.

</div>

<div>

<h2>Error 7</h2>
<div align="center">
    <img src="images/rds-q3.png" alt="rds-q3" style="border-radius: 10px;">
</div>

<h2>Error 8</h2>
<div align="center">
    <img src="images/rds-q7.png" alt="rds-q7" style="border-radius: 10px;">
</div>

</div>

<h1>Networking</h1>

<div>

<h2>Error 1</h2>
<div align="center">
    <img src="images/networking-q3.png" alt="networking-q3" style="border-radius: 10px;">
</div>

- You're absolutely correct that making an S3 bucket private restricts access to unauthorized users. However, in this scenario, where the goal is to serve global users (who may not have AWS authorization or authentication), the **CloudFront Origin Access Identity (OAI)** or **Origin Access Control (OAC)** provides the necessary mechanism to securely handle access without needing individual user authentication.

**Why This Works for "Global Unauthorized Users":**

- **Bucket Privacy**: Making the S3 bucket private ensures that **direct access** to the bucket is not possible, adding a security layer.
- **CloudFront as a Gateway**: With OAI/OAC, CloudFront acts as the authorized intermediary, fetching content from the private bucket on behalf of the users. It doesn't matter if the end users are authorized in AWS or not—they only interact with CloudFront.
- **Public Accessibility Through CloudFront**: Users are not interacting with the S3 bucket directly. Instead, they access the content via the CloudFront distribution, which securely retrieves and serves the content.

**Assumption in the Solution:**

The solution assumes:

1. Users (even "global unauthorized" ones) **don't need direct access to AWS services**, but they need access to the training video via CloudFront.
2. **No individual user-level authorization** is required for access. If it were, additional mechanisms like signed URLs or cookies would be necessary.

</div>

<div>

<h2>Error 2</h2>
<div align="center">
    <img src="images/networking-q4.png" alt="networking-q4" style="border-radius: 10px;">
</div>

<div align="center">
    <img src="images/networking-a4.png" alt="networking-a4" style="border-radius: 10px;">
</div>

</div>

<h2>Error 3</h2>
<div align="center">
    <img src="images/networking-q6.png" alt="networking-q4" style="border-radius: 10px;">
</div>

</div>

</div>
