# Amazon OpenSearch

Amazon OpenSearch Service is a managed service that makes it easy to deploy, operate, and scale OpenSearch clusters in AWS Cloud.

- It is used as a near real-time, scalable search and analytics engine.
- It can be used to search all kinds of documents.
- OpenSearch Dashboards is an OpenSearch component used for analytics and visualization.
- Use cases include real-time security, application, and infrastructure monitoring, log and clickstream analytics, and searching data

---

- OpenSearch integrates with Logstash, Kinesis, S3, CloudWatch logs, DynamoDB, IoT and Lambda.
- It also integrates with SNS for alerting.
- It uses IAM and resource-based policies, and Cognito for user authentication.
- It supports VPC Endpoints.
- Pay as you go, no upfront costs.
- Like ELB, It launches ENIs in your VPC and supports security groups.
- It supports encryption in-transit and at rest.

## Searching Data

- URI searches (query strings)
- Request body Searches
- Dashboard Query Language (DQL)
- SQL Support
- Asynchronous search (queries submitted and processed in the background)

## Data Sources

- We can load data from Kinesis Data Firehose, CloudWatch Logs (through subscription filters) and IoT directly into OpenSearch domains.
- For DynamoDB, S3 and Kinesis Data Streams, we need an AWS Lambda function to load the data into OpenSearch.
- Visualization is done using OpenSearch Dashboards.
