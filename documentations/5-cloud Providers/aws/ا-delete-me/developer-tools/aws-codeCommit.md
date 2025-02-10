# Code Commit

You have three methods to authenticate with AWS CodeCommit repositories:

1. **IAM Credentials**: Uses the AWS CLI credential helper, leveraging your IAM credentials.
2. **HTTPS Git Credentials**: Involves creating and using specific HTTPS Git credentials for your IAM user.
3. **SSH Public Key**: Utilizes an SSH key pair for secure authentication.

## 1. IAM Credentials (Using AWS CLI Credential Helper)

This method uses your IAM credentials configured in the AWS CLI to authenticate with CodeCommit.

1. **Install the AWS CLI**: Ensure the AWS CLI is installed.

   ```sh
   sudo apt install awscli
   ```

2. **Configure the AWS CLI**: Set up your IAM user's access key and secret key.

   ```sh
   aws configure
   ```

   Enter your IAM user's access key, secret key, default region, and output format.

3. **Configure Git**: Set up Git to use the AWS CodeCommit credential helper.

   ```sh
   git config --global credential.helper '!aws codecommit credential-helper $@'
   git config --global credential.UseHttpPath true
   ```

    - How it works:
        1. **Git Needs Credentials**: When you try to clone, push, or pull from a CodeCommit repository, Git needs to authenticate you.

        1. **Credential Helper Activated**: The configured credential helper (aws codecommit credential-helper) is called instead of prompting you for a username and password.

        1. **AWS CLI Handles Authentication**: The credential helper uses your IAM credentials, which are already configured in your AWS CLI (aws configure), to obtain temporary credentials.

        1. **Access Granted**: These temporary credentials are used to authenticate your Git request to the CodeCommit repository.

4. **Clone the Repository**:

   ```sh
   git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/your-repo-name
   ```

## 2. HTTPS Git Credentials

This method involves creating specific HTTPS Git credentials for your IAM user and using them to authenticate.

1. **Generate HTTPS Git Credentials**: In the AWS Management Console, navigate to IAM > Users > Your User > Security credentials > HTTPS Git credentials for AWS CodeCommit > Generate.
   - Note down the generated username and password.

2. **Clone the Repository**:

   ```sh
   git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/your-repo-name
   ```

   When prompted, enter the generated username and password.

3. **Optional**: Store the credentials using Git's credential helper to avoid re-entering them:

   ```sh
   git config --global credential.helper store
   ```

## 3. SSH Public Key

This method uses an SSH key pair for authentication with CodeCommit.

1. **Generate an SSH Key Pair** (if you don’t have one):

   ```sh
   ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
   ```

   Save the key to the default location and set a passphrase if desired.

2. **Upload the SSH Public Key**:
   - In the AWS Management Console, navigate to IAM > Users > Your User > Security credentials > SSH keys for AWS CodeCommit > Upload SSH public key.
   - Upload the `id_rsa.pub` file.

3. **Configure SSH**: Edit your `~/.ssh/config` file to include CodeCommit.

   ```sh
   nano ~/.ssh/config
   ```

   Add the following configuration:

   ```plaintext
   Host git-codecommit.*.amazonaws.com
       User APKAYOURSSHUSERID
       IdentityFile ~/.ssh/id_rsa
   ```

   Replace `APKAYOURSSHUSERID` with the SSH key ID provided by AWS.

4. **Clone the Repository**:

   ```sh
   git clone ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/your-repo-name
   ```

## Why You Can't Mix SSH and HTTPS Methods in Git

#### Understanding Git Remote URLs

- **HTTPS URL**: Starts with `https://` (e.g., `https://git-codecommit.us-east-1.amazonaws.com/v1/repos/your-repo-name`).
- **SSH URL**: Starts with `ssh://` (e.g., `ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/your-repo-name`).

#### Different Authentication Mechanisms

- **HTTPS**: Uses HTTPS credentials (username/password) or AWS CLI credential helper.
- **SSH**: Uses SSH keys.

#### Switching Remote URLs

If you need to switch from one method to another, update the remote URL configuration.

#### Switching from HTTPS to SSH

1. **Check current remote URL**:

   ```sh
   git remote -v
   ```

2. **Change to SSH**:

   ```sh
   git remote set-url origin ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/your-repo-name
   ```

3. **Verify**:

   ```sh
   git remote -v
   ```

#### Switching from SSH to HTTPS

1. **Check current remote URL**:

   ```sh
   git remote -v
   ```

2. **Change to HTTPS**:

   ```sh
   git remote set-url origin https://git-codecommit.us-east-1.amazonaws.com/v1/repos/your-repo-name
   ```

3. **Verify**:

   ```sh
   git remote -v
   ```
