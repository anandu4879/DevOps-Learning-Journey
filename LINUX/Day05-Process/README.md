# Day 05 — Process Management, cron, systemctl & System Monitoring

Biggest day yet in terms of how much actually clicked. Process management
felt abstract at first but once I started running ps and watching things live
in top it started making a lot of sense. The cron and systemctl stuff at the
end was genuinely satisfying — automating things and making scripts run as
services feels like real sysadmin work.

---

## What is a Process?

Every program running on your system is a process. When you run a command
Linux creates a process for it, gives it a unique ID, and tracks it.

```
PID   — Process ID, unique number for this process
PPID  — Parent Process ID, who spawned this process
UID   — which user owns it
TTY   — which terminal it's attached to
STAT  — current state of the process
```

Every process comes from a parent. Your terminal spawns your shell, your
shell spawns commands you run. It's a tree all the way up to PID 1 which
is systemd — the first process Linux starts on boot.

```bash
echo $$         # your current shell's PID
echo $!         # PID of the last background command
```

### Process States

```
R   Running              — actively using CPU right now
S   Sleeping             — waiting for something, most are here
D   Uninterruptible      — waiting for disk/IO, can't be killed
Z   Zombie               — finished but parent hasn't cleaned it up
T   Stopped              — paused, usually by Ctrl+Z
```

---

## Watching Processes

### `ps` — snapshot of what's running

```bash
ps                          # your processes in this terminal
ps aux                      # every process on the system
ps -ef                      # another full view, shows PPID too
ps auxf                     # tree view — shows parent/child

# filter
ps aux | grep bash
ps aux | grep python

# sort by CPU
ps aux | sort -rk3 | head -10       # Mac
ps aux --sort=-%cpu | head -10      # Linux

# sort by memory
ps aux | sort -rk4 | head -10       # Mac
ps aux --sort=-%mem | head -10      # Linux

# pick your own columns
ps -eo pid,ppid,user,stat,cmd
ps -eo pid,%cpu,%mem,cmd
```

Reading `ps aux`:
```
USER    PID  %CPU  %MEM   VSZ   RSS  TTY   STAT  START  TIME  COMMAND
anand  1234   0.0   0.1  1234  4567  pts/0  Ss   10:00  0:00  bash
               ↑     ↑                      ↑
               │     │                      └── process state
               │     └──────────────────────── % of RAM used
               └────────────────────────────── % of CPU used
```

---

### `top` — live process viewer

```bash
top                     # live view, updates every 3 seconds
top -u anand            # filter to one user
top -n 1                # run once and exit — good in scripts
```

Inside top:
```
q       quit
k       kill a process
M       sort by memory
P       sort by CPU
u       filter by user
1       show individual CPU cores
```

Reading the top header:
```
load average: 0.15, 0.10, 0.05
               ↑      ↑     ↑
             1 min  5 min  15 min

# if load average is above your number of CPU cores
# your system is under pressure
```

---

## Controlling Processes

### Signals — how you talk to a process

You don't kill a process directly — you send it a signal and the process
decides what to do with it. Most important ones:

```
Signal    Number   What it does
─────────────────────────────────────────────────────
SIGHUP      1      Reload config — used for web servers
SIGINT      2      Interrupt — same as Ctrl+C
SIGKILL     9      Kill immediately — cannot be ignored
SIGTERM    15      Graceful stop — process can clean up first
SIGSTOP    19      Pause — cannot be ignored
SIGCONT    18      Resume a paused process
SIGTSTP    20      Stop from terminal — same as Ctrl+Z
```

### `kill` — send signals by PID

```bash
kill 1234               # SIGTERM — graceful, try this first
kill -9 1234            # SIGKILL — force kill, last resort
kill -1 1234            # SIGHUP — reload config
kill -15 1234           # same as default kill
kill 1234 5678 9012     # kill multiple at once
```

`kill -15` vs `kill -9`:
```
kill -15    process gets warning, saves files, closes connections, exits clean
            process CAN ignore this signal
            always try this first

kill -9     kernel kills it instantly, no cleanup at all
            process CANNOT ignore this — it's just gone
            use only when -15 doesn't work
```

### `pkill` and `killall` — kill by name

```bash
pkill firefox               # kill by name
pkill -9 firefox            # force kill by name
pkill -u anand              # kill all processes for a user
pkill -f "python script.py" # match full command line

killall firefox             # similar to pkill
killall -9 firefox
```

---

## Foreground & Background Jobs

```bash
./script.sh             # runs in foreground — terminal is blocked
./script.sh &           # runs in background — terminal stays free
# [1] 12345 — shows job number and PID

jobs                    # list all background jobs
jobs -l                 # with PIDs

fg                      # bring most recent job to foreground
fg %1                   # bring job number 1
bg                      # resume stopped job in background
bg %1                   # resume job number 1

# typical flow
./longscript.sh         # start it
Ctrl+Z                  # pause it
bg                      # send to background
jobs                    # verify it's running
fg                      # bring back when needed
```

### `nohup` — survive logout

```bash
nohup ./script.sh &                     # keeps running after logout
nohup ./script.sh > output.log 2>&1 &   # save output to file
tail -f nohup.out                       # watch output live
```

---

## Process Priority — Niceness

Every process has a niceness value. Range is -20 (highest priority) to
19 (lowest). Default is 0. Lower number = greedier for CPU.

```bash
nice -n 10 ./script.sh      # start with lower priority
nice -n -10 ./script.sh     # higher priority — needs root

renice 10 -p 1234           # change running process priority
renice 10 -u anand          # change all processes for a user

ps -eo pid,ni,cmd           # see niceness column
```

---

## cron — Scheduling Tasks

