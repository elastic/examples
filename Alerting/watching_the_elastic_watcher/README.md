# Watching the Elastic watcher

Elastic Watcher is very flexible and powerful. When you use this feature you start to depend on the correct behavior of the Elastic Watcher engine and the execution of your watches. "Trust is good, control is better", so you might want to monitor the Elastic Watcher. Watching the watcher so to speak. To effectively do that you need something like Elastic Watcher but outside of the system because if Elastic Watcher fails, it could not alert you of it.

## Implementation

To address this issue, the core functionally of Watcher has been re-implemented in a Python script. It understands a similar watch definition syntax that Elastic Watcher supports. Systemd timer is used to run to ensure that no interval is skipped due to scheduling time shifts over time that can occur when scheduling based on timer delays instead of realtime (i.e. wallclock) intervals.

To transform watcher payload, Python code can be used as the only supported language. Painless is not supported.

Currently only email as action is supported.

## Watches

### watcher_history_errors.yaml

Watch for errors in `.watcher-history-*` and alert via Email. This finds errors like timeout_exception.

### watcher_history_running.yaml

Check the number of run watches against thresholds specific to each watch. This will find watches that have not triggered the number of times you specified or more times.

For this to work, we need to know the schedule definition of the watch to check. It is suggested that watches expose their schedule interval using Elastic Watcher metadata. Example of a watch that runs every minute:

```YAML
metadata:
  time_window: '1m'
```

This metadata field has other uses as well. Refer to https://discuss.elastic.co/t/ensure-that-watcher-does-not-miss-documents-logs/127780/1.

If you want to check Elastic watches outside of your control, you can also define the schedule interval in our watch definition.

## Dependencies

Python3 and the following Python packages:

* PyYAML
* pystache
* systemd-python
* elasticsearch

Additionally, to run the watches provided, you will need those Python packages as well:

* pytimeparse

## TODO

Watch action that hooks into Monitoring systems instead of direct Email alerting.
