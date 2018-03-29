# Monitoring Cluster State

## Description

A simple watch which alerts if the cluster state is red or yellow for more than N seconds.  This watch reproduces the data structure used by X-Pack Monitoring, utilising the same mapping.  
Specifically, it relies on the document type "cluster_state" produced by X-Pack Monitoring.

It is assumed this data will be collected by X-Pack Monitoring.  The watch raises an alert if the following holds true:

* A cluster is currently red or yellow and has been in this state for > N seconds. N can be defined within the watch using the metadata parameter `not_green_secs` 

More specifically, the number of cluster updates that have reported a cluster in the yellow/red state must be >= to `not_green_secs/monitoring_update_interval`.

This watch is capable of Alerting on multiple clusters.  The watch first aggregates on the `cluster_uuid` using a terms aggregation. Within each bucket the most recent cluster_state document is returned, using a top_hits aggregation, along with the number
of documents reporting the cluster as red or yellow - using a filters aggregation on the `cluster_state.status` field.  A painless script in turn checks:

* The most recent cluster_state document is not green **and**
* The number of cluster updates that have reported a cluster in the yellow/red state must be >= to `not_green_secs/monitoring_update_interval`.

If at least one cluster statisfies the above conditions, an alert is raised listing those clusters which require further attention.

## Mapping Assumptions

A mapping is provided in mapping.json.  Watches require data producing the following fields:

* timestamp - authoritative date field for each cluster_state message
* cluster_uuid (keyword) - cluster uuid.
* cluster_state.status (keyword) - Current status of the cluster i.e. 'red', 'yellow' or 'green'.

## Data Assumptions

* The Watch assumes each document represents the a cluster_state update as produced by the Monitoring plugin.
* The watch assumes data is indexed into an index `.monitoring-es-test`.
**This must be changed prior to production use to monitor the appropriate Monitoring index e.g. `monitoring-es-*`**.
* The watch assumes the data is indexed into the type `doc`.
* The watch assumes relevant documents are identified by the `type` field having the value `cluster_stats`.

## Other Assumptions

* The watch assumes the user has configured the parameter `monitoring_update_interval` to be consistent with the Marvel update interval.
* The parameter `not_green_secs` is divisible by the parameter `monitoring_update_interval`.

# Configuration

* The watch is scheduled to execute every `not_green_secs` seconds.  This also controls how long the cluster must be red or yellow before an Alert is raised.
* The `monitoring_update_interval` is used to determine the number of cluster_state documents which must report a cluster as red or yellow before an Alert is raised.  Ensure this is consistent with the monitoring configuration.
* The `throttle_period` is set to 30m i.e. atleast one cluster alert will be raised every 30mins.
