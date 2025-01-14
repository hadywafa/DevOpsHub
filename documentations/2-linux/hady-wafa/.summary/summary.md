# Common Linux Commands

## Navigation

- `cd`: Change directory.
- `ls`: List files and directories.
- `pwd`: Print working directory.

## File Operations

- `touch`: Create an empty file.
- `cp`: Copy files or directories.
- `mv`: Move or rename files or directories.
- `rm`: Remove files or directories.
- `mkdir`: Create a new directory.
- `cat`: Concatenate and display the content of files.

## Text Processing

- `echo`: Print text to the terminal.
- `grep`: Search for patterns in files.
- `sed`: Stream editor for text transformation.
- `awk`: Powerful text processing tool.

## File Viewing

- `less`: View file content page by page.
- `more`: View file content page by page (similar to `less`).
- `cat`: Display entire file content.

## System Information

- `uname`: Print system information.
- `df`: Display disk space usage.
- `free`: Display memory usage.
- `top`: Display real-time system information.

## Process Management

- `ps`: Display information about processes.
- `kill`: Send a signal to a process.
- `pkill`: Kill processes based on their name.

## Package Management

- `apt`: Advanced Package Tool for Debian-based systems.
- `yum`: Yellowdog Updater Modified for RPM-based systems.
- `dnf`: Dandified Yum for RPM-based systems.

## User Management

- `useradd`: Add a new user.
- `passwd`: Change user password.
- `usermod`: Modify user properties.
- `userdel`: Delete a user.

## Network Tools

- `ifconfig`: Configure network interfaces.
- `ping`: Test network connectivity.
- `traceroute`: Display the route packets take to reach a destination.
- `netstat`: Display network statistics.

## File Permissions

- `chmod`: Change file permissions.
- `chown`: Change file ownership.
- `chgrp`: Change file group ownership.

## Compression and Archiving

- `tar`: Create and extract tar archives.
- `gzip`: Compress and decompress files using Gzip.

## Miscellaneous

- `history`: Display command history.
- `date`: Display or set the system date and time.
- `shutdown`: Shut down or restart the system.
- `reboot`: Reboot the system.

## Container root password

Docker containers typically do not have a root password set by default. This is because containers are designed to be lightweight and secure, and root access is usually managed through the host system. Here are a few key points:

- No Default Root Password: Most Docker images, including Ubuntu, do not come with a root password set. This is why you encounter an “Authentication failure” when trying to use su -.

- Accessing Root: You can access the root user directly from the host system using:
  docker exec
