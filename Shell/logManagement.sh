#!/bin/bash

# Parent directory containing log directories
parent_dir="/app/microservices/project"

# Threshold for disk usage percentage
full_threshold=100
low_threshold=20

# Number of days to consider for deleting old log files. Please adjust this value based on disk space and log size
days=5

# Function to delete old log files
delete_old_logs() {
    local log_dir=$1

    # Find and delete log files older than specified days
    find "$log_dir" -name "*.log" -type f -mtime +$days -exec rm -f {} \;
}

# Function to restart service
restart_service() {
    local service_name=$1

    # Restart service
    systemctl restart "$service_name"
}

# Iterate over each log directory matching the wildcard
for log_dir in "$parent_dir"/*/logs; do
    # Get disk usage percentage of log directory
    disk_usage=$(df -h "$log_dir" | grep "$log_dir" | awk '{sub(/%/,"", $5); print $5}')

    # Check disk usage conditions
    if [ $disk_usage -eq $full_threshold ]; then
        echo "Disk usage of $log_dir is at $full_threshold%. Deleting old log files and restarting service..."
        delete_old_logs "$log_dir"
        # Example: Restarting service
        # restart_service "your_service_name"
        echo "Old log files older than $days days have been deleted in $log_dir."
        echo "Service restarted."
    elif [ $disk_usage -lt $low_threshold ]; then
        echo "Disk usage of $log_dir is below $low_threshold%. Deleting old log files..."
        delete_old_logs "$log_dir"
        echo "Old log files older than $days days have been deleted in $log_dir."
    else
        echo "Disk usage of $log_dir is between $low_threshold% and $full_threshold%. No action needed."
    fi
done
