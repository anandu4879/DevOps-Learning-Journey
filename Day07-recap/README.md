# DevOps Learning Notes - Day 7

## Linux Troubleshooting, Networking & Production Debugging

---

# 11. Why is this bad?

```bash
chmod 777 /var/www/html/
```

## What it does

Gives:

```text
Owner   = rwx
Group   = rwx
Others  = rwx
```

Everyone can:

* Read
* Write
* Execute

---

## Why it's dangerous

Anyone on the server can:

* Modify website files
* Delete files
* Upload malicious code
* Deface the website

This violates the Principle of Least Privilege.

---

## Better approach

```bash
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
```

or

```bash
chmod -R 750 /var/www/html
```

depending on requirements.

---

## Interview Answer

> chmod 777 gives full access to everyone and is a security risk. Permissions should be restricted to only the required users and services.

---

# 12. App Crashed - What's the First Command?

Most beginners check:

```bash
top
```

or

```bash
ps -ef
```

A DevOps engineer checks logs first.

---

## Step 1

```bash
journalctl -xe
```

or

```bash
journalctl -u myapp.service -n 50
```

---

## Step 2

```bash
systemctl status myapp
```

---

## Why?

Logs reveal:

* Permission issues
* Port conflicts
* Application exceptions
* Memory issues
* Service startup failures

---

## Production Thinking

```text
Problem
 ↓
Logs
 ↓
Service Status
 ↓
Processes
 ↓
Resources
```

---

# 13. Find Processes Using More Than 1% CPU

```bash
ps -eo pid,comm,%cpu --sort=-%cpu | awk '$3 > 1'
```

Example:

```text
1234 java 12.5
5678 nginx 2.1
```

---

## Interactive Methods

```bash
top
```

or

```bash
htop
```

---

# 14. Run Script Every Day at 6 AM

Suppose:

```bash
/opt/scripts/backup.sh
```

Cron entry:

```cron
0 6 * * * /opt/scripts/backup.sh >> /var/log/backup.log 2>&1
```

---

## Breakdown

```text
0 6 * * *

Minute = 0
Hour   = 6
```

Runs every day at 6:00 AM.

---

## Logging

```bash
>> /var/log/backup.log
```

Append output.

```bash
2>&1
```

Append errors too.

---

## Best Practice

Always log cron jobs.

Bad:

```cron
0 6 * * * /opt/scripts/backup.sh
```

Good:

```cron
0 6 * * * /opt/scripts/backup.sh >> /var/log/backup.log 2>&1
```

---

# 15. No One Listening on Port 80

Command:

```bash
ss -tulnp | grep LISTEN | grep :80
```

No output.

---

## Meaning

Nothing is listening on port 80.

---

## Possible Causes

### Web Server Stopped

```bash
systemctl status nginx
```

or

```bash
systemctl status httpd
```

---

### Service Crashed

```bash
journalctl -xe
```

---

### Wrong Port

```bash
ss -tulnp
```

Application may be listening on:

```text
8080
8443
3000
```

instead.

---

### Configuration Error

Example:

```nginx
listen 8080;
```

instead of

```nginx
listen 80;
```

---

### Container Failed

```bash
docker ps
```

or

```bash
kubectl get pods
```

---

## Troubleshooting Flow

```text
Traffic
 ↓
Load Balancer
 ↓
Port 80
 ↓
Web Server
 ↓
Application
 ↓
Database
```

---

# 16. Application Cannot Connect to PostgreSQL

Database:

```text
192.168.1.20:5432
```

---

## Step 1 - Verify Application Configuration

```bash
cat application.properties
```

or

```bash
env | grep DB
```

---

## Step 2 - Test Network Reachability

```bash
ping 192.168.1.20
```

---

## Step 3 - Test Port Connectivity

```bash
nc -zv 192.168.1.20 5432
```

---

## Step 4 - Verify PostgreSQL is Listening

On DB server:

```bash
ss -tulnp | grep 5432
```

Expected:

```text
LISTEN 0 128 0.0.0.0:5432
```

---

## Step 5 - Verify Service

```bash
systemctl status postgresql
```

---

## Step 6 - Check Firewall

```bash
firewall-cmd --list-ports
```

or

```bash
iptables -L -n
```

---

## Step 7 - Verify PostgreSQL Configuration

```bash
grep listen_addresses /var/lib/pgsql/data/postgresql.conf
```

Bad:

```text
listen_addresses='localhost'
```

Good:

```text
listen_addresses='*'
```

---

## Step 8 - Check Logs

```bash
journalctl -u postgresql -n 50
```

---

## Troubleshooting Flow

```text
Application
 ↓
Network
 ↓
Port
 ↓
Database Service
 ↓
Firewall
 ↓
Configuration
 ↓
Logs
```

---

# 17. Connection Refused vs Timeout

## Command

```bash
nc -zv 192.168.1.20 5432
```

---

## Connection Refused

```text
Connection refused
```

Meaning:

* Host reachable
* Service unavailable

Possible causes:

* PostgreSQL stopped
* PostgreSQL crashed
* Wrong port
* Not listening

Think:

```text
Network works
Application doesn't
```

---

## Timeout

```text
Connection timed out
```

Meaning:

* No response received

Possible causes:

* Firewall
* Security Group
* Routing problem
* Network ACL

Think:

```text
Network problem
```

---

## Interview Answer

```text
Connection Refused = Host reachable, service unavailable.

Timeout = Network or firewall issue preventing access.
```

---

# 18. DNS Resolving to Wrong IP

## First Command

```bash
dig myapp.com
```

or

```bash
nslookup myapp.com
```

---

## Quick Check

```bash
dig myapp.com +short
```

Example:

```text
10.0.0.50
```

Expected:

```text
34.123.45.67
```

---

## Check Which DNS Server Responded

```bash
dig myapp.com
```

Look for:

```text
SERVER:
```

---

## Query Specific DNS Server

```bash
dig @8.8.8.8 myapp.com
```

---

## Flush Cache

```bash
resolvectl flush-caches
```

or

```bash
systemd-resolve --flush-caches
```

---

# 19. curl Returns 502

Command:

```bash
curl -o /dev/null -s -w "%{http_code}\n" https://myapp.com
```

Output:

```text
502
```

---

## Meaning

```text
Bad Gateway
```

---

## Typical Architecture

```text
User
 ↓
Nginx
 ↓
Application
 ↓
Database
```

---

## What 502 Usually Means

Proxy is working.

Backend application is unhealthy.

---

## Check Nginx Logs

```bash
tail -f /var/log/nginx/error.log
```

---

## Check Application

```bash
systemctl status myapp
```

or

```bash
docker ps
```

or

```bash
kubectl get pods
```

---

## Verify Backend Port

```bash
ss -tulnp
```

Expected:

```text
127.0.0.1:8080
```

If missing:

Application isn't running.

---

## Quick Thinking

```text
502
 ↓
Proxy alive
 ↓
Backend dead
```

---

# 20. SSH Disconnected During Long Script

Question:

Is the script still running?

Answer:

Maybe.

Depends on how it was started.

---

## Normal Execution

```bash
./backup.sh
```

SSH disconnects.

Usually:

```text
Script stops
```

because it receives SIGHUP.

---

## Check After Reconnecting

```bash
ps -ef | grep backup.sh
```

or

```bash
pgrep -af backup
```

---

# How To Prevent It

## Method 1 - tmux (Recommended)

Start session:

```bash
tmux
```

Run script:

```bash
./backup.sh
```

Detach:

```text
Ctrl+b d
```

Reconnect:

```bash
tmux attach
```

---

## Method 2 - screen

```bash
screen
./backup.sh
```

Detach:

```text
Ctrl+a d
```

---

## Method 3 - nohup

```bash
nohup ./backup.sh > backup.log 2>&1 &
```

Monitor:

```bash
tail -f backup.log
```

---

## Method 4 - systemd

```bash
systemctl start backup.service
```

---

# Important DevOps Lessons

## Always Check Logs First

```bash
journalctl -xe
```

---

## Always Verify Ports

```bash
ss -tulnp
```

---

## Always Test Connectivity

```bash
nc -zv HOST PORT
```

---

## Always Log Cron Jobs

```cron
>> logfile 2>&1
```

---

## Use tmux For Long Operations

```bash
tmux
```

---

## Remember

```text
Logs explain WHY.
Ports show WHAT is running.
Network tests show WHERE it breaks.
Services reveal WHETHER it is healthy.
```

This troubleshooting mindset is more valuable than memorizing commands.
