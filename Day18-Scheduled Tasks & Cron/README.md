# Day 18 — Scheduled Tasks & Cron Jobs

Today was about making things happen automatically on a schedule.
Backups at 2am. Reports every Monday. Cleanup every day. All without
you being awake to run them.

---

## Why Schedule Tasks

Without scheduling: you have to remember to run backups, reports, cleanup.
With scheduling: computer does it automatically forever.

```
Backup at 2am every night
Report every Monday morning
Cleanup old files daily
Health check every hour

You sleep. Computer works.
```

---

## Cron — The Task Scheduler

Cron is a daemon that runs tasks on a schedule.

```bash
# edit your cron jobs
crontab -e

# see your cron jobs
crontab -l

# remove all cron jobs
crontab -r
```

---

## Cron Syntax (The Confusing Part)

```
* * * * * command
│ │ │ │ │
│ │ │ │ └─ day of week (0-6, 0=Sunday)
│ │ │ └─── month (1-12)
│ │ └───── day of month (1-31)
│ └─────── hour (0-23)
└───────── minute (0-59)
```

### Examples

```bash
0 2 * * *           # 2:00 AM every day
0 0 * * 1           # midnight every Monday
*/5 * * * *         # every 5 minutes
0 9 1 * *           # 9:00 AM on 1st of month
30 3 * * 0          # 3:30 AM every Sunday
0 */6 * * *         # every 6 hours
```

### Shortcuts

```bash
@yearly             # once a year
@monthly            # once a month
@weekly             # once a week
@daily              # every day
@hourly             # every hour
@reboot             # at boot
```

---

## Create Cron Jobs

```bash
# edit crontab
crontab -e

# add your job:
0 2 * * * /home/anand/backup.sh

# save (Ctrl+O, Enter, Ctrl+X in nano)

# verify it was added
crontab -l

# check system logs for cron activity
grep CRON /var/log/syslog | tail -10
journalctl SYSLOG_IDENTIFIER=CRON | tail -20
```

---

## Good Cron Job Script

Always use full paths and log:

```bash
#!/bin/bash
set -euo pipefail

LOG="/var/log/backup.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"
}

log "Backup started"

# Do work
tar -czf /backups/db.tar.gz /var/lib/postgresql/

if [ $? -eq 0 ]; then
    log "Backup successful"
else
    log "Backup FAILED"
    exit 1
fi

# Cleanup old backups
find /backups -name "*.tar.gz" -mtime +7 -delete

log "Backup completed"
```

In crontab:
```bash
0 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1
#                                      └─ logs go to file
#                                         2>&1 = errors too
```

---

## System Cron (vs User Cron)

User cron: `crontab -e` (your personal jobs)

System cron: for admin jobs
```bash
# System cron files
/etc/cron.d/          # custom cron files
/etc/cron.daily/      # runs daily
/etc/cron.weekly/     # runs weekly
/etc/cron.monthly/    # runs monthly
/etc/cron.hourly/     # runs hourly

# Just drop a script there
sudo cp backup.sh /etc/cron.daily/
sudo chmod +x /etc/cron.daily/backup.sh

# It runs automatically on schedule
```

In system cron, must specify user:
```bash
0 2 * * * root /usr/local/bin/backup.sh
#         ↑
#         username required in system cron
```

---

## systemd Timers (Modern Alternative)

systemd timers are newer, more powerful than cron.

Create two files:

**Service file** (`/etc/systemd/system/backup.service`):
```ini
[Unit]
Description=Backup Service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
StandardOutput=journal
StandardError=journal
```

**Timer file** (`/etc/systemd/system/backup.timer`):
```ini
[Unit]
Description=Daily Backup Timer
Requires=backup.service

[Timer]
OnCalendar=daily
OnCalendar=*-*-* 02:00:00
Persistent=true
# Persistent = run missed tasks when server comes back

[Install]
WantedBy=timers.target
```

Use it:
```bash
# enable and start
sudo systemctl enable backup.timer
sudo systemctl start backup.timer

# check status
sudo systemctl status backup.timer

# see logs
journalctl -u backup.service
```

### OnCalendar Format

```bash
OnCalendar=daily              # every day at midnight
OnCalendar=*-*-* 02:00:00     # 2:00 AM every day
OnCalendar=*-*-* 09:00:00     # 9:00 AM every day
OnCalendar=Mon *-*-* 09:00:00 # Monday at 9:00 AM
OnCalendar=*-01-01 00:00:00   # Jan 1 at midnight
OnCalendar=*-*-1 03:00:00     # 1st of month at 3am
```

---

## Real Scenarios

### Scenario 1 — Daily Database Backup

