# Declare Hydra variables
USERPASS="user:pass"

# Get Hostname
HOSTNAME=$(hostname)

# Set the Kafka connect URL
KAFKA_CONNECT_URL="https://$HOSTNAME:8083"

#Function to generate HTML Report
generate_HTML_report(){
    echo "<table border=\"1\">"
    echo "<tr><th style=\"background-color: #d4c8ff;\">Connector Name</th><th style=\"background-color: #d4c8ff;\">Connector Status</th><th style=\"background-color: #d4c8ff;\">Task Status</th></tr>"

    # Get list of all connectors
    ConnectorList=$(curl -k -u $USERPASS -s "$KAFKA_CONNECT_URL/connectors")

    for Connector in $(echo "${ConnectorList}" | jq -r '.[]'); do
        
        # Get Connector Status
        status=$(curl -k -u $USERPASS -s "$KAFKA_CONNECT_URL/connectors/$Connector/status" | jq -r '.connector.state')

        # Get Task Status  
        task=$(curl -k -u $USERPASS -s "$KAFKA_CONNECT_URL/connectors/$Connector/status" | jq -r '.tasks[].state')

        # Highlight FAILED connector status
        if [ "$status" = "FAILED" ] || [ "$status" = "UNASSIGNED" ]; then

            reported_status="<span style=\"color: red;\">$status</span>"



        else

            reported_status="$status"

        fi

        # Highlight FAILED connector task
        if [ "$task" = "FAILED" ] || [ "$task" = "UNASSIGNED" ]; then

            reported_task="<span style=\"color: red;\">$task</span>"

        else

            reported_task="$task"

        fi

        # Output to HTML report
        echo "<tr><td style=\"text-align: left;\">$Connector</td><td style=\"text-align: center;\">$reported_status</td><td style=\"text-align: center;\">$reported_task</td></tr>"


    done

    echo "</table>"
    echo "<br>"

}

# Generate HTML Report
generate_HTML_report
