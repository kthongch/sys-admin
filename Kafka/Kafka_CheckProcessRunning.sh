# Declare content of process CLI here (CLI you prefered to grep)
zookeeper=/app/kafka/confluent/etc/kafka/zookeeper.properties
server=/app/kafka/confluent/etc/kafka/server.properties
connect=/app/kafka/confluent/etc/kafka/connect-distributed.properties
schema=/app/kafka/confluent/etc/schema-registry/schema-registry.properties
rest=/app/kafka/confluent/etc/kafka-rest/kafka-rest.properties
ksqldb=/app/kafka/confluent/etc/ksqldb/ksql-server.properties
mrm=/app/kafka/confluent/etc/kafka/connect-mm2-CHE-to-AWS-UAT.properties

ProcessList=("$zookeeper" "$server" "$connect" "$schema" "$rest" "$ksqldb" "$mrm")
FailProcessCount=0

CheckProcessRunning () {


    if ps aux | grep -v "grep" | grep "${ProcessName}" >/dev/null; then

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