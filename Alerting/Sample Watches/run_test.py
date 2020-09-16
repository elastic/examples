#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# SPDX-FileCopyrightText: 2017 Dale McDiarmid <dalem@elastic.co>
# SPDX-FileCopyrightText: 2017-2020 Robin Schneider <robin.schneider@geberit.com>
# SPDX-FileCopyrightText: 2020 Dan Roscigno <dan@roscigno.com>
# SPDX-License-Identifier: Apache-2.0

from __future__ import (print_function, unicode_literals,
                        absolute_import, division)

import datetime
import json
import logging
import subprocess
import sys

import yaml

from elasticsearch7 import Elasticsearch
from elasticsearch7.client.ingest import IngestClient


def load_file(serialized_file):
    with open(serialized_file, 'r') as serialized_file_fh:
        if serialized_file.endswith('.json'):
            decoded_object = json.loads(serialized_file_fh.read())
        elif serialized_file.endswith('.yml') or serialized_file.endswith('.yaml'):
            decoded_object = yaml.safe_load(serialized_file_fh)
    return decoded_object


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Index Connection Log data into ES with the last event at the current time')
    parser.add_argument('-v', '--verbose', help='verbose output', action='store_true')
    parser.add_argument('--endpoint', help='endpoint')
    parser.add_argument('--port', help='port')
    parser.add_argument('--protocol', help='protocol')
    parser.add_argument('--cacert', help='CA certificate to trust for HTTPS')
    parser.add_argument('--user', help='user')
    parser.add_argument('--password', help='password')
    parser.add_argument('--test_file', help='test file')
    parser.add_argument(
        '--minify-scripts',
        help='Minify script source code as workaround for' +
        ' "Scripts may be no longer than 16384 characters." in ES < v6.6.',
        action='store_true')
    # Ref: https://github.com/elastic/elasticsearch/pull/35184
    parser.add_argument('--keep-index', help='Keep the index where test documents have been loaded to after the test', action='store_true')
    parser.add_argument('--metadata-git-commit', help='Include the git commit hash in the metadata field of the watcher', action='store_true')
    parser.add_argument('--modify-watch-by-eval', help='Python code to modify the watch before loading it into Elastic')
    parser.add_argument(
        '--no-test-index',
        help='Don’t put the test data into an index.',
        action='store_false',
        dest='test_index')
    parser.add_argument(
        '--no-execute-watch',
        help='Do not force watch execution. This can be useful when you use this script to deploy the watch.',
        action='store_false',
        dest='execute_watch')

    parser.set_defaults(endpoint='localhost', port="9200", protocol="http", test_file='data.json', user='elastic', password='changeme')
    args = parser.parse_args()

    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)

    es = Elasticsearch([args.protocol+"://"+args.endpoint+":"+args.port], http_auth=(args.user, args.password), ca_certs=args.cacert)

    test = load_file(args.test_file)

    if args.test_index:
        # Load Mapping
        try:
            es.indices.delete(test['index'])
        except Exception as err:
            print("Unable to delete current dataset")
            pass
        index_template = load_file(test['mapping_file'])
        for unneeded_keys in ['order', 'version', 'index_patterns']:
            index_template.pop(unneeded_keys)
        es.indices.create(index=test["index"], body=index_template)

        # Load pipeline if its declared
        params = {}
        if "ingest_pipeline_file" in test:
            pipeline = load_file(test['ingest_pipeline_file'])
            p = IngestClient(es)
            p.put_pipeline(id=test["watch_name"], body=pipeline)
            params["pipeline"] = test["watch_name"]

        # Index data
        current_data = last_time = datetime.datetime.utcnow()
        i = 0
        time_fields = test.get('time_fields', test.get('time_field', '@timestamp'))
        time_fields = set([time_fields] if isinstance(time_fields, str) else time_fields)
        for event in test['events']:
            # All offsets are in seconds.
            event_time = current_data+datetime.timedelta(seconds=int(event['offset'] if 'offset' in event else 0))
            for time_field in time_fields:
                event.setdefault(time_field, event_time.strftime('%Y-%m-%dT%H:%M:%S.%fZ'))
            es.index(index=test['index'], body=event, id=event['id'] if "id" in event else i, params=params)
            i += 1
        es.indices.refresh(index=test["index"])

    # Load Scripts
    if 'scripts' in test:
        for script in test['scripts']:
            script_content = load_file(script['path'])
            if args.minify_scripts:
                # https://stackoverflow.com/questions/30795954/how-to-uglify-or-minify-c-code
                p = subprocess.Popen(['gcc', '-fpreprocessed', '-dD', '-E', '-P', '-'], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
                script_content['script']['source'] = p.communicate(input=script_content['script']['source'].encode('utf-8'))[0].decode('utf-8')
            es.put_script(id=script["name"], body=script_content)

    # Load Watch and Execute
    watch = load_file(test['watch_file'])

    if args.modify_watch_by_eval:
        eval(compile(args.modify_watch_by_eval, '<string>', 'exec'))

    if args.metadata_git_commit:
        watch.setdefault('metadata', {})
        watch['metadata']['git_commit_hash'] = subprocess.check_output(['git', 'rev-parse', '--short', 'HEAD']).strip()
        watch['metadata']['git_uncommitted_changes'] = True if len(subprocess.check_output(['git', 'status', '--porcelain']).strip()) > 0 else False

    es.watcher.put_watch(id=test["watch_name"], body=watch)

    if args.execute_watch:
        response = es.watcher.execute_watch(id=test["watch_name"])

        # Cleanup after the test to not pollute the environment for other tests.
        if not args.keep_index:
            try:
                es.indices.delete(test['index'])
            except Exception as err:
                print("Unable to delete current dataset")
                pass

        # Confirm Matches
        match = test['match'] if 'match' in test else True
        print("Expected: Watch Condition: {}".format(match))
        if 'condition' not in response['watch_record']['result']:
            print("Condition not evaluated due to watch error: {}".format(
                json.dumps(response['watch_record'], sort_keys=True, indent=2)
            ))
            print("TEST FAIL")
            sys.exit(1)
        met = response['watch_record']['result']['condition']['met']
        print("Received: Watch Condition: {}".format(met))
        if match:
            if met and response['watch_record']['result']['condition']['status'] == "success":
                print("Expected: {}".format(test.get('expected_response')))
                if len(response['watch_record']['result']['actions']) == 0:
                    if response['watch_record']['result']['transform']['status'] == 'failure':
                        print("No actions where taken because transform failed: {}".format(
                            json.dumps(response['watch_record']['result'], sort_keys=True, indent=2)
                        ))
                    else:
                        print("No actions where taken: {}".format(
                            json.dumps(response['watch_record']['result'], sort_keys=True, indent=2)
                        ))
                    print("TEST FAIL")
                    sys.exit(1)

                logging_action = next((action for action in response['watch_record']['result']['actions'] if action["type"] == "logging"), None)
                if logging_action is None:
                    print("No logging actions was taken. This test framework uses the logging action for comparison so you might need enable this action.")
                    print("TEST FAIL")
                    sys.exit(1)
                if logging_action.get('transform', {}).get('status', 'success') != 'success':
                    print("Logging transform script failed: {}".format(
                        json.dumps(logging_action.get('transform', {}), sort_keys=True, indent=2),
                    ))
                    print("TEST FAIL")
                    sys.exit(1)
                if 'logging' not in logging_action:
                    print("Logging action is not present: {}".format(logging_action))
                    print("TEST FAIL")
                    sys.exit(1)
                logging = logging_action['logging']
                if logging:
                    print("Received: {}".format(logging['logged_text']))
                    if logging['logged_text'] == test.get('expected_response'):
                        print("TEST PASS")
                        sys.exit(0)
                else:
                    print("Logging action required for testing")
            print("TEST FAIL")
            sys.exit(1)
        else:
            print("TEST {}".format("FAIL" if response['watch_record']['result']['condition']['met'] else "PASS"))
            sys.exit(met)
