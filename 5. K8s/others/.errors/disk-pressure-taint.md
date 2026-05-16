# Resolving Kubernetes `disk-pressure` on Ubuntu VM by Increasing VirtualBox Disk Size

## **Problem Overview**

When running Kubernetes (K8s) on an Ubuntu virtual machine (VM) managed by VirtualBox, you encountered a `disk-pressure` taint on the worker node. This issue prevented workloads from being scheduled on the affected node, disrupting your Kubernetes cluster's functionality.

### **Symptoms**

- Kubernetes worker node was tainted with `disk-pressure`.
- Workloads were not scheduling on the affected node.
- VirtualBox VM disk size was initially set to **10 GB**.
- Attempting to increase the disk size in VirtualBox did not reflect within the Ubuntu distribution.

## **Cause**

The `disk-pressure` taint indicates that the node is running low on disk space, preventing Kubernetes from scheduling additional pods to ensure system stability. Although you increased the VM's disk size from **10 GB** to **25 GB** using VirtualBox's media manager, the Ubuntu guest OS did not recognize the additional space. This discrepancy occurred because the underlying partitions and Logical Volume Manager (LVM) setup within Ubuntu were not resized to utilize the newly allocated disk space.

## **Solution**

To resolve the `disk-pressure` issue, you need to ensure that the Ubuntu VM recognizes the increased disk space. This involves resizing the disk partitions, extending the LVM physical and logical volumes, and expanding the filesystem to utilize the additional space.

### **Step-by-Step Guide**

#### **Prerequisites**

- **Backup Important Data:** Always back up critical data before modifying disk partitions or LVM configurations.
- **Administrative Privileges:** Ensure you have `sudo` access on the Ubuntu VM.

#### **1. Verify Current Disk and Partition Layout**

Start by checking the current disk and partition setup to understand the existing configuration.

```bash
lsblk
sudo fdisk -l /dev/sda
```

**Expected Output:**

From your initial setup:

- **sda**: 25 GB total
- **sda1**: 1 MB
- **sda2**: 1.8 GB (`/boot`)
- **sda3**: 8.2 GB (LVM Physical Volume)
- **Unallocated Space**: ~15 GB

#### **2. Resize the `sda3` Partition**

Assuming `sda3` is the last partition and there's unallocated space after it, you can resize it to utilize the remaining space using `parted`.

1. **Install `parted` (if not already installed):**

   ```bash
   sudo apt update
   sudo apt install parted
   ```

2. **Start `parted`:**

   ```bash
   sudo parted /dev/sda
   ```

3. **Within the `parted` prompt:**

   - **Print the Current Partition Table:**

     ```bash
     (parted) print
     ```

   - **Resize `sda3` to Occupy All Remaining Space:**

     ```bash
     (parted) resizepart 3 100%
     ```

     - Confirm the new end position when prompted.

   - **Exit `parted`:**

     ```bash
     (parted) quit
     ```

**Note:** If `parted` doesn't support resizing directly, you may need to delete and recreate `sda3` with the new size **without** losing data. Ensure you specify the exact start sector to maintain data integrity. **Proceed with caution and ensure backups are in place.**

#### **3. Inform the OS of Partition Changes**

After resizing the partition, notify the operating system of the changes.

```bash
sudo partprobe
```

If you encounter issues or the changes aren't recognized, perform a system reboot:

```bash
sudo reboot
```

#### **4. Resize the Physical Volume (PV)**

Extend the LVM physical volume to recognize the new space in `sda3`.

```bash
sudo pvresize /dev/sda3
```

**Verify the PV has been Resized:**

```bash
sudo pvdisplay
```

You should see increased "PE Size" or "Free PE" indicating additional space.

#### **5. Extend the Logical Volume (LV)**

Identify your logical volume path from the `lvdisplay` output, typically `/dev/ubuntu-vg/ubuntu-lv`.

1. **Extend the LV to Use All Available Free Space:**

   ```bash
   sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
   ```

   - **Explanation:**
     - `-l +100%FREE`: Utilizes all available free extents in the volume group.

2. **Verify the LV Size Has Increased:**

   ```bash
   sudo lvdisplay /dev/ubuntu-vg/ubuntu-lv
   ```

#### **6. Resize the Filesystem**

Depending on your filesystem type (`ext4` or `XFS`), resize it to utilize the extended LV space.

1. **Check Your Filesystem Type:**

   ```bash
   df -Th /
   ```

2. **Resize Accordingly:**

   - **For `ext4`:**

     ```bash
     sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
     ```

   - **For `XFS`:**

     ```bash
     sudo xfs_growfs /
     ```

3. **Verify the Filesystem Has Been Resized:**

   ```bash
   df -h /
   ```

   The root (`/`) filesystem should now reflect the increased space.

### **Summary of Commands**

Here's a condensed list of the commands executed:

```bash
# Update and install parted
sudo apt update
sudo apt install parted

# Resize the partition using parted
sudo parted /dev/sda
(parted) print
(parted) resizepart 3 100%
(parted) quit

# Inform the OS of partition changes
sudo partprobe
# If necessary, reboot
# sudo reboot

# Resize the physical volume
sudo pvresize /dev/sda3

# Extend the logical volume
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv

# Resize the filesystem
# For ext4:
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
# For XFS:
# sudo xfs_growfs /

# Verify the changes
df -h /
```

## **Post-Solution Outcome**

After completing the above steps:

- The Ubuntu VM recognized the increased disk space.
- The LVM physical and logical volumes were successfully extended.
- The filesystem utilized the additional space.
- Kubernetes no longer reported `disk-pressure` on the worker node, allowing workloads to be scheduled normally.

## **Final Notes**

- **Backup First:** Always ensure you have backups before modifying disk partitions and LVM configurations.
- **Downtime Considerations:** Some steps may require system downtime, especially if a reboot is necessary.
- **Caution with Partitioning Tools:** Misusing tools like `fdisk` or `parted` can lead to data loss. Double-check each step.
- **LVM Flexibility:** LVM provides flexibility in managing disk space, allowing you to extend volumes without much hassle once set up correctly.
