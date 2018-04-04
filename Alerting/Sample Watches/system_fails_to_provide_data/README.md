# System Fails to Provide data

## Description
Alert if a system/host that was providing logs has stopped.

A system not providing logs is defined as “The system provided logs in the last N minutes but has not in the last X minutes”.  For example, “The system provided logs in the last 24 hrs but has not in the last 5 minutes”.  X and N are configurable.

## Mapping Assumptions

A mapping is provided in mapping.json.  Watches require data producing the following fields:

* host (non-analyzed string) - Contains the host name from which the message originated.
* @timestamp (date field) - Date of log message.

## Data Assumptions

The watch assumes each document in Elasticsearch represents a log entry.

## Other Assumptions

* All events are index "log" and type "doc".

# Configuration

The following watch metadata parameters influence behaviour:

* window_period - The period N (hrs) over which which the list of total known systems should be collected.  Defaults to 24hrs.
* last_period - The period X (mins) in which all hosts should respond with a log message. Defaults to 5 mins.
