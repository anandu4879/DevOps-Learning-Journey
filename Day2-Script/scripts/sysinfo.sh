#!/bin/bash

echo "System Info"
echo "User     : $(whoami)"
echo "Hostname : $(hostname)"
echo "Date     : $(date)"
echo "Disk     : $(df -h | grep disk3s5 | awk '{print $3 " used out of " $2}')"
echo "RAM      : $(top -l 1 | grep PhysMem | awk '{print $2 " used, " $6 " unused"}')"
