#!/bin/bash

# Collect Mozi sample data
curl -X POST https://threatfox-api.abuse.ch/api/v1/ -d '{ "query": "taginfo", "tag": "Mozi", "limit": 1000 }' > mozi-raw.json

# Local Elasticsearch
ES_HOST='localhost:9200'

# Elastic Cloud
# ES_HOST='https://elastic:changeme@abcdef0123456789abcdef0123456789.us-central1.gcp.cloud.es.io:9243'

# Create the Threat Fox Ingest Pipeline
curl -XPUT ${ES_HOST}/_ingest/pipeline/threatfox-enrichment -d@ingest-node-pipeline.json

# Creates a new index called 'indicators' with the given settings
curl -XPUT ${ES_HOST}/indicators -H 'Content-Type: application/json' -d@index-mappings.json

# Ingests raw data from the cURL response of Threat Fox in the file listed, then does a bulk upload to ES
cat mozi-raw.json | jq -c -r '.data[]' | \
while read line; do
    echo '{"index":{}}';
    echo $line;
done | \
curl --silent -XPOST \
    -H 'Content-Type: application/x-ndjson' \
    --data-binary \
    @- \
    ${ES_HOST}/indicators/_doc/_bulk
