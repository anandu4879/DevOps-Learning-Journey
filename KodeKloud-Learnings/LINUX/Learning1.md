# KodeKloud Engineer Learning Notes

## About

This repository contains my hands-on learning notes from KodeKloud Engineer challenges. The goal is to document Linux, System Administration, Networking, Security, AWS, and DevOps concepts learned through real-world tasks.

---

# Linux User Management

## Create a User

```bash
sudo useradd john
```

Verify:

```bash
id john
```

---

## Create a User Without Home Directory

```bash
sudo useradd -M jim
```

### Explanation

* `useradd` → Create user
* `-M` → Do not create home directory

Verify:

```bash
ls -ld /home/jim
```

Expected:

```text
No such file or directory
```

---

## Create User With Expiry Date

```bash
sudo useradd -e 2027-02-17 mariyam
```

Verify:

```bash
sudo chage -l mariyam
```

Useful for:

* Contractors
* Interns
* Temporary Developers

---

## Create User With Non-Interactive Shell

```bash
sudo useradd -s /sbin/nologin john
```

### Purpose

Prevent interactive login while allowing service account usage.

Common non-login shells:

```bash
/sbin/nologin
/usr/sbin/nologin
/bin/false
```

---

# Linux Group Management

## Create Group

```bash
sudo groupadd nautilus_developers
```

---

## Add User to Group

```bash
sudo usermod -aG nautilus_developers stark
```

### Meaning

* `-a` → Append
* `-G` → Secondary Group

Verify:

```bash
groups stark
```

or

```bash
id stark
```

---

# File Permissions

## Make Script Executable

```bash
chmod +x script.sh
```

---

## Grant Execute Permission to Everyone

```bash
chmod a+x script.sh
```

### Meaning

| Symbol | Meaning |
| ------ | ------- |
| u      | User    |
| g      | Group   |
| o      | Others  |
| a      | All     |

---

## Numeric Permissions

```bash
chmod 755 script.sh
```

Meaning:

```text
7 = rwx
5 = r-x
5 = r-x
```

Result:

```text
rwxr-xr-x
```

---

# Ownership Management

## Change Owner

```bash
sudo chown root file.txt
```

---

## Change Owner and Group

```bash
sudo chown root:root file.txt
```

Verify:

```bash
ls -l file.txt
```

---

# ACL (Access Control Lists)

ACL allows assigning permissions to specific users without changing file ownership.

## Grant Read Permission

```bash
sudo setfacl -m u:jerome:r-- /etc/hostname
```

---

## Remove All Permissions

```bash
sudo setfacl -m u:yousuf:--- /etc/hostname
```

---

## View ACL

```bash
getfacl /etc/hostname
```

---

# Find Command

## Find Files

```bash
find /home/usersdata -type f
```

### Common Options

| Option     | Purpose          |
| ---------- | ---------------- |
| -type f    | Files only       |
| -type d    | Directories only |
| -user rose | Owner filter     |

---

## Find Files Owned by User

```bash
find /home/usersdata -type f -user rose
```

---

# Using -exec

## Syntax

```bash
find path -exec command {} \;
```

### Meaning

* `-exec` → Run command
* `{}` → Current file found
* `\;` → End of command

Example:

```bash
find /tmp -type f -exec rm {} \;
```

Deletes every file found.

---

# Copy Files While Preserving Directory Structure

```bash
find /home/usersdata -type f -user rose -exec cp --parents {} /media \;
```

### What does --parents do?

Original:

```text
/home/usersdata/project/file.txt
```

Copied as:

```text
/media/home/usersdata/project/file.txt
```

Directory structure is preserved.

---

# Tar Archives

## Create Compressed Archive

```bash
tar -czf archive.tar.gz directory/
```

### Meaning

| Option | Meaning          |
| ------ | ---------------- |
| c      | Create           |
| z      | gzip compression |
| f      | File             |

Example:

```bash
tar -czf /home/ammar.tar.gz /data/ammar
```

---

## View Archive Contents

```bash
tar -tzf archive.tar.gz
```

---

# SSH Security

## Disable Root Login

Edit:

```bash
/etc/ssh/sshd_config
```

Set:

```text
PermitRootLogin no
```

Restart service:

```bash
sudo systemctl restart sshd
```

### Why?

Prevents direct root login and improves security.

---

# Useful Commands

## Show Current User

```bash
whoami
```

---

## Show Current Directory

```bash
pwd
```

---

## Show Hostname

```bash
hostname
```

---

## Detailed File Listing

```bash
ls -lh
```

### Meaning

* `l` → Long listing
* `h` → Human-readable sizes

Example:

```text
-rw-r--r-- 1 root root 2.3M backup.tar.gz
```

---

# Common Interview Questions

### Difference Between chmod 755 and chmod 644?

755:

```text
rwxr-xr-x
```

644:

```text
rw-r--r--
```

---

### What is ACL?

Access Control Lists provide fine-grained permissions for specific users and groups beyond standard Linux permissions.

---

### Why Disable Root SSH Login?

Improves security by forcing administrators to log in as normal users and use sudo when required.

---

# Key Learnings

✅ Linux User Management

✅ Linux Groups

✅ File Permissions

✅ ACL Management

✅ SSH Security

✅ Tar and Compression

✅ Find Command

✅ Ownership Management

✅ Script Execution Permissions

✅ Real-world System Administration Tasks

---