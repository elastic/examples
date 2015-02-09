#Start Elasticsearch
/elasticsearch/bin/elasticsearch &

#Wait 10 seconds
sleep 10

#Set backup repository to the right path.
curl -XPUT 'http://localhost:9200/_snapshot/backup' -d '{
    "type": "fs",
    "settings": {
        "location": "/lapdsnap",
        "compress": true
    }
}'

#Perform restore of data.
curl -XPOST "localhost:9200/_snapshot/backup/snapshot/_restore"

#Start Kibana
/kibana/bin/kibana
