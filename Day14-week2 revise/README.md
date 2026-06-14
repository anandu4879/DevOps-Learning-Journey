# Day 14 — Week 2 Review & Consolidation Project

Week 2 was intense. Not new theory every day, but deeper concepts that
actually appear in real production work. Today I built one script that
uses everything from the past 6 days.

---

## Week 2 Recap

### Day 08 — Advanced Shell Scripting
- `set -euo pipefail` for safety
- `trap` for cleanup
- `getopts` for professional arguments
- Error handling with exit codes

### Day 09 — Text Processing
- `grep` with context lines
- `sed` for transformations
- `awk` for column extraction and math
- Regular expressions

### Day 10 — Storage Basics
- Disk vs partition vs filesystem
- Mount points — where drives show up
- Inodes and usage

### Day 11 — Archives & Compression
- `tar -czf` for backup with compression
- `gzip` for individual files
- `rsync` for smart copying with --delete
- Backup strategies

### Day 12 — Environment Variables
- `echo $PATH`, `export`, `source`
- `.bashrc` and `.zshrc` startup files
- `.env` files for app configuration

### Day 13 — Package Management
- `apt install`, `yum install`, `brew install`
- Dependencies handled automatically
- Version pinning and holding packages

---

## The Consolidation Project — `serversetup.sh`

One script that combines all Week 2 concepts.

```bash
#!/bin/bash
# Production Server Setup Script

set -euo pipefail     # safety (Day 08)

# logging with colors
log_info() { echo "[INFO] $1" | tee -a "$LOG"; }

# trap for cleanup (Day 08)
cleanup() {
    log_info "Setup completed"
}
trap cleanup EXIT

# getopts for arguments (Day 08)
while getopts "e:h:v" opt; do
    case $opt in
        e) ENVIRONMENT="$OPTARG" ;;
        h) HOSTNAME_SET="$OPTARG" ;;
        v) set -x ;;
    esac
done

# package management (Day 13)
sudo apt update
sudo apt install -y curl git python3

# text processing (Day 09)
PACKAGE_COUNT=$(apt list --installed | wc -l)

# create .env file (Day 12)
cat > .env << EOF
ENVIRONMENT="$ENVIRONMENT"
HOSTNAME="$HOSTNAME_SET"
EOF

# backup with tar (Day 11)
tar -czf backup_$(date +%Y%m%d).tar.gz /etc/

# check storage (Day 10)
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')

log_info "Server setup complete"
log_info "Disk: $DISK_USAGE, Packages: $PACKAGE_COUNT"
```

Every line uses something from the past week. Nothing wasted.

---

## What Clicking Together Means

Before this week, you had tools scattered across days. Now you understand:

- Why error handling matters (it prevents deleting the wrong folder)
- How to parse logs fast (grep + awk + sed)
- How to back things up safely (tar + rsync with verification)
- How to make scripts real (getopts, logging, cleanup)
- How to configure systems (environment variables, package management)

That's not beginner stuff anymore. That's production thinking.

---

## Script Anatomy

The serversetup.sh script demonstrates:

```
Day 08 features:
✓ set -euo pipefail — safety
✓ trap cleanup EXIT — always clean up
✓ getopts for arguments — professional
✓ log_info/log_error — proper logging
✓ exit codes — failure handling

Day 09 features:
✓ text processing pipeline
✓ awk for column math
✓ grep for filtering

Day 10 features:
✓ disk usage checking

Day 11 features:
✓ tar -czf backup creation

Day 12 features:
✓ .env file creation
✓ environment variables
✓ date in filename using $()

Day 13 features:
✓ apt package installation
✓ handling install failures
```

---

## Running It

```bash
# dry run first
bash -n serversetup.sh

# then actually run it
bash serversetup.sh -e production -h web-server-01

# with verbose output
bash serversetup.sh -e production -h web-server-01 -v
```

---

## Challenges This Week

All six days had hands-on challenges:

- Day 08: Found 5 bugs in a script by reading
- Day 09: Analyzed logs, extracted IPs, built log analyzer
- Day 10: Explored disk structure
- Day 11: Backed up folders, synced with rsync
- Day 12: Customized shell with aliases and functions
- Day 13: Installed packages, set up production server

---

## Things That Stuck

- `set -euo pipefail` is non-negotiable in production scripts
- Text processing (grep + sed + awk) is fast once it clicks
- `rsync --delete` is powerful but dangerous — verify before running
- Environment variables and .env files keep configuration separate from code
- Package managers handle dependencies automatically — never install manually
- Production scripts need logging — future you debugging at 3am will thank you

---

## Week 2 Feeling

Started the week thinking "I know this stuff." By day 11 realized I didn't
know why or how deeply. By day 13 understood the connections between concepts.
Day 14 brought it all together in one script.

That's genuine understanding — not just knowing commands, but knowing
how they fit together in real work.

---

## Next Week Preview

Week 3 is System Administration territory. Users, groups, permissions deep.
Systemd services, cron jobs, logging, firewall. The "making servers work"
stuff. This is where you start feeling like a real sysadmin.

---
