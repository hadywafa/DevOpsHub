# Backup vs Snapshot

## Backup

A backup is a copy of data created to ensure that it can be recovered in case the original data is lost, corrupted, or otherwise inaccessible. Backups are essential for data protection, disaster recovery, and maintaining data integrity.

### Types of Backups

#### 1. Full Backup

- **Definition**: A full backup captures a complete copy of all the data at a specific point in time.
- **Frequency**: Often performed periodically, such as weekly or monthly.
- **Storage**: Requires more storage space since it copies all data every time.
- **Restore Process**: Simplifies the restoration process, as only one backup file is needed.
- **Pros**: Comprehensive data protection and simple restore process.
- **Cons**: Time-consuming and storage-intensive.

#### 2. Incremental Backup

- **Definition**: An incremental backup only captures the data that has changed since the last backup (full or incremental).
- **Frequency**: Can be performed more frequently, such as daily or even hourly.
- **Storage**: Requires less storage space compared to full backups, as only changed data is stored.
- **Restore Process**: Requires the last full backup and all subsequent incremental backups to restore.
- **Pros**: Efficient in terms of storage and time.
- **Cons**: More complex restoration process since multiple backup files are needed.

#### 3. Differential Backup

- **Definition**: A differential backup captures all the data that has changed since the last full backup.
- **Frequency**: Typically performed after an initial full backup, and then periodically until the next full backup.
- **Storage**: Requires more storage space than incremental backups but less than full backups.
- **Restore Process**: Requires the last full backup and the latest differential backup to restore.
- **Pros**: Easier restoration process compared to incremental backups.
- **Cons**: Can become storage-intensive over time as more data changes.

### How They Work Together

In many backup strategies, these different types of backups are used together to provide a balanced approach to data protection:

- **Weekly Full Backups**: Start with a full backup at the beginning of the week.
- **Daily Incremental Backups**: Follow up with incremental backups each day to capture only the changes.
- **Periodic Differential Backups**: Optionally, differential backups can be used mid-week to ensure faster recovery times.

### Example Scenario

Let's consider a weekly backup schedule:

- **Sunday**: Perform a full backup.
- **Monday to Saturday**: Perform incremental backups each day.
- **Mid-week (e.g., Wednesday)**: Perform a differential backup to capture changes since Sunday.

## Snapshot

### What is a Snapshot?

Think of a snapshot as a photograph of your data at a specific moment in time. It captures the exact state of your data at that moment without actually copying all the data. Instead, it creates references to the existing data blocks. If the data changes after the snapshot is taken, only the changes are stored separately.

### Example Scenario

Imagine you have a document. You take a snapshot of it. Now, if you make changes to the document (e.g., add a paragraph), the snapshot still has the original version, and the changes are tracked separately. If you decide to "revert" to the snapshot, you can go back to the original version of the document as it was when the snapshot was taken.

### How Snapshots Work

1. **Initial Snapshot**: When you take a snapshot, it marks the current data blocks as part of the snapshot. No actual data is copied at this point.
2. **Tracking Changes**: Any changes made after the snapshot are stored separately. The snapshot keeps the original state, while the system tracks the changes.
3. **Restoring**: To restore to a snapshot, the system uses the original data blocks and ignores the changes made after the snapshot.

### Benefits of Snapshots

- **Speed**: Snapshots are very quick to create because they don't copy the data; they just mark the existing data blocks.
- **Storage Efficiency**: Snapshots only store changes made after the snapshot, making them more space-efficient initially.
- **Quick Reversion**: You can quickly revert to a previous state using a snapshot, which is useful for testing or recovery.

### Differences from Backups

- **Data Handling**: Unlike backups that create a full or partial copy of the data, snapshots reference the existing data blocks and track changes.
- **Purpose**: Snapshots are great for quick, short-term recovery. Backups are better for long-term data retention and disaster recovery.
- **Storage**: Snapshots are more storage-efficient for tracking changes, while backups require more storage space as they copy data.

## Difference

Great analogy! There are indeed similarities. Let’s compare it to Git to help clarify the concepts:

### Snapshots and Git

- **Snapshots**: Think of a snapshot as a commit in Git. When you take a snapshot, it captures the state of your data at a specific point in time, similar to how a Git commit captures the state of your codebase.
  - **Creation**: Quick to create, as it only records the changes from the previous state (delta changes).
  - **Restoration**: You can quickly revert to any previous snapshot, much like you can checkout a previous commit in Git.

### Backups and Traditional Workflows

- **Backups**: Imagine working on a project without Git and making manual copies of your entire project directory at regular intervals.
  - **Full Backup**: Like copying the entire project folder every time.
  - **Incremental Backup**: Copying only the files that have changed since the last backup.
  - **Differential Backup**: Copying all changes made since the last full backup.

### Why Git is Like Snapshots

- **Efficiency**: Git commits (snapshots) are efficient because they track changes rather than copying everything every time.
- **Quick Rollback**: You can quickly revert to previous states, just like using snapshots to rollback to a previous state of data.

### Why Traditional Backups Are Different

- **Storage and Time**: Traditional backups are more storage-intensive and time-consuming since they involve copying data.
- **Restoration Complexity**: To restore, you often need to combine multiple backups (full + incremental or differential), similar to manually piecing together project versions without Git.

### Summary

- **Snapshots**: Efficient, quick to create, and easy to revert to a previous state, much like Git commits.
- **Backups**: Comprehensive, more storage-intensive, and involve more complex restoration processes, akin to manually copying project directories.
