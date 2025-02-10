# VIP Notes

## SSH Files Must be owned by one user

### Key Points

1. **SSH Key Permissions**: SSH private keys must have strict permissions to ensure security. The permissions must be set so that only the owner can read and write the file.
2. **Ownership and Permissions**: Files should be owned by a single user and not be accessible by others.
3. **WSL and Windows File System**: When using Windows Subsystem for Linux (WSL), files located in the Windows file system (`/mnt/c/...`) may have different permission settings that can cause SSH to fail.

### Common Issues and Solutions

#### Issue: Permission Denied Error

When trying to use an SSH key stored in the Windows file system (e.g., `/mnt/c/Users/YourName/...`) from WSL, you might encounter:

```bash
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Permissions 0777 for '/mnt/c/Users/YourName/ssh-key.pem' are too open.
It is required that your private key files are NOT accessible by others.
This private key will be ignored.
Load key "/mnt/c/Users/YourName/ssh-key.pem": bad permissions
ubuntu@your-instance-public-ip: Permission denied (publickey).
```

#### Root Cause

- **File Permissions**: The permissions on the private key file are too open (e.g., 0777), making it insecure.
- **Ownership**: Files in the Windows file system might not reflect correct ownership and permissions when accessed through WSL.

#### Solution

1. **Move the SSH Key to the WSL File System**:
   Copy your SSH key to the WSL file system to ensure it has proper permissions and ownership.

   ```sh
   cp /mnt/c/Users/YourName/ssh-key.pem ~/ssh-key.pem
   ```

2. **Set Correct Permissions**:
   Ensure the SSH key has the correct permissions (readable only by the owner).

   ```sh
   chmod 600 ~/ssh-key.pem
   ```

3. **Set Correct Ownership**:
   Ensure the SSH key is owned by the correct user.

   ```sh
   chown $(whoami):$(whoami) ~/ssh-key.pem
   ```

4. **Connect Using the SSH Key**:
   Use the SSH key to connect to your remote VM.

   ```sh
   ssh -i ~/ssh-key.pem ubuntu@your-instance-public-ip
   ```

## How AWS Create Public IP

- AWS manages the allocation and assignment of public IP addresses from its own pool of IP addresses
