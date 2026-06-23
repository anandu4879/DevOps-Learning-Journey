# Day 21 — Week 3 Consolidation & Integration

Not a learning day. A building day.

Today I took 6 separate topics from Week 3 and built something real:
a complete production server setup that uses all of them together.

---

## Week 3: The Server Administration Foundation

```
Day 15  → User Management        (who can log in, what they can do)
Day 16  → Logging                (what the system is doing)
Day 17  → systemd Services       (apps that run automatically)
Day 18  → Scheduled Tasks        (automate things daily)
Day 19  → SSH                    (secure access and deployment)
Day 20  → Firewalls              (protect from attacks)

These aren't separate skills. They work together to build
secure, monitored, automated production systems.
```

---

## The Integration Project

Built a complete server setup script that uses all 6 concepts:

### Day 15 Integration — User Management

```bash
# Create app user (restricted, no shell)
sudo useradd -m -s /bin/false webapp
sudo mkdir -p /opt/myapp
sudo chown -R webapp:webapp /opt/myapp
sudo chmod 750 /opt/myapp
```

Why: Running as app user prevents attackers from getting root access.

### Day 16 Integration — Logging

```bash
# App logs to journalctl automatically
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapp

# View with:
journalctl -u myapp -f
```

Why: You can't debug what you can't see.

### Day 17 Integration — systemd Service

```bash
[Service]
Restart=always
RestartSec=5

# If app crashes, restarts automatically in 5 seconds
```

Why: Production apps must stay running 24/7.

### Day 18 Integration — Scheduled Backups

```bash
# Backup script runs daily at 2am
0 2 * * * /usr/local/bin/myapp-backup.sh

# Keeps 7 days of backups automatically
find /backups -name "*.tar.gz" -mtime +7 -delete
```

Why: Backups save your career when things break.

### Day 19 Integration — SSH Deployment

```bash
#!/bin/bash
# deploy.sh - deploy code via SSH

scp -r ./code/* myserver:/opt/myapp/
ssh myserver "sudo systemctl restart myapp"
```

Why: You deploy code hundreds of times. Automating prevents mistakes.

### Day 20 Integration — Firewall Protection

```bash
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# Only needed ports are open
```

Why: Every open port is an attack surface.

---

## Real Scenarios

### Scenario 1 — Deploy New Code

```bash
# Local: make changes
git add .
git commit -m "feature: new login page"

# Deploy
./deploy.sh production

# Done! App restarted, old code backed up, logged
```

### Scenario 2 — Server Crashes at 3am

```
3:00 AM - App crashes
3:00:05 AM - systemd restarts it
3:00:10 AM - App is back up

Logs show exactly what happened:
journalctl -u myapp -n 50
```

### Scenario 3 — Attacker Tries to Break In

```
Attacker tries random ports:
- Port 22: rate limited after 6 attempts
- Port 80: redirects to 443
- Port 443: authenticated request required
- Everything else: dropped by firewall

Logs show all attempts:
grep "[UFW BLOCK]" /var/log/ufw.log
```

### Scenario 4 — 2am Backup Runs Automatically

```
2:00 AM - Backup starts
2:00:30 AM - App backed up
2:00:31 AM - Old backups (>7 days) deleted
2:00:32 AM - Log entry: "Backup complete"

You sleep. Computer works.
```

---

---

## The "Aha" Moment

Week 3 wasn't about 6 separate tools. It was about understanding
how production systems actually work:

1. Restrict who can do what (users)
2. Record what happened (logs)
3. Keep apps running (services)
4. Automate routine work (scheduling)
5. Deploy safely (SSH)
6. Protect from attacks (firewalls)

Put these together = a production system that runs itself,
logs everything, and survives attacks.

---

## Week 3 Mindset Shift

**Beginning of week**: Tools. Separate commands. Separate concerns.

**Middle of week**: Understanding. How things work. Why they matter.

**End of week**: Integration. How it all works together. How to build real systems.

This is the difference between someone who knows commands
and someone who can build production systems.

---

---

## Statistics

```
Week 3 work:
- 6 separate topics
- 6 integration challenges
- 1 complete working system

Days: 21 total
Weeks: 3 complete
Topics: User management, logging, services, scheduling, SSH, firewalls
Lines of code: 500+ in production scripts
```


## Real DevOps Engineer Workflow

This is what you just learned to do:

```
Code change → Git commit
      ↓
SSH deploy to server
      ↓
systemd restarts app
      ↓
journalctl logs it
      ↓
Automatic daily backup
      ↓
Firewall protects it
      ↓
Metrics show all is well

This is production DevOps.
```

---

## Things That Clicked

- Week 3 isn't 6 topics, it's 1 system with 6 layers
- Users provide isolation
- Logs provide visibility
- Services provide reliability
- Scheduling provides automation
- SSH provides deployment
- Firewalls provide protection

Stack them together = production system.

---

## The Real Value

You didn't just learn tools. You learned the architecture of
how servers actually work in the real world.

Every production server on the planet uses these 6 things:
- Someone (or some system) manages users
- Everything is logged
- Critical services are managed
- Work is scheduled
- Code is deployed
- Traffic is controlled

You just built one from scratch. That's not a beginner skill.

---
