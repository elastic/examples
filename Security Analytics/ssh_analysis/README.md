# Alerting on SSH CEF Data

This **Getting Started with Elastic Stack** example provides sample files to ingest, analyze and alert on **SSH Logs in the CEF Format** using the Elastic Stack. 

Included are example Watches for proactively monitoring this data for possible security incidents.  These examples support the Security Analytics blog post series, specifically:
 
* [Integrating Elasticsearch with ArcSight SIEM - Part 2](https://elastic.co/blog/integrating-elasticsearch-with-arcsight-siem-part-2).
* [Integrating Elasticsearch with ArcSight SIEM - Part 4](https://elastic.co/blog/integrating-elasticsearch-with-arcsight-siem-part-4).  

Watches include:

* The means to detect successful logins from an external IP Addresses.
* The means to detect a successful brute force attack - defined as a sequence of N failed logins, followed by a success.

This example includes:

- [`ssh.cef`](http://download.elasticsearch.org/demos/cef_ssh/ssh.cef) - Sample SSH logs in CEF format used in both blog posts.
- `ssh_analysis_logstash.conf` - An appropriate Logstash configuration for indexing the above CEF data
- `ssh_analysis_kibana.json` - Simple Kibana visualizations and dashboards for the associated blog posts
- `successful_login_external.json` -  A watch that detects remote logins from external IP addresses. REFERENCE ONLY. 
- `successful_login_external.inline.json` - The above watch in an inline execution format so it can be used with the `run_watch.sh` script and be executed over the full dataset.
- `brute_force_login.json` -  A watch that detects successful failed logins followed by a success for a specific user. REFERENCE ONLY. 
- `brute_force_login.inline.json` - The above watch in an inline execution format so it can be used with the `run_watch.sh` script and be executed over the full dataset.
- `run_watch.sh` - A convenience script to execute the above watches

This example depends on:

- [cef_template.json](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/cef/logstash/pipeline/cef_template.json) 

which will be installed when Logstash is run with the above configuration.

### Versions

Example has been tested with the following versions:

- Elasticsearch 5.2
- Logstash 5.2
- Kibana 5.2
- X-Pack 5.2

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

- [`ssh.cef`](http://download.elasticsearch.org/demos/cef_ssh/ssh.cef).  
- `ssh_analysis_logstash.conf`
- `ssh_analysis_kibana.json`
- `successful_login_external.json`
- `successful_login_external.inline.json`
- `brute_force_login.json`
- `brute_force_login.inline.json`
- `run_watch.sh` - depends on curl.

Additionally, download the following template dependency into the same local directory:

- `cef_template.json` from [here](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/cef/logstash/pipeline/cef_template.json)

Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. Use sample code provided below to download the required files to a local directory:

```shell
mkdir ssh_analysis
cd ssh_analysis
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/ssh_analysis/ssh_analysis_logstash.conf
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/ssh_analysis/successful_login_external.json
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/ssh_analysis/successful_login_external.inline.json
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/ssh_analysis/brute_force_login.json
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/ssh_analysis/brute_force_login.inline.json
curl -O https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/ssh_analysis/ssh_analysis_kibana.json
curl -O http://download.elasticsearch.org/demos/cef_ssh/ssh.cef
curl -O https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/cef/logstash/pipeline/cef_template.json
```


### Run Example

Both blog posts utilise the same dataset.  Steps 1 and 2 therefore only need to be performed once, after which both watches can be utilised.

#### 1. Start Logstash with the appropriate configuration

**Note:** Included `ssh_analysis_logstash.conf` configuration file assumes that you are running Elasticsearch on the same host as Logstash and have not changed the defaults. Modify the `host` and `cluster` settings in the `output { elasticsearch { ... } }`   section of apache_logstash.conf, if needed. 
Furthermore, it assumes the default X-Pack security username/password of elastic/changeme - [change as required](https://github.com/elastic/examples/blob/master/Security%20Analytics/ssh_analysis/ssh_analysis_logstash.conf#L42-L43) .

```shell
<path_to_logstash_root_dir>/bin/logstash -f ssh_analysis_logstash.conf
```

Wait for Logstash to start, as indicated by the message "Successfully started Logstash API endpoint"

#### 2. Ingest data into Elasticsearch using Logstash

* Execute the following command to load sample logs into Elasticsearch in a separate terminal. [Note: It takes a few minutes to ingest the entire file (114,147 documents) into Elasticsearch]

```shell
cat ssh.cef | nc localhost 5000
```

Once indexing is complete this command will return.

* Verify that data is successfully indexed into Elasticsearch

  Running `curl http://localhost:9200/cef-ssh-*/_count -u elastic:changeme` should return a response a `"count":114147`.  This command will return a higher count if you have executed either of the watches.

The above assumes the default username and password.

#### 3. Execute A Watch

**The watch must be executed over the full dataset, rather than just the previous N minutes, as the data is historical.**
**The inline version of the watch removes the time restriction and allows this.**

To run a watch over the full dataset, either:

* Execute the following command from the `ssh_analysis` directory to execute a specific watch.  For all dashboards to function, all watches will need to be executed once.

```shell
./run_watch <name of watch> <username> <password>
```

`username` and `password` are both optional and default to 'elastic' and 'changeme' respectively.

e.g.

```shell
./run_watch.sh successful_login_external.inline
./run_watch.sh brute_force_login.inline
```


OR MANUALLY

* Access Kibana by going to `http://localhost:5601` in a web browser
* Click the **Dev Tools** tab >> **Console** tab
* Use the [inline execution api](https://www.elastic.co/guide/en/x-pack/5.2/watcher-api-execute-watch.html#watcher-api-execute-inline-watch) to execute the watch, copying the contents for the watch key from the appropriate inline file e.g. `successful_login_external.inline.json`

#### 4. Visualize the results in Kibana

* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `cef-ssh-*` and `cef-ssh-watch-results` indices in Elasticsearch (autocreated in step 1)
    * Click the **Management** tab >> **Index Patterns** tab >> **Create New**. Specify `cef-ssh-*` as the index pattern name and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked and use @timestamp as the Time Field)
    * Click the **Management** tab >> **Index Patterns** tab >> **Create New**. Specify `cef-ssh-watch-results` as the index pattern name and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked and use @timestamp as the Time Field)
* Load sample dashboard into Kibana
    * Click the **Management** tab >> **Saved Objects** tab >> **Import**, and select `ssh_analysis_kibana.json`. If you have loaded an earlier version of this dashboard you will be promoted to override existing objects. Accept this override.
* Open dashboard
    * Click on **Dashboard** tab and open either `CEF Login Dashboard` or `CEF Brute Force Dashboard` dashboard

![Kibana External Login Dashboard Screenshot](https://cloud.githubusercontent.com/assets/12695796/24197080/168a40fc-0ef8-11e7-9c32-3182dd23c76c.png)
![Kibana Brute Force Dashboard Screenshot](https://cloud.githubusercontent.com/assets/12695796/24197092/1eb5f82a-0ef8-11e7-9cdf-6c55e144f9b5.png)

### We would love your feedback!
If you found this example helpful and would like more such Getting Started examples for other standard formats, we would love to hear from you. If you would like to contribute Getting Started examples to this repo, we'd love that too!
