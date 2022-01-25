## APM: RUM Javascript

Detect problematic spans and identify user agents that are potentially causing issues.
These jobs are applicable to data from Elastic APM RUM JavaScript Agents (where
`agent.name` is `js-base`).

### Create anomaly detection jobs and datafeeds

Copy the contents of the appropriate *.json file into the
[create anomaly detection jobs API](https://www.elastic.co/guide/en/elasticsearch/reference/8.0/ml-put-job.html) in the Kibana Dev Console. For example:

```
PUT _ml/anomaly_detectors/abnormal_span_durations_jsbase
{
  ...
}
```

* `abnormal_span_durations_jsbase.json`: Models the duration of spans. Detects spans that are taking longer than usual to process.

* `anomalous_error_rate_for_user_agents_jsbase.json`: Models the error rate of user agents. Detects user agents that are encountering errors at an above normal rate. This job can help detect browser compatibility issues.

* `decreased_throughput_jsbase.json`: Models the transaction rate of the application. Detects periods during which the application is processing fewer requests than normal.

* `high_count_by_user_agent_jsbase.json`: Models the request rate of user agents. Detects user agents that are making requests at a suspiciously high rate. This job is useful in identifying bots.

For more information about anomaly detection and running machine learning jobs,
refer to [Finding anomalies](https://www.elastic.co/guide/en/machine-learning/master/ml-ad-finding-anomalies.html).