# Unexpected Account Activity

## Description

A watch which aims detect and to alert if a user is created in Active Directory/LDAP and subsequently deleted within N mins.

## Mapping Assumptions

A mapping is provided in mapping.json.  Watches require data producing the following fields:

* event_type (non-analyzed string) - Contains the AD event type with values "add" or "remove".
* @timestamp (date field) - Date of log message.
* user (non-analyzed string) - The id of the user for which the operation is performed.

## Data Assumptions

The watch assumes each document in Elasticsearch represents an Active Directory or LDAP change event.  The collection of data is left to the user.

## Other Assumptions

* All events are in an index "logins" and type "login".
* Watch assumes upto a maximum of 1000 users are monitored concurrently.

# Configuration

The following watch metadata parameters influence behaviour:

* window_period - The period N (mins) within which an account should be created and subsequently deleted. Defaults to 5 mins.
