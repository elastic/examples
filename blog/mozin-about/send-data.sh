#!/bin/bash

ES_HOST='https://elastic:changeme@abcdef0123456789abcdef0123456789.us-central1.gcp.cloud.es.io:9243'

# Creates a new index called 'indicators' with the given settings
curl -XPUT $ES_HOST/indicators -H 'Content-Type: application/json' -d@index-mappings.json

# Ingests raw data from the curl response of threatfox in the file listed, then does a bulk index to ES
cat data/mozi-raw.json | jq -c -r '.data[]' | \
while read line; do
    echo '{"index":{}}';
    echo $line;
done | \
curl --silent -XPOST \
    -H 'Content-Type: application/x-ndjson' \
    --data-binary \
    @- \
    $ES_HOST/indicators/_doc/_bulk
