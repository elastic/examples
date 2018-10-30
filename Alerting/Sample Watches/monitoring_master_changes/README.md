# Monitoring Master Changes 

## Description

A simple watch that alerts on changes in master elected node by getting the count of master elected nodes from monitoring data. The master elected node is found from the `cluster_state.master_node` field in the automatically generated index .monitoring-*.

It is assumed this data will be collected by X-Pack Monitoring.  The watch raises an alert if the following holds true:

* The number of master nodes reaches count greater than N, where N is a configurable number.

This watch is capable of Alerting on multiple clusters.  The watch first aggregates on the `cluster_uuid` using a terms aggregation. Then it aggregates on `cluster_state.master_node` as a terms sub-aggregation.

A painless script is used to:

* Collect `cluster_uuid` and `node_id` of master elected nodes that exceed the threshold  (must be greater than) into a variable `ctx.vars.clusters_over_threshold`
* Raise a condition is met boolean if there are any clusters that exceed the threshold

## Mapping Assumptions

A mapping is provided in mapping.json.  Watches require data producing the following fields:

* timestamp - authoritative date field for each cluster_state message
* cluster_uuid (keyword) - cluster uuid.
* cluster_state.master_node (keyword) - Current master elected node's id.

## Data Assumptions

* The Watch assumes each document represents the cluster_state update as produced by Elastic Monitoring.
* The watch assumes data is indexed into an index `.monitoring-es-6-*`.
**This must be changed prior to production use to monitor the appropriate Monitoring index e.g. `monitoring-es-*`**.
* The watch assumes the data is indexed into the type `doc`.

# Configuration

* The watch is by default scheduled to trigger every 30 mins. This can be changed in the `trigger` block of the watch.  
* The window of time (in seconds) to evaluate the number of master nodes can be configured in the `metadata` under `window_secs`. The default is 1800 seconds/ 30 minutes.
* The number of master nodes threshold can be configured in the `metadata` under `number_of_master_nodes_threshold`. The default is 1.