#!/bin/bash

# Collect Mozi sample data
curl -X POST https://threatfox-api.abuse.ch/api/v1/ -d '{ "query": "taginfo", "tag": "Mozi", "limit": 1000 }' > mozi-raw.json

# Local Elasticsearch & Kibana
ES_HOST='http://elastic:password@localhost:9200'
KBN_HOST='http://elastic:password@localhost:5601'

# Elastic Cloud
# ES_HOST='https://elastic:changeme@abcdef0123456789abcdef0123456789.us-central1.gcp.cloud.es.io:9243'
# KBN_HOST='https://elastic:changeme@0123456789abcdef01234567890abcdef.us-central1.gcp.cloud.es.io:9243'

# Create the Threat Fox Ingest Pipeline
curl -XPUT ${ES_HOST}/_ingest/pipeline/threatfox-enrichment -H 'Content-Type: application/json' -d@ingest-node-pipeline.json

# Creates a new index called 'indicators' with the given settings
curl -XPUT ${ES_HOST}/indicators -H 'Content-Type: application/json' -d@index-settings.json

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

# Create Kibana index pattern
curl -XPOST -H 'kbn-xsrf: true' -H 'Content-Type: application/json' \
     ${KBN_HOST}/api/index_patterns/index_pattern -d'
{
    "override": false,
    "refresh_fields": true,
    "index_pattern": {
        "title": "indicators*",
        "timeFieldName": "event.ingested"
    }
}'
