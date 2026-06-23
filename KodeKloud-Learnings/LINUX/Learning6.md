# DevOps Learning Notes - xFusion Challenges

## Date

June 2026

---

# What I Learned

This session taught me how to troubleshoot Linux services, configure HAProxy, debug backend connectivity issues, work with MariaDB, and create automation scripts using Bash.

---

# Challenge 1: HAProxy Configuration

## Objective

Configure HAProxy as a load balancer on the LBR server and route traffic to application servers.

## Key Concepts Learned

### HAProxy Architecture

```text
Client
   |
   v
HAProxy (Port 80)
   |
   +--> App Server 1
   +--> App Server 2
   +--> App Server 3
```

### Important Configuration Sections

Frontend:

```cfg
frontend http_front
    bind *:80
    default_backend apache_backend
```

Backend:

```cfg
backend apache_backend
    balance roundrobin
    server app1 stapp01:3003 check
    server app2 stapp02:3003 check
    server app3 stapp03:3003 check
```

### Validation Command

```bash
haproxy -c -f /etc/haproxy/haproxy.cfg
```

### Lesson Learned

Never restart a service before validating its configuration.

---

# Challenge 2: HAProxy Troubleshooting

## Problem

HAProxy service was not working correctly.

## Troubleshooting Steps

### Check Service Status

```bash
systemctl status haproxy
```

### Validate Configuration

```bash
haproxy -c -f /etc/haproxy/haproxy.cfg
```

### Inspect Problem Lines

```bash
nl -ba /etc/haproxy/haproxy.cfg
```

### Fix Syntax Errors

Examples:

Wrong:

```cfg
server app2 stapp02 :3003 check
```

Correct:

```cfg
server app2 stapp02:3003 check
```

### Lesson Learned

Error messages usually provide:

* File name
* Line number
* Root cause

Read them carefully before making changes.

---

# Challenge 3: HAProxy Backend Connectivity Issue

## Problem

```html
503 Service Unavailable
No server is available to handle this request.
```

HAProxy was running but backend servers were unavailable.

## Investigation

Check service:

```bash
systemctl status haproxy
```

Check backend configuration:

```bash
grep -A10 backend /etc/haproxy/haproxy.cfg
```

Found:

```cfg
server app1 stapp01:6200 check
server app2 stapp02:6200 check
server app3 stapp03:6200 check
```

Actual application port:

```text
8080
```

Fixed:

```cfg
server app1 stapp01:8080 check
server app2 stapp02:8080 check
server app3 stapp03:8080 check
```

### Lesson Learned

503 errors often indicate:

* Backend service unavailable
* Wrong backend IP
* Wrong backend hostname
* Wrong backend port

---

# Challenge 4: MariaDB Service Troubleshooting

## Problem

Application could not connect to the database.

MariaDB service was down.

## Troubleshooting Process

### Check Service Status

```bash
systemctl status mariadb
```

### Check Logs

```bash
journalctl -xeu mariadb.service
```

### Check MariaDB Logs

```bash
tail -50 /var/log/mariadb/mariadb.log
```

Found:

```text
Can't create/write to file '/run/mariadb/mariadb.pid'
Permission denied
```

### Investigate Permissions

```bash
ls -ld /run/mariadb
```

### Fix Ownership

```bash
chown -R mysql:mysql /run/mariadb
```

### Restart Service

```bash
systemctl restart mariadb
```

### Lesson Learned

When logs show:

```text
Permission denied
```

Always check:

* Directory ownership
* File ownership
* Service user permissions

---

# Challenge 5: Bash Automation Script

## Objective

Create a script to archive website files and copy them to a storage server.

## Script

```bash
#!/bin/bash

zip -r /archives/xfusioncorp_blog.zip /var/www/html/blog

scp /archives/xfusioncorp_blog.zip natasha@ststor01:/archives/
```

## Make Executable

```bash
chmod +x /scripts/blog_archive.sh
```

## Passwordless SSH

Generate key:

```bash
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
```

Copy key:

```bash
ssh-copy-id natasha@ststor01
```

### Lesson Learned

Automation should never require manual password entry.

Use SSH key authentication for:

* Scripts
* Cron jobs
* Automated backups
* CI/CD pipelines

---

# Universal Troubleshooting Workflow

Whenever a service is down:

## Step 1

Check status

```bash
systemctl status <service>
```

## Step 2

Check logs

```bash
journalctl -xeu <service>
```

## Step 3

Look for keywords

Examples:

```text
Permission denied
No such file
Address already in use
Connection refused
Configuration error
Cannot bind
```

## Step 4

Verify the resource mentioned

Examples:

```bash
ls -l
ls -ld
ss -tulpn
```

## Step 5

Fix root cause

## Step 6

Restart service

```bash
systemctl restart <service>
```

## Step 7

Verify

```bash
systemctl status <service>
```

---

# Commands I Used Frequently

## Service Management

```bash
systemctl status
systemctl start
systemctl restart
systemctl enable
```

## Logs

```bash
journalctl -xeu
tail -f
```

## Networking

```bash
curl
ping
nc
ss -tulpn
```

## File Inspection

```bash
ls -l
ls -ld
cat
grep
```

## Permissions

```bash
chmod
chown
```

---

# Biggest Takeaway

A DevOps engineer does not memorize every command or configuration.

A DevOps engineer:

1. Reads the error carefully.
2. Uses logs to identify the root cause.
3. Verifies assumptions.
4. Fixes one issue at a time.
5. Tests after every change.

