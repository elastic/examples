# Alerting on SSH CEF Data

This **Getting Started with Elastic Stack** example provides sample files to ingest, analyze and alert on **SSH Logs in the CEF Format** using the Elastic Stack. 

Included are example Watches for proactively monitoring this data for possible security incidents.  These examples support the Security Analytics blog post series, specifically [Integrating Elasticsearch with ArcSight SIEM - Part 3]().  
The first watch provides the means to detect successful logins from external IP Addresses.

This example includes:

- [`ssh.cef`](http://download.elasticsearch.org/demos/cef_ssh/ssh.cef) - Sample SSH logs in CEF format
- `ssh_analysis_logstash.conf` - An appropriate Logstash configuration for indexing the above CEF data
- `ssh_analysis_kibana.json` - Simple Kibana visualizations and dashboards for the associated blog posts
- `successful_login_external.json` -  A watch detects remote logins from external IP addresses.  
- `successful_login_external.json.inline` - The above watch in an inline execution format so it can be used with the `run_watch.sh` script.
- `run_watch.sh` - A convenience script to execute a watch

This example depends on:

- [cef_template.json](https://github.com/elastic/examples/blob/master/Security_Analytics/cef_demo/logstash/pipeline/cef_template.json) 

### Versions

Example has been tested in following versions:

- Elasticsearch 5.1
- Logstash 5.1
- Kibana 5.1
- X-Pack 5.1

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
  - Open `localhost:9200` in web browser -- should return status code 200
  - Open `localhost:5601` in web browser -- should display Kibana UI.

  **Note:** By default, Elasticsearch runs on port 9200, and Kibana run on ports 5601. If you changed the default ports, change   the above calls to use appropriate ports.

### Download Example Files

Download the following files in this repo to a local directory:

- [`ssh.cef`](http://download.elasticsearch.org/demos/cef_ssh/ssh.cef)
- `ssh_analysis_logstash.conf`
- `ssh_analysis_kibana.json`
- `successful_login_external.json`
- `successful_login_external.json.inline`

Additionally, download the following template dependency into the same local directory:

- `cef_template.json` from [here](https://github.com/elastic/examples/blob/master/Security_Analytics/cef_demo/logstash/pipeline/cef_template.json)

Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. Use sample code provided below to download the required files to a local directory:

```shell
mkdir ssh_analysis
cd ssh_analysis
wget https://raw.githubusercontent.com/elastic/examples/master/Security_Analytics/ssh_analysis/ssh_analysis_logstash.conf
wget https://raw.githubusercontent.com/elastic/examples/master/Security_Analytics/ssh_analysis/successful_login_external.json
wget https://raw.githubusercontent.com/elastic/examples/master/Security_Analytics/ssh_analysis/successful_login_external.json.inline
wget https://raw.githubusercontent.com/elastic/examples/master/Security_Analytics/ssh_analysis/ssh_analysis_kibana.json
wget http://download.elasticsearch.org/demos/cef_ssh/ssh.cef
wget https://raw.githubusercontent.com/elastic/examples/master/Security_Analytics/cef_demo/logstash/pipeline/cef_template.json
```

### Run Example

#### 1. Start Logstash with the appropriate configuration

```shell
cat ssh.cef | <path_to_logstash_root_dir>/bin/logstash -f ssh_analysis_logstash.conf
```

Wait for Logstash to start, as indicated by the message "Successfully started Logstash API endpoint"


#### 2. Ingest data into Elasticsearch using Logstash

* Execute the following command to load sample logs into Elasticsearch. [Note: It takes a few minutes to ingest the entire file (114,147 documents) into Elasticsearch]

```shell
cat ssh.cef | nc localhost 5000
```

Once indexing is complete this command will return.

* Verify that data is succesfully indexed into Elasticsearch

  Running `http://localhost:9200/cef-ssh-*/_count` should return a response a `"count":114147`

**Note:** Included `ssh_analysis_logstash.conf` configuration file assumes that you are running Elasticsearch on the same host as Logstash and have not changed the defaults. Modify the `host` and `cluster` settings in the `output { elasticsearch { ... } }`   section of apache_logstash.conf, if needed. Furthermore, it assumes the default X-Pack security username/password of elastic/changeme - change as required.

#### 3. Execute A Watch

To run a watch over the full dataset, either:

* Execute the following command from the `ssh_analysis` directory to execute a specific watch

```shell
./run_watch <name of watch> <username> <password>
```

`username` and `password` are both optional and default to 'elastic' and 'changeme' respectively.

e.g.

```shell
./run_watch successful_login_external
```


OR MANUALLY

* Access Kibana by going to `http://localhost:5601` in a web browser
* Click the **Dev Tools** tab >> **Console** tab
* Use the [inline execution api](https://www.elastic.co/guide/en/x-pack/5.1/watcher-api-execute-watch.html#watcher-api-execute-inline-watch) to execute the watch, copying the contents for the watch key from the appropriate inline file e.g. `successful_login_external.json.inline`

#### 4. Visualize the results in Kibana

* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `cef-ssh-*` and `cef-ssh-watch-results` indices in Elasticsearch (autocreated in step 1)
    * Click the **Management** tab >> **Index Patterns** tab >> **Create New**. Specify `cef-ssh-*` as the index pattern name and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked and use @timestamp as the Time Field)
    * Click the **Management** tab >> **Index Patterns** tab >> **Create New**. Specify `cef-ssh-watch-results` as the index pattern name and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked and use @timestamp as the Time Field)
* Load sample dashboard into Kibana
    * Click the **Management** tab >> **Saved Objects** tab >> **Import**, and select `ssh_analysis_kibana.json`
* Open dashboard
    * Click on **Dashboard** tab and open `CEF Login Dashboard` dashboard

Voila! You should see the following dashboard.

![Kibana Dashboard Screenshot](https://cloud.githubusercontent.com/assets/12695796/21648199/0078db7e-d295-11e6-8a3c-357074a4e12a.png)

### We would love your feedback!
If you found this example helpful and would like more such Getting Started examples for other standard formats, we would love to hear from you. If you would like to contribute Getting Started examples to this repo, we'd love that too!
