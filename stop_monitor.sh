#!/bin/bash
# stop_monitor.sh - Stops monitor.sh and produces summary JSON

OUTPUT_FILE="resource_metrics.log"
SUMMARY_FILE="resource_summary.json"

# Kill monitor.sh process
pkill -f monitor.sh

# Compute summary
if [[ -f "$OUTPUT_FILE" ]]; then
    AVG_CPU=$(awk -F',' 'NR>1 {sum+=$2; count++} END {if(count>0) print sum/count; else print 0}' "$OUTPUT_FILE")
    MAX_CPU=$(awk -F',' 'NR>1 {if($2>max) max=$2} END {print max+0}' "$OUTPUT_FILE")

    AVG_MEM=$(awk -F',' 'NR>1 {sum+=$3; count++} END {if(count>0) print sum/count; else print 0}' "$OUTPUT_FILE")
    MAX_MEM=$(awk -F',' 'NR>1 {if($3>max) max=$3} END {print max+0}' "$OUTPUT_FILE")

    cat <<EOF > "$SUMMARY_FILE"
{
  "avg_cpu_percent": $AVG_CPU,
  "max_cpu_percent": $MAX_CPU,
  "avg_mem_mb": $AVG_MEM,
  "max_mem_mb": $MAX_MEM
}
EOF

    echo "Summary written to $SUMMARY_FILE"
else
    echo "No log file found!"
fi
