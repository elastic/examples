# Monitoring Free Disk Space

## Description

A simple watch which alerts if the free disk space on an Elasticsearch host falls below a configurable ratio.  This watch requires the data structure used by X-Pack Monitoring, utilising the same mapping.
Specifically, it relies on the document type `node_stats` produced by X-Pack Monitoring.

It is assumed this data will be collected by X-Pack Monitoring.  The watch raises an alert if the following holds true:

* The ratio `node_stats.fs.total.total_in_bytes/node_stats.fs.total.available_in_bytes` is lower than the metadata parameter `lower_bound` (default 0.5), where `total_in_bytes` and `available_in_bytes` are the total file system size and available space in bytes respectively as reported by the X-Pack Monitoring agent.

This watch monitors the data reported by all nodes - potentially from multiple clusters.  Every N minutes the watches queries the previous period, aggregating on the node name field `source_node.name`.  This watch uses date math to only target the current day's monitoring index.  A bucket_script aggregation `free_ratio` in turn calculates the used file system ratio using two sibling metric aggregations - which request the max values for the fields `node_stats.fs.total.total_in_bytes` and `node_stats.fs.total.available_in_bytes`.  A painless condition script fires the alert if **any** node has a `free_ratio` value that is < than the metadata parameter `lower_bound`. Finally a painless script uses several lambda functions to collect an entry for each node which satisfies the earlier condition, returning the used and available space in GB. 


## Mapping Assumptions

A mapping is provided in mapping.json.  Watches require data producing the following fields:

* timestamp - authoritative date field for each node_stat message
* node_stats.fs.total.total_in_bytes (long) - Used space on FS in bytes.
* node_stats.fs.total.available_in_bytes (long) - Free space on FS in bytes.
* source_node.name - name of the ES node.

## Data Assumptions

* The Watch assumes each document represents a node_stat update as produced by the Monitoring plugin for a specific host i.e. Each document contains a disk report for a specific host on which ES is running.
* The watch assumes the index pattern `<.monitoring-es-2-{now/d}>`. 
**The index prefix should be modified prior to production deployment to target the correct version of the X-Pack monitoring indices**.  It defaults to 2.
* The watch assumes the data is indexed into the type `node_stats`

## Other Assumptions

This watch is supported in environments where multiple ES nodes are running on a single host. However, these will potentially result in multiple messages for the same host as both nodes documents will indicate the lower_bound threshold has been reached.

# Configuration

* The watch is scheduled to execute every 5 minutes. This is appropriate for most production deployments but can be modified if required. Ensure the date range filter is modified to be be consistent.
* The `throttle_period` is set to 30m i.e. at most one disk space alert will be raised every 30 mins.
* The parameter `lower_bound` is between 0 and 1. This represents the minimum ratio of free disk space that must be available for a node's host. If the ratio is lower than this bound for any host, an alert is fired.