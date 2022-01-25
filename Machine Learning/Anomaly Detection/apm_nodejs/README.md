## APM: NodeJS

Detect abnormal traces, anomalous spans, and identify periods of decreased
throughput. These jobs are applicable to data from Elastic APM Node.js Agents
(where `agent.name` is `nodejs`).

### Create anomaly detection jobs and datafeeds

Copy the contents of the appropriate *.json file into the
[create anomaly detection jobs API](https://www.elastic.co/guide/en/elasticsearch/reference/8.0/ml-put-job.html) in the Kibana Dev Console. For example:

```
PUT _ml/anomaly_detectors/abnormal_span_durations_nodejs
{
  ...
}
```

* `abnormal_span_durations_nodejs.json`: Models the duration of spans. Detects spans that are taking longer than usual to process.
* `abnormal_trace_durations_nodejs.json`: Models the duration of trace transactions. Detects trace transactions that are processing slower than usual.
* `decreased_throughput_nodejs.json`: Models the transaction rate of the application.
Detects periods during which the application is processing fewer requests than normal.


For more information about anomaly detection and running machine learning jobs,
refer to [Finding anomalies](https://www.elastic.co/guide/en/machine-learning/master/ml-ad-finding-anomalies.html).