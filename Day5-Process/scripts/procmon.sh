#!/bin/bash

LOGFILE="$HOME/process_kill.log"

echo "======================================"
echo "       PROCESS MONITOR SCRIPT"
echo "======================================"

# 1. Show uptime and load average
echo
echo "===== SYSTEM UPTIME ====="
uptime

# 2. Top 5 CPU consuming processes
echo
echo "===== TOP 5 CPU PROCESSES ====="
ps -eo pid,user,%cpu,%mem,cmd --sort=-%cpu | head -n 6

# 3. Top 5 Memory consuming processes
echo
echo "===== TOP 5 MEMORY PROCESSES ====="
ps -eo pid,user,%cpu,%mem,cmd --sort=-%mem | head -n 6

# 4. Show zombie processes
echo
echo "===== ZOMBIE PROCESSES ====="
zombies=$(ps -eo pid,ppid,state,cmd | awk '$3 ~ /Z/')

if [ -z "$zombies" ]; then
    echo "No zombie processes found."
else
    echo "$zombies"
fi

# 5. Search process
echo
read -p "Enter process name to search: " pname

matches=$(ps -eo pid,%cpu,%mem,cmd | grep "$pname" | grep -v grep)

if [ -z "$matches" ]; then
    echo "No matching process found."
    exit 0
fi

echo
echo "Matching Processes:"
echo "$matches"

# Extract first PID
pid=$(echo "$matches" | awk 'NR==1 {print $1}')

echo
read -p "Do you want to kill PID $pid? (y/n): " ans

if [[ "$ans" =~ ^[Yy]$ ]]; then

    echo
    echo "1) Graceful Kill (SIGTERM)"
    echo "2) Force Kill (SIGKILL)"
    read -p "Choose option: " option

    case $option in
        1)
            kill -15 "$pid"
            signal="SIGTERM"
            ;;
        2)
            kill -9 "$pid"
            signal="SIGKILL"
            ;;
        *)
            echo "Invalid choice."
            exit 1
            ;;
    esac

    sleep 2

    # 7. Confirm process is gone
    if ps -p "$pid" > /dev/null 2>&1; then
        echo "Process still running."
    else
        echo "Process successfully terminated."

        # 8. Log kill action
        echo "$(date '+%Y-%m-%d %H:%M:%S') | PID=$pid | Process=$pname | Signal=$signal" >> "$LOGFILE"

        echo "Logged to $LOGFILE"
    fi

else
    echo "Kill operation cancelled."
fi