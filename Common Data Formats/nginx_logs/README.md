### Getting Started with Elastic Stack for NGINX Logs

This **Getting Started with Elastic Stack** example provides sample files to ingest, analyze & visualize **NGINX access logs** using the Elastic Stack, i.e. Elasticsearch, Filebeat and Kibana. The sample NGINX access logs in this example use the default NGINX combined log format.

In order to achieve this we use the Filebeat [Nginx module](https://www.elastic.co/guide/en/beats/filebeat/6.0/filebeat-module-nginx.html) per Elastic Stack best practices.

Historically this example used Logstash. This configuration is provided for reference only.

### Versions
Example has been tested in following versions:

- Elasticsearch 6.0
- Elasticsearch [user agent plugin 6.0](https://www.elastic.co/guide/en/elasticsearch/plugins/5.4/ingest-user-agent.html)
- Elasticsearch [user geoip plugin 6.0](https://www.elastic.co/guide/en/elasticsearch/plugins/5.4/ingest-geoip.html)
- Filebeat 6.0
- Kibana 6.0

### Example Contents

* [nginx_logs](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_logs/nginx_logs) - Sample nginx log files

This example includes:

##### Legacy Files:

* [nginx_logstash.conf](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_logs/logstash/nginx_logstash.conf) -  Logstash configuration. REFERENCE ONLY.
* [nginx_kibana.json](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_logs/logstash/nginx_kibana.json) - Custom Kibana dashboard associated with Logstash configuration. REFERENCE ONLY.
* [nginx_template.json](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/nginx_logs/logstash/nginx_template.json) - Template for Logstash ingestion. REFERENCE ONLY.

### Installation & Setup

* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the Elastic Stack (*you can skip this step if you have a working installation of the Elastic Stack*)

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

Download the following files in this repo to a local directory:

- `nginx_logs` - sample data **

Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. Use sample code provided below to download the required files to a local directory:

** The NGINX logs used in this example were created with the default combined `log_format` entry in the `nginx.config` file.
```
log_format combined '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
```

```shell
wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/nginx_logs/nginx_logs
```

### Run Example
##### 1. Ingest data into Elasticsearch using Filebeat

* From the Filebeat installation directory setup the apache2 module and ingest the sample provided. Modify the following command to include the location to the above sample data file.

```shell
cd <path_to_filebeat_root_dir>
./filebeat -e --modules=nginx --setup  -M "nginx.access.var.paths=[<PATH_TO_NGINX_LOGS_FILE>]"
```

* Verify that data is successfully indexed into Elasticsearch

  Running `curl http://localhost:9200/filebeat-*/_count` should return a response a `"count":51462`

 **Note:** The module assumes that you are running Elasticsearch on the same host as Filebeat and have not changed the defaults. Modify the settings my appending the parameter to the `-E` switch:
 
 `-E output.elasticsearch.hosts=<HOST>:<PORT>`
 
 
 ##### 2. Visualize data in Kibana

* Access Kibana by going to `http://localhost:5601` in a web browser
* You may be asked to select a default index pattern, if this is a clean Kibana/ES install. If so, select the "filebeat-*" index pattern and click the star button in the upper right.
* Open dashboard
    * Click on **Dashboard** tab and open `[Filebeat Nginx] Access and error logs` dashboard
* Change the time period
    * From the time range selector in the top right, selec the time period `2015-05-16 00:00:00.000` to `2015-06-05 23:59:59.999` and click `Go`

Voila! You should see the following dashboards. Enjoy!
![Kibana Dashboard Screenshot](https://user-images.githubusercontent.com/12695796/32498756-6ebc80e8-c3c8-11e7-8d1f-dca6ea03d8c2.png)

### We would love your feedback!
If you found this example helpful and would like to see more such Getting Started examples for other standard formats, we would love to hear from you. If you would like to contribute examples to this repo, we'd love that too!
