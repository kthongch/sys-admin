# Declare Hydra variables
WORKING_DIRECTORY="/path"
USERPASS="user:pass"

# Get Hostname
HOSTNAME=$(hostname)

# Set the Kafka connect URL
KAFKA_CONNECT_URL="https://$HOSTNAME:8083"


# Set HTML report file name
HTML_REPORT="$WORKING_DIRECTORY/check_con_report.html"

#Function to generate HTML Report
generate_HTML_report(){
    echo "<table border=\"1\">" >> "$HTML_REPORT"
    echo "<tr><th>Connector Name</th><th>Connector Status</th><th>Task Status</th></tr>" >> "$HTML_REPORT"

    # Get list of all connectors

        printf "%-60s | %-40s | %-40s\n" "Connector" "status" "task"
        printf "%-60s | %-40s | %-40s\n" "--------------------" "--------------------" "--------------------"

    ConnectorList=$(curl -k -u $USERPASS -s "$KAFKA_CONNECT_URL/connectors")

    for Connector in $(echo "${ConnectorList}" | jq -r '.[]'); do
        
        # Get Connector Status
        status=$(curl -k -u $USERPASS -s "$KAFKA_CONNECT_URL/connectors/$Connector/status" | jq -r '.connector.state')

        # Get Task Status  
        task=$(curl -k -u $USERPASS -s "$KAFKA_CONNECT_URL/connectors/$Connector/status" | jq -r '.tasks[].state')

        # Print output through console
        printf "%-60s | %-40s | %-40s\n" "$Connector" "$status" "$task"

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
        echo "<tr><td style=\"text-align: left;\">$Connector</td><td>$reported_status</td><td>$reported_task</td></tr>" >> "$HTML_REPORT"


    done

    echo "</table>" >> "$HTML_REPORT"

}

# Generate HTML Report
generate_HTML_report
echo ""
echo "INFO:: Generating HTML report to $HTML_REPORT"
