#!/bin/bash

# Parent directory containing log directories
application_dir="/app/microservices/project"

# Threshold for disk usage percentage
full_threshold=100
threshold=80

# Number of days to consider for deleting old log files. Please adjust this value based on disk space and log size
days=5

# Function to delete old log files
delete_old_logs() {

    find "$application_dir" -type d -name 'logs' -exec find {} -maxdepth 1 -name 'application-*.log' -type f -mtime +$days -delete \;
}


    # Get disk usage percentage
    disk_usage=$(df -h "$application_dir" | grep "$application_dir" | awk '{sub(/%/,"", $5); print $5}')

    # Check disk usage conditions
    if [ $disk_usage -eq $full_threshold ]; then

        echo "Disk usage of $log_dir is at $full_threshold%. Deleting old log files and restarting service."

        delete_old_logs

        echo "Old log files older than $days days have been deleted in $log_dir."

        sudo systemctl restart $service_name
        echo "Service restarted."

    elif [ $disk_usage -gt $low_threshold ] || [ $disk_usage -lt $low_threshold ]; then

        echo "Disk usage of $log_dir is below $low_threshold%. Deleting old log files."

        delete_old_logs

        echo "Old log files older than $days days have been deleted in $log_dir."

    else

        echo "Disk usage of $log_dir is between $low_threshold% and $full_threshold%. No action needed."

    fi
