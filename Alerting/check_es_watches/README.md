# Watching the Elastic watcher

[Elastic Watcher](https://www.elastic.co/guide/en/elasticsearch/reference/current/how-watcher-works.html) is very flexible and powerful. When you use this feature you start to depend on the correct behavior of the Elastic Watcher engine and the execution of your watches. "Trust is good, control is better", so you might want to monitor the Elastic Watcher. Watching the watcher so to speak. To effectively do that you need something like Elastic Watcher but outside of the system because if Elastic Watcher fails, it could not alert you of it.

## Implementation

To address this issue, the core functionally of Watcher has been re-implemented in a Python script. It understands a similar watch definition syntax that Elastic Watcher supports. Systemd timer is used to run to ensure that no interval is skipped due to scheduling time shifts over time that can occur when scheduling based on timer delays instead of realtime (i.e. wallclock) intervals.

To transform watcher payload, Python code can be used as the only supported language. Painless is not supported.

Supported watch actions:

* [email](https://www.elastic.co/guide/en/elasticsearch/reference/current/actions-email.html)
* Custom `nagios` action that allows the watch to be run as a Monitoring check using the widely supported Nagios Plugin API.

## Usage

```
usage: check_es_watches [-h] [-m {es_emulation,nagios_active,nagios_passive}]
                        [-c CURATOR_FILE] -w WATCH_FILE [-n] [-v] [-V]

Implementation of Elasticsearch watcher in Python. The watch definition is
kept very similar to the original. The main use case for this watcher outside
of Elasticsearch is to monitor the operation of Elasticsearch watches because
we don’t want to rely on self monitoring alone.

optional arguments:
  -h, --help            show this help message and exit
  -m {es_emulation,nagios_active,nagios_passive}, --mode {es_emulation,nagios_active,nagios_passive}
                        The mode in which the check should run. (default:
                        nagios_active)
  -c CURATOR_FILE, --curator-file CURATOR_FILE
                        File path to curator YAML file used to get
                        Elasticsearch entpoint and credentials. (default:
                        /etc/curator/curator.yml)
  -w WATCH_FILE, --watch-file WATCH_FILE
                        File path to watch YAML file.
  -n, --dry-run         Do not take any actions.
  -v, --verbose
  -V, --version         show program's version number and exit
```

## Watches

### watcher_history_failures.yaml

Watch failures in `.watcher-history-*`.

Example output:

```
./check_es_watches --watch-file watches/watcher_history_failures.yaml
ESWATCHES WARNING - 4 watches and exception type combinations over the last 2h.

The following table lists Elasticsearch watches that failed to execute. This conclusion was reached by searching the `.watcher-history-*` Elasticsearch index pattern for state:failed. This means that for example potential errors in logs have not been notified by the watch.

Watch ID                                                 Failed runs  ES node ID              Failure
-----------------------------------------------------  -------------  ----------------------  -------------------------------------------------------------------------------------------
hOwgG9LeQVSL7qGp69Os8A_elasticsearch_cluster_status               46  jUVSG6KPSv2cZKo6dXgQqQ  exception.type: timeout_exception
hOwgG9LeQVSL7qGp69Os8A_elasticsearch_cluster_status                5  jUVSG6KPSv2cZKo6dXgQqQ  exception.type: version_conflict_engine_exception
hOwgG9LeQVSL7qGp69Os8A_elasticsearch_nodes                        58  dnH3qfIrS3afbprbMq9YkQ  exception.type: timeout_exception
hOwgG9LeQVSL7qGp69Os8A_elasticsearch_nodes                         5  dnH3qfIrS3afbprbMq9YkQ  exception.type: version_conflict_engine_exception
```

### watcher_history_running.yaml

Watches did not trigger the number of times matching their schedule specification.

For this to work, we need to know the schedule definition of the watch to check. It is suggested that watches expose their schedule interval using Elastic Watcher metadata. Example of a watch that runs every minute:

```YAML
metadata:
  time_window: '1m'
```

This metadata field has other uses as well. Refer to https://discuss.elastic.co/t/ensure-that-watcher-does-not-miss-documents-logs/127780/1.

If you want to check Elastic watches outside of your control, you can also define the schedule interval in the watch definition.

Example output:

```
./check_es_watches --curator-file /etc/curator/curator_prod.yml --watch-file watches/watcher_history_running.yaml
ESWATCHES WARNING - 2 watches did not trigger the number of times matching their schedule specification over the last 2h.

The following table lists Elasticsearch watches that did not run the number of times that they should have run. This conclusion was reached by comparing the schedule specifications to the actually occurred watch runs according to the `.watcher-history-*` Elasticsearch index pattern. Watches (typically) search a defined time window per run. When the number of actual runs is lower than the expected runs this means that not all time windows have been observed by the given watch. The result of this is that for example potential errors in logs have not been notified by the watch.


Watch ID                                                 Time window (s)    Expected runs    Actual runs
-----------------------------------------------------  -----------------  ---------------  -------------
hOwgG9LeQVSL7qGp69Os8A_elasticsearch_cluster_status                   60              120             60
hOwgG9LeQVSL7qGp69Os8A_elasticsearch_nodes                            60              120             60
```

## Dependencies

See the requirements.txt file.
