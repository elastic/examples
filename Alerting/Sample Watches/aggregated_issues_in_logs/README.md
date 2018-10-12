# log issues watch

## Description

A watch which searches for issues in logs and aggregates them.

The idea is to find issues in logs of any source. Generic filters on the "severity" and "msg" fields are used which are uniform across all index-sets. Additionally, a blacklist is used to exclude certain events.

After filtering, a Elasticsearch aggregation on the fields "host", "severity" and "msg" is used to create one aggregated issue for similar events per hour.

The output is indexed into `log_issues__v4_{now/y{YYYY}}` for further analytics and long term archiving.
The staging watch output is indexed into `log_issues_env=staging__v4_{now/y{YYYY}}`.

## Query overview

This is only an overview and not the full query.

```YAML
## Include events
## * severity: Critical or worse
## * severity: Notice or worse AND msg contains one or more keywords
must:
  - range:
      severity:
        lte: 5
  - bool:
      should:
        - terms:
            msg:
              - attack
              - crash
              - conflict
              - critical
              - denied
              - down
              - dump
              - error
              - exit
              - fail
              - failed
              - fatal
              - fault
              - overflow
              - poison
              - quit
              - restart
              - unable
        - range:
            severity:
              lte: 2
```

## Schedules and date ranges

The watch is scheduled at minute 32 every hour and selects the complete last hour.
Because the actual time where the query is executed various slightly (which determines the value of `now` in the range query), we use date rounding to the full hour.

Because events need some time from when they are emitted on the origin, until they have traveled though the log collection pipeline and got indexed and refreshed (`_refresh` API) in Elasticsearch, a watch running `now` does not look at the range from `now` until `now-1h` but an additional delay of 30 minutes is used.
See: https://discuss.elastic.co/t/ensure-that-watcher-does-not-miss-documents-logs/127780/1

The first timestamp included is for example 2018-04-16T05:00:00.000Z and the last 2018-04-16T05:59:59.999Z.

This can be tested with the following query. Just index suitable documents before.
2018-04-16T06:29:59.999Z represents `now`:

```
GET test-2018/_search?filter_path=took,hits.total,hits.hits._source
{
  "sort": [
    "@timestamp"
  ],
  "query": {
    "range": {
      "@timestamp": {
        "gte": "2018-04-16T06:29:59.999Z||-1h-30m/h",
        "lt": "2018-04-16T06:29:59.999Z||-30m/h"
      }
    }
  }
}
```

## Fields in the aggregated output

As each generated document originates from an aggregation over one or multiple source documents, certain metadata fields were introduced. All metadata fields start with "#" as they are not contained in the original log events. The following fields are defined:

* host: Log source host name contained in source documents.
* severity: Severity of log event contained in source documents.
* msg: Log event message contained in source documents.
* \#count: Count of source documents where all above fields are the same over the scheduled interval.
* \#source: Source/Type of log event as defined by our Logstash configuration. This field determines the first part of the index name/index-set.
* @first_timestamp: Timestamp of first occurrence of a document matching the query in the scheduled interval. Technically, this is the minimum @timestamp field in the aggregation.
* @last_timestamp: Timestamp of last occurrence of a document matching the query in the scheduled interval. Technically, this is the maximum @timestamp field in the aggregation.
* \#timeframe: Duration between @first_timestamp and @last_timestamp in milliseconds.
* \#watch_timestamp: Timestamp the watch executed and created this document.
* doc: Nested object containing all keys of one source document not contained somewhere else already. This can be useful for debugging and for excluding events where where wrongly classified as issues.
* \#doc_ref: URL referring to one source document. This can be useful for debugging and for excluding false positives. It is faster than \#doc_context_ref.
* \#doc_context_ref: URL referring to one source document in the context of surrounding documents based on @timestamp. This can be useful for debugging and for excluding false positives. It is slower than \#doc_id.

## Quality assurance

The watch implementation is integration tested using the official integration
testing mechanism used by Elastic to test public watch examples.
Please be sure to add new tests for any changes you do here to ensure that they
have the desired effect and to avoid regressions. All tests must be run and
pass before deploying to production.
Those tests are to be run against a development Elasticsearch instance.