```bash
#!/bin/bash
set -euo pipefail

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
LOG="/var/log/db_backup.log"

mkdir -p "$BACKUP_DIR"

{
    echo "[$(date)] Backup started"
    pg_dump mydb > "$BACKUP_DIR/db_$DATE.sql"
    gzip "$BACKUP_DIR/db_$DATE.sql"
    find "$BACKUP_DIR" -name "db_*.sql.gz" -mtime +7 -delete
    echo "[$(date)] Backup completed"
} >> "$LOG" 2>&1
```

Crontab:
```bash
0 2 * * * /usr/local/bin/db-backup.sh
# daily at 2am
```

### Scenario 2 — Hourly Health Check

```bash
#!/bin/bash
LOG="/var/log/healthcheck.log"

{
    echo "[$(date)] Health check"
    
    # Check services
    systemctl is-active nginx || echo "nginx DOWN"
    systemctl is-active postgres || echo "postgres DOWN"
    
    # Check disk
    DISK=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    [ "$DISK" -gt 80 ] && echo "Disk at ${DISK}%"
    
    echo "[$(date)] Complete"
} >> "$LOG" 2>&1
```

Crontab:
```bash
0 * * * * /usr/local/bin/healthcheck.sh
# every hour
```

### Scenario 3 — Weekly Report

```bash
#!/bin/bash
REPORT="/tmp/weekly_$(date +%Y%W).txt"

{
    echo "=== Weekly Report $(date) ==="
    echo "Failed logins: $(grep -c 'Failed password' /var/log/auth.log)"
    echo "Disk usage: $(df -h /)"
    echo "Services: $(systemctl status | grep running | wc -l)"
} > "$REPORT"

# Email it: mail -s "Report" admin@example.com < "$REPORT"
```

Crontab:
```bash
0 9 * * 1 /usr/local/bin/weekly-report.sh
# Monday at 9am
```

## Common Mistakes

```bash
# ❌ WRONG: cron can't find script
0 2 * * * backup.sh
# Script runs from cron working directory, not ~

# ✅ RIGHT: use full path
0 2 * * * /usr/local/bin/backup.sh

# ❌ WRONG: no logging
0 2 * * * /usr/local/bin/backup.sh

# ✅ RIGHT: log everything
0 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1

# ❌ WRONG: password prompts
0 2 * * * sudo psql -c "VACUUM"
# cron won't have terminal for password

# ✅ RIGHT: .pgpass file or no-password setup
0 2 * * * /usr/local/bin/vacuum-db.sh
```

---

## Monitoring Cron Jobs

```bash
# see if a job ran
tail -f /var/log/syslog | grep CRON

# see journal logs
journalctl SYSLOG_IDENTIFIER=CRON

# check your specific script's log
tail -f /var/log/backup.log

# test a job manually
/usr/local/bin/backup.sh

# check timing
# if job didn't run, check crontab syntax
crontab -l

# check if cron service is running
sudo systemctl status cron

# list all active cron jobs
sudo ps aux | grep cron
```

---

## Things That Clicked

- Cron syntax: minute, hour, day, month, day-of-week
- Always use full paths in cron jobs
- Always log what cron jobs do
- `crontab -l` shows what's scheduled
- `/etc/cron.daily/` runs automatically, no crontab needed
- systemd timers are more powerful but more complex
- `Persistent=true` in timers runs missed jobs when server comes back up
- Cron won't have a terminal, so scripts must not prompt for input

---

## Cron vs systemd Timers

| Feature | Cron | systemd Timer |
|---------|------|---------------|
| Syntax | Simple (*/5 * * * *) | Complex (OnCalendar) |
| Logging | Manual | journalctl |
| Missed tasks | Lost if server down | Can recover with Persistent |
| Accuracy | Minute level | Second level |
| Complex conditions | Limited | Full systemd features |

For most things: use cron. For complex: use systemd.

---

## Real Production Checklist

When setting up production scheduled tasks:

```bash
☐ Use full paths: /usr/local/bin/script.sh
☐ Add logging: >> /var/log/script.log 2>&1
☐ Test manually first: /usr/local/bin/script.sh
☐ Redirect errors: 2>&1
☐ Check crontab syntax: crontab -l
☐ Monitor logs: tail -f /var/log/script.log
☐ Set correct user: sudo chown root:root /usr/local/bin/script.sh
☐ Make executable: chmod +x /usr/local/bin/script.sh
☐ Test after reboot: does it still run?
☐ Have backup of all scheduled jobs
```

---

## Tomorrow — Day 19
SSH deep dive — keys, config, tunneling, scp, rsync over SSH.
The tool you'll use more than anything else as a DevOps engineer.