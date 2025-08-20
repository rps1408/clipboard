#!/bin/bash
# monitor.sh - start resource monitoring (CPU & RAM)
# Runs in background, logs usage to monitor.log

LOG_FILE="monitor.log"

echo "[INFO] Starting monitoring..."
: > "$LOG_FILE"   # truncate previous log if exists

# Collect CPU & Memory every second
while true; do
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    cpu=$(top -bn1 | awk '/^%Cpu/{print 100 - $8}')   # CPU usage %
    mem=$(free -m | awk '/Mem/{printf "%.2f", $3/$2*100}') # RAM usage %

    echo "$timestamp CPU:$cpu RAM:$mem" >> "$LOG_FILE"
    sleep 1
done
