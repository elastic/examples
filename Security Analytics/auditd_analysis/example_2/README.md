# Alerting on Auditd CEF Data - Alerting on Unusual Processes

This example supports the Security Analytics blog post [Integrating Elasticsearch with ArcSight SIEM - Using Machine Learning - Part 6](https://www.elastic.co/blog/integrating-elasticsearch-with-arcsight-siem-part-6), detailing how X-Pack Machine Learning can be used to detect statistically rare processes based on the historical behaviour of each server. Rare processes result in anomaly documents which are in turn alerted on using X-Pack.

This example adapts the machine learning recipe described here.

**Prior to using this example, please read the high level instructions for preparing the environment [here](https://github.com/elastic/examples/blob/master/Security%20Analytics/README.md).**

## Example specific instructions

This example utilises:

- [auditd.cef.tar.gz](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/example_2/auditd.cef.tar.gz) - Sample Auditd logs in CEF format used in the above blog post.
- [unusual_process.json](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/example_2/unusual_process.json) -  A watch that alerts on anomalies detected by X-Pack Machine Learning. REFERENCE ONLY. 
- [unusual_process.inline.json](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/example_2/unusual_process.inline.json) - The above watch in an inline execution format so it can be used with the `simulate_watch.py` script and be executed over the full dataset.
- [simulate_watch.py](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/simulate_watch.py) - A convenience script to execute the above watch. In order to test this watch against the provided test data set, this script which performs a “sliding window” execution of the watch. 
This repeatedly executes the watch, each time adjusting the date filters to target the next 5 minute time range thus simulating the execution against a live stream of several days of data in a few seconds.
- [requirements.txt](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/requirements.txt) - Python dependencies for pip
- [auditd_analysis_logstash.conf](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/auditd_analysis_logstash.conf) - An appropriate Logstash configuration for indexing the above CEF data.
- [cef_template.json](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/cef/logstash/pipeline/cef_template.json) -  This will be installed when Logstash is run with the above configuration.
- [job.json](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/example_2/job.json) - Machine Learning Job configuration for rare processes.
- [data_feed.json](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/example_2/data_feed.json) - Machine Learning Datafeed configuration for rare processes.

## Download Example Files

The following assumes the user is using curl. Commands below can be replicated with wget if required.

Download the above files in this repo to a local directory.  Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. Use sample code provided below to download the required files to a local directory:

```shell
mkdir auditd_analysis
cd auditd_analysis
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/auditd_analysis/auditd_analysis_logstash.conf
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/audidt_analysis/example_2/unusual_process.inline.json
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/audidt_analysis/example_2/unusual_process.json
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/auditd_analysis/simulate_watch.py
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/auditd_analysis/example_2/auditd.cef.tar.gz
curl -O https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/cef/logstash/pipeline/cef_template.json
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/auditd_analysis/example_2/job.json
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/auditd_analysis/example_2/data_feed.json
```

## Run Example

### 1. Start Logstash with the appropriate configuration

**Note:** Included `auditd_analysis_logstash.conf` configuration file assumes that you are running Elasticsearch on the same host as Logstash and have not changed the defaults. Modify the `host` and `cluster` settings in the `output { elasticsearch { ... } }`   section of apache_logstash.conf, if needed. 
Furthermore, it assumes the default X-Pack security username/password of elastic/changeme - [change as required](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/auditd_analysis_logstash.conf#L40-L41) .

```shell
<path_to_logstash_root_dir>/bin/logstash -f auditd_analysis_logstash.conf
```

Wait for Logstash to start, as indicated by the message "Successfully started Logstash API endpoint"

### 2. Extract CEF data

Extract the auditd.cef.tar.gz` file.

```shell
tar -xvf auditd.cef.tar.gz
```

### 3. Ingest data into Elasticsearch using Logstash

* Execute the following command to load sample logs into Elasticsearch in a separate terminal. 

```shell
cat auditd.cef | nc localhost 5000
```

Once indexing is complete this command will return. [Note: It takes a few minutes to ingest the entire file (TODO documents) into Elasticsearch]

* Ensure all data is indexed and searchable i.e.

```
curl localhost:9200/cef-auditd-*/_refresh -u elastic:changeme
```

* Verify that data is successfully indexed into Elasticsearch

  Running `curl http://localhost:9200/cef-auditd-*/_count -u elastic:changeme` should return a response a `"count":TODO`.  This command will return a higher count if you have executed either the provided watche.

The above assumes the default username and password.

### 4. Install the Machine Learning Job

The Machine Learning Recipe can be loaded prior to the complete data capture however for exploration purposes.

* Load the Job by running the supplied reset_job.sh script.

```
./reset_job.sh unusual_process
```

This script assumes the default Elasticsearch host, port, user and password. To supply alternatives, supply as arguments e.g.

```
./reset_job.sh unusual_process <host_port> <username> <password>
```

* Access Kibana by going to http://localhost:5601 in a web browser

* Select "Machine Learning" from the left tab. This should list the "Unusual Process" job e.g.

[http://localhost:5601/app/ml#/jobs?_g=()](http://localhost:5601/app/ml#/jobs?_g=())

![ML Job Listing Screenshot](https://cloud.githubusercontent.com/assets/12695796/25095014/a384c664-2391-11e7-8b25-e4026fa370c0.png)

### 5. Run the Machine Learning Job

* The Machine Learning job can be started. To start, either:

    - issue the following command to the ML API

        ```
        curl -s -X POST localhost:9200/_xpack/ml/datafeeds/datafeed-dns_exfiltration/_start -u elastic:changeme
        ```  
    OR

    - Click the `>` icon for the job in the UI, followed by `Start`.

### 6. Visualize the Machine Learning Result in Kibana

* On completion of the job execution navigate to the explorer results view for the job. An example anomaly is shown below:

![Example Explorer View for Suspicious Process Activity](https://cloud.githubusercontent.com/assets/12695796/25095074/e9ca1660-2391-11e7-8a1d-6063b75f3e6b.png)

### 7. Execute the Watch

**The watch must be executed over the full dataset, rather than just the previous N minutes, as the data is historical.**
**The provided python script utilises the inline version of the watch, executing the watch as a sliding window over the data - thus reproducing a "live" exeuction of several days in a few seconds.**

To simulate the execution over the full dataset, run the following:

* Execute the following command from the `auditd_analysis` directory to execute a specific watch.  For all dashboards to function, all watches will need to be executed once.

```shell
python simulate_watch.py --interval 1200 --start_time 2017-06-05T17:06:30Z --end_time 2017-06-27T09:06:34Z --watch_template unusual_process.inline.json
```


`es_user` and `es_password` are both optional and default to 'elastic' and 'changeme' respectively.  This script accepts additional parameters to allow execution on your own dataset, including:

* `watch_template`- The inline watch file populated for each execution. **Required**
* `start_time` - Time at which to start the sliding time. Defaults to `2017-06-05T17:06:30Z` or the earliest time in the dataset provided.  **Required**
* `end_time` - Time at which to stop the sliding window. Defaults to `2017-06-06T11:12:35Z` or the oldest time in the dataset provided.  **Required**
* `es_host` - Elasticsearch host and port. Defaults to `localhost:9200`
* `interval` - Size of the window in seconds. Defaults to 300 or 5m as indicated in the blog.

The watch uses a log action to record the alert.  The dataset contains only a single critical anomaly. During execution the user should therefore see a message similar to the following in the Elasticsearch logs:

 `Alert for job [unusual_process] at [2017-06-12T07:30:00.000Z] score [78]`
