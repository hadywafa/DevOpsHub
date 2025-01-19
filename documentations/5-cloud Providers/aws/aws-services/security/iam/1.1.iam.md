# IAM

## Notes

### Creating User

1. Users automatically get the `IAMUserChangePassword` policy to allow them to change their own password.

1. it is recommend using groups to manage user permissions by job function.

1. custom password policy will impact any new user creation and all the existing users changing their passwords.

## Questions

### 1. What is IDentity Center

AWS Identity Center, also known as **AWS IAM Identity Center**, is a service that helps you **manage workforce access to AWS applications and resources**. It allows you to connect your existing identity provider (like Okta, Google Workspace, or Microsoft Active Directory) to AWS, providing a **single sign-on (SSO) experience** for your users.

Here are some key features:

- **Centralized Management**: Manage user access to multiple AWS accounts and applications from a single place.
- **Single Sign-On**: Users can access AWS services with one set of credentials.
- **Integration with AWS Applications**: Seamlessly integrates with AWS managed applications like Amazon QuickSight and Amazon SageMaker Studio.
- **Improved Security and Visibility**: Provides better control and visibility over user access, making it easier to audit and monitor activities.

We recommend that you use Identity Center to provide console access to a person. With Identity Center, you can centrally manage user access to their AWS accounts and cloud applications.

### 2. What is Credential Report

The credentials report lists all your IAM users in this account and the status of their various credentials. After a report is created, it is stored for up to four hours.
