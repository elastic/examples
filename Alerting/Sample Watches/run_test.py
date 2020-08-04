import sys

__author__ = 'dalem@elastic.co'

import datetime
from elasticsearch7 import Elasticsearch
from elasticsearch7.client.ingest import IngestClient
import argparse
import json

parser = argparse.ArgumentParser(description='Index Connection Log data into ES with the last event at the current time')
parser.add_argument('--user',help='user')
parser.add_argument('--password',help='password')
parser.add_argument('--endpoint',help='endpoint')
parser.add_argument('--port',help='port')
parser.add_argument('--protocol',help='protocol')
parser.add_argument('--test_file',help='test file')

parser.set_defaults(endpoint='localhost',port="9200",protocol="http",test_file='data.json',user='elastic',password='changeme')
args = parser.parse_args()
es = Elasticsearch([args.protocol+"://"+args.endpoint+":"+args.port],http_auth=(args.user, args.password))

def find_item(list, key):
    for item in list:
        if key in item:
            return item
    return None

with open(args.test_file,'r') as test_file:
    test=json.loads(test_file.read())
    try:
        es.indices.delete(test['index'])
    except:
        print("Unable to delete current dataset")
        pass
    with open(test['mapping_file'],'r') as mapping_file:
        es.indices.create(index=test["index"],body=json.loads(mapping_file.read()))
    params={}
    if "ingest_pipeline_file" in test:
        with open(test['ingest_pipeline_file'],'r') as ingest_pipeline_file:
            pipeline=json.loads(ingest_pipeline_file.read())
            p = IngestClient(es)
            p.put_pipeline(id=test["watch_name"],body=pipeline)
            params["pipeline"]=test["watch_name"]
    current_data=last_time=datetime.datetime.utcnow()
    i=0
    time_field = test["time_field"] if "time_field" in test else "@timestamp"
    for event in test['events']:
        event_time=current_data+datetime.timedelta(seconds=int(event['offset'] if 'offset' in event else 0))
        event[time_field]=event_time.strftime('%Y-%m-%dT%H:%M:%S.%fZ') if not time_field in event else event[time_field]
        es.index(index=test['index'],body=event,id=event['id'] if "id" in event else i,params=params)
        i+=1
    es.indices.refresh(index=test["index"])
    if 'scripts' in test:
        for script in test['scripts']:
            with open(script['path'], 'r') as script_file:
                es.put_script(id=script["name"],body=json.loads(script_file.read()))

    with open(test['watch_file'],'r') as watch_file:
        watch=json.loads(watch_file.read())
        es.watcher.put_watch(id=test["watch_name"],body=watch)
        response=es.watcher.execute_watch(id=test["watch_name"])

        match = test['match'] if 'match' in test else True
        print("Expected: Watch Condition: %s"%match)
        if not 'condition' in response['watch_record']['result']:
            print("Condition not evaluated due to watch error")
            print("TEST FAIL")
            sys.exit(1)
        met=response['watch_record']['result']['condition']['met']
        print("Received: Watch Condition: %s"%met)
        if match:
            if met and response['watch_record']['result']['condition']['status'] == "success":
                print("Expected: %s"%test['expected_response'])
                logging=find_item(response['watch_record']['result']['actions'],'logging')['logging']
                if logging:
                    print("Received: %s"%logging['logged_text'])
                    if logging['logged_text'] == test['expected_response']:
                        print("TEST PASS")
                        sys.exit(0)
                else:
                    print("Logging action required for testing")
            print("TEST FAIL")
            sys.exit(1)
        else:
            print("TEST %s"%("PASS" if not response['watch_record']['result']['condition']['met'] else "FAIL"))
            sys.exit(met)
