#!/bin/bash

# Define variables
SERVER_NAME=`hostname`
INSTANCE_LIST="Instance1,Instance2,Instance3"
JBOSS_HOME="/app/jboss"


# Define another variables
WAIT_SECONDS=60

# Function to stop JBoss gracefully
stop_jboss() {
    local INSTANCE_NUM=$1

    echo "Stopping JBoss instance $INSTANCE_NUM..."

    $JBOSS_HOME/bin/jboss-cli.sh --connect --controller=$MANAGEMENT_BIND_ADDRESS --command=:shutdown > /dev/null 2>&1
}


# Function to kill JBoss process forcefully
kill_jboss() {
    local INSTANCE_NUM=$1 
    echo "Killing JBoss process for instance $INSTANCE_NUM..."

    PIDS=$(ps -aux | grep -v "grep" | grep $MANAGEMENT_BIND_ADDRESS | awk '{print $2}')

        if [ -n "$PIDS" ]; then
            echo "Found the following processes with IP address: $IP_ADDRESS"

            for PID in $PIDS; do
                echo "Killing process with PID: $PID"
                kill -9 "$PID"
            done
            
        else
            echo "No processes found with IP address: $IP_ADDRESS"
        fi
}


# Function to start JBoss
start_jboss() {
    local INSTANCE_NUM=$1
    echo "Starting JBoss instance $INSTANCE_NUM..."
    
    export JAVA_OPTS="-Xms700M -Xmx1000M -Djava.net.preferIPv4Stack=true -Djboss.modules.system.pkgs=org.jboss.byteman -Djava.awt.headless=true"
    sudo -E -u jboss sh -c -E "nohup $JBOSS_HOME/bin/standalone.sh -Djboss.server.base.dir=$JBOSS_HOME/$INSTANCE_NUM -c standalone.xml -b $MANAGEMENT_BIND_ADDRESS -bmanagement $MANAGEMENT_BIND_ADDRESS > /dev/null 2>&1 &"

}


# Function to check JBoss status
check_jboss_status() {
    local INSTANCE_NUM=$1
    echo "Checking JBoss status for instance $INSTANCE_NUM..."

    $JBOSS_HOME/bin/jboss-cli.sh --connect --controller=$MANAGEMENT_BIND_ADDRESS --command=":read-attribute(name=server-state)" | grep -q running
}


# Function to manage JBoss lifecycle for each instance
manage_jboss_instance() {
    local INSTANCE_NUM=$1

    # check if log files is exist
    if [[ -e "$LOG_FILE" ]]; then
        echo "Removing $LOG_FILE"
        rm "$LOG_FILE"
        echo "$LOG_FILE has been deleted"
    else
        echo "$LOG_FILE does not exist"
    fi
    
    stop_jboss $INSTANCE_NUM 
    
    if check_jboss_status $INSTANCE_NUM; then
        echo "Error: Failed to stop JBoss instance $INSTANCE_NUM gracefully. Attempting to kill process..."
        kill_jboss $INSTANCE_NUM 
        
        # Wait before attempting to start again
        sleep 10
        
        # Check if JBoss is still running after kill
        if check_jboss_status $INSTANCE_NUM; then
            echo "Error: JBoss instance $INSTANCE_NUM could not be killed. Exiting."
            exit 1
        else
             echo "JBoss instance $INSTANCE_NUM killed successfully."
        fi

    else
        echo "JBoss instance $INSTANCE_NUM stopped successfully."

    fi
    
    # Start JBoss after stopping or killing
    start_jboss $INSTANCE_NUM
    
    # Wait for JBoss to start
    sleep $WAIT_SECONDS
    
    # Verify if JBoss started successfully
    if check_jboss_status $INSTANCE_NUM; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") - JBoss instance $INSTANCE_NUM started successfully." >> $LOG_FILE
    else
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Error: JBoss instance $INSTANCE_NUM could not be started." >> $LOG_FILE
    fi
}

# Loop through each INSTANCE_NUM
IFS=',' read -ra INSTANCE_LIST <<< "$INSTANCE_LIST"

for INSTANCE_NUM in "${INSTANCE_LIST[@]}"; do

    echo "Managing JBoss instance $INSTANCE_NUM..."
    echo ""

    SERVICE_INSTANCE="$JBOSS_HOME/$INSTANCE_NUM"
    echo "Value SVF Instance:"$SERVICE_INSTANCE

    LOG_FILE="$JBOSS_HOME/daily_restart/${SERVER_NAME}_${INSTANCE_NUM}_restart.log"
    echo "Log File:"$LOG_FILE

    # declare standalone path
    STANDALONE_PATH="${JBOSS_HOME}/${INSTANCE_NUM}/configuration/standalone.xml"
    echo "Value Standalone file:"$STANDALONE_PATH

    # check if variables are empty	
    if [[ -z $STANDALONE_PATH ]]; then
        echo "ERROR:: Please check for missing variable(s)" >> $LOG_FILE
        exit 1
    fi

    # Get Bind management IP
    MANAGEMENT_BIND_ADDRESS=$(cat $STANDALONE_PATH | grep jboss.bind.address: | sed -n 's/.*value="[^:]*:\([^"]*\)\}".*/\1/p')
    echo "Value Management Bind Address:"$MANAGEMENT_BIND_ADDRESS
    echo ""
    manage_jboss_instance $INSTANCE_NUM
    echo ""
    echo "=========================================="
done