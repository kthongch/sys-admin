# Get Hostname
HOSTNAME=$(hostname)
REPORT_HOSTNAME=$(echo "$HOSTNAME" | cut -d'.' -f1)

generate_HTML_report(){
    echo "<table border=\"1\">"
    echo "<tr><th style=\"background-color: #b5f0ff;\">Server</th><th style=\"background-color: #b5f0ff;\">Service</th><th style=\"background-color: #b5f0ff;\">Service Status</th></tr>"

    # Declare content of process CLI here (CLI you prefered to grep)
    zookeeper=/app/kafka/confluent/etc/kafka/zookeeper.properties
    server=/app/kafka/confluent/etc/kafka/server.properties
    connect=/app/kafka/confluent/etc/kafka/connect-distributed.properties
    schema=/app/kafka/confluent/etc/schema-registry/schema-registry.properties
    rest=/app/kafka/confluent/etc/kafka-rest/kafka-rest.properties
    ksqldb=/app/kafka/confluent/etc/ksqldb/ksql-server.properties
    ksql_AWS_DEV=/app/kafka/confluent/etc/ksqldb/ksql-server-aws-dev.properties
    ksql_AWS_UAT=/app/kafka/confluent/etc/ksqldb/ksql-server-aws-uat.properties
    INT_TEST_AWS_DEV=/app/kafka/confluent/etc/kafka/connect-mm2-INT-TEST-to-AWS-DEV.properties
    INT_TEST_AWS_UAT=/app/kafka/confluent/etc/kafka/connect-mm2-INT-TEST-to-AWS-UAT.properties
    CHE_AWS_DEV=/app/kafka/confluent/etc/kafka/connect-mm2-CHE-to-AWS-DEV.properties
    CHE_AWS_UAT=/app/kafka/confluent/etc/kafka/connect-mm2-CHE-to-AWS-UAT.properties
    INT_EXT_TEST=/app/kafka/confluent/etc/kafka/connect-mm2-INT-to-EXT-TEST.properties

    ProcessList=("$zookeeper" "$server" "$connect" "$schema" "$rest" "$ksqldb" "$ksql_AWS_DEV" "$ksql_AWS_UAT" "$INT_TEST_AWS_DEV" "$INT_TEST_AWS_UAT" "$CHE_AWS_DEV" "$CHE_AWS_UAT" "$INT_EXT_TEST")
    FailProcessCount=0

    CheckProcessRunning () {


        if ps aux | grep -v "grep" | grep "${ProcessName}" >/dev/null; then

        reported_status="active"

        else

        reported_status="<span style=\"color: red;\">inactive</span>"

        fi
    }


    for ProcessName in "${ProcessList[@]}"; do

    CheckProcessRunning

    # Output to HTML report

    ProcessName=$(echo "$ProcessName" | cut -d'/' -f7 | cut -d'.' -f1)

    echo "<tr><td>$REPORT_HOSTNAME</td><td>$ProcessName</td><td style=\"text-align: center;\">$reported_status</td></tr>"

    done

    echo "</table>"
    echo "<br>"

}

# Generate HTML Report
generate_HTML_report