#!/bin/bash
set -e

# ---- Config ----
REPO_URL="https://raw.githubusercontent.com/<your-org>/<your-repo>/main"
MONITOR_SCRIPT="monitor.sh"
STOP_MONITOR_SCRIPT="stop_monitor.sh"
S3_BUCKET="s3://my-automation-metrics"
RUN_ID=$(date +"%Y%m%d_%H%M%S")   # unique run ID
METRICS_FILE="perf_summary.json"

# ---- Fetch monitoring scripts ----
echo "[INFO] Downloading monitoring scripts..."
curl -s -O "$REPO_URL/$MONITOR_SCRIPT"
curl -s -O "$REPO_URL/$STOP_MONITOR_SCRIPT"

chmod +x $MONITOR_SCRIPT $STOP_MONITOR_SCRIPT

# ---- Start monitoring ----
echo "[INFO] Starting monitoring..."
./$MONITOR_SCRIPT &
MONITOR_PID=$!

# ---- Run automation tests ----
echo "[INFO] Running automation tests..."
# Replace with your test command
./gradlew clean test

# ---- Stop monitoring ----
echo "[INFO] Stopping monitoring..."
./$STOP_MONITOR_SCRIPT

# ---- Upload metrics to S3 ----
if [ -f "$METRICS_FILE" ]; then
    echo "[INFO] Uploading metrics to S3..."
    aws s3 cp "$METRICS_FILE" "$S3_BUCKET/$RUN_ID-$METRICS_FILE"
    echo "[INFO] Metrics uploaded to $S3_BUCKET/$RUN_ID-$METRICS_FILE"
else
    echo "[WARN] Metrics file not found, skipping upload."
fi

# ---- Cleanup ----
wait $MONITOR_PID || true
echo "[INFO] Automation + Monitoring complete."
