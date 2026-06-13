# Day 08 - Advanced Shell Scripting 🔧

## Goal

Today we learned how to write production-ready shell scripts with:

* Error handling
* Exit codes
* Cleanup using trap
* Debugging techniques
* Professional argument parsing using getopts
* Reusable DevOps functions
* Deployment script design

---

# 1. Defensive Scripting with set -euo pipefail

## Why?

Without proper error handling, scripts can continue running even when critical commands fail.

### Dangerous Example

```bash
#!/bin/bash

cd /tmp/fakefolder
rm -rf *
echo "cleanup done"
```

Problem:

* `cd` fails
* script continues
* `rm -rf *` executes in current directory
* data loss possible

---

## Safe Version

```bash
#!/bin/bash
set -euo pipefail

cd /tmp/fakefolder
rm -rf *
echo "cleanup done"
```

---

## What Each Option Does

### set -e

Exit immediately when a command fails.

```bash
false
echo "This never runs"
```

---

### set -u

Treat undefined variables as errors.

```bash
echo "$USERNAME"
```

If USERNAME isn't defined:

```bash
unbound variable
```

---

### set -o pipefail

Detect failures inside pipes.

Without:

```bash
cat missingfile | grep test
echo $?
```

May show success.

With pipefail:

```bash
set -o pipefail
```

Pipeline correctly returns failure.

---

# Challenge 1 Analysis

Script:

```bash
#!/bin/bash

BACKUP_DIR=$1
APP_DIR="/var/www/myapp"

cd $BACKUP_DIR
tar -czf backup.tar.gz $APP_DIR
cp backup.tar.gz /storage/backups/
rm backup.tar.gz
echo "Backup complete"
```

## Problems

### 1. Missing set -euo pipefail

Script continues on failures.

### 2. No argument validation

```bash
BACKUP_DIR=$1
```

Fails if argument missing.

### 3. Unquoted variables

```bash
cd $BACKUP_DIR
```

Should be:

```bash
cd "$BACKUP_DIR"
```

### 4. No cd failure handling

```bash
cd "$BACKUP_DIR" || exit 1
```

### 5. Backup path not verified

```bash
/storage/backups/
```

May not exist.

### 6. tar failure ignored

Could create incomplete backup.

### 7. Success message always shown

Even when backup fails.

---

# 2. Exit Codes

Every command returns a number.

| Exit Code | Meaning           |
| --------- | ----------------- |
| 0         | Success           |
| 1         | General error     |
| 2         | Misuse of shell   |
| 126       | Permission denied |
| 127       | Command not found |
| 130       | Ctrl+C            |

---

## Check Exit Code

```bash
ls /etc
echo $?
```

Output:

```bash
0
```

---

## Failed Command

```bash
ls /missing
echo $?
```

Output:

```bash
1
```

---

## AND Operator

```bash
mkdir test && echo "Created"
```

Runs second command only if first succeeds.

---

## OR Operator

```bash
mkdir test || echo "Failed"
```

Runs second command only if first fails.

---

## Common Pattern

```bash
cd /app || {
    echo "Directory missing"
    exit 1
}
```

---

# Challenge 2 Answers

## Ping Google

```bash
ping -c 1 google.com
```

Expected:

```bash
0
```

If network works.

---

## Missing Directory

```bash
ls /nonexistent
```

Expected:

```bash
1
```

---

## Match Exists

```bash
grep root /etc/passwd
```

Expected:

```bash
0
```

---

## Match Missing

```bash
grep zzznomatch /etc/passwd
```

Expected:

```bash
1
```

---

## Read Shadow File

```bash
cat /etc/shadow
```

Expected:

```bash
0
```

As root.

Or:

```bash
1
```

If permission denied.

---

# 3. trap - Cleanup on Exit

## Why Use trap?

Scripts often create:

* Temp files
* Lock files
* Partial backups

These should always be removed.

---

## Example

```bash
#!/bin/bash
set -euo pipefail

cleanup() {
    echo "Cleaning..."
    rm -f /tmp/test.lock
    rm -f /tmp/test.tmp
}

trap cleanup EXIT

touch /tmp/test.lock
touch /tmp/test.tmp

false
```

Cleanup runs automatically.

---

## Error Handler

```bash
on_error() {
    echo "Error on line $1"
}

trap 'on_error $LINENO' ERR
```

---

# Lock Files

Prevent multiple instances.

```bash
LOCK="/tmp/deploy.lock"

if [ -f "$LOCK" ]; then
    echo "Already running"
    exit 1
fi

touch "$LOCK"
```

---

# 4. Script Debugging

## Syntax Check

```bash
bash -n script.sh
```

Checks syntax only.

---

## Debug Mode

```bash
bash -x script.sh
```

Shows every command executed.

Example:

