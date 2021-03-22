Adding a watch to an ML job allows you create watches to alert on detected anomalies! The included watch, `my_watch.json` can be added to your cluster using the watcher API or by creating an advanced watch in the watcher UI in Stack Management.

`my_watch.json` is meant to be used as a template, and requires a few adjustments to allow it to function properly on your system. The following fields should be replaced in `my_watch.json` with values unique to your implementation.

1. `input.search.request.body.query.bool.filter[0].term.job_id`: replace this with the job_id of the anomaly detection job that you would like to trigger watches on.
2. (optional) to set the anomaly score on which this watch triggers, change `input.search.request.body.aggs.bucket_results.filter.range.anomaly_score.gte` from `75` to your desired value.
3. (optional) if you have [email enabled for watcher](https://www.elastic.co/guide/en/elasticsearch/reference/current/actions-email.html) you can use the `my_watch_email.json` configuration to send an email alert. If you do, the following need to be updated:
   1. change `actions.send_email.to` to include a list of email addresses that should recieve the email.
   2. change any instance of `<es_url>` in `actions.send_email.email.body.html` to your elasticsearch cluster's url.


Once the configuration is ready, you can put the watch:

```
PUT _watcher/watch/my-watch
{
    ...contents of json here
}
```

# Notes

1. The Watch is not deleted if the associated ML job is deleted.
2. “Send email” is only enabled if the system has email enabled. Whether an email can be successfully sent or not cannot be determined by ML, and is down to the local admin.
3. We have a built-in log action on the Watch. This writes to the elasticsearch log if the Watch conditions are met. No throttling can be applied to this. You may wish to delete this action as it could result in noisier logs.
4. You may wish to adjust the trigger interval to suit your environment - to change this, update `trigger.schedule.interval`.
5. Because the anomaly results are written according to the timestamp of the data, the input search looks for anomalies in the previous 2 bucket spans - this allows for time delays due to time to collect and ingest data and make it available to search, and time taken to perform end-of-bucket processing. You may need to adjust this time range (`input.search.filter[1].timestamp.gte`), for example if it takes longer than 2 buckets for data to be made available to search, or if the bucket span is less than 1-2 mins.
6. As we look over the last 2 buckets every 1-2mins, a Watch can find repeated anomalies. To allow for these duplicates, we have a 15m throttle on the email action (`actions.send_email.throttle_period_in_millis`). This prevents the receiver from being sent too many emails. You may need to adjust this throttle value depending on the tolerated frequency of emails. If you add in another action type, then we strongly recommend using throttling (if available) or to manage duplicates in your destination system (which often have dup handling).
7. The Watch search input queries for the `anomaly_score`. The search uses top hits aggregation to return the top `anomaly_score` and also the top influencers (if configured and if existing) and the top records. Influencers and records give more granular details relating to the anomaly, such as clientip or username, along with actual and typical values - this is useful info to include in the email. If writing your own Watch, we recommend using the `anomaly_score` for alerting as it is rate limited. The more granular detail can then be additionally included to help make the alert more actionable.