cron is your personal assistant that runs commands on a schedule
automatically. You write what you want done and when — cron handles the rest.

```bash
crontab -e          # edit your schedule
crontab -l          # see your current schedule
crontab -r          # delete everything — careful
```

### Cron syntax

```
*    *    *    *    *   command
↑    ↑    ↑    ↑    ↑
│    │    │    │    └── day of week  (0-6, Sunday=0)
│    │    │    └─────── month        (1-12)
│    │    └──────────── day of month (1-31)
│    └─────────────────hour          (0-23)
└──────────────────────minute        (0-59)
```

Special characters:
```
*       every possible value
*/15    every 15 units
1-5     range from 1 to 5
1,3,5   specific values
```

Shortcuts:
```bash
@reboot     # once at startup
@hourly     # 0 * * * *
@daily      # 0 0 * * *
@weekly     # 0 0 * * 0
@monthly    # 0 0 1 * *
```

Real examples:
```bash
# backup repo every night at midnight
0 0 * * * cd ~/linux-journey && git add . && git commit -m "auto backup" && git push

# clean /tmp every Sunday at 3am
0 3 * * 0 rm -rf /tmp/*

# log disk usage every hour
0 * * * * df -h >> ~/disk_log.txt

# run script every 5 minutes
*/5 * * * * /home/anand/scripts/monitor.sh

# always redirect output or it fills up your mail
0 9 * * * /path/script.sh >> /var/log/myjob.log 2>&1
```

---

## systemctl — Managing Services

A service is a program that runs in the background automatically. Web
servers, SSH, databases — all services. systemd manages them all and
systemctl is how you control systemd.

```bash
# start, stop, restart
systemctl start nginx
systemctl stop nginx
systemctl restart nginx
systemctl reload nginx          # reload config without stopping

# boot behaviour
systemctl enable nginx          # start automatically on boot
systemctl disable nginx         # don't start on boot

# check status
systemctl status nginx          # detailed status + recent logs
systemctl is-active nginx       # just: active or inactive
systemctl is-enabled nginx      # just: enabled or disabled

# see everything
systemctl list-units                        # all active units
systemctl list-units --failed               # only broken ones
systemctl list-units --type=service         # only services
```

Reading `systemctl status`:
```
● nginx.service
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled)
   Active: active (running) since Mon 2026-06-01
  Main PID: 1234 (nginx)
```

### Writing your own service file

You can turn any script into a service that starts on boot and
restarts if it crashes.

```ini
# /etc/systemd/system/mymonitor.service

[Unit]
Description=My process monitor script
After=network.target

[Service]
Type=simple
User=anand
ExecStart=/home/anand/scripts/monitor.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload        # tell systemd about the new file
sudo systemctl start mymonitor
sudo systemctl enable mymonitor
systemctl status mymonitor
```

### journalctl — reading service logs

```bash
journalctl -u nginx             # logs for one service
journalctl -u nginx -f          # live follow
journalctl -u nginx -n 50       # last 50 lines
journalctl -b                   # logs since last boot
journalctl -p err               # only errors
journalctl --since "2026-06-01 10:00" --until "2026-06-01 11:00"
```

---

## Disk & Memory Monitoring

### Disk

```bash
df -h                           # all filesystems
df -h | grep disk3s5            # Mac — just main drive
du -sh *                        # size of everything here
du -h ~ | sort -rh | head -10   # top 10 largest in home folder
du -sh /var/log/*               # what's eating log space

# find large files
find / -type f -size +100M 2>/dev/null
find ~ -type f -size +50M

# live disk updates
watch -n 2 df -h
```

### Memory

```bash
top -l 1 | grep PhysMem         # Mac
free -h                         # Linux

# reading free -h
#        total   used   free   shared  buff/cache  available
# Mem:   7.7G    4.2G   800M   120M    2.7G        3.2G
#                                                   ↑
#                               this is what actually matters

# top memory processes
ps aux | sort -rk4 | head -10           # Mac
ps aux --sort=-%mem | head -10          # Linux

# watch memory live
free -h -s 2                            # Linux
```

---

## Scripts I Wrote Today

### `procmon.sh`
Interactive process monitor — shows uptime, top CPU and memory processes,
finds zombie processes, lets you search by name and kill gracefully or
by force. Logs everything killed with a timestamp.

### `healthcheck.sh`
Full system health report — checks disk usage and flags partitions above
80%, checks available memory, shows top processes, lists failed services,
finds large files. Saves a dated report file. Set up as a daily cron job
at 7am.

### `mymonitor.service`
systemd service file for monitor.sh — starts on boot, restarts
automatically on failure, runs as my user.

---

## Things That Tripped Me Up

- `kill` without a signal number sends SIGTERM (15) not SIGKILL (9).
  I kept assuming kill meant force kill — it doesn't. Always try -15
  first, only use -9 when nothing else works.
- cron output goes to mail if you don't redirect it. Always add
  `>> logfile.log 2>&1` at the end of every cron job.
- `systemctl enable` doesn't start the service right now — it just
  marks it to start on next boot. Use `start` separately.
- `free -h` shows "free" memory as tiny — that's normal. Linux uses
  spare RAM as cache. The "available" column is the real number to watch.
- After creating a service file you must run `systemctl daemon-reload`
  or systemd won't see it.

---

## Mac vs Linux Differences

| Task | Linux | Mac |
|------|-------|-----|
| Memory info | `free -h` | `top -l 1 \| grep PhysMem` |
| Services | `systemctl` | `launchctl` (completely different) |
| Service logs | `journalctl` | `log show` or Console app |
| Sort ps by CPU | `--sort=-%cpu` | `sort -rk3` |
| Sort ps by mem | `--sort=-%mem` | `sort -rk4` |

---