# Day 17 — systemd & Services

Today was about managing services — making apps start automatically,
restart on crash, and handle dependencies. This is core DevOps work.

---

## What Is systemd?

systemd is the manager for everything on Linux:
- Services (nginx, postgres, your app)
- Devices (disks, USB drives)
- Mount points (filesystems)
- Timers (like cron but better)
- Targets (boot stages)

You control it with `systemctl`.

---

## systemctl — Control Services

```bash
# start a service
sudo systemctl start nginx

# stop a service
sudo systemctl stop nginx

# restart
sudo systemctl restart nginx

# reload config without restarting
sudo systemctl reload nginx

# see status
sudo systemctl status nginx

# start on boot
sudo systemctl enable nginx

# don't start on boot
sudo systemctl disable nginx

# check if running
systemctl is-active nginx

# check if starts on boot
systemctl is-enabled nginx

# list all services
systemctl list-units --type=service

# see failed services
systemctl list-units --failed
```

---

## Service Files — Tell systemd About Your App

A service file is a config file in `/etc/systemd/system/myapp.service`.

```ini
[Unit]
Description=My Python Application
After=network.target
# After = start after network is ready
# Description = what this service is

[Service]
Type=simple
# Type = how the service runs (simple = foreground)

User=appuser
# User = which user runs the service (never root!)

WorkingDirectory=/opt/myapp
# where the app lives

ExecStart=/usr/bin/python3 app.py
# the command to run

Restart=always
RestartSec=10
# restart if crashes, wait 10 seconds

StandardOutput=journal
StandardError=journal
# log to systemd journal (use journalctl to read)

[Install]
WantedBy=multi-user.target
# start when normal boot reaches multi-user
```

---

## Create a Service File (Step by Step)

```bash
# 1. Create app directory
sudo mkdir -p /opt/myapp

# 2. Create the app
sudo cat > /opt/myapp/app.py << 'EOF'
#!/usr/bin/env python3
import time
while True:
    print("App running")
    time.sleep(5)
EOF

# 3. Create user for app (security)
sudo useradd -m -s /bin/false appuser

# 4. Create service file
sudo nano /etc/systemd/system/myapp.service
# paste the service file content above

# 5. Reload systemd
sudo systemctl daemon-reload

# 6. Enable on boot
sudo systemctl enable myapp

# 7. Start it
sudo systemctl start myapp

# 8. Check status
sudo systemctl status myapp

# 9. See logs
journalctl -u myapp -f

# 10. Test restart
sudo systemctl stop myapp
# should restart automatically in 10 seconds
```

---

## Service File Sections Explained

### [Unit] — Identity and Dependencies

```ini
[Unit]
Description=What this service does
Documentation=https://example.com/docs
After=postgresql.service network.target
# After = start AFTER these services
# (but don't fail if they're not available)

Requires=postgresql.service
# Requires = MUST have this, fail if missing

Wants=network-online.target
# Wants = try to start this, but don't fail
```

### [Service] — How to Run It

```ini
[Service]
Type=simple
# Type = what kind of service
# simple = runs in foreground
# forking = forks into background
# oneshot = runs once

User=appuser
Group=appgroup
# who runs the service (security critical)

WorkingDirectory=/opt/app
# where it runs from

ExecStart=/usr/bin/python3 app.py
ExecStop=/bin/kill $MAINPID
# what to run on start/stop

Restart=always
RestartSec=10
# restart on crash, wait 10 seconds

StartLimitInterval=60
StartLimitBurst=5
# if crashes > 5 times in 60 seconds, give up for a bit

StandardOutput=journal
StandardError=journal
# log to systemd journal

SyslogIdentifier=myapp
# name to use in logs

Environment="APP_ENV=production"
# environment variables for the app
```

### [Install] — Boot Integration

```ini
[Install]
WantedBy=multi-user.target
# multi-user.target = normal boot
# graphical.target = desktop boot

Alias=myapp.service
# alternative name for the service
```

---

## Targets — Boot Stages

```
poweroff.target          machine off
rescue.target            emergency mode
multi-user.target        normal boot (servers)
graphical.target         with GUI (desktops)
reboot.target            rebooting
```

Most servers use `multi-user.target`.

```bash
# see current target
systemctl get-default

# see all targets
systemctl list-units --type=target

# change default
sudo systemctl set-default multi-user.target

# see what starts at boot
systemctl list-dependencies multi-user.target
```

---

## Dependencies (One Service Needs Another)

```ini
[Unit]
Description=App that needs database
After=postgresql.service
Wants=postgresql.service
# After = start AFTER postgresql
# Wants = but don't fail if postgresql missing

# OR

Requires=postgresql.service
# Requires = MUST have postgresql
```

---

## Real Service Examples

### Simple Python App

```ini
[Unit]
Description=Simple App
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/app
ExecStart=/usr/bin/python3 app.py
Restart=always
StandardOutput=journal

[Install]
WantedBy=multi-user.target
```

### Production App with Security

```ini
[Unit]
Description=Production API Server
After=postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=api
WorkingDirectory=/opt/api
ExecStart=/usr/bin/python3 server.py
Restart=always
RestartSec=5
StartLimitInterval=60
StartLimitBurst=5

StandardOutput=journal
StandardError=journal

NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=yes
# security hardening

Environment="APP_ENV=production"

[Install]
WantedBy=multi-user.target
```

---

## Challenges Done

### Challenge 1 — Explore systemd
Looked at running services, boot status, service files.

### Challenge 2 — Control Services
Started, stopped, enabled, disabled services.

### Challenge 3 — Create Real Service
Made a Python app into a systemd service.

### Challenge 4 — Understand Dependencies
Saw how services depend on each other.

### Challenge 5 — Understand Targets
Checked boot stages and what runs at each stage.

---

## Scripts Written

No scripts today — but service files are the "script" of systemd.

---

## Things That Clicked

- systemd is the system manager — everything on Linux runs through it
- Service files tell systemd exactly how to run your app
- Never run apps as root — create a dedicated user
- `Restart=always` means "keep it running no matter what"
- `After=postgresql.service` ensures database starts first
- `StandardOutput=journal` makes logs available via journalctl
- `daemon-reload` is required after changing service files
- `systemctl enable` and `systemctl start` are different
  - enable = starts on boot
  - start = starts right now

---

## Production Checklist

When writing a production service file:

```bash
☐ Restart=always (so crashes don't bring everything down)
☐ User=appuser (never root)
☐ WorkingDirectory set correctly
☐ StandardOutput=journal (logs go to journalctl)
☐ After=postgresql.service if it needs database
☐ StartLimitBurst to prevent crash loops
☐ SyslogIdentifier for clear log identification
☐ NoNewPrivileges=true for security
☐ ProtectSystem=strict if handling sensitive data
☐ Test the service with systemctl status
☐ Check logs with journalctl -u servicename
☐ Test restart with systemctl stop
```

---

## Real DevOps Scenario

Deploying an app:

```bash
# 1. Create user
sudo useradd -m -s /bin/false myapp

# 2. Put app code there
sudo git clone ... /opt/myapp
sudo chown -R myapp:myapp /opt/myapp

# 3. Create service file
sudo nano /etc/systemd/system/myapp.service

# 4. Enable and start
sudo systemctl daemon-reload
sudo systemctl enable myapp
sudo systemctl start myapp

# 5. Monitor
journalctl -u myapp -f

# Now:
- If server reboots, app auto-starts
- If app crashes, it auto-restarts
- Logs go to journalctl with one command
- Can restart with: sudo systemctl restart myapp
```

---
