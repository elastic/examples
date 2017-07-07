# Filesystem Usage

## Description

A simple watch which alerts if the filesystem usage for a specific host is greater than a configured threshold N - where N is a %.

The watch searches across the last X minutes, restricting the scope to hosts with a filesystem usage of > N.
A terms aggregation collects all matching hostnames and their respective maximum filesystem usage.

An alert is raised, with the maximum usage of each host, if the number of matching hosts > 0.

This watch can be adapted to work with either topbeat or metricbeat data.

## Mapping Assumptions

A mapping is provided in mapping.json.  Watches require data producing the following fields:

* @timestamp - authorative date field for each log message
* hostname (string not_analyzed) - hostname of data.
* used_p (double) - percentage of filesystem used on a specific host.

## Data Assumptions

The Watch assumes each document represents the Filesystem state for a specific host at any moment in time.
The watch assumes data is indexed into an index "logs" with type "filesystem".

## Other Assumptions

* The schedule interval is equal to the window period to ensure no data is missed.

# Configuration

* The watch is scheduled to execute every 5 minutes.  This can be adjusted but should be equal to the "window_period" parameter below.
* the "window_period" X over which the watch is executed and the filesystem of each host is checked.  Should be equal to the schedule interval to ensure no data points are missed.
* The "threshold" N over which the filesystem usage for a host is required to exceed for an alert to be generated.