# Declare content of process CLI here (CLI you prefered to grep)
cli1=/app/kafka/confluent/etc/kafka/zookeeper.properties
cli2=/app/kafka/confluent/etc/kafka/server.properties
cli3=/app/kafka/confluent/etc/kafka/connect-distributed.properties
cli4=/app/kafka/confluent/etc/schema-registry/schema-registry.properties
cli5=/app/kafka/confluent/etc/kafka-rest/kafka-rest.properties
cli6=/app/kafka/confluent/etc/ksqldb/ksql-server.properties
cli7=/app/kafka/confluent/etc/kafka/connect-mm2-CHE-to-AWS-UAT.properties

ProcessList=("$cli1" "$cli2" "$cli3" "$cli4" "$cli5" "$cli6" "$cli7")
FailProcessCount=0

CheckProcessRunning () {


    if pgrep -f "${ProcessName}" >/dev/null; then

    echo "INFO:: $ProcessName is running"

    FailProcessCount=$[$FailProcessCount + 0]

    else


    echo "WARNING:: $ProcessName is not running, please start the process"

    FailProcessCount=$[$FailProcessCount + 1]
    fi
}


for ProcessName in "${ProcessList[@]}"; do

CheckProcessRunning

done

# Report number of failed service
# All services should be working

if [[ $FailProcessCount -gt 0 ]]; then
echo ""
echo "WARNING:: Number of Failed process = $FailProcessCount"
exit 1
else
echo ""
echo "INFO:: All services are running"
exit 0
fi