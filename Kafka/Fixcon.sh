timestamp="$(date "+%F-%H-%M-%S")"
log_path="/path"
log_file="$log_path/fixcon-$timestamp.log"

echo "INFO:: Value log_path="$log_path
echo "INFO:: Value log_file="$log_file
echo "INFO:: Running fixcon command"

fixcon='/home/kafka/fixcon.sh'

$fixcon > $log_file 2> /dev/null

echo "------------------------------"


FailConCount="$(grep "FAILED" "$log_file" | wc -l)"
UnassignConCount="$(grep "UNASSIGNED" "$log_file" | wc -l)"


echo "INFO:: Checking for FAILED CONNECTOR/TASK"

if [[ ${FailConCount} -gt 0 ]] ; then
echo "WARNING:: Found FAILED CONNECTORS/TASKS"
echo "WARNING:: Please check the $log_file"
echo "------------------------------"
exit 1
else 
echo "INFO:: NO FAILED CONNETOR/TASK"
echo "INFO:: ALL CONNECTOR/TASK ARE IN RUNNING STATE"
echo "------------------------------"
fi


echo "INFO:: Checking for UNASSIGNED CONNECTOR/TASK"

if [[ ${UnassignConCount} -gt 0 ]] ; then
echo "WARNING:: Found UNASSIGNED CONNECTORS/TASKS"
echo "WARNING:: Please check the $log_file"
echo "------------------------------"
exit 1
else 
echo "INFO:: NO UNASSIGNED CONNETOR/TASK"
echo "INFO:: ALL CONNECTOR/TASK ARE IN RUNNING STATE"
echo "------------------------------"
fi

