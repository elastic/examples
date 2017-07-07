### Community Contribution

Contributed by [Kunal Pariani](https://github.com/kunalvjti) from NGINX

If you have trouble running the example or have suggestions for improvement, please create a Github issue and copy Kunal Pariani [@kunalvjti](https://github.com/kunalvjti) in it.

### Getting Started with the Elastic Stack for NGINX Plus (JSON) Logs

This **Getting Started with Elastic Stack** example provides sample files to ingest, analyze & visualize **Nginx Plus logs obtained from its status API** using the Elastic Stack, i.e. Elasticsearch, Filebeat and Kibana. The logs obtained from the status API are in JSON format.

This example historically used Logstash for ingestion. Per recommended best practices this is now achieved with Filebeat. The Logstash configuration is provided for reference only.

### Versions:

Example has been tested with following versions:
- Elasticsearch 5.4
- Filebeat 5.4
- Kibana 5.4


### Example Contents

* [nginxplus_json_logs](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_json_plus_logs/nginxplus_json_logs) - Sample JSON Nginx Plus log files
* [ngix_json_plus_filebeat.yml](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_json_plus_logs/ngix_json_plus_filebeat.yml) - Filebeat configuration for ingesting JSON files.
* [nginxplus_json_kibana.json](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_json_plus_logs/nginxplus_json_kibana.json) - Custom Kibana dashboard.
* [nginxplus_json_template.json](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_json_plus_logs/nginxplus_json_template.json) - ES Template for ingestion.
* [nginxplus_json_pipeline.json](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_json_plus_logs/nginxplus_json_pipeline.json) - ES Pipeline for ingestion.


#####Legacy Files:

* [nginx_json_logstash.conf](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_json_plus_logs/logstash/nginxplus_json_logstash.conf) -  Logstash configuration. REFERENCE ONLY.


### Installation & Setup

* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the Elastic Stack (*you can skip this step if you have a working installation of the Elastic Stack,*)

* Run Elasticsearch & Kibana
  ```
  <path_to_elasticsearch_root_dir>/bin/elasticsearch
  <path_to_kibana_root_dir>/bin/kibana
  ```

* Check that Elasticsearch and Kibana are up and running.
  - Open `localhost:9200` in web browser -- should return status code 200
  - Open `localhost:5601` in web browser -- should display Kibana UI.

  **Note:** By default, Elasticsearch runs on port 9200, and Kibana run on ports 5601. If you changed the default ports during/after installation, change the above calls to use appropriate ports.

* Download and install Filebeat as described [here](https://www.elastic.co/guide/en/beats/filebeat/5.4/filebeat-installation.html). **Do not start Filebeat**


### Download Example Files

Download the following files in this repo to a local directory:

- `nginxplus_json_logs` - sample JSON formatted Nginx Plus logs from its status API
- `ngix_json_plus_filebeat.yml` - Filebeat config for ingesting data into Elasticsearch
- `nginxplus_json_template.json` - template for custom mapping of fields
- `nginxplus_json_kibana.json` - config file to load prebuilt Kibana dashboard
- `nginxplus_json_pipeline.json` - Ingestion pipeline

Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. Use sample code provided below to download the required files to a local directory:

```
wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/nginx_json_plus_logs/ngix_json_plus_filebeat.yml
wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/nginx_json_plus_logs/nginxplus_json_kibana.json
wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/nginx_json_plus_logs/nginxplus_json_template.json
wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/nginx_json_plus_logs/nginxplus_json_pipeline.json
wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/nginx_json_plus_logs/nginxplus_json_logs
```

** The JSON formatted logs used in this example were created using status API of NGINX Plus. Please refer to [Live activity monitoring with NGINX Plus](https://www.nginx.com/products/live-activity-monitoring/) for more information on how to use status API of NGINX Plus

### Run Example

##### 1. Ingest data into Elasticsearch using Filebeat

* Modify the filebeat configuration file `ngix_json_plus_filebeat.yml`. Specifically:

    - The parameter `hosts: ["localhost:9200"]` in case your are not running Elasticsearch node on your local host
    - The path to the example data file downloaded above.
    
        ```shell
        paths:
          - ./nginxplus_json_logs
        ```

* Move the files `nginx_json_template.json` and `nginx_json_filebeat.yml` to the Filebeat installation directory i.e.
    
     ```shell
    mv nginxplus_json_template.json <filebeat_installation_dir>/nginxplus_json_template.json
    mv ngix_json_plus_filebeat.yml <filebeat_installation_dir>/ngix_json_plus_filebeat.yml
    ```
    
* Install the ingest pipeline

    ```shell
    curl -XPUT -H 'Content-Type: application/json' 'localhost:9200/_ingest/pipeline/nginxplus_json_pipeline' -d @nginxplus_json_pipeline.json
    ```

* Start Filebeat to begin ingesting data to Elasticsearch. Ingestion should take around a min.

    ```shell
    cd <filebeat_installation_dir>
    ./filebeat -e -c ngix_json_plus_filebeat.yml

 * Verify that data is successfully indexed into Elasticsearch

  Running `http://localhost:9200/nginxplus_json_elastic_stack_example/_count` should return a response a `"count":500`

##### 2. Visualize data in Kibana

* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `nginxplus_json_elastic_stack_example` index in Elasticsearch (auto-created in step 1)
    * Click the **Management** tab >> **Index Patterns** tab >> **Add New**. Specify `nginxplus_json_elastic_stack_example` as the index pattern name and click **Create** to define the index pattern, using the @timestamp field as the Time-Field.
* Load sample dashboard into Kibana
    * Click the **Settings** tab >> **Saved Objects** tab >> **Import**, and select `nginxplus_json_kibana.json`
* Open dashboard
    * Click on **Dashboard** tab and open `NginxPlus: Sample Dashboard` dashboard

Voila! You should see the following dashboard. Enjoy!
![Kibana Dashboard Screenshot](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_json_plus_logs/nginx_plus_json_dashboard.jpg?raw=true)
