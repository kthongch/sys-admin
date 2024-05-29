# Path to checking
checking_path='/deployments'

check_disk_space_mb () {
    required_space=50 #50 Mb
    avaiable_space=$(df -BM "$checking_path" | grep "$checking_path" | awk '{sub(/M/,"",$4); print $4}')

    if [[ $required_space -gt $avaiable_space ]]; then
    echo "WARNING: $checking_path have $avaiable_space MB available"
    echo "WARNING: Insufficient disk space. Required $required_space MB"
    echo "WARNING: Please free up the $checking_path space"

    else
    echo "INFO: $checking_path have $avaiable_space MB available"
    echo "INFO: Sufficient disk space. Required $required_space MB"
    echo "INFO: Proceed the deployments"
    fi
    
}

check_disk_space_mb