import argparse
import json
import sys
from datetime import datetime, timedelta

from elasticsearch import Elasticsearch
from elasticsearch.client import _make_path

parser = argparse.ArgumentParser()
parser.add_argument("--es_host", default="localhost:9200", help="ES Connection String")
parser.add_argument("--es_user", default="elastic", help="ES User")
parser.add_argument("--es_password", default="changeme", help="ES Password")
parser.add_argument("--interval", default=300, help="Interval in Seconds", type=int)
parser.add_argument("--start_time", help="Start Time")
parser.add_argument("--end_time", help="End Time")
parser.add_argument("--watch_template", help="Watch File")
options = parser.parse_args()

start_time = datetime.strptime(options.start_time, '%Y-%m-%dT%H:%M:%SZ')
end_time = datetime.strptime(options.end_time, '%Y-%m-%dT%H:%M:%SZ')
client = Elasticsearch(hosts=[options.es_host], http_auth=(options.es_user, options.es_password), use_ssl=False,
                           timeout=300)
try:
    cluster = client.info()
except:
    print("Cluster not accessible")
    sys.exit(1)

watch_template = json.loads(open(options.watch_template).read())
next_time = start_time
while next_time < end_time:
    print("Executing for %s-%s seconds"%(next_time.strftime('%Y-%m-%dT%H:%M:%SZ'),options.interval))
    watch_body = watch_template
    watch_body["metadata"]["time_period"] = "%ss"%options.interval
    client.transport.perform_request('POST', _make_path('_xpack',
                                                     'watcher', 'watch', '_execute'), body={
        "trigger_data":{
            "scheduled_time":next_time.strftime('%Y-%m-%dT%H:%M:%SZ')
        },
        "watch":watch_body
    })
    next_time = next_time + timedelta(seconds=options.interval)