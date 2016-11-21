# CPU - Change in IOWait

## Description

A watch which alerts if the time spent by a hosts CPU in IOWait, has increased by more than than N% in the last Y mins. N defaults to 5%, Y to 2 mins.

The watch searches across the last X minutes (default 4m), aggregating by hostname. A date histogram is constructed per host using an interval of Y (default 2m) - to ensure two buckets are present to calculate 'change' (see below).
For each interval a metric script aggregation calculates the percentage of time spent in IOWait.  A derivative pipeline aggregation in turn calculates the 'change' in IOWait between the intervals.
If the 'change' for any host exceeds the configured threshold N, an alert is raised.

This watch can be adapted to work with either topbeat or metricbeat data.

## Mapping Assumptions

A mapping is provided in mapping.json.  Watches require data producing the following fields:

* @timestamp - authorative date field for each log message
* beat.hostname (string not_analyzed) - The host for which the document represents.

CPU statistics configured as double (with doc values) as produced by topbeat/metricbeat:

* cpu.iowait
* cpu.user
* cpu.nice
* cpu.system
* cpu.idle
* cpu.iowait
* cpu.irq
* cpu.softirq
* cpu.steal


## Data Assumptions

The Watch assumes each document represents the CPU state for a specific host at any moment in time.
The watch assumes data is indexed into an index prefixed by "topbeat" with type "system".

## Other Assumptions

* The watch assumes the window period X is twice that of the interval Y i.e. by default 4 and 2m respectively.
* The watch assumes the schedule interval is equal to the interval Y i.e. 2m, to ensure no periods are "missed".

# Configuration

* The watch is scheduled to execute every 2 minutes.  This can be adjusted but should be equal to the "interval" parameter below.
* The "interval" Y is the period over which IOWait is measured.  This should be equal to the schedule and normally half the window.  Defaults to 2m.
* The "window" X over which the watch is executed. Allows the wait time to be calculated for the previous 2 intervals and thus a derivative to be used as the threshold i.e. change in IOwait.  Defaults to 4m and will typically be twice the interval.
* The threshold N.  The amount of time IOWait must increase by on a specific host, for an alert to be produced.  A % value. Defaults to 5.