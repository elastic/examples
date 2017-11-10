# Example Watches

## Overview

This package provides a collection of example watches.  These watches have been developed for the purposes of POC's and demonstrations.  Each makes independent assumptions as to the data structure, volume and mapping.  For each watch a description, with assumptions is provided, in addition to a mapping file.  Whilst functionally tested, these watches have not been tested for effectiveness or query performance in production environments.  The reader is therefore encouraged to test and review all watches with production data volumes prior to deployment.

## Generic Assumptions

* Elasticsearch 6.2 + x-pack
* All watches use the log output for purposes of testing. Replace with output e.g. email, as required.
* Painless scripts, located within the "scripts" folder of each watch, must be indexed first.
* All watches assume Watcher is running in the same cluster as that in which the relevant data is hosted.  They all therefore use the search input.  In a production deployment this is subject to change i.e. a http input maybe required.

## Structure

In each watch directory the following is provided:

* README - describes the watch including any assumptions regards mapping, data structure and behaviour.
* mapping.json - An re-usable mapping which is also appropriate for the test data provided.
* watch.json - Body of the watch. Used in the below tests.
* /tests - Directory of tests.  Each test is defined as JSON file.  See Below.
* /scripts - Directory of painless scripts utilised by the watch.


The parent directory includes the following utility scripts:

* run_test.py - A python script which can be used to run a specific test e.g. python run_test.py --test_file new_process_started/tests/test1.json. Include optional username and password with --user and --password parameters.
* load_watch.sh.  Utility script for loading a watch to a local Elasticsearch cluster.  Each watch can be loaded by running `load_watch.sh <watch folder name>`.  This will also index any scripts. Username and password for the cluster can be specified as parameters e.g.
`load_watch.sh <watch folder name> <username> <password> <protocol>`
* run_test.sh - Runs a specified watches tests. Specify watch by directory name e.g. `run_test.sh port_scan`. Include optional username and password e.g. `run_test.sh port_scan <username> <password> <protocol>`.
* run_all_tests.sh - Runs all tests. Include optional username and password e.g. `run_all_tests.sh <username> <password> <protocol>`.

If username, password, and protocol are not specified, the above scripts assume the x-pack default of "elastic", "changeme", and "http" respectively.

## Watches

* Errors in log files - A watch which alerts if errors are present in a log file. Provides example errors as output.
* Port Scan - A watch which aims to detect and alert if a server established a high number of connections to a destination across a large number of ports.
* Twitter Trending - A watch which alerts if a social media topic/tag begins to show increase activity
* Unexpected Account Activity - A watch which aims detect and to alert if a user is created in Active Directory/LDAP and subsequently deleted within N mins.
* New Process Started - A watch which aims to detect if a process is started on a server for the first time.
* New User-Server Communication - A watch which aims to detect if a user logs onto a server for the first time within the current time period.
* System Fails to Provide Data - A watch which alerts if a system, which has previously sent data, fails to send events.
* File System Usage - A watch which alerts if a systems filesystem usage exceeds a predetermined percentage threshold.
* IO Wait time increases - A watch which alerts if a systems iowait time rises beyond a predetermined threshold.
* Monitoring Cluster Health - A watch which monitors an ES cluster for red or yellow cluster state.  Assumes use of X-Pack Monitoring.
* Monitoring Free Disk Space - A watch which monitors an ES cluster for free disk usage on hosts.  Assumes use of X-Pack Monitoring.

## Testing

Each watch includes a test directory containing a set of tests expressed as JSON files.  Each JSON file describes a single isolated test and includes:

* watch_name - The watch name
* watch_file - Location of the watch file (relative to base directory)
* mapping_file - Location of the mapping file (relative to base directory)
* index - The required index on which both the watch and test depend.
* type - The required type on which both the watch and test depend.
* scripts (optional) - List of Painless scripts, each with a name and path, that need to be indexed prior to the watch running.
* events - A list of test data objects.  Each test data object contains the required fields and an 'offset' value.  This is only considered if the event does not have a time_field field.  This integer can be positive and negative.  This value is added to the current system time when the events are indexed by the run_test.py.  To ensure the "past" is populated as required use negative values.  This ensures the test data is populated for the current period, allowing time based watches to match. If an offset is not specified, the default is 0 i.e. the event receives the current time. If the user specifies an "id" field this will be used as the event id, otherwise events are assigned a sequential id based on their list order, starting at 0.
* match (optional) - A field indicating if the watch should match - defaults to true.
* time_field (optional) - time to use for events. Defaults to @timestamp.

The run_test.py performs the following when running a test file:

1. Deletes the index specified.
1. Loads the required mapping.
1. Loads any required scripts.
1. Loads any declared ingest pipeline used to modify the test data.
1. Loads the dataset, setting the timestamps of the events to the current+offset.
1. Refreshes the index.
1. Adds the watch
1. Executes the watch
1. Confirms the watch matches the intended outcome. Matched and confirms the output of the watch (log text)

## Requirements

* >= python 3.5
* see requirements.txt - Install dependencies through `pip install -r requirements.txt`
