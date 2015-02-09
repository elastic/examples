/elasticsearch/bin/elasticsearch &
sleep 10
curl -XPUT 'http://localhost:9200/_snapshot/backup' -d '{
    "type": "fs",
    "settings": {
        "location": "/lapdsnap",
        "compress": true
    }
}'
curl -XPOST "localhost:9200/_snapshot/backup/snapshot/_restore"
/kibana/bin/kibana
