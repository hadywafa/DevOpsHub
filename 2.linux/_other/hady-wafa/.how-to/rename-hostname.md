# Rename Hostname in Ubuntu

To rename the hostname in Ubuntu, you can follow these steps:

## 1. **Temporarily Change the Hostname (Current Session Only)**

- Use the `hostnamectl` command to change the hostname temporarily. This will only last until the next reboot.

```bash
sudo hostnamectl set-hostname new-hostname
```

## 2. **Permanently Change the Hostname**

To make the hostname change permanent, you'll need to update the following files:

### a. **/etc/hostname**

- Edit the `/etc/hostname` file, which contains your system's hostname. Replace the existing hostname with your new hostname.

```bash
sudo nano /etc/hostname
```

- Change the content of this file to your new hostname and save the file.

### b. **/etc/hosts**

- Edit the `/etc/hosts` file to associate your new hostname with `127.0.1.1`.

```bash
sudo nano /etc/hosts
```

- Update the line that reads `127.0.1.1 old-hostname` to `127.0.1.1 new-hostname`.

## **Verify the Change**

- After the reboot, you can verify the hostname change by using the following command:

```bash
hostnamectl
```
