# Day 3 Learning Notes - Linux System Administration & DevOps Fundamentals

## 1. File Text Replacement Using sed

### Objective

Replace text inside files without manually editing them.

### Command

```bash
sed -i 's/Random/Submarine/g' /root/nautilus.xml
```

### Breakdown

| Option    | Meaning                 |
| --------- | ----------------------- |
| sed       | Stream editor           |
| -i        | Modify file in place    |
| s         | Substitute              |
| Random    | Existing text           |
| Submarine | New text                |
| g         | Replace all occurrences |

### Verification

```bash
grep Random /root/nautilus.xml
grep Submarine /root/nautilus.xml
```

### Real DevOps Usage

* Updating configuration values
* Modifying environment files
* Replacing URLs or hostnames during deployments

---

# 2. Secure File Transfer Using SCP

### What is SCP?

SCP stands for Secure Copy Protocol.

Used to securely copy files between Linux servers using SSH.

### Syntax

Copy local file to remote server:

```bash
scp file.txt user@server:/destination/path
```

Copy remote file to local system:

```bash
scp user@server:/path/file.txt .
```

### Example

```bash
scp /tmp/nautilus.txt.gpg tony@stapp01:/home/appdata/
```

### Real DevOps Usage

* Copy deployment artifacts
* Transfer backups
* Move configuration files

---

# 3. Cron Access Control

### Purpose

Control which users can create cron jobs.

### Files

Allow list:

```bash
/etc/cron.allow
```

Deny list:

```bash
/etc/cron.deny
```

### Example

Allow:

```bash
echo "anita" > /etc/cron.allow
```

Deny:

```bash
echo "eric" > /etc/cron.deny
```

### Verification

```bash
cat /etc/cron.allow
cat /etc/cron.deny
```

### Real DevOps Usage

Prevent unauthorized scheduled jobs.

---

# 4. Linux Runlevels and Systemd Targets

### Traditional Runlevels

| Runlevel | Purpose          |
| -------- | ---------------- |
| 0        | Shutdown         |
| 1        | Single User Mode |
| 3        | Multi-user CLI   |
| 5        | GUI Mode         |
| 6        | Reboot           |

### Modern Systemd Targets

| Target            | Equivalent |
| ----------------- | ---------- |
| multi-user.target | Runlevel 3 |
| graphical.target  | Runlevel 5 |

### Set GUI as Default

```bash
systemctl set-default graphical.target
```

### Verify

```bash
systemctl get-default
```

### Output

```text
graphical.target
```

---

# 5. Timezone Management

### Why Important?

Logs and monitoring depend on accurate timestamps.

### View Current Timezone

```bash
timedatectl
```

### Change Timezone

```bash
timedatectl set-timezone America/Belize
```

### Verify

```bash
timedatectl
```

### Real DevOps Usage

* Consistent logging
* Easier troubleshooting
* Correct alert timestamps

---

# 6. Firewalld Fundamentals

## What is a Firewall?

Controls network traffic entering and leaving a server.

### Common Ports

| Port | Service |
| ---- | ------- |
| 22   | SSH     |
| 80   | HTTP    |
| 443  | HTTPS   |
| 3000 | Grafana |
| 8080 | Jenkins |

---

## What is Firewalld?

Linux firewall management service.

### Install

```bash
yum install -y firewalld
```

### Start Service

```bash
systemctl enable firewalld
systemctl start firewalld
```

### Check Status

```bash
systemctl status firewalld
```

---

## Zones

Common zones:

* public
* internal
* trusted
* dmz

### Set Default Zone

```bash
firewall-cmd --set-default-zone=public
```

---

## Open a Port

```bash
firewall-cmd --permanent --zone=public --add-port=3002/tcp
```

### Breakdown

| Option        | Meaning           |
| ------------- | ----------------- |
| --permanent   | Survive reboot    |
| --zone=public | Public zone       |
| --add-port    | Open port         |
| 3002/tcp      | Port and protocol |

### Reload Rules

```bash
firewall-cmd --reload
```

### Verify

```bash
firewall-cmd --list-ports
```

---

# 7. User Process Limits

## Purpose

Prevent users from consuming excessive system resources.

### Configuration File

```bash
/etc/security/limits.conf
```

### Example

```text
nfsuser soft nproc 1026
nfsuser hard nproc 2025
```

### Meaning

| Field       | Meaning               |
| ----------- | --------------------- |
| nfsuser     | Username              |
| soft        | Current limit         |
| hard        | Maximum allowed limit |
| nproc       | Number of processes   |
| 1026 / 2025 | Limit values          |

### Verification

```bash
grep nfsuser /etc/security/limits.conf
```

### Real DevOps Usage

Protect servers from runaway processes.

---

# 8. SELinux Fundamentals

## What is SELinux?

Security-Enhanced Linux.

Provides Mandatory Access Control (MAC).

### Security Layers

```text
User
  ↓
Linux Permissions
  ↓
SELinux Policies
  ↓
Resources
```

### Modes

| Mode       | Description       |
| ---------- | ----------------- |
| Enforcing  | Blocks violations |
| Permissive | Logs only         |
| Disabled   | SELinux off       |

---

## Check Status

```bash
getenforce
```

or

```bash
sestatus
```

---

## Configuration File

```bash
/etc/selinux/config
```

Example:

```text
SELINUX=enforcing
```

Disable permanently:

```text
SELINUX=disabled
```

### Change Using sed

```bash
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
```

---

## Install Required Packages

```bash
yum install -y selinux-policy selinux-policy-targeted
```

### Verify

```bash
rpm -qa | grep selinux
```

---

# 9. Cron and Cronie

## What is Cron?

Linux job scheduler.

Runs commands automatically at scheduled times.

## What is Cronie?

Package providing cron functionality.

### Install

```bash
yum install -y cronie
```

### Start Service

```bash
systemctl enable crond
systemctl start crond
```

### Verify

```bash
systemctl status crond
```

---

## Create Cron Job

Edit root cron:

```bash
crontab -e
```

Add:

```cron
*/5 * * * * echo hello > /tmp/cron_text
```

---

## Cron Syntax

```text
* * * * *
| | | | |
| | | | +-- Day of Week
| | | +---- Month
| | +------ Day of Month
| +-------- Hour
+---------- Minute
```

### Example

```cron
*/5 * * * *
```

Means:

```text
Every 5 minutes
```

---

# Key Commands Learned Today

```bash
sed
scp
crontab
timedatectl
systemctl
firewall-cmd
getenforce
sestatus
setenforce
grep
rpm
yum
```

# DevOps Takeaways

1. Automate repetitive work using cron.
2. Secure servers with firewalld and SELinux.
3. Manage user resource consumption using limits.conf.
4. Maintain consistent server timezones.
5. Transfer files securely using SCP.
6. Understand systemd services and targets.
7. Learn Linux administration before moving deeper into Kubernetes and cloud technologies.

End of Day 3 Notes.
