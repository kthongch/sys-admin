# Declare Hydra variables
WORKING_DIRECTORY="/path"

# Get Hostname
HOSTNAME=$(hostname)

# Set HTML report file name
HTML_REPORT="$WORKING_DIRECTORY/Daily_report_$HOSTNAME.html"

#Function to generate HTML Report
generate_HTML_report(){
    echo "<style>
            table {
                border-collapse: collapse;
                margin: 20px;
            }

            th {
                padding: 8px;
                font-weight: 700;
                background-color: #f2f2f2;
            }

            td {
                padding: 8px;
                font-weight: normal;
            }

        </style>" >> "$HTML_REPORT"
    echo "<h1>Kafka services and connectors Status Report</h1>" >> "$HTML_REPORT"
    echo "<table border=\"1\">" >> "$HTML_REPORT"
    echo "<tr><th>Server</th><th>Service</th><th>Service Status</th></tr>" >> "$HTML_REPORT"

    ServiceList=("kafka-zookeeper" "kafka-server" "kafka-connect" "kafka-schema-registry" "kafka-rest" "kafka-ksqldb")
    FailServiceCount=0

    CheckServiceEnable () {

        STATUS="$(systemctl is-active ${ServiceName})"

        # Check and Highlight FAILED service status
        if [[ ${STATUS} = "active" ]]; then

        echo "INFO:: $ServiceName is active"

        FailServiceCount=$[$FailServiceCount + 0]

        reported_status="$STATUS"

        else


        echo "WARNING:: $ServiceName is not active, please restart the service"

        FailServiceCount=$[$FailServiceCount + 1]

        reported_status="<span style=\"color: red;\">$STATUS</span>"

        fi
    }


    for ServiceName in "${ServiceList[@]}"; do

    CheckServiceEnable

    # Output to HTML report
    echo "<tr><td>$HOSTNAME</td><td>$ServiceName</td><td>$reported_status</td></tr>" >> "$HTML_REPORT"

    done

    echo "</table>" >> "$HTML_REPORT"

}

# Report number of failed service
# All services should be working

# Generate HTML Report
generate_HTML_report

if [[ $FailServiceCount -gt 0 ]]; then
echo ""
echo "WARNING:: Number of Failed service = $FailServiceCount"
else
echo ""
echo "INFO:: All services are running"
fi

echo ""
echo "INFO:: Generating HTML report to $HTML_REPORT"
