#!/bin/bash

## To create with security disabled remove -u username:password to curl commands

HOST='localhost'
PORT=9200
VER=5.4.0
INDEX_NAME='user-activity'
URL="http://${HOST}:${PORT}"
USERNAME=elastic
PASSWORD=changeme
printf "\n== Script for creating index and uploading data == \n \n"
printf "\n== Deleting old index == \n\n"
curl -s -u ${USERNAME}:${PASSWORD} -X DELETE ${URL}/${INDEX_NAME}

printf "\n== Creating Index - ${INDEX_NAME} == \n\n"
curl -s  -u ${USERNAME}:${PASSWORD} -X PUT -H 'Content-Type: application/json' ${URL}/${INDEX_NAME} -d '{
   "settings":{
      "number_of_shards":1,
      "number_of_replicas":0
   },
   "mappings":{
      "metric":{
        "properties": {
          "@timestamp": {
            "type": "date",
            "format": "dateOptionalTime"
          },
          "username": {
              "type": "text",
              "fielddata" : true
            },
          "bytesSent": {
            "type": "long"
          }
        }
      }
   }
}'

printf "\n== Bulk uploading data to index... \n"
curl -s -u ${USERNAME}:${PASSWORD} -X POST -H "Content-Type: application/json" ${URL}/${INDEX_NAME}/_bulk --data-binary "@user-activity.json"
printf "\nUser activity loaded"

printf "Adding index-pattern server-*"

curl -s -u ${USERNAME}:${PASSWORD} -XDELETE "http://$HOST:$PORT/.kibana/index-pattern/user-activity"

curl -s -u ${USERNAME}:${PASSWORD} -XPOST -H 'kbn-version: $VER' "http://$HOST:$PORT/.kibana/index-pattern/user-activity/_create" -d '
{
  "title" : "user-activity",
  "timeFieldName": "@timestamp"
}'
