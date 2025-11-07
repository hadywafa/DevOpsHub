# File ownership and permissions in Linux

Here's a detailed overview of file ownership and permissions in Linux, organized into key topics:

## 1. File Ownership

### 1.1. Owner and Group

- **Owner**: Each file and directory in Linux is associated with a user who has the owner permissions. This user can modify the file or directory as defined by the permissions.
- **Group**: Each file is also associated with a group. Users who are part of this group share the same permissions as defined for the group.

### 1.2. Identifying Ownership

Ownership can be viewed using the `ls -l` command, which displays the owner and group of each file:

```out
drwxr-xr-x 3 hady hw-ubuntu 4096 May 14 18:14 aws
```

Here, _hady_ is the owner and _hw-ubuntu_ is the group.

## 2. File Permissions

### 2.1. Types of Permissions

- Permissions control what actions users can perform on files and directories:
  - **Read (r)**: Permission to view the contents of the file or directory.
  - **Write (w)**: Permission to modify the file or directory (including deletion).
  - **Execute (x)**: Permission to run a file as a program or access a directory.

### 2.2. Permission Structure

Permissions are displayed in three sets of three characters:

- **Owner permissions**: First three characters
- **Group permissions**: Next three characters
- **Other permissions**: Last three characters

```in
-rwxr-xr-x
```

This means:

- Owner: read, write, execute
- Group: read, execute
- Others: read, execute

### 2.3. Permission Types

- **File Type Indicator**:
  - `-`: Regular file
  - `d`: Directory
  - `l`: Symbolic link

## 3. Modifying Permissions

### 3.1. Changing Ownership

Use the `chown` command to change the owner and/or group of a file or directory:

```bash
chown [new_owner]:[new_group] filename
```

Example:

```bash
chown hady:hw-ubuntu myfile.txt
```

### 3.2. Changing Permissions

Use the `chmod` command to modify file permissions:

- **Symbolic mode**:

  - `+`: Adds permission
  - `-`: Removes permission
  - `=`: Sets exact permission

  ```bash
  # Add execute permission for the owner
  chmod u+x filename
  # Remove write permission for the group
  chmod g-w filename
  ```

- **Numeric mode**:

  - Permissions are represented by numbers:
    - Read = 4
    - Write = 2
    - Execute = 1

  ```bash
  # Sets permissions to rwxr-xr-x
  chmod 755 filename
  ```

## 4. Special Permissions

### 4.1. Setuid and Setgid

- **Setuid (Set User ID)**: When set on an executable file, it allows users to run the file with the permissions of the file owner.
- **Setgid (Set Group ID)**: When set on a directory, files created within inherit the group ownership of the directory.

### 4.2. Sticky Bit

- The sticky bit can be set on directories to restrict file deletion. Only the file's owner can delete or modify their own files within the directory.

## 5. Viewing Permissions

- You can view permissions and ownership using the `ls -l` command.
- To view the effective user and group for the current session, use:

  ```bash
  id
  ```

## 6. Summary

- Understanding file ownership and permissions is crucial for managing access control in a Linux environment. By correctly setting ownership and permissions, you can enhance security and ensure that users have the appropriate level of access to files and directories. This management is essential for system administration and collaboration in multi-user environments.