### Date selection considerations

> gte: 2018-04-16T05:00:00.000Z, offset -5400
> lt:  2018-04-16T05:59:59.999Z, offset -1800.001
> now: 2018-04-16T06:30:00.000Z
>
> gte: 2018-04-16T04:00:00.000Z, offset -8999.999
> lt:  2018-04-16T04:59:59.999Z, offset -5400
> now: 2018-04-16T06:29:59.999Z

offset -5400 is always in the range. Offset from -8999.999 until (including)
-1800.001 is sometimes in the range, depending on `now`. `now` is not mocked by
the test framework so we need to use -5400 for all test data or something
outside of the range for deterministic tests.
Unfortunately, deterministic tests can not be ensured currently because there is some delay between offset to timestamp calculation and the execution of the watch. If that happens in integration tests, rerun the test. The probability for this to happen is very low with ~0.005 % (~0.2s / 3600s * 100).

This has the negative affect that we can not test (reliably) with different
timestamps so that the `#timeframe` field can not be tested anymore.

The offset calculations can be verified with this Python code:

```Python
(datetime.datetime.strptime('2018-04-16T12:20:59.999Z', "%Y-%m-%dT%H:%M:%S.%fZ") - datetime.datetime.strptime('2018-04-16T12:14:00.000Z', "%Y-%m-%dT%H:%M:%S.%fZ")).total_seconds()
```


## Basic concepts

Only be as restrictive as needed. The input data might change and if we defined the conditions too precisely, the data will never match again and we will not know. Rather have false positives and change it to more restrictive in that case.

## Helpers

```Shell
## Getting example data from production using a Elasticsearch query. After that, you can use this yq/jq one liner to generate watch test input:

curl --cacert "$(get_es_cacert)" -u "$(get_es_creds)" "$(get_es_url)/${INDEX_PATTERN}/_search?pretty" -H 'Content-Type: application/yaml' --data-binary @log_issues/helpers/get_from_production.yaml > /tmp/es_out.yaml

yq '{events: {"ignore this – needed to get proper indention": ([ .hits.hits[]._source ] | length as $length | to_entries | map(del(.value["@timestamp"], .value["#logstash_timestamp"]) | {id: (.key + 1), offset: (10 * (.key - $length))} + .value)) }}' /tmp/es_out.yaml -y
yq '[ .hits.hits[] | ._source ] | length as $length | to_entries | map({id: (.key + 1), offset: (10 * (.key - $length))} + .value)' /tmp/es_out.yaml

## Painless debugging can be difficult. curl can be used to get proper syntax error messages:

curl -u 'elastic:changeme' 'http://localhost:9200/_scripts/log_issues-index_transform' -H 'Content-Type: application/yaml' --data-binary @log_issues/scripts/log_issues-index_transform.yaml
```

## Mapping Assumptions

A mapping is provided in `mapping.json`. This watch requires source data producing the following fields:

* @timestamp (date): authoritative date field for each log message.
* msg (string): Contents of the log message.
* host (string): Log origin.
* severity (byte): Field with severity as defined in RFC 5424. Ref: https://en.wikipedia.org/wiki/Syslog#Severity_level.

## Data Assumptions

The watch assumes each log message is represented by an Elasticsearch document. The watch assumes data is indexed in any index.

## Other Assumptions

* None

## Configuration

* The watch is scheduled to find errors every hour. Configurable in the `watch.yaml` configuration file.

## Deployment

The `./watch.yaml` mentions a `Makefile`

```Shell
python run_test.py --test_file ./aggregated_issues_in_logs/tests_disabled/90_deploy_to_production_empty_test_data.yaml --metadata-git-commit --no-test-index --no-execute-watch --host "$(get_es_url)" --user "$(get_es_user)" --password "$(get_es_pw)" --cacert "$(get_es_cacert)" --modify-watch-by-eval "del watch['actions']['log']; watch['actions']['index_payload']['index']['index'] = '<' + watch['metadata']['index_category'] + '_' + watch['metadata']['index_type'] + watch['metadata']['index_kv'] + '__' + watch['metadata']['index_revision'] + '_{now/y{YYYY}}>';"
```
