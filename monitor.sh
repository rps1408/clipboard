#!/bin/bash
# monitor.sh - Portable CPU & Memory Monitor (Linux + macOS)

OUTPUT_FILE="resource_metrics.log"
INTERVAL=5   # seconds between samples

# Start fresh
echo "timestamp,cpu_percent,mem_mb" > "$OUTPUT_FILE"

while true; do
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

    # --- CPU Usage (sum of all processes) ---
    CPU=$(ps -A -o %cpu= | awk '{s+=$1} END {print s}')
    # If empty, set to 0
    CPU=${CPU:-0}

    # --- Memory Usage (sum of all processes) ---
    MEM=$(ps -A -o rss= | awk '{s+=$1} END {print s/1024}')
    MEM=${MEM:-0}

    echo "$TIMESTAMP,$CPU,$MEM" >> "$OUTPUT_FILE"

    sleep $INTERVAL
done
