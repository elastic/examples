# Errors in Logs

## Description

A watch which alerts if errors are present in a log file. Provides example errors as output.

The following watch utilises a basic query_string search, as used by Kibana, to find all documents in the last N minutes which either contain the word “error” or have a value of “ERROR” for the field “loglevel” i.e. the log level under which the message was generated.  The query returns the ids of upto 10 hits ordered by @timestamp in descending order.

## Mapping Assumptions

A mapping is provided in mapping.json.  Watches require data producing the following fields:

* @timestamp - authorative date field for each log message
* message (string) - contents of the log message as generated with Logstash
* loglevel (string not_analyzed) - field with the value "ERROR", "DEBUG", "INFO" etc

## Data Assumptions

The Watch assumes each log message is represented by an Elasticsearch document. The watch assumes data is indexed in a "logs" index and "log" type.

## Other Assumptions

* None

# Configuration

* The watch is scheduled to find errors very minute. Modify through the schedule.
* The watch will raise a maximum of 1 alert every 15 minutes, even if the condition is satsified more than once. Modify through the throttle parameter.