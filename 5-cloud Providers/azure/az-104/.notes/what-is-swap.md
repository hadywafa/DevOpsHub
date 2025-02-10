# Swap

**Swapping** generally refers to the act of replacing one thing with another. In the context of Azure Virtual Machines, **swapping an OS disk** means replacing the current operating system disk of a VM with another OS disk.

## Swap OS Disk

**Definition**: Swapping an OS disk involves replacing the existing OS disk with a new or different OS disk. This process retains the VM’s configuration, identity, and network settings, while changing the underlying operating system.

**Use Cases**:

1. **Restoring from Backup**: If you have a snapshot or backup of a previous OS disk and need to restore the VM to that state.
2. **Cloning Configurations**: When you want to replicate the configuration and software setup of another VM.
3. **Upgrading or Changing OS**: If you need to upgrade the operating system or change it to a different version.

## How to Swap an OS Disk

1. **Stop the VM**: Deallocate the VM to ensure it is in a stopped state.
2. **Detach the Current OS Disk**: Detach the existing OS disk from the VM.
3. **Attach a New OS Disk**: Attach the new OS disk that you want to use as the operating system.
4. **Start the VM**: Start the VM again, and it will boot from the new OS disk.

## Benefits of Swapping OS Disks:

- **Minimal Configuration Changes**: You don’t have to reconfigure the VM’s network settings, IP addresses, or other resources.
- **Flexibility**: Allows for quick recovery or replication of VM states.
- **Efficiency**: Useful for migrating VMs to different configurations or restoring them from backups without creating entirely new VMs.
