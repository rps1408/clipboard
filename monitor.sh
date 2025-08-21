#!/bin/bash
# monitor.sh - Portable CPU & Memory Monitor (Linux + macOS)

OUTPUT_FILE="resource_metrics.log"
INTERVAL=5   # seconds between samples

# Detect number of CPU cores
if command -v nproc >/dev/null 2>&1; then
    CPU_CORES=$(nproc)
else
    CPU_CORES=$(sysctl -n hw.ncpu)
fi

# Save core count for stop_monitor.sh
echo "$CPU_CORES" > .cpu_cores

# Start fresh
echo "timestamp,cpu_percent,mem_mb" > "$OUTPUT_FILE"

while true; do
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

    # --- CPU Usage (normalized 0–100%) ---
    RAW_CPU=$(ps -A -o %cpu= | awk '{s+=$1} END {print s}')
    CPU=$(echo "scale=2; $RAW_CPU / $CPU_CORES" | bc -l)

    # --- Memory Usage (MB) ---
    MEM=$(ps -A -o rss= | awk '{s+=$1} END {print s/1024}')
    MEM=${MEM:-0}

    echo "$TIMESTAMP,$CPU,$MEM" >> "$OUTPUT_FILE"

    sleep $INTERVAL
done
