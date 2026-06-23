# Day 10 - Storage & Disks 💿

## Objective
Learn the fundamentals of storage in Linux/macOS:

- What is a disk?
- What is a partition?
- What is a filesystem?
- What is a mount point?
- How to inspect storage and disk usage.

---

# Core Concepts

##1. Disk

A disk is the physical storage device.

Examples:

```bash
/dev/sda
/dev/nvme0n1
```

Think of it as a hard drive or SSD.

---

## 2. Partition

A partition is a logical section of a disk.

Examples:

```bash
/dev/sda1
/dev/sda2
/dev/nvme0n1p1
```

One disk can contain multiple partitions.

Example:

```text
Disk: /dev/sda

├── /dev/sda1
├── /dev/sda2
└── /dev/sda3
```

---

## 3. Filesystem

A filesystem defines how files are stored and organized.

Common filesystems:

| OS | Filesystem |
|-----|-----------|
| Linux | ext4 |
| macOS | APFS |
| Windows | NTFS |

Examples:

```text
ext4
xfs
apfs
ntfs
```

Without a filesystem, data cannot be stored properly.

---

## 4. Mount Point

A mount point is the directory where a filesystem becomes accessible.

Example:

```text
/
```

Root filesystem mounted at:

```bash
/
```

USB drive might be mounted at:

```bash
/mnt/usb
```

Think of mounting as plugging storage into the folder tree.

---

# Relationship

```text
Disk
  ↓
Partition
  ↓
Filesystem
  ↓
Mount Point
```

Example:

```text
/dev/sda
   ↓
/dev/sda1
   ↓
ext4
   ↓
/
```

---

# Commands Learned

## 1. View Disks and Partitions

Linux:

```bash
lsblk
```

Example Output:

```text
sda
├─sda1
└─sda2
```

Useful For:

- Viewing disks
- Viewing partitions
- Understanding storage layout

---

macOS:

```bash
diskutil list
```

Displays:

- Physical disks
- APFS containers
- Volumes

---

## 2. View Mounted Filesystems

```bash
df -h
```

### Meaning

| Option | Meaning |
|----------|---------|
| d | disk |
| f | filesystem |
| -h | human readable |

Example:

```bash
Filesystem      Size Used Avail Use%
/dev/sda1        50G  25G   23G  52%
```

Useful For:

- Checking free space
- Checking used space
- Troubleshooting storage issues

---

## 3. View Filesystem Types

```bash
mount | column -t
```

Displays:

```text
/dev/sda1 on / type ext4
```

Useful For:

- Seeing mount points
- Seeing filesystem types
- Understanding storage configuration

---

## 4. Check Folder Sizes

```bash
du -sh ~/* 2>/dev/null
```

### Meaning

| Part | Purpose |
|--------|----------|
| du | disk usage |
| -s | summary |
| -h | human readable |
| 2>/dev/null | hide errors |

Example:

```text
5G Downloads
2G Movies
500M Documents
```

Useful For:

- Finding storage hogs
- Cleaning disk space

---

# Challenge Completed

## Find the 5 Biggest Folders

Command:

```bash
du -sh ~/* 2>/dev/null | sort -rh | head -5
```

### Breakdown

Step 1:

```bash
du -sh ~/*
```

Gets folder sizes.

---

Step 2:

```bash
sort -rh
```

Sorts largest first.

Options:

```text
-r = reverse
-h = human readable
```

---

Step 3:

```bash
head -5
```

Shows only top 5 results.

---

Example Output

```text
12G Downloads
8G Movies
4G VirtualMachines
2G Projects
1G Documents
```

---

# Mounting and Unmounting

## Mount a Device

```bash
mount /dev/sdb1 /mnt/usb
```

Meaning:

```text
Attach filesystem from /dev/sdb1
to folder /mnt/usb
```

After mounting:

```bash
ls /mnt/usb
```

shows USB contents.

---

## Unmount a Device

```bash
umount /mnt/usb
```

Meaning:

```text
Detach filesystem safely
```

---

## Why Unmount?

Prevents:

- Data corruption
- Incomplete writes
- Lost files

Always unmount before removing:

- USB drives
- External SSDs
- External HDDs

---

## View Mounted USB Devices

```bash
mount | grep "/mnt"
```

Useful for:

- Checking mounted drives
- Verifying USB attachment

---

# Real DevOps Use Cases

## Server Running Out of Space

Check:

```bash
df -h
```

Find:

```text
Filesystem at 95%
```

---

## Find Large Directories

```bash
du -sh /*
```

or

```bash
du -sh /var/*
```

---

## Verify New Disk Attached

```bash
lsblk
```

Look for:

```text
sdb
```

or

```text
nvme1n1
```

---

## Verify Filesystem Type

```bash
mount
```

or

```bash
df -Th
```

---

# Interview Questions

## Q1. Difference between Disk and Partition?

Answer:

A disk is the physical storage device. A partition is a logical section created inside a disk.

---

## Q2. What is a filesystem?

Answer:

A filesystem is the structure used to organize and store files on a partition.

Examples:

- ext4
- xfs
- APFS
- NTFS

---

## Q3. What is a mount point?

Answer:

A mount point is a directory where a filesystem becomes accessible in the operating system.

---

## Q4. Which command checks free disk space?

```bash
df -h
```

---

## Q5. Which command checks folder size?

```bash
du -sh foldername
```

---

## Q6. Why should a USB drive be unmounted before removal?

Answer:

To ensure all pending writes are completed and prevent data corruption.

---

# Key Learnings

✅ Disk = Physical storage

✅ Partition = Slice of a disk

✅ Filesystem = Data organization format

✅ Mount Point = Location where storage appears

✅ `lsblk` shows disks and partitions

✅ `df -h` shows free space

✅ `du -sh` shows folder size

✅ `mount` shows mounted filesystems

✅ Always unmount external drives before removing

---

# Commands to Remember

```bash
lsblk

df -h

mount | column -t

du -sh ~/*

du -sh ~/* 2>/dev/null | sort -rh | head -5

mount /dev/sdb1 /mnt/usb

umount /mnt/usb

mount | grep "/mnt"
```

---

# Day 10 Status

✅ Storage Basics Learned

✅ Disk vs Partition Understood

✅ Filesystem Concepts Understood

✅ Mount/Unmount Concepts Learned

✅ Disk Usage Analysis Practiced
