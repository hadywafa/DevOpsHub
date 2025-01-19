# HW Questions

## Why AWS API Gateway so Important

API Gateway can indeed serve as a central hub that manages and routes requests to different APIs, regardless of whether they are hosted on EC2 instances, ECS, EKS, or even AWS Lambda. Here’s a quick summary:

### Use of API Gateway

- **Centralized Routing**: Acts as a single entry point to route API requests to various backend services.
- **Inter-Service Communication**: Can be used to allow APIs to call other APIs, regardless of their underlying infrastructure.
- **Unified Management**: Provides a consistent interface and set of features (security, throttling, monitoring) for all your APIs.

### Scenario

- **Microservices Architecture**: Imagine you have multiple microservices deployed on EC2, ECS, and EKS. Each microservice exposes its own API.
- **API Gateway**: You use API Gateway as the front door to manage these APIs. It handles incoming requests, routes them to the appropriate microservice, and manages security and monitoring.

### Benefits

- **Consistency**: Ensures a consistent way of accessing and managing APIs.
- **Security**: Enhances security by centralizing authentication and authorization.
- **Scalability**: Easily scales with your application's needs, handling millions of requests per second.
- **Monitoring and Analytics**: Provides detailed insights into API usage and performance.
