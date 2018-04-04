# First Execution of a Process

## Description

A watch aims to alert if a process is started on a server for the first time.
 
The watch examines the previous N minutes for started processes.  This list is in turn used to search data older than N minutes, to see if the processes have been historically started.
Any differences result in an alert.

## Mapping Assumptions

A mapping is provided in mapping.json.  Watches require data producing the following fields:

* @timestamp (date field) - Date of log message.
* process_host - Contains the process name and host on which the process was started as a concatenated string e.g. testServerA_testServerB.  Watch assumes the delimiter is an _ char.
* event_type (non-analyzed string) - Contains the type for an event.  Indicates a process has started with the value “process_started”.

## Data Assumptions

The watch assumes each document in Elasticsearch represents a process event on a server.

## Other Assumptions

* All events are index "log" and type "doc".

# Configuration

The following watch metadata parameters influence behaviour:

* window_period - The period N (mins) over which the watch checks for newly started processes.  This should be equal to the scheduled interval.  Defaults to 30s.