# KodeKloud / Nautilus Linux Admin Tasks Reference

## 1. Create User and Group

### Task

Create a user named `sonya` on App Server 2.

Requirements:

* Username: `sonya`
* UID: `1433`
* Home Directory: `/opt/sonya`
* Create group: `nautilus_noc`
* Add user `sonya` to group `nautilus_noc`

### Commands

```bash
groupadd nautilus_noc

mkdir -p /opt/sonya

useradd -u 1433 -d /opt/sonya sonya

usermod -aG nautilus_noc sonya

chown sonya:sonya /opt/sonya
```

### Verify

```bash
id sonya
grep '^nautilus_noc:' /etc/group
```

---

# 2. Configure Firewalld

### Task

* Install firewalld
* Enable and start firewalld
* Set zone to public
* Allow port 6100/tcp

### Commands

```bash
yum install -y firewalld

systemctl enable --now firewalld

firewall-cmd --set-default-zone=public

firewall-cmd --permanent --zone=public --add-port=6100/tcp

firewall-cmd --reload
```

### Verify

```bash
firewall-cmd --get-default-zone

firewall-cmd --zone=public --list-ports
```

---

# 3. Copy File from Jump Server to App Server

### Task

Copy:

```text
/tmp/nautilus.txt.gpg
```

to

```text
/home/webapp
```

on App Server 2.

### Command

```bash
scp /tmp/nautilus.txt.gpg webapp@stapp02:/home/webapp/
```

### Verify

```bash
ssh webapp@stapp02

ls -l /home/webapp/nautilus.txt.gpg
```

---

# 4. Create Directory Structure

### Task

Create:

```text
/opt/app/backup/latest
```

### Command

```bash
mkdir -p /opt/app/backup/latest
```

### Verify

```bash
ls -ld /opt/app/backup/latest
```

---

# 5. Configure ACL Permissions

### Task

File:

```text
/etc/hostname
```

Requirements:

* virat → no permissions
* vivek → read only
* devops group → read/write

### Commands

```bash
setfacl -m u:virat:--- /etc/hostname

setfacl -m u:vivek:r-- /etc/hostname

setfacl -m g:devops:rw- /etc/hostname
```

### Verify

```bash
getfacl /etc/hostname
```

---

# 6. Create Tar Archives

### Task

Create:

```text
/home/natasha/logs.tar
```

and

```text
/home/natasha/logs.tar.gz
```

from:

```text
/var/log
```

### Commands

```bash
tar -cvf /home/natasha/logs.tar /var/log

tar -czvf /home/natasha/logs.tar.gz /var/log
```

### Verify

```bash
ls -lh /home/natasha/logs.tar*

```

---

# 7. Text Processing Using grep and sed

### Task

Source file:

```text
/home/BSD.txt
```

#### A. Remove lines containing

```text
following
```

Save to:

```text
/home/BSD_DELETE.txt
```

#### B. Replace exact word

```text
from
```

with

```text
is
```

Save to:

```text
/home/BSD_REPLACE.txt
```

### Commands

```bash
grep -v 'following' /home/BSD.txt > /home/BSD_DELETE.txt

sed 's/\<from\>/is/g' /home/BSD.txt > /home/BSD_REPLACE.txt
```

---

# 8. Install Apache (httpd)

### Task

Install and start Apache on App Server 2.

### Commands

```bash
yum install -y httpd

systemctl enable --now httpd
```

### Verify

```bash
systemctl status httpd
```

---

# 9. Install Bind Package

### Task

Install bind on all App Servers.

Servers:

```text
stapp01
stapp02
stapp03
```

### Commands

```bash
yum install -y bind

systemctl enable --now named
```

### Verify

```bash
systemctl status named
```

---

# 10. Install SQLite Package

### Task

Install sqlite package on all App Servers.

### Commands

```bash
yum install -y sqlite
```

### Verify

```bash
rpm -q sqlite
```

---

# Common Verification Commands

## User

```bash
id username
```

## Group

```bash
grep '^groupname:' /etc/group
```

## ACL

```bash
getfacl filename
```

## Firewall

```bash
firewall-cmd --list-all
```

## Services

```bash
systemctl status service_name
```

## Installed Packages

```bash
rpm -q package_name
```

## Open Ports

```bash
ss -tulpn
```

## Directory Check

```bash
ls -ld /path
```

---

# Key Learning Points

* `useradd` creates users.
* `usermod -aG` adds users to supplementary groups.
* `mkdir -p` creates nested directories.
* `scp` copies files between servers.
* `setfacl` manages ACL permissions.
* `tar` creates archives.
* `grep -v` removes matching lines.
* `sed` performs text replacements.
* `systemctl enable --now` starts and enables services.
* `firewall-cmd` manages firewalld rules.
* `rpm -q` verifies package installation.
* Always verify after making changes.

```
```
