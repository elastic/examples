### Getting Started with Elastic Stack for NGINX (JSON) Logs

This **Getting Started with Elastic Stack** example provides sample files to ingest, analyze & visualize **NGINX access logs** using the Elastic Stack. This example uses JSON formatted version of Nginx logs. The NGINX `log format` entry used to generate these logs is shown in  Download section below.

This example historically used Logstash for ingestion. Per recommended best practices this is now achieved with Filebeat. The Logstash configuration is provided for reference only.


##### WARNING: Invalid JSON
By default NGINX uses \xXX to encode some characters. The resulting "JSON" string is not valid (the JSON standard specifies \u00XX) and in Logstash you will get a json parse error for the invalid JSON string. It only happens when any variables e.g. $http_user_agent contain characters that NGINX will escape e.g. backslash or reverse solidus.
Newer versions of NGINX (>=1.11.8) support `escape=json` as an argument to log_format. See the [ngx_http_log_module documentation](https://nginx.org/en/docs/http/ngx_http_log_module.html#log_format). 

### Versions

Example has been tested in following versions:

- Elasticsearch 6.0
- Elasticsearch [user agent plugin 6.0](https://www.elastic.co/guide/en/elasticsearch/plugins/6.0/ingest-user-agent.html)
- Elasticsearch [user geoip plugin 6.0](https://www.elastic.co/guide/en/elasticsearch/plugins/6.0/ingest-geoip.html)
- Filebeat 6.0
- Kibana 6.0

### Example Contents

* [nginx_json_logs](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_json_logs/nginx_json_logs) - Sample JSON Nginx log files
* [ngix_json_filebeat.yml](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_json_logs/nginx_json_filebeat.yml) - Filebeat configuration for ingesting JSON files.
* [nginx_json_kibana.json](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_json_logs/nginx_json_kibana.json) - Custom Kibana dashboard.
* [nginx_json_template.json](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_json_logs/nginx_json_template.json) - ES Template for ingestion.
* [nginx_json_pipeline.json](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_json_logs/nginx_json_pipeline.json) - ES Pipeline for ingestion.

##### Legacy Files:

* [nginx_json_logstash.conf](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_json_logs/logstash/nginx_json_logstash.conf) -  Logstash configuration. REFERENCE ONLY.


### Installation & Setup

* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the Elastic Stack stack (*you can skip this step if you have a working installation of the Elastic Stack,*)

* Run Elasticsearch & Kibana
  ```
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

  **Note:** By default, Elasticsearch runs on port 9200, and Kibana run on ports 5601. If you changed the default ports during/after installation, change the above calls to use appropriate ports.

* Download and install Filebeat as described [here](https://www.elastic.co/guide/en/beats/filebeat/5.4/filebeat-installation.html). **Do not start Filebeat**

### Download Example Files

Download the following files in this repo to a local directory:
- `nginx_json_logs` - sample JSON formatted NGINX logs**
- `nginx_json_filebeat.yml` - Filebeat configuration
- `nginx_json_template.json` - ES template
- `nginx_json_kibana.json` - Kibana dashboards
- `nginx_json_pipeline.json` - Ingestion pipeline

Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. Use sample code provided below to download the required files to a local directory:

```shell
wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/nginx_json_logs/nginx_json_logs
wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/nginx_json_logs/nginx_json_filebeat.yml
wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/nginx_json_logs/nginx_json_kibana.json
wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/nginx_json_logs/nginx_json_template.json
wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/nginx_json_logs/nginx_json_pipeline.json
```

** The JSON formatted NGINX logs used in this example were created with the following `log_format` entry in the `nginx.config` file.

```
log_format json_logstash '{ "time": "$time_local", '
                           '"remote_ip": "$remote_addr", '
                           '"remote_user": "$remote_user", '
                           '"request": "$request", '
                           '"response": "$status", '
                           '"bytes": "$body_bytes_sent", '
                           '"referrer": "$http_referer", '
                           '"agent": "$http_user_agent" }';
```

### Run Example

##### 1. Ingest data into Elasticsearch using Filebeat


* Move the file `nginx_json_filebeat.yml` to the Filebeat installation directory i.e.
    
     ```shell
    mv nginx_json_filebeat.yml <filebeat_installation_dir>/nginx_json_filebeat.yml
    ```
    
* Install the ingest pipeline

    ```shell
    curl -XPUT -H 'Content-Type: application/json' 'localhost:9200/_ingest/pipeline/nginx_json_pipeline' -d @nginx_json_pipeline.json
    ```
    
* Install the Elasticsearch template

    ```shell
    curl -XPUT -H 'Content-Type: application/json' 'localhost:9200/_template/nginx_json' -d @nginx_json_template.json
    ```

* Start Filebeat to begin ingesting data to Elasticsearch, modifying the command below to point to your Elasticsearch instance and the sample log file `nginx_json_logs`. Ingestion should take around a few seconds. Ingestion should take around a min.

    ```shell
    cd <filebeat_installation_dir>
    ./filebeat -e -c nginx_json_filebeat.yml -E "output.elasticsearch.hosts=["localhost:9200"]" -E "filebeat.prospectors.0.paths=["<path to nginx_json_logs>"]"

* Verify that data is successfully indexed into Elasticsearch.

  Running `http://localhost:9200/nginx_json_elastic/_count` should return a response a `"count":51462`


##### 2. Visualize data in Kibana

* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `nginx_json_elastic` index in Elasticsearch (auto-created in step 1)
    * Click the **Management** tab >> **Index Patterns** tab >> **Add New**. Specify `nginx_json_elastic` as the index pattern name, selecting @timestamp as the time field, and click **Create** to define the index pattern.
    * If this is the only index pattern declared, you will also need to select the star in the top upper right to ensure a default is defined. 
* Load sample dashboard into Kibana
    * Click the **Management** tab >> **Saved Objects** tab >> **Import**, and select `nginx_json_kibana.json`
    * On import you will be asked to overwrite existing objects - select "Yes, overwrite all". Additionally, select the index pattern "nginx_json_elastic" when asked to specify a index pattern for the dashboards.
* Open dashboard
    * Click on **Dashboard** tab and open `Sample Dashboard for Nginx Logs` dashboard

Voila! You should see the following dashboards. Enjoy!
![Kibana Dashboard Screenshot](https://user-images.githubusercontent.com/12695796/32549960-3a056e08-c483-11e7-9c6c-be7e50018cd5.png)

### We would love your feedback!
If you found this example helpful and would like to see more such Getting Started examples for other standard formats, we would love would to hear from you. If you would like to contribute examples to this repo, we'd love that too!
