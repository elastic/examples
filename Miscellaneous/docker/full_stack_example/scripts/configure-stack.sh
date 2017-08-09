#!/bin/bash


# Wait for Elasticsearch to start up before doing anything.
until curl -u elastic:changeme -s http://elasticsearch:9200/_cat/health -o /dev/null; do
    echo Waiting for Elasticsearch...
    sleep 1
done
echo "Setting password to ${ES_PASSWORD}"
curl -XPUT -u elastic:changeme 'elasticsearch:9200/_xpack/security/user/elastic/_password' -H "Content-Type: application/json" -d "{
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