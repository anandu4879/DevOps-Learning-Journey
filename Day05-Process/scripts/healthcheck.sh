#!/bin/bash

REPORT="$HOME/health_$(date +%Y%m%d).txt"

{
echo "========================================="
echo "  System Health Report — $(date)"
echo "========================================="

# 1. Uptime and Load Average

echo -e "\n[Uptime]"
uptime

# 2. Disk Usage

echo -e "\n[Disk Usage]"
df -h | awk '
NR==1 {print; next}
{
print
usage=$5
gsub("%","",usage)
if (usage > 80)
print "WARNING: Partition " $6 " is above 80% usage!"
}
'

# 3. Memory Check

echo -e "\n[Memory]"
free -m

available=$(free -m | awk '/Mem:/ {print $7}')

if [ "$available" -lt 500 ]; then
echo "WARNING: Available memory is below 500MB!"
fi

# 4. Top CPU Processes

echo -e "\n[Top CPU Processes]"
ps -eo pid,user,%cpu,%mem,cmd --sort=-%cpu | head -n 6

# 5. Top Memory Processes

echo -e "\n[Top Memory Processes]"
ps -eo pid,user,%cpu,%mem,cmd --sort=-%mem | head -n 6

# 6. Failed Services

echo -e "\n[Failed Services]"
systemctl --failed --no-pager

# 7. Large Files

echo -e "\n[Large Files in Home Directory]"
find $HOME -type f -size +100M -exec ls -lh {} ;

echo -e "\n========================================="
echo "Report Generated Successfully"
echo "========================================="

} | tee "$REPORT"

echo
echo "Report saved to: $REPORT"
