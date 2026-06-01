#!/bin/bash

while true
do
    current_time=$(date +"%H:%M:%S")
    current_user=$(whoami)

    disk_used=$(df -h / | awk 'NR==2 {print $3 " / " $2}')

    ram_used=$(vm_stat | awk '
    /Pages active/ {active=$3}
    /Pages wired down/ {wired=$4}
    /Pages free/ {free=$3}
    END {
        used=(active+wired)*4096/1024/1024
        unused=free*4096/1024/1024
        printf "%.0fM used, %.0fM unused", used, unused
    }')

    top_process=$(ps -Ao pid,%cpu,comm --sort=-%cpu | sed -n '2p')

    echo "===== System Monitor — $current_time ====="
    echo "User       : $current_user"
    echo "Disk Used  : $disk_used"
    echo "RAM Used   : $ram_used"
    echo "Top Process: $top_process"
    echo "=========================================="

    sleep 5
done