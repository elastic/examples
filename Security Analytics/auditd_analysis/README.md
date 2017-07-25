# Alerting on Auditd CEF Data

This **Getting Started with Elastic Stack** example provides sample files to ingest, analyze and alert on **Auditd Logs in the CEF Format** using the Elastic Stack. 

Included are example Watches for proactively monitoring this data for possible security incidents.  These examples support the Security Analytics blog post series, specifically:
 
[Integrating Elasticsearch with ArcSight SIEM - Part 5](https://www.elastic.co/blog/integrating-elasticsearch-with-arcsight-siem-part-5).
[Integrating Elasticsearch with ArcSight SIEM - Using Machine Learning - Part 6](https://www.elastic.co/blog/integrating-elasticsearch-with-arcsight-siem-part-6).

The examples complement the above blog posts, providing a means to:

- [Detect New Processes](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/example_1/README.md) - Detect a new process signature occuring on a server in the last N minutes, that has not occurred on the server historically.
- [Detect an Unusual Process](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/example_2/README.md) - Detect an unusual process on a server using X-Packs Machine Learning capabilities. Unusual here is defined as statistically rare within the context of a specific server.

Both examples utilise:

- [auditd_analysis_logstash.conf](https://raw.githubusercontent.com/elastic/examples/master/Security%20Analytics/audidt_analysis/auditd_analysis_logstash.conf) - An appropriate Logstash configuration for indexing the above CEF data. This configuration creates a `process_signature` field for the first example.
- [cef_template.json](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/cef/logstash/pipeline/cef_template.json) -  This will be installed when Logstash is run with the above configuration.
- [simulate_watch.py](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/simulate_watch.py) - A convenience script to execute the above watch. In order to test this watch against the provided test data set, this script which performs a “sliding window” execution of the watch. 
This repeatedly executes the watch, each time adjusting the date filters to target the next 5 minute time range thus simulating the execution against a live stream of several days of data in a few seconds.
- [requirements.txt](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/requirements.txt) - Python dependencies for pip

## Versions

The examples has been tested with the following versions:

- Elasticsearch 5.5
- Logstash 5.5 with [CEF codec](https://www.elastic.co/guide/en/logstash/current/plugins-codecs-cef.html)
- Kibana 5.5
- X-Pack 5.5
- Python 3.5 with Elasticsearch dependency

## Installation & Setup

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

## Setup Python

* Install Python 3.5.x
* Ensure pip is installed
* Install dependencies using pip i.e. `pip install -r requirements.txt`


## Follow specific example instructions

Example specific instructions should be followed, either:

- [Detect New Processes](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/example_1/README.md) for [Integrating Elasticsearch with ArcSight SIEM - Part 5](https://www.elastic.co/blog/integrating-elasticsearch-with-arcsight-siem-part-5).
- [Detect an Unusual Process](https://github.com/elastic/examples/blob/master/Security%20Analytics/auditd_analysis/example_2/README.md) for [Integrating Elasticsearch with ArcSight SIEM - Using Machine Learning - Part 6](https://www.elastic.co/blog/integrating-elasticsearch-with-arcsight-siem-part-6).

## We would love your feedback!

If you found this example helpful, and would like more such Getting Started examples for other standard formats, we would love to hear from you. If you would like to contribute Getting Started examples to this repo, we'd love that too!
