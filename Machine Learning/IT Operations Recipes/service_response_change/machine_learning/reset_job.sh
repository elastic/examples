#!/usr/bin/env bash


if [ -z "$1" ]
  then
    echo "No job name supplied - Usage: $0 <job_name> <host_port> <username> <password>"
    exit 1
fi

JOB_ID=$1
USERNAME="elastic"
PASSWORD="changeme"
HOST='localhost:9200'

if [ "$2" ] ; then
  HOST=$2
fi

if [ "$3" ] ; then
  USERNAME=$3
fi

if [ "$4" ] ; then
  PASSWORD=$4
fi
printf "Resetting $JOB_ID Job"

ROOT="http://${HOST}/_xpack/ml"
JOBS="${ROOT}/anomaly_detectors"
DATAFEEDS="${ROOT}/datafeeds"

printf "\n== Creating job ${JOB_ID}..."
api_response=$(curl -s --w "%{http_code}" -X PUT -H 'Content-Type: application/json' ${JOBS}/${JOB_ID} -u $USERNAME:$PASSWORD -d @job.json)

if [ 0 -eq $? ] && [[ $api_response  == *"\"job_id\":\"$JOB_ID\""* ]] && [[ $api_response  == *"200"* ]]; then
    printf "OK"
else
    printf "ERROR. Unable to add $1 Job"
    echo $api_response
    exit 1
fi

printf "\n== Creating datafeed for ${JOB_ID}..."
api_response=$(curl -s --w "%{http_code}" -X PUT -H 'Content-Type: application/json' ${DATAFEEDS}/datafeed-${JOB_ID} -u $USERNAME:$PASSWORD -d @data_feed.json)

if [ 0 -eq $? ] && [[ $api_response  == *"\"datafeed_id\":\"datafeed-$1\""* ]] && [[ $api_response  == *"200"* ]]; then
    printf "OK"

else
    printf "ERROR. Unable to add datafeed-$1 Datafeed"
    echo $api_response
    exit 1
fi

printf "\n== Opening job for ${JOB_ID}... "
api_response=$(curl -H 'Content-Type: application/json' -s --w "%{http_code}" -X POST ${JOBS}/${JOB_ID}/_open -u $USERNAME:$PASSWORD)
if [ 0 -eq $? ] && [[ $api_response  == *"\"opened\":true"* ]] && [[ $api_response  == *"200"* ]]; then
    printf "OK\n"
else
    printf "ERROR. Job $1 could not be opened\n"
    echo $api_response
    exit 1
fi
