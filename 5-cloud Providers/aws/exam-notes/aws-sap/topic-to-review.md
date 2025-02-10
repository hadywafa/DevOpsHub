# AWS SAP Topics to Review

## **Advanced Policy Syntax** 👮

**References:**

[policies variables](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_variables.html)

## **AZ Name vs AZ ID** 🆔

An **Availability Zone ID** is a **unique, immutable identifier** for an AWS **Availability Zone (AZ)** within a region. Each AZ ID is consistent across accounts, ensuring that you can refer to the same physical infrastructure irrespective of account or region mapping differences.

For example:

- **Region**: `us-east-1`
- **Availability Zone Names**: `us-east-1a`, `us-east-1b`
- **Availability Zone IDs**: `use1-az1`, `use1-az2`

## **Revoking Temporary Credentials in AWS IAM** ⛔

Temporary credentials in AWS IAM provide short-term, limited access to AWS resources for users, roles, or services. These credentials are typically used when assuming a role or using AWS Security Token Service (STS). While they automatically expire after a set duration, you can mitigate their impact or restrict their use by implementing certain techniques.
