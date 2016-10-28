### Getting Started with Elastic Stack for NGINX Logs
This **Getting Started with Elastic Stack** example provides sample files to ingest, analyze & visualize **NGINX access logs** using the Elastic Stack, i.e. Elasticsearch, Logstash and Kibana. The sample NGINX access logs in this example use the default NGINX combined log format.

##### Version
Example has been tested in following versions:
- Elasticsearch 5.0
- Logstash 5.0
- Kibana 5.0

### Installation & Setup
* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the Elastic Stack (*you can skip this step if you have a working installation of the Elastic Stack,*)

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
- `nginx_logs` - sample data **
- `nginx_logstash.conf` - Logstash config for ingesting data into Elasticsearch
- `nginx_template.json` - template for custom mapping of fields
- `nginx_kibana.json` - config file to load prebuilt Kibana dashboard

Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. Use sample code provided below to download the required files to a local directory:

** The NGINX logs used in this example were created with the default combined `log_format` entry in the `nginx.config` file.
```
log_format combined '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
```

```shell
mkdir  nginx_ElasticStack_Example
cd nginx_ElasticStack_Example
wget https://raw.githubusercontent.com/elastic/examples/master/ElasticStack_NGINX/nginx_logstash.conf
wget https://raw.githubusercontent.com/elastic/examples/master/ElasticStack_NGINX/nginx_template.json
wget https://raw.githubusercontent.com/elastic/examples/master/ElasticStack_NGINX/nginx_kibana.json
wget https://raw.githubusercontent.com/elastic/examples/master/ElasticStack_NGINX/nginx_logs
```

### Run Example
##### 1. Ingest data into Elasticsearch using Logstash
* Execute the following command to load sample logs into Elasticsearch.

```shell
cat nginx_logs | <path_to_logstash_root_dir>/bin/logstash -f nginx_logstash.conf
```

 * Verify that data is succesfully indexed into Elasticsearch

  Running `http://localhost:9200/nginx_elastic_stack_example/_count` should return a response a `"count":51462`

 **Note:** Included `nginx_logstash.conf` configuration file assumes that you are running Elasticsearch on the same host as     Logstash and have not changed the defaults. Modify the `host` and `cluster` settings in the `output { elasticsearch { ... } }`   section of nginx_logstash.conf, if needed.

##### 2. Visualize data in Kibana

* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `nginx_elastic_stack_example` index in Elasticsearch (autocreated in step 1)
    * Click the **Management** tab >> **Index Patterns** tab >> **Add New**. Specify `nginx_elastic_stack_example` as the index pattern name and click **Create** to define the index pattern with the field @timestamp
* Load sample dashboard into Kibana
    * Click the **Management** tab >> **Saved Objects** tab >> **Import**, and select `nginx_kibana.json`
* Open dashboard
    * Click on **Dashboard** tab and open `Sample Dashboard for Nginx Logs` dashboard

Voila! You should see the following dashboards. Enjoy!
![Kibana Dashboard Screenshot](https://cloud.githubusercontent.com/assets/5269751/9672317/7c5b763e-524e-11e5-949f-b8dad81bce8f.png)

### We would love your feedback!
If you found this example helpful and would like to see more such Getting Started examples for other standard formats, we would love to hear from you. If you would like to contribute examples to this repo, we'd love that too!
