# Get Hostname
HOSTNAME=$(hostname)
REPORT_HOSTNAME=$(echo "$HOSTNAME" | cut -d'.' -f1)

#Function to generate HTML Report
generate_HTML_report(){
    echo "<h1>Kafka services and connectors Status Report</h1>"
    echo "<style>table {border-collapse: collapse; border-color: #00718e;} th, td {padding-top: 7px; padding-bottom: 7px; padding-left: 7px; padding-right: 10px;} th {font-weight: 700;background-color: #f2f2f2;} td {font-weight: normal;}</style>"
    echo "<table border=\"1\">"
    echo "<tr><th style=\"background-color: #b5f0ff;\">Server</th><th style=\"background-color: #b5f0ff;\">Service</th><th style=\"background-color: #b5f0ff;\">Service Status</th></tr>"

    ServiceList=("kafka-zookeeper" "kafka-server" "kafka-connect" "kafka-schema-registry" "kafka-rest" "kafka-ksqldb")
    FailServiceCount=0

    CheckServiceEnable () {

        STATUS="$(systemctl is-active ${ServiceName})"

        # Check and Highlight FAILED service status
        if [[ ${STATUS} = "active" ]]; then

        reported_status="$STATUS"

        else

        reported_status="<span style=\"color: red;\">$STATUS</span>"

        fi
    }


    for ServiceName in "${ServiceList[@]}"; do

    CheckServiceEnable

    # Output to HTML report
    echo "<tr><td>$REPORT_HOSTNAME</td><td>$ServiceName</td><td style=\"text-align: center;\">$reported_status</td></tr>"
    
    done

    echo "</table>"
    echo "<br>"

}

# Generate HTML Report
generate_HTML_report