```bash
+ name=anand
+ echo Hello
```

---

## Enable Inside Script

```bash
set -x

problem_area_here

set +x
```

---

# 5 Common Bash Bugs

---

## Bug 1

Wrong:

```bash
name = "anand"
```

Correct:

```bash
name="anand"
```

---

## Bug 2

Wrong:

```bash
cat $file
```

Correct:

```bash
cat "$file"
```

---

## Bug 3

Wrong:

```bash
if [ $name == "anand" ]
```

Correct:

```bash
if [[ "$name" == "anand" ]]
```

---

## Bug 4

Typo in Variable

```bash
echo "$NMAE"
```

Use:

```bash
set -u
```

to detect it.

---

## Bug 5

Pipe Failure Hidden

```bash
cat missing | grep test
```

Fix:

```bash
set -o pipefail
```

---

# 5. getopts

Professional command-line argument parsing.

---

## Example Usage

```bash
./backup.sh -s /var/log -d /backup -c
```

---

## Example Script

```bash
#!/bin/bash
set -euo pipefail

SOURCE=""
DEST=""
COMPRESS=false

usage() {
    echo "Usage: $0 -s source -d dest [-c]"
    exit 1
}

while getopts "s:d:ch" opt
do
    case $opt in
        s) SOURCE="$OPTARG" ;;
        d) DEST="$OPTARG" ;;
        c) COMPRESS=true ;;
        h) usage ;;
        *) usage ;;
    esac
done
```

---

## Understanding

```bash
"s:d:ch"
```

Meaning:

```bash
s: -> requires value
d: -> requires value
c  -> flag
h  -> flag
```

---

# Challenge 5 - netcheck.sh Requirements

## Usage

```bash
./netcheck.sh -h 192.168.1.10 -p 80 -t 3 -v
```

---

## Required Options

| Option | Meaning |
| ------ | ------- |
| -h     | Host    |
| -p     | Port    |
| -t     | Timeout |
| -v     | Verbose |

---

## Checks

### Ping Test

```bash
ping -c 1 host
```

PASS if reachable.

---

### Port Check

```bash
nc -zv host port
```

PASS if open.

---

### Verbose

Show response timing.

```bash
curl -o /dev/null -s -w "%{time_total}\n"
```

---

# 6. Reusable DevOps Functions

---

## Logging

```bash
log() {
    echo "[$(date '+%H:%M:%S')] $*"
}
```

---

## Fatal Error

```bash
die() {
    log "FATAL: $*"
    exit 1
}
```

---

## Require Command

```bash
require() {
    command -v "$1" >/dev/null 2>&1 || \
    die "$1 missing"
}
```

Example:

```bash
require git
require docker
require curl
```

---

## Retry Function

```bash
retry() {
    local attempts=$1
    local delay=$2

    shift 2

    for ((i=1;i<=attempts;i++))
    do
        if "$@"
        then
            return 0
        fi

        sleep "$delay"
    done

    return 1
}
```

---

## Example

```bash
retry 3 5 ping -c 1 google.com
```

Meaning:

* Try 3 times
* Wait 5 seconds between tries
* Exit if all fail

---

# Boss Challenge - deploy.sh Requirements

## Usage

```bash
./deploy.sh -a myapp -e production -b main
```

---

## Required Arguments

```bash
-a app name
-e environment
```

---

## Optional

```bash
-b branch
-v verbose
-h help
```

---

## Environment Validation

Allowed:

```bash
dev
staging
production
```

---

## Safety Checks

Before deployment:

* git installed
* app directory exists
* valid environment
* lock file check

---

## Backup

Create:

```bash
/tmp/backups/<app>_<timestamp>/
```

Copy application files.

---

## Deployment Steps

Log each:

```bash
Pulling code
Installing dependencies
Running tests
Restarting service
```

---

## Failure Handling

If anything fails:

```bash
restore backup
remove lock file
log line number
exit 1
```

---

## Success Summary

Show:

```bash
Application
Environment
Branch
Duration
Timestamp
```

---

## Measure Runtime

```bash
START=$SECONDS

# work

DURATION=$((SECONDS - START))
```

---

# Recommended Repository Structure

```text
day08-advanced-scripting/
│
├── README.md
│
├── scripts/
│   ├── netcheck.sh
│   └── deploy.sh
│
└── practice/
```

---

# Git Commands

```bash
git add .
git commit -m "day08 - advanced shell scripting"
git push origin main
```

---

# Day 08 Summary

By the end of Day 08 you should know:

✅ set -euo pipefail

✅ Exit codes

✅ trap and cleanup

✅ Lock files

✅ bash debugging

✅ getopts

✅ Logging functions

✅ Retry functions

✅ Network checking scripts

✅ Production deployment script structure

These are the exact shell scripting patterns used by DevOps engineers in production environments.
