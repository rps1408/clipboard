#!/bin/bash
# stop_monitor.sh - Stops monitor.sh and generates resource_metrics.json

OUTPUT_FILE="resource_metrics.log"
JSON_FILE="resource_metrics.json"

# Kill the monitor.sh process
pkill -f start_monitor.sh

# Wait briefly to ensure it's stopped
sleep 1

if [ ! -f "$OUTPUT_FILE" ]; then
    echo "No metrics log found!"
    exit 1
fi

CPU_CORES=$(cat .cpu_cores 2>/dev/null || echo "unknown")

# Compute statistics
AVG_CPU=$(awk -F, 'NR>1 {sum+=$2; count++} END {if(count>0) print sum/count; else print 0}' "$OUTPUT_FILE")
MAX_CPU=$(awk -F, 'NR>1 {if($2>max) max=$2} END {print max+0}' "$OUTPUT_FILE")

AVG_MEM=$(awk -F, 'NR>1 {sum+=$3; count++} END {if(count>0) print sum/count; else print 0}' "$OUTPUT_FILE")
MAX_MEM=$(awk -F, 'NR>1 {if($3>max) max=$3} END {print max+0}' "$OUTPUT_FILE")

# Save as JSON
cat <<EOF > "$JSON_FILE"
{
  "cpu_cores": "$CPU_CORES",
  "cpu_avg_percent": $AVG_CPU,
  "cpu_max_percent": $MAX_CPU,
  "mem_avg_mb": $AVG_MEM,
  "mem_max_mb": $MAX_MEM
}
EOF

echo "Metrics saved to $JSON_FILE"
