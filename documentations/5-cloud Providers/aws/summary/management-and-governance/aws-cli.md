# AWS Fundamentals

## Install AWS CLI

```bash
## remove prevoius one
 sudo yum remove awscli
## download last version
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" 
# unzip
unzip awscliv2.zip 
# run
sudo ./aws/install
# check installation path
which aws
# check version
aws --version
```

## Configure the AWS CLI

The AWS CLI uses configuration and credential files to manage settings and authentication information

- `credentials` : identify who is calling the API. Access credentials are used to encrypt the request to the AWS servers to confirm your identity and retrieve associated permissions policies. These permissions determine the actions you can perform.

- `configuration` : tell the AWS CLI how to process requests, such as the default output format and the default AWS Region.

### Using  Configuration and credential files

#### Configuration and Credential Files

1. **Location of Files**:
   - **Configuration File**: `~/.aws/config`
   - **Credentials File**: `~/.aws/credentials`

2. **File Structure**:
   - Both files are plain text files with specific sections and key-value pairs.

3. **Configuration File (`~/.aws/config`)**:
   - **Purpose**: Contains settings such as default region, output format, and named profiles.
   - **Structure**:

     ```ini
     [default]
     region = us-west-2
     output = json

     [profile user1]
     region = us-east-1
     output = text
     ```

4. **Credentials File (`~/.aws/credentials`)**:
   - **Purpose**: Stores access keys and secret keys for different profiles.
   - **Structure**:

     ```ini
     [default]
     aws_access_key_id = YOUR_ACCESS_KEY_ID
     aws_secret_access_key = YOUR_SECRET_ACCESS_KEY

     [user1]
     aws_access_key_id = USER1_ACCESS_KEY_ID
     aws_secret_access_key = USER1_SECRET_ACCESS_KEY
     ```

##### Key Settings

1. **Profile**:
   - Profiles are used to define different sets of credentials and configuration settings.
   - The `default` profile is used if no profile is specified.

2. **Common Configuration Settings**:
   - **region**: Specifies the default region (e.g., `us-west-2`).
   - **output**: Specifies the output format (`json`, `text`, or `table`).

3. **Common Credential Settings**:
   - **aws_access_key_id**: Your AWS access key ID.
   - **aws_secret_access_key**: Your AWS secret access key.

##### Using Profiles

- **Switching Profiles**: Use the `--profile` option with the CLI commands to switch between profiles.

  ```sh
  aws s3 ls --profile user1
  ```

- **Default Profile**: If no profile is specified, the `default` profile settings are used.

##### Additional Configuration Options

- **MFA and Temporary Credentials**: Can be specified for advanced security configurations.
- **Role-Based Access**: Use roles and temporary security credentials for IAM roles.

#### Example Usage

1. **Setting Up Default Profile**:

   ```sh
   aws configure
   ```

   This command prompts for your AWS access key, secret key, default region, and output format, and stores them in the `default` profile.

2. **Adding a Named Profile**:

   ```sh
   aws configure --profile user1
   ```

   This allows you to configure a different set of credentials and settings under the `user1` profile.

By organizing your credentials and configuration settings in these files, you can easily manage multiple AWS accounts and environments, ensuring that the appropriate settings are used for each context.

### Using  Environment variables

Environment variables allow you to set configuration values directly in your system's environment, which can be useful for temporary settings or automated scripts.

#### Key Environment Variables

1. **AWS Access Credentials**:
   - **AWS_ACCESS_KEY_ID**: Your AWS access key ID.
   - **AWS_SECRET_ACCESS_KEY**: Your AWS secret access key.
   - **AWS_SESSION_TOKEN**: (Optional) Token for temporary session credentials.

2. **Configuration Settings**:
   - **AWS_DEFAULT_REGION**: Sets the default region (e.g., `us-west-2`).
   - **AWS_DEFAULT_OUTPUT**: Sets the default output format (`json`, `text`, or `table`).

3. **Profile Settings**:
   - **AWS_PROFILE**: Specifies which profile to use from the configuration and credentials files.

4. **AWS Shared Config and Credentials File Locations**:
   - **AWS_CONFIG_FILE**: Overrides the default config file location (e.g., `/custom/path/config`).
   - **AWS_SHARED_CREDENTIALS_FILE**: Overrides the default credentials file location (e.g., `/custom/path/credentials`).

#### Usage Examples

- **Setting Environment Variables in a Unix Shell**:

   ```sh
   export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY_ID
   export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_ACCESS_KEY
   export AWS_DEFAULT_REGION=us-west-2
   ```

- **Using a Specific Profile**:

   ```sh
   export AWS_PROFILE=user1
   aws s3 ls
   ```

- **Custom Config and Credentials File Locations**:

   ```sh
   export AWS_CONFIG_FILE=/custom/path/config
   export AWS_SHARED_CREDENTIALS_FILE=/custom/path/credentials
   ```

### Using Command line options

### Notes

- Ensure your computer's date and time are set correctly because AWS requires cryptographically signed requests with a date/time stamp.

- The AWS CLI uses credentials and configuration settings from multiple sources, prioritized (Ordered them) as follows:
    1. Command Line Options:
    1. Environment Variables
    1. Assume Role
    1. Assume Role with Web Identity
    1. AWS IAM Identity Center
    1. Credentials File
    1. Custom Process
    1. Configuration File
    1. Container Credentials
    1. Amazon EC2 Instance Profile Credentials
