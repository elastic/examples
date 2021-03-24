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

## Example chained watch

file: `chained_watch.json`

This watch queries for results at the bucket level for a job (`job1_name`), then if a bucket is found with a high score, it looks for prior anomalies in 2 additional jobs - (`job2_name` and `job3_name`). 

Things to note:

* This watch is only triggered if all 3 jobs have anomalies that match the conditions.
* additional filters can be applied to the search queries.

The example output of this watch looks like:

```
[2018-03-17T09:02:28,053][INFO ][o.e.x.w.a.l.ExecutableLoggingAction] [Iv3Ksae] [CRITICAL] Anomaly Alert for job it_ops_kpi: score=85.4309 at 2017-02-08 15:15:00 UTC
Possibly influenced by these other anomalous metrics (within the prior 10 minutes):
job:it_ops_network: (anomalies with at least a record score of 10):
field=In_Octets: score=11.217614808972602, value=13610.62255859375 (typical=855553.8944717721) at 2017-02-08 15:15:00 UTC
field=Out_Octets: score=17.00518, value=1.9079535783333334E8 (typical=1116062.402864764) at 2017-02-08 15:15:00 UTC
field=Out_Discards: score=72.99199, value=137.04444376627606 (typical=0.012289061361553099) at 2017-02-08 15:15:00 UTC
job:it_ops_sql: (anomalies with at least a record score of 5):
hostname=dbserver.acme.com field=SQLServer_Buffer_Manager_Page_life_expectancy: score=6.023424, value=846.0000000000005 (typical=12.609336298838242) at 2017-02-08 15:10:00 UTC
hostname=dbserver.acme.com field=SQLServer_Buffer_Manager_Buffer_cache_hit_ratio: score=8.337633, value=96.93249340057375 (typical=98.93088463835487) at 2017-02-08 15:10:00 UTC
hostname=dbserver.acme.com field=SQLServer_General_Statistics_User_Connections: score=27.97728, value=168.15000000000006 (typical=196.1486370757187) at 2017-02-08 15:10:00 UTC
```


## Example multiple jobs

file: `multiple_jobs_watch.json`

Similar to the prior watch, but now the watch is only triggered if the weighted combined score of the anomlies is greater than 75. The weights of this calculation and the threshold can be altered in `condition.script.source`.

The example output of this watch looks like:

```
"logged_text" : "[CRITICAL] Anomaly Alert for combined score of 3 jobs: score=75.62571425721299"
```

## Data 

The data used in these example watches is the demo "farequote" data set available [here](https://s3.amazonaws.com/prelert_demo/farequote_to_ES_sample.tar.gz).

The ML job for the example data would be `max(responsetime) partition_field_name=airline`