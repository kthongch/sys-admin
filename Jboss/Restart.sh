#!/bin/bash

# Variables
SERVICE_INSTANCE=/app/jboss/service_instances
WAIT_SECONDS=10
MAX_RETRIES=3
LOG_DIR=/path/to/central/log/folder

# Define the instance numbers as comma-separated list
instance_nums="test1,test2,test3"

# Function to stop JBoss gracefully
stop_jboss() {
    local instance_num=$1
    echo "Stopping JBoss instance $instance_num..."
    ${SERVICE_INSTANCE}/bin/jboss-cli.sh --connect --command=:shutdown > /dev/null 2>&1
}

# Function to kill JBoss process forcefully
kill_jboss() {
    local instance_num=$1
    echo "Killing JBoss process for instance $instance_num..."
    pkill -9 -f "jboss-modules.jar -c standalone$instance_num.xml"
}

# Function to start JBoss
start_jboss() {
    local instance_num=$1
    echo "Starting JBoss instance $instance_num..."
    ${SERVICE_INSTANCE}/bin/standalone.sh -c standalone$instance_num.xml > /dev/null 2>&1 &
}

# Function to check JBoss status
check_jboss_status() {
    local instance_num=$1
    echo "Checking JBoss status for instance $instance_num..."
    ${SERVICE_INSTANCE}/bin/jboss-cli.sh --connect --command=":read-attribute(name=server-state)" | grep -q running
}

# Function to manage JBoss lifecycle for each instance
manage_jboss_instance() {
    local instance_num=$1
    local log_file="${LOG_DIR}/instance_${instance_num}_restart.log"
    
    stop_jboss $instance_num
    
    if check_jboss_status $instance_num; then
        echo "JBoss instance $instance_num stopped successfully."
    else
        echo "Error: Failed to stop JBoss instance $instance_num gracefully. Attempting to kill process..."
        kill_jboss $instance_num
        
        # Wait before attempting to start again
        sleep ${WAIT_SECONDS}
        
        # Check if JBoss is still running after kill
        if check_jboss_status $instance_num; then
            echo "JBoss instance $instance_num killed successfully."
        else
            echo "Error: JBoss instance $instance_num could not be killed. Exiting."
            exit 1
        fi
    fi
    
    # Start JBoss after stopping or killing
    start_jboss $instance_num
    
    # Wait for JBoss to start
    sleep ${WAIT_SECONDS}
    
    # Verify if JBoss started successfully
    if check_jboss_status $instance_num; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") - JBoss instance $instance_num started successfully." >> $log_file
    else
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Error: JBoss instance $instance_num could not be started." >> $log_file
    fi
}

# Loop through each instance_num
IFS=',' read -ra instance_num_array <<< "$instance_nums"
for instance_num in "${instance_num_array[@]}"; do
    echo "Managing JBoss instance $instance_num..."
    manage_jboss_instance $instance_num
done
