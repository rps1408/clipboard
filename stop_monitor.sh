#!/bin/bash
# stop_monitor.sh - stop monitoring and generate summary JSON

LOG_FILE="monitor.log"
OUT_FILE="perf_summary.json"

echo "[INFO] Stopping monitoring..."

# Kill monitor.sh background process
pkill -f monitor.sh || true

if [ ! -f "$LOG_FILE" ]; then
    echo "[ERROR] Log file not found."
    exit 1
fi

# Extract CPU and RAM values
cpu_values=$(awk '{print $2}' "$LOG_FILE" | cut -d: -f2)
ram_values=$(awk '{print $3}' "$LOG_FILE" | cut -d: -f2)

# Compute averages and max
avg_cpu=$(echo "$cpu_values" | awk '{sum+=$1} END {if (NR>0) printf "%.2f", sum/NR; else print 0}')
max_cpu=$(echo "$cpu_values" | sort -nr | head -1)

avg_ram=$(echo "$ram_values" | awk '{sum+=$1} END {if (NR>0) printf "%.2f", sum/NR; else print 0}')
max_ram=$(echo "$ram_values" | sort -nr | head -1)

# Save JSON summary
cat <<EOF > "$OUT_FILE"
{
  "cpu": {
    "avg": $avg_cpu,
    "max": $max_cpu
  },
  "ram": {
    "avg": $avg_ram,
    "max": $max_ram
  }
}
EOF

echo "[INFO] Summary written to $OUT_FILE"
