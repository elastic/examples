#!/bin/bash


# Wait for Elasticsearch to start up before doing anything.
until curl -u elastic:changeme -s http://elasticsearch:9200/_cat/health -o /dev/null; do
    echo Waiting for Elasticsearch...
    sleep 1
done
echo "Setting password to ${ES_PASSWORD}"
curl -s -XPUT -u elastic:changeme 'elasticsearch:9200/_xpack/security/user/elastic/_password' -H "Content-Type: application/json" -d "{
  \"password\" : \"${ES_PASSWORD}\"
}"

# Wait for Kibana to start up before doing anything.
until curl -s http://kibana:5601/login -o /dev/null; do
    echo Waiting for Kibana...
    sleep 1
done

# Import the standard Beats dashboards.
/usr/share/metricbeat/scripts/import_dashboards \
  -beat '' \
  -file /usr/share/metricbeat/beats-dashboards-${ELASTIC_VERSION}.zip \
  -es http://elasticsearch:9200 \
  -user elastic \
  -pass ${ES_PASSWORD}


curl -s -XPUT http://elastic:${ES_PASSWORD}@elasticsearch:9200/.kibana/index-pattern/logstash-* \
     -d '{"title" : "logstash-*",  "timeFieldName": "@timestamp"}'

# Set the default index pattern.
curl -s -XPUT http://elastic:${ES_PASSWORD}@elasticsearch:9200/.kibana/config/${ELASTIC_VERSION} \
     -d "{\"defaultIndex\" : \"${DEFAULT_INDEX_PATTERN}\"}"

# Load any declared ingest pipelines
PIPELINES=/usr/local/bin/pipelines/*.json
for f in $PIPELINES
do
     filename=$(basename $f)
     pipeline_id="${filename%.*}"
     echo "Loading $pipeline_id ingest chain..."
     curl -s  -H 'Content-Type: application/json' -XPUT http://elastic:${ES_PASSWORD}@elasticsearch:9200/_ingest/pipeline/$pipeline_id -d@$f
done

# Load any declared extra index templates
TEMPLATES=/usr/local/bin/templates/*.json
for f in $TEMPLATES
do
     filename=$(basename $f)
     template_id="${filename%.*}"
     echo "Loading $template_id template..."
     curl -s  -H 'Content-Type: application/json' -XPUT http://elastic:${ES_PASSWORD}@elasticsearch:9200/_template/$template_id -d@$f
     #We assume we want an index pattern in kibana
     curl -s -XPUT http://elastic:${ES_PASSWORD}@elasticsearch:9200/.kibana/index-pattern/$template_id-* \
     -d "{\"title\" : \"$template_id-*\",  \"timeFieldName\": \"@timestamp\"}"
done
