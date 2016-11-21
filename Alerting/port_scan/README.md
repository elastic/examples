# Port Scan

## Description

A watch which aims to detect and alert if a server establishes a high number of connections to a destination across a large number of ports.

A port scan occurs when a high number of connections are established between two servers across a large number of ports.  This can be detected as a high number of documents, with unique port values, for the same source-destination values.  This also be described as an above than normal cardinality of the port field for a distinct source ip - destination ip pair.

This alert avoids attaching an exact value to "high".  Instead it aims to base the intepretation of high on available data and usual behaviour.  Additionally this alert should be able to cope with a large number of devices > 100k.

## Mapping Assumptions

A mapping is provided in mapping.json.  Watches require data producing the following fields:

* source_dest (non-analyzed string) - Contains the source and destination of the communication as a concatenated string e.g. testServerA_testServerB.  Watch assumes the delimiter is an _ char.
* @timestamp (date field) - Date of log message.
* source_dest_port (non-analyzed string) -  Contains the source, destination and port of the communication as a concatenated string e.g. testServerA_testServerB_5002. Watch assumes the delimiter is an _ char.
* dest_port (integer) - port on which communication occured.

## Data Assumptions

The watch assumes each document in Elasticsearch represents a communication between 2 servers and conform to the above mapping.  

## Other Assumptions

* All events are index "connection" and type "connection".

### How it works

* Every time_period (default 1m) the watch executes and identifies those communications between two servers which have used the highest number of ports in the last time_window (default 30m).  This is achieved using a terms agg on the source_dest field sorted by a cardinality of the dest_port.  A date histogram inturn builds a profile of the dest_port cardinality over the time_window for each source_dest pair, bucketing by the time_period.   The std. dev and median are inturn calculated for each source_dest profile using a extended_stats_bucket and percentiles_bucket aggregation respectively.
* A portscan is considered to be occuring between two hosts when the number of ports in the last time_period (i.e. last bucket of the profile) is 2 std. deviations above the median. To avoid alerting on host pairs with steady connection counts, and a low std. deviation, the watch requires the std. dev to also be > 0.  The window size and time period will need adjusting based on the data to tune both accuracy and performance.  
* The above are also likely to require explicit blacklisting of hosts/ports - to avoid alerting where scanning behaviour is considered to be normal behaviour. 

# Configuration

The following watch metadata parameters influence behaviour:

* time_window - The period N (mins) over which which the median and std. dev. is calculated for each source_dest pair. Defaults to 30m.
* time_period - The period X (mins) or size of each bucket.  This defines the smallest period in which a port scan can be detected.  Defaults to 1m.
* sensitivity - The "sensitivity" of the watch to fluctuations in the number of ports used between 2 hosts. A smaller value means smaller flucutations from the median will result in an alert. This value is mulitplied by the std. dev. of the cardinality of dest_ports (per source_dest pair) and added to the median.  Defaults to 2.0. 

The number of buckets used to compute the average will significantly affect performance i.e. the window_size/time_period.