# Path to checking
checking_path='/deployments'

check_disk_space_threshold () {
    threshold=10 #10% of available disk space
    disk_usage=$(df -h "$checking_path" | grep "$checking_path" | awk '{sub(/%/,"", $5); print $5}')

    if [ "$disk_usage" -gt $((100 - threshold)) ]; then
    echo "WARNING: $checking_path space used $disk_usage%. Avalablie disk space are under $threshold% threshold"
    echo "WARNING: Please free up the $checking_path disk space"

    else
    echo "INFO:  $checking_path space used $disk_usage%. Avalablie disk space are above $threshold% threshold"
    echo "INFO: Proceed the deployments"
    fi
}

check_disk_space_threshold