# Example ML watches

## Description

Machine Learning (ML) creates anomalies in a results index that can be found via querying the `.ml-anomalies-*` index pattern. This index is further narrowed by selecting the appropriate `job_id` in the query (or alternatively using the pre-built `.ml-anomalies-myjobname` index alias, where `myjobname` is the name of your ML job. The alias takes into account of the selection via the proper `job_id`). In the `.ml-anomalies-*` indicies, there are 3 "levels" of results that can be queried, accessible via the `result_type` field:

* “bucket” level
	* Answers: How unusual was the job in a particular bucket of time?
	* Essentially an aggregated anomaly score – useful for rate-limited alerts
* “record” level
	* Answers: What individual anomalies are present in a range of time?
	* All the detailed anomaly information, but records can be numerous in big data
* “influeners”
	* Answers: What are the most unusual entities in a range of time?


## Example bucket watch

file:  `bucket_watch.json`

This watch queries for results at the summary (bucket) level. Some things to note: 


* The `trigger` interval is 5m - you would likely choose a watch interval that is less than or equal to the `bucket_span` of the ML job, which in this case, the bucket_span was 5m. Although queries to the anomalies index will be low-overhead (since it will be relatively small), querying more frequently than once per bucket_span is sort of wasted work since results from ML will only get published into the anomalies index once every bucket_span.
* The `range` in this example is now-2y merely because of the nature of this static data set used in the example. In "live" data one would choose a range that is only looking for "newly created" anomalies in the most recent execution of the ML analytics. Because the analytics run only once per bucket_span, AND it runs by default with a `query_delay` of 60s, AND because anomalies are indexed with a `timestamp` that is the beginning time of the bucket_span,  you'll need to carefully make sure that the range you pick doesn't inadvertently "miss" the newly indexed anomalies. A good choice for range might be the equivalent of "now-(bucket_span+query_delay+buffer)" where "buffer" is the amount of time it typically takes to run the ML analytics on a bucket's worth of data - probably under most circumstances on the order of a few seconds. Choosing a range that is equivlanet to (but not literally) "now-(2*bucket_span)" would be safe.
* We're using the `anomaly_score` of the job and filtering to only show buckets where the score is above 75.
* This example watch uses just simple logging action. Use the watch action that's appropriate for your situation.

The example output of this watch looks like:

```
Anomalies:
score=90.7 at time=1455034500000
```

## Example bucket/records chained watch

file: `bucket_record_chain_watch.json`

This watch queries for results at the summary (bucket) level, then if a bucket is found for with a high score, the results are subsequently queried for that bucket time. Some things to note: 


* Uses “chained” inputs to make 2 queries:
	* First to “bucket” level to test aggregated anomaly score and see if it is above 75
	* Second to “records” level for that bucket time to return the details of the anomaly records, if the bucket score was more than 75
* The second search at the "record" level uses the `timestamp` from the matching first query. In this way, the records are only queried for the bucket where the overall score is high (above 75).
* because of the two chained queries, a transform is used in the actions section to combine the context from the two chained queries into a single context for the logging action. This is how one would get both the summary info (i.e. the job's anomaly score) and the detail (the individual record information) in the same context.


The example output of this watch looks like:

```
Anomaly of score=90.7 at 2016-02-09 11:15:00 influenced by:
airline=AAL: score=95.4659, responsetime=296.19ms (typical=99.2962ms)
airline=AWE: score=0.00871093, responsetime=19.1644ms (typical=19.9918ms)
```




## Data 

The data used in these example watches is the demo "farequote" data set available [here](https://s3.amazonaws.com/prelert_demo/farequote_to_ES_sample.tar.gz).

The ML job for the example data would be `max(responsetime) partition_field_name=airline`

