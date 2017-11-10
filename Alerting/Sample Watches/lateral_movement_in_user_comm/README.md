# Lateral Movement in User Communication

## Description

A watch which aims to detect and alert if users log onto a server which they have not accessed within the same time period previously.  The time period here is a configurable window either side of time the watch is executed. For example if the watch checks at 11:15 and the window size is 1hr, the watch will check if any users who have logged in within the last N seconds had logged into the same servers between 10:15 and 12:15 previously.  Any user-server communication which is "new", will result in an alert.

The watch achieves the above by using a three stage query chain. The first identifies a time window based on the configuration. The second periodically checks for user logins in the last N secs (default 30s), using a terms aggregation on the user_server field.  This list is then used to query against the index during the calculated time period, again aggregating on the user_server.  Values identified in the list collected during the second stage, which do not appear in the third stage list, are highlighted as new communication.

This watch represents a complex variant of the "first process execution" watch, which could be easily adapted to detect just new user logons to servers, adding a time period constraint.

## Mapping Assumptions

A mapping is provided in mapping.json.  Watches require data producing the following fields:

* user_server (non-analyzed string) - Contains the user and server as a concatenated string e.g. userA_testServerB.  Watch assumes the delimiter is an `_` char.
* @timestamp (date field) - Date of log message.
* time (date field) - time at which the logon occurred based on a strict_time_no_millis format.

## Data Assumptions

The watch assumes each document in Elasticsearch represents a logon to a server by a user.

## Other Assumptions

* All events are index "log".
* The watch assumes no more than 1000 user logons occur within the time period i.e. by default the last 30s.  This value can be adjusted, with consideration for scaling, for larger environments.

# Configuration

The following watch metadata parameters influence behaviour:

* window_width- The period in N (minutes) during which the user should have logged onto the server previously.  The window is calculated as T-N to T+N, where T is the time the watch executed. Defaults to 30mins, giving a total window width of approximately 1hr.
* time_period - The period for which user server logons are aggregated, and compared against the time period to check as to whether they represent new communication. Defaults to 30s.  This should be equal to the schedule interval to ensure no logins are not evaluated.
