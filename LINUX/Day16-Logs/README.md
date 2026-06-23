# Day 16 — Logging & System Analysis

Today was about reading what your system actually did. Logs are your
time machine — they show exactly what happened, when, and why.

---

## Logs Are Everywhere

Linux logs everything:  who logged in, when services crashed, what 
commands ran, security events, everything.

```
/var/log/syslog         → system messages
/var/log/auth.log       → logins, sudo usage
/var/log/kernel.log     → kernel stuff
/var/log/cron.log       → scheduled tasks
/var/log/nginx/         → web server logs
/var/log/postgresql/    → database logs
```

Every line has a pattern:
```
Jun 15 10:34:56 web-01 sshd[1234]: Failed password for invalid user admin from 192.168.1.100
│    │ │        │      │          │
│    │ │        │      └─ process and ID
│    │ │        └─ server name
│    │ └─ time
└─ date

This means: Someone tried SSH login and failed. Good — security worked.
```

---

## Reading Logs — Detective Work

```bash
# See recent lines
tail -20 /var/log/auth.log

# See old lines
head -20 /var/log/auth.log

# Watch in real time
tail -f /var/log/syslog

# Count lines
wc -l /var/log/auth.log

# Find specific events
grep "Failed password" /var/log/auth.log

# Find failed logins
grep "Failed password" /var/log/auth.log | wc -l

# Find successful logins
grep "Accepted" /var/log/auth.log

# Find sudo usage
grep "sudo" /var/log/auth.log

# Find top attacking IPs
grep "Failed password" /var/log/auth.log | \
  grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | \
  sort | uniq -c | sort -rn | head -5
```

---

## `journalctl` — Modern Logging

systemd systems use journalctl instead of syslog.

```bash
# see all logs
journalctl

# last 50 lines
journalctl -n 50

# follow in real time
journalctl -f

# logs for a service
journalctl -u nginx
journalctl -u postgresql
journalctl -u docker

# only errors
journalctl -p err

# warnings and above
journalctl -p warning

# since a time
journalctl --since "2 hours ago"
journalctl --since "2024-06-15 10:00:00"

# until a time
journalctl --until "5 minutes ago"

# combine filters
journalctl -u nginx -p err --since "1 hour ago"
# nginx errors from last hour
```

### Log Levels

```
emerg (0)   catastrophic
alert (1)   needs immediate action
crit (2)    critical
err (3)     error
warning (4) warning
notice (5)  normal but significant
info (6)    information
debug (7)   debug messages
```

---

## Real Log Analysis

### Website Down — Find the Problem

```bash
# when did it go down?
journalctl -u nginx --since "1 hour ago" | tail -20

# what errors?
journalctl -u nginx -p err

# is the database running?
journalctl -u postgresql -p err

# found it: "could not connect to database"
# fix: sudo systemctl restart postgresql
```

### Security — Check for Hacking

```bash
# how many failed login attempts?
grep "Failed password" /var/log/auth.log | wc -l
# if > 100, you're under attack

# who attacked?
grep "Failed password" /var/log/auth.log | \
  grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | \
  sort | uniq -c | sort -rn | head -3

# did they succeed?
grep "Accepted password" /var/log/auth.log | \
  grep -E "successful|accepted" | tail

# if there's a successful login from a suspicious IP, you got hacked
```

---

## `logrotate` — Archive Old Logs

Logs grow forever. logrotate automatically archives and compresses old logs.

```bash
# see logrotate config
cat /etc/logrotate.conf

# service-specific configs
ls /etc/logrotate.d/

# see rotated logs
ls -lh /var/log/syslog*
# shows syslog, syslog.1.gz, syslog.2.gz etc

# read old compressed log
zcat /var/log/syslog.1.gz | head -20
# zcat = uncompress and cat

# test logrotate (dry run, don't actually rotate)
sudo logrotate -d /etc/logrotate.conf
```

A logrotate config:
```
/var/log/app/*.log {
    daily           # rotate once per day
    rotate 14       # keep 14 days
    compress        # gzip old logs
    missingok       # OK if file missing
    notifempty      # don't rotate if empty
    create 0640     # new file permissions
}
```

---

## Writing Your Own Logs

Apps should log to files too.

```bash
#!/bin/bash

LOG="/var/log/myapp.log"

# write a log line with timestamp
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Something happened" >> $LOG

# log and show on screen
echo "Backup started" | tee -a $LOG

# log an error
echo "[$(date)] ERROR: Database failed" >> $LOG

# read the log
tail $LOG

# count errors
grep "ERROR" $LOG | wc -l
```

---

## Logging Best Practices

```bash
log_info()  { echo "[$(date '+%H:%M:%S')] [INFO]  $1" >> $LOG; }
log_error() { echo "[$(date '+%H:%M:%S')] [ERROR] $1" >> $LOG; }
log_warn()  { echo "[$(date '+%H:%M:%S')] [WARN]  $1" >> $LOG; }

log_info "App started"
log_warn "Disk at 85%"
log_error "Database connection failed"

# results in:
# [10:34:56] [INFO]  App started
# [10:34:57] [WARN]  Disk at 85%
# [10:34:58] [ERROR] Database connection failed
```

---

## Challenges Done

### Challenge 1 — Explore Logs
Looked at log files, checked sizes, read recent/old lines, counted lines.

### Challenge 2 — Read Logs Like a Detective
Found SSH attempts, failed logins, successful logins, sudo usage.

### Challenge 3 — Use journalctl
Filtered by service, by time, by log level.

### Challenge 4 — Create Fake Activity
Simulated finding logs of specific events.

### Challenge 5 — Understand logrotate
Saw how old logs compress and archive automatically.

### Challenge 6 — Build Logging Script
Created app that logged events with timestamps and read them back.

---

## Scripts Written

### `loganalyzer.sh`
Full log analysis tool. Shows:
- Failed login attempts
- Top attacking IPs
- Sudo usage
- System errors
- Service status
- Log disk usage
- Activity timeline
- Actionable summary

Real DevOps tool — not just learning.

---

## Things That Clicked

- Logs are timestamped so you can correlate events across the system
- `/var/log/auth.log` is gold for security — shows all login attempts
- `journalctl -f` is like watching your server's heartbeat in real time
- Log levels (err, warn, info, debug) let you filter noise and find real problems
- Failed login count tells you if you're under attack
- `logrotate` prevents `/var/log` from filling your disk
- Every app should log with timestamps — past you at 2am debugging thanks future you

---

## Real DevOps Thinking

When something breaks:
1. Check the relevant log file first
2. Filter to the time it broke
3. Look for ERROR or FAILED lines
4. Read the 5 lines before to understand context
5. That's your problem — now fix it

No guessing. No random reboots. Data-driven debugging.

---

## Mac vs Linux Logging

| Item | Linux | Mac |
|------|-------|-----|
| Logs location | /var/log/ | /var/log/ or ~/Library/Logs |
| System logs | journalctl | log show |
| Auth logs | /var/log/auth.log | /var/log/system.log |
| logrotate | apt install logrotate | native |

Mac has similar concepts, different tools.

---
