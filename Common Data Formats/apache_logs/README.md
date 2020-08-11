### Getting Started with Elastic Stack for Apache Logs

This example provides sample files to ingest, analyze & visualize **Apache Access Logs** using the Elastic Stack, i.e. Elasticsearch, Filebeat and Kibana. The sample logs in this example are in the default apache combined log format.

In order to achieve this we use the Filebeat [Apache2 module](https://www.elastic.co/guide/en/beats/filebeat/6.0/filebeat-module-apache2.html) per Elastic Stack best practices.

Historically this example used Logstash. This configuration is provided for reference only.

### Versions

Example has been tested in following versions:

- Elasticsearch 6.0
- Elasticsearch [user agent plugin 6.0](https://www.elastic.co/guide/en/elasticsearch/plugins/6.0/ingest-user-agent.html)
- Elasticsearch [user geoip plugin 6.0](https://www.elastic.co/guide/en/elasticsearch/plugins/6.0/ingest-geoip.html)
- Filebeat 6.0
- Kibana 6.0

### Example Contents

* [apache_logs](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/apache_logs/apache_logs) - Sample apache log files

##### Legacy Files:

* [apache_logstash.conf](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/apache_logs/logstash/apache_logstash.conf) -  Logstash configuration. REFERENCE ONLY.
* [apache_kibana.json](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/apache_logs/logstash/apache_kibana.json) - Custom Kibana dashboard associated with Logstash configuration. REFERENCE ONLY.
* [apache_template.json](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/apache_logs/logstash/apache_template.json) - Template for Logstash ingestion. REFERENCE ONLY.

### Installation & Setup

* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the Elastic Stack (*you can skip this step if you have a working installation of the Elastic Stack,*)

* Run Elasticsearch & Kibana

  ```shell
    <path_to_elasticsearch_root_dir>/bin/elasticsearch
    <path_to_kibana_root_dir>/bin/kibana
    ```

* Install the required plugins

  ```shell
    <path_to_elasticsearch_root_dir>/bin/elasticsearch-plugin install ingest-user-agent
    <path_to_elasticsearch_root_dir>/bin/elasticsearch-plugin install ingest-geoip
    ```
* Check that Elasticsearch and Kibana are up and running.
  - Open `localhost:9200` in web browser -- should return status code 200
  - Open `localhost:5601` in web browser -- should display Kibana UI.

  **Note:** By default, Elasticsearch runs on port 9200, and Kibana run on ports 5601. If you changed the default ports, change   the above calls to use appropriate ports.

* Download and install Filebeat as described [here](https://www.elastic.co/guide/en/beats/filebeat/6.0/filebeat-installation.html). **Do not start Filebeat**


### Download Example Files

Download the following file in this repo to a local directory:

- `apache_logs` - sample data (in apache combined log format)

Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. Use sample code provided below to download the required files to a local directory:

```shell
wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/apache_logs/apache_logs
```

### Run Example

##### 1. Ingest data into Elasticsearch using Filebeat Module


* From the Filebeat installation directory setup the apache2 module and ingest the sample provided. Modify the following command to include the location to the above sample data file.

```shell
cd <path_to_filebeat_root_dir>
./filebeat -e --modules=apache2 -M "apache2.access.var.paths=[<PATH_TO_APACHE_LOGS_FILE>]"
```

Further details on the apache2 module configuration can be found [here](https://www.elastic.co/guide/en/beats/filebeat/6.0/filebeat-module-apache2.html).

* Verify that data is succesfully indexed into Elasticsearch

  Running `http://localhost:9200/filebeat-*/_count` should return a response a `"count":10000`

 **Note:** The module assumes that you are running Elasticsearch on the same host as Filebeat and have not changed the defaults. Modify the settings my appending the parameter to the `-E` switch:
 
 `-E output.elasticsearch.hosts=<HOST>:<PORT>`
 
##### 2. Visualize data in Kibana

* Access Kibana by going to `http://localhost:5601` in a web browser
* You may be asked to select a default index pattern, if this is a clean Kibana/ES install. If so, select the "filebeat-*" index pattern and click the star button in the upper right.
* Open dashboard
    * Click on **Dashboard** tab and open `[Filebeat Apache2] Access and error logs` dashboard
* Change the time period
    * From the time range selector in the top right, select the time period `2015-05-17 00:00:00.000` to `2015-05-21 12:00:00.000` and click `Go`
Voila! You should see the following dashboard. Happy Data Exploration!

![Kibana Dashboard Screenshot](https://user-images.githubusercontent.com/12695796/32498856-c61c75c8-c3c8-11e7-85ab-515a337bd83d.png)

### We would love your feedback!
If you found this example helpful and would like more such Getting Started examples for other standard formats, we would love to hear from you. If you would like to contribute Getting Started examples to this repo, we'd love that too!
