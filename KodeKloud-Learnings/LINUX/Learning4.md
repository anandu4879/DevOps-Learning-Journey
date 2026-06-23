# Day 4 - Linux Administration & DevOps Practice (KodeKloud Stratos)

## Overview

Today I practiced several real-world Linux administration tasks commonly performed by DevOps Engineers and System Administrators.

Skills covered:

* Linux file permissions
* Group ownership and SetGID
* SSH passwordless authentication
* MOTD (Message of the Day) configuration
* Text processing using grep and sed
* Finding and copying files while preserving directory structure
* Package installation across multiple servers
* Troubleshooting common mistakes

---

# 1. Configure Message of the Day (MOTD)

## Requirement

Update the login banner on all application servers using an approved template.

Source file:

```bash
/home/thor/nautilus_banner
```

Target file:

```bash
/etc/motd
```

## Commands

```bash
scp /home/thor/nautilus_banner tony@stapp01:/tmp/
ssh tony@stapp01
sudo cp /tmp/nautilus_banner /etc/motd
```

Repeat for all app servers.

## Verification

```bash
cat /etc/motd
```

## Key Learning

MOTD stands for Message Of The Day.

Linux displays the contents of:

```bash
/etc/motd
```

after a successful login.

---

# 2. Create Secure Collaborative Directory

## Requirement

Create:

```bash
/sysadmin/data
```

Requirements:

* Group owner = sysadmin
* User and group = rwx
* Others = no access
* Files inherit sysadmin group

## Commands

```bash
sudo mkdir -p /sysadmin/data
sudo chown root:sysadmin /sysadmin/data
sudo chmod 2770 /sysadmin/data
```

## Verification

```bash
ls -ld /sysadmin/data
```

Expected:

```bash
drwxrws--- root sysadmin
```

## Key Learning

### SetGID

```bash
chmod 2770 directory
```

The leading:

```bash
2
```

enables SetGID.

New files automatically inherit the group ownership.

---

# 3. Text Processing with grep and sed

File:

```bash
/home/BSD.txt
```

---

## Delete Lines Containing a Word

Requirement:

Delete lines containing:

```text
software
```

Output:

```bash
/home/BSD_DELETE.txt
```

Command:

```bash
grep -v "software" /home/BSD.txt > /home/BSD_DELETE.txt
```

### Explanation

```bash
-v
```

means invert match.

Print everything except matching lines.

---

## Replace Whole Word Only

Requirement:

Replace:

```text
and
```

with

```text
for
```

Output:

```bash
/home/BSD_REPLACE.txt
```

Command:

```bash
sed 's/\<and\>/for/g' /home/BSD.txt > /home/BSD_REPLACE.txt
```

### Explanation

```bash
\<word\>
```

matches whole words only.

Example:

```text
and     -> replaced
android -> not replaced
command -> not replaced
```

---

# 4. Passwordless SSH Authentication

## Requirement

User:

```bash
thor
```

must access:

```bash
tony@stapp01
steve@stapp02
banner@stapp03
```

without passwords.

---

## Generate Key

Switch to thor:

```bash
su - thor
```

Generate key:

```bash
ssh-keygen -t rsa -N ""
```

---

## Copy Key

```bash
ssh-copy-id tony@stapp01
ssh-copy-id steve@stapp02
ssh-copy-id banner@stapp03
```

---

## Verify

```bash
ssh tony@stapp01
ssh steve@stapp02
ssh banner@stapp03
```

No password prompt should appear.

---

## Common Mistake

I initially created the key as:

```bash
root
```

instead of:

```bash
thor
```

This caused the task to fail.

Always verify:

```bash
whoami
```

before generating SSH keys.

---

# 5. Find and Copy Files While Preserving Structure

## Requirement

Find:

```bash
*.js
```

files from:

```bash
/var/www/html/beta
```

Copy them to:

```bash
/beta
```

while preserving directory structure.

---

## Solution

```bash
mkdir -p /beta

cd /var/www/html/beta

find . -type f -name "*.js" -exec cp --parents {} /beta \;
```

---

## Verification

Count source files:

```bash
find /var/www/html/beta -type f -name "*.js" | wc -l
```

Count copied files:

```bash
find /beta -type f -name "*.js" | wc -l
```

Counts should match.

---

## Common Mistake

I accidentally ran:

```bash
cd /var/www/html/official
```

instead of:

```bash
cd /var/www/html/beta
```

Result:

Wrong files copied.

Lesson:

Always verify the path before running destructive or bulk operations.

---

# 6. Install Packages on Multiple Servers

## Requirement

Install:

```bash
strace
```

on all application servers.

---

## Commands

### App Server 1

```bash
ssh tony@stapp01
sudo yum install -y strace
```

### App Server 2

```bash
ssh steve@stapp02
sudo yum install -y strace
```

### App Server 3

```bash
ssh banner@stapp03
sudo yum install -y strace
```

---

## Verify

```bash
rpm -q strace
```

or

```bash
strace -V
```

---

# Commands Learned Today

## grep

```bash
grep word file
grep -v word file
```

Used for filtering lines.

---

## sed

```bash
sed 's/old/new/g'
```

Used for text replacement.

---

## find

```bash
find . -type f -name "*.js"
```

Used to locate files.

---

## cp --parents

```bash
cp --parents file destination
```

Preserves directory structure.

---

## ssh-copy-id

```bash
ssh-copy-id user@host
```

Installs SSH public key on remote server.

---

## chmod

```bash
chmod 770 directory
chmod 2770 directory
```

Manages permissions.

---

## chown

```bash
chown user:group file
```

Changes ownership.

---

# DevOps Concepts Reinforced

* Linux permissions
* User ownership
* Group ownership
* SetGID
* SSH key authentication
* Package management
* Text manipulation
* Secure file handling
* Remote server administration
* Troubleshooting production issues

---

# Key Takeaway

Before executing commands:

1. Verify the server.
2. Verify the user.
3. Verify the path.
4. Verify the permissions.
5. Verify the result.

Small mistakes such as using the wrong user or wrong directory can cause an entire task to fail.
