ServiceList=("SERVICENAME1" "SERVICENAME2" "SERVICENAME3" "SERVICENAME4" "SERVICENAME5" "SERVICENAME6")
FailServiceCount=0

CheckServiceEnable () {

    STATUS="$(systemctl is-active ${ServiceName})"

    if [[ ${STATUS} = "active" ]]; then

    echo "INFO:: $ServiceName is active"

    FailServiceCount=$[$FailServiceCount + 0]

    else


    echo "WARNING:: $ServiceName is not active, please restart the service"

    FailServiceCount=$[$FailServiceCount + 1]
    fi
}


for ServiceName in "${ServiceList[@]}"; do

CheckServiceEnable

done

# Report number of failed service
# All services should be working

if [[ $FailServiceCount -gt 0 ]]; then
echo ""
echo "WARNING:: Number of Failed service = $FailServiceCount"
exit 1
else
echo ""
echo "INFO:: All services are running"
exit 0
fi