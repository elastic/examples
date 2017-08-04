# Alerting on Auditd CEF Data - Alerting on New Processes

This example supports the Security Analytics blog post [Integrating Elasticsearch with ArcSight SIEM - Part 5](https://www.elastic.co/blog/integrating-elasticsearch-with-arcsight-siem-part-5), detailing how X-Pack Alerting can be used to detect new processes starting on servers that have not existed historically.

**Prior to using this example, please read the high level instructions for preparing the environment [here](https://github.com/elastic/examples/blob/master/Security%20Analytics/README.md).**

## Example specific instructions

This example relies on the user creating a `process_signature` which acts as a unique identifier for a process. This is an imprecise process, relying on the user selecting fields to concatenate which best represent a unique identifier across server instances when combined.  Too coarse an identifier, which fails to encode sufficient properties of the processes characteristics, will result in the alert failing to detect new process effectively. Too granular and all processes will incorrectly be identified as being new.

For auditd CEF encoded data we utilise the following fields, concatenating them to form a single `process_signature` field with the delimiter “|” using a Logstash filter:

- ahost - the host from which the event originated
- ad.a0 - first argument of the command used to execute the process 
- ad.a1 - second argument of the command. This could be removed for coarsening process detection.

## Contents

This example utilises:

- [auditd.cef](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/example_1/auditd.cef) - Sample Auditd logs in CEF format used in the above blog post.
- [auditd_analysis_kibana.json](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/example_1/auditd_analysis_kibana.json) - Simple Kibana visualizations and dashboards for the associated blog post.
- [new_process.json](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/example_1/new_process.json) -  A watch that detects new processes starting. REFERENCE ONLY. 
- [new_process.inline.json](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/example_1/new_process.inline.json) - The above watch in an inline execution format so it can be used with the `simulate_watch.py` script and be executed over the full dataset.
- [simulate_watch.py](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/simulate_watch.py) - A convenience script to execute the above watch. In order to test this watch against the provided test data set, this script which performs a “sliding window” execution of the watch. 
This repeatedly executes the watch, each time adjusting the date filters to target the next 5 minute time range thus simulating the execution against a live stream of several days of data in a few seconds.
- [requirements.txt](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/requirements.txt) - Python dependencies for pip
- [auditd_analysis_logstash.conf](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/auditd_analysis_logstash.conf) - An appropriate Logstash configuration for indexing the above CEF data. This configuration creates a `process_signature` field for the first example.
- [cef_template.json](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/cef/logstash/pipeline/cef_template.json) -  This will be installed when Logstash is run with the above configuration.


## Download Example Files

The following assumes the user is using curl. Commands below can be replicated with wget if required.

Download the above files in this repo to a local directory.  Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. Use sample code provided below to download the required files to a local directory:

```shell
mkdir auditd_analysis
cd auditd_analysis
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/auditd_analysis/auditd_analysis_logstash.conf
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/audidt_analysis/example_1/auditd_analysis_kibana.json
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/audidt_analysis/example_1/new_process.inline.json
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/audidt_analysis/example_1/new_process.json
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/auditd_analysis/simulate_watch.py
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/auditd_analysis/example_1/auditd.cef
curl -O https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/cef/logstash/pipeline/cef_template.json
```

## Run Example


### 1. Start Logstash with the appropriate configuration

**Note:** Included `auditd_analysis_logstash.conf` configuration file assumes that you are running Elasticsearch on the same host as Logstash and have not changed the defaults. Modify the `host` and `cluster` settings in the `output { elasticsearch { ... } }`   section of apache_logstash.conf, if needed. 
Furthermore, it assumes the default X-Pack security username/password of elastic/changeme - [change as required](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/auditd_analysis_logstash.conf#L40-L41) .

```shell
<path_to_logstash_root_dir>/bin/logstash -f auditd_analysis_logstash.conf
```

Wait for Logstash to start, as indicated by the message "Successfully started Logstash API endpoint"

### 2. Ingest data into Elasticsearch using Logstash

* Execute the following command to load sample logs into Elasticsearch in a separate terminal. [Note: It takes a few seconds to ingest the entire file (10925 documents) into Elasticsearch]

```shell
cat auditd.cef | nc localhost 5000
```

Once indexing is complete this command will return.

* Verify that data is successfully indexed into Elasticsearch

  Running `curl http://localhost:9200/cef-auditd-*/_count -u elastic:changeme` should return a response a `"count":10925`.  This command will return a higher count if you have executed either of the watches.

The above assumes the default username and password.

### 3. Execute The Watch

**The watch must be executed over the full dataset, rather than just the previous N minutes, as the data is historical.**
**The provided python script utilises the inline version of the watch, executing the watch as a sliding window over the data - thus reproducing a "live" exeuction of several days in a few seconds.**

To simulate the execution over the full dataset, run the following:

* Execute the following command from the `auditd_analysis` directory to execute a specific watch.  For all dashboards to function, all watches will need to be executed once.

```shell
python simulate_watch.py --watch_template new_process.inline.json --start_time 2017-06-05T17:06:30Z --end_time 2017-06-27T09:06:34Z
```

`es_user` and `es_password` are both optional and default to 'elastic' and 'changeme' respectively.  This script accepts additional parameters to allow execution on your own dataset, including:

* `watch_template`- The inline watch file populated for each execution. **Required**
* `start_time` - Time at which to start the sliding time. Defaults to `2017-06-05T17:06:30Z` or the earliest time in the dataset provided.  **Required**
* `end_time` - Time at which to stop the sliding window. Defaults to `2017-06-06T11:12:35Z` or the oldest time in the dataset provided.  **Required**
* `es_host` - Elasticsearch host and port. Defaults to `localhost:9200`
* `interval` - Size of the window in seconds. Defaults to 300 or 5m as indicated in the blog.
* `start_time` - Time at which to start the sliding time. Defaults to `2017-06-05T17:06:30Z` or the earliest time in the dataset provided.
* `end_time` - Time at which to stop the sliding window. Defaults to `2017-06-06T11:12:35Z` or the oldest time in the dataset provided.


### 4. Visualize the results in Kibana

* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `cef-auditd-*` and `cef-auditd-watch-results` indices in Elasticsearch (autocreated in step 1)
    * Click the **Management** tab >> **Index Patterns** tab >> **Create New**. Specify `cef-auditd-*` as the index pattern name and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked and use @timestamp as the Time Field)
    * Click the **Management** tab >> **Index Patterns** tab >> **Create New**. Specify `cef-auditd-watch-results` as the index pattern name and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked and use @timestamp as the Time Field)
* Load sample dashboard into Kibana
    * Click the **Management** tab >> **Saved Objects** tab >> **Import**, and select `auditd_analysis_kibana.json`. 
* Open dashboard
    * Click on **Dashboard** tab and open either `Auditd New Process Dashboard` dashboard

![Kibana Auditd_New Process Screenshot](https://user-images.githubusercontent.com/12695796/27012292-e7bd5e6e-4ec4-11e7-9d8d-08d90b67cbf3.png)
