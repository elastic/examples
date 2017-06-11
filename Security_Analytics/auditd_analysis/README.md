# Alerting on Auditd CEF Data

This **Getting Started with Elastic Stack** example provides sample files to ingest, analyze and alert on **Auditd Logs in the CEF Format** using the Elastic Stack. 

Included are example Watches for proactively monitoring this data for possible security incidents.  These examples support the Security Analytics blog post series, specifically:
 
[Integrating Elasticsearch with ArcSight SIEM - Part 5](https://elastic.co/blog/integrating-elasticsearch-with-arcsight-siem-part-5).

This example complements the above blog post, providing a means to detect unusual processes starting on servers in the last N minutes. Unusual is defined as "A new process signature that has not occurred on the server historically".

This example relies on the user creating a `process_signature` which acts as a unique identifier for a process. This is an imprecise process, relying on the user selecting fields to concatenate which best represent a unique identifier across server instances when combined.  Too coarse identifier, which fails to encode sufficient properties of the processes characteristics, will result in the alert failing to detect new process effectively. Too granular and all processes will incorrectly be identified as being new.

For auditd CEF encoded data we utilise the following fields, concatenating them to form a single process_signature field with the delimiter “|” using a Logstash filter:

- ahost - the host from which the event originated
- ad.a0 - first argument of the command used to execute the process 
- ad.a1 - second argument of the command. This could be removed for coarsening process detection.


This example includes:

- [`auditd.cef`](https://raw.githubusercontent.com/elastic/examples/master/Security_Analytics/audidt_analysis/audit.cef) - Sample Auditd logs in CEF format used in the above blog post.
- `auditd_analysis_logstash.conf` - An appropriate Logstash configuration for indexing the above CEF data and creating a `process_signature` field.
- `auditd_analysis_kibana.json` - Simple Kibana visualizations and dashboards for the associated blog posts
- `unusual_process.json` -  A watch that detects new processes starting. REFERENCE ONLY. 
- `unusual_process.inline.json` - The above watch in an inline execution format so it can be used with the `simulate_watch.py` script and be executed over the full dataset.
- `simulate_watch.py` - A convenience script to executes the above watch. In order to test this watch against the provided test data set this script which performs a “sliding window” execution of the watch. 
This repeatedly executes the watch, each time adjusting the date filters to target the next 5 minute time range thus simulating the execution against a live stream of several days of data in a few seconds.
- `requirements.txt` - Python dependencies for pip

This example depends on:

- [cef_template.json](https://github.com/elastic/examples/blob/master/Security_Analytics/cef_demo/logstash/pipeline/cef_template.json) 

which will be installed when Logstash is run with the above configuration.

### Versions

Example has been tested with the following versions:

- Elasticsearch 5.4
- Logstash 5.4 with [CEF codec](https://www.elastic.co/guide/en/logstash/current/plugins-codecs-cef.html)
- Kibana 5.4
- X-Pack 5.4
- Python 3.5 with Elasticsearch dependency

### Installation & Setup

* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the Elastic Stack (*you can skip this step if you have a working installation of the Elastic Stack,*)


* Install the X-Pack in Kibana and Elasticsearch 

  ```shell
  <path_to_elasticsearch_root_dir>/elasticsearch-plugin install x-pack
  <path_to_kibana_root_dir>/bin/kibana-plugin install x-pack
  ```

* Run Elasticsearch & Kibana
  ```shell
    <path_to_elasticsearch_root_dir>/bin/elasticsearch
    <path_to_kibana_root_dir>/bin/kibana
    ```

* Check that Elasticsearch and Kibana are up and running.
  - Open `localhost:9200` in web browser -- should return a json message indicating ES is running.
  - Open `localhost:5601` in web browser -- should display Kibana UI.

  **Note:** By default, Elasticsearch runs on port 9200, and Kibana run on ports 5601. If you changed the default ports, change the above calls to use the appropriate ports.  
  The cluster will be secured using basic auth. If changing the default credentials of `elastic` and `changeme` as described [here](https://www.elastic.co/guide/en/x-pack/current/security-getting-started.html), ensure the logstash configuration file is updated.

### Download Example Files

The following assumes the user is using curl. Commands below can be replicated with wget if required.

Download the following files in this repo to a local directory:

- [`auditd.cef`](https://raw.githubusercontent.com/elastic/examples/master/Security_Analytics/audidt_analysis/auditd.cef).  
- `auditd_analysis_logstash.conf`
- `auditd_analysis_kibana.json`
- `unusual_process.json`
- `unusual_process.inline.json`
- `simulate_watch.py`
- `requirements.txt`

Additionally, download the following template dependency into the same local directory:

- `cef_template.json` from [here](https://github.com/elastic/examples/blob/master/Security_Analytics/cef_demo/logstash/pipeline/cef_template.json)

Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. Use sample code provided below to download the required files to a local directory:

```shell
mkdir auditd_analysis
cd auditd_analysis
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security_Analytics/audidt_analysis/auditd_analysis_logstash.conf
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security_Analytics/audidt_analysis/auditd_analysis_kibana.json
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security_Analytics/audidt_analysis/unusual_process.inline.json
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security_Analytics/audidt_analysis/unusual_process.json
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security_Analytics/audidt_analysis/simulate_watch.py
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security_Analytics/audidt_analysis/auditd.cef
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security_Analytics/audidt_analysis/requirements.txt
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security_Analytics/cef_demo/logstash/pipeline/cef_template.json
```
### Setup Python

* Install Python 3.5.x
* Ensure pip is installed
* Install dependencies using pip i.e. `pip install -r requirements.txt`

### Run Example


#### 1. Start Logstash with the appropriate configuration

**Note:** Included `auditd_analysis_logstash.conf` configuration file assumes that you are running Elasticsearch on the same host as Logstash and have not changed the defaults. Modify the `host` and `cluster` settings in the `output { elasticsearch { ... } }`   section of apache_logstash.conf, if needed. 
Furthermore, it assumes the default X-Pack security username/password of elastic/changeme - [change as required](LINK TO LINE) .

```shell
<path_to_logstash_root_dir>/bin/logstash -f auditd_analysis_logstash.conf
```

Wait for Logstash to start, as indicated by the message "Successfully started Logstash API endpoint"

#### 2. Ingest data into Elasticsearch using Logstash

* Execute the following command to load sample logs into Elasticsearch in a separate terminal. [Note: It takes a few seconds to ingest the entire file (10925 documents) into Elasticsearch]

```shell
cat auditd.cef | nc localhost 5000
```

Once indexing is complete this command will return.

* Verify that data is successfully indexed into Elasticsearch

  Running `curl http://localhost:9200/cef-auditd-*/_count -u elastic:changeme` should return a response a `"count":10925`.  This command will return a higher count if you have executed either of the watches.

The above assumes the default username and password.

#### 3. Execute The Watch

**The watch must be executed over the full dataset, rather than just the previous N minutes, as the data is historical.**
**The provided python script utilises the inline version of the watch, executing the watch as a sliding window over the data - thus reproducing a "live" exeuction of several days in a few seconds.**

To simulate the execution over the full dataset, run the following:

* Execute the following command from the `auditd_analysis` directory to execute a specific watch.  For all dashboards to function, all watches will need to be executed once.

```shell
./simulate_watch.py <username> <password>
```
`username` and `password` are both optional and default to 'elastic' and 'changeme' respectively.  This script accepts additional parameters to allow execution on your own dataset, including:

* `es_host` - Elasticsearch host and port. Defaults to `localhost:9200`
* `interval` - Size of the window in seconds. Defaults to 300 or 5m as indicated in the blog.
* `start_time` - Time at which to start the sliding time. Defaults to `2017-06-05T17:06:30Z` or the earliest time in the dataset provided.
* `end_time` - Time at which to stop the sliding window. Defaults to `2017-06-06T11:12:35Z` or the oldest time in the dataset provided.
* `watch_template`- The inline watch file populated for each execution. Defaults to `unusual_process.inline.json`.

#### 4. Visualize the results in Kibana

* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `cef-auditd-*` and `cef-auditd-watch-results` indices in Elasticsearch (autocreated in step 1)
    * Click the **Management** tab >> **Index Patterns** tab >> **Create New**. Specify `cef-auditd-*` as the index pattern name and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked and use @timestamp as the Time Field)
    * Click the **Management** tab >> **Index Patterns** tab >> **Create New**. Specify `cef-auditd-watch-results` as the index pattern name and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked and use @timestamp as the Time Field)
* Load sample dashboard into Kibana
    * Click the **Management** tab >> **Saved Objects** tab >> **Import**, and select `auditd_analysis_kibana.json`. 
* Open dashboard
    * Click on **Dashboard** tab and open either `Auditd New Process Dashboard` dashboard

![Kibana Auditd_New Process Screenshot](TODO)

### We would love your feedback!
If you found this example helpful and would like more such Getting Started examples for other standard formats, we would love to hear from you. If you would like to contribute Getting Started examples to this repo, we'd love that too!
