### Community Contribution

Contributed by [Kunal Pariani](https://github.com/kunalvjti) from NGINX

##### Product Versions:
Example has been tested with following versions:
- Elasticsearch 5.0
- Logstash 5.0
- Kibana 5.0

If you have trouble running the example or have suggestions for improvement, please create a Github issue and copy Kunal Pariani [@kunalvjti](https://github.com/kunalvjti) in it.

### Getting Started with the Elastic Stack for NGINX Plus (JSON) Logs
This **Getting Started with Elastic Stack** example provides sample files to ingest, analyze & visualize **Nginx Plus logs obtained from its status API** using the Elastic Stack, i.e. Elasticsearch, Logstash and Kibana. The logs obtained from the status API are in JSON format.

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

### Download Example Files

Download the following files in this repo to a local directory:
- `nginxplus_json_logs` - sample JSON formatted Nginx Plus logs from its status API
- `nginxplus_json_logstash.conf` - Logstash config for ingesting data into Elasticsearch
- `nginxplus_json_template.json` - template for custom mapping of fields
- `nginxplus_json_kibana.json` - config file to load prebuilt Kibana dashboard

Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. Use sample code provided below to download the required files to a local directory:

```
mkdir nginxplus_json_ELK_Example
cd nginxplus_json_ELK_Example
wget https://raw.githubusercontent.com/elastic/examples/master/ELK_NGINX_Plus-json/nginxplus_json_logstash.conf
wget https://raw.githubusercontent.com/elastic/examples/master/ELK_NGINX_Plus-json/nginxplus_json_kibana.json
wget https://raw.githubusercontent.com/elastic/examples/master/ELK_NGINX_Plus-json/nginxplus_json_template.json
wget https://raw.githubusercontent.com/elastic/examples/master/ELK_NGINX_Plus-json/nginxplus_json_logs
```

** The JSON formatted logs used in this example were created using status API of NGINX Plus. Please refer to [Live activity monitoring with NGINX Plus](https://www.nginx.com/products/live-activity-monitoring/) for more information on how to use status API of NGINX Plus

### Run Example
##### 1. Ingest data into Elasticsearch using Logstash
* Execute the following command to load sample logs into Elasticsearch.

```shell
cd nginxplus_json_ELK_Example
cat nginxplus_json_logs | <path_to_logstash_root_dir>/bin/logstash -f nginxplus_json_logstash.conf
```

 * Verify that data is successfully indexed into Elasticsearch

  Running `http://localhost:9200/nginxplus_json_elastic_stack_example/_count` should return a response a `"count":500`

 **Note:** Included `nginxplus_json_logstash.conf` configuration file assumes that you are running Elasticsearch on the same host as Logstash and have not changed the defaults. Modify the `host` and `cluster` settings in the `output { elasticsearch { ... } }`   section of nginxplus_json_logstash.conf, if needed.

##### 2. Visualize data in Kibana

* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `nginxplus_json_elastic_stack_example` index in Elasticsearch (auto-created in step 1)
    * Click the **Management** tab >> **Index Patterns** tab >> **Add New**. Specify `nginxplus_json_elastic_stack_example` as the index pattern name and click **Create** to define the index pattern, using the @timestamp field as the Time-Field.
* Load sample dashboard into Kibana
    * Click the **Settings** tab >> **Saved Objects** tab >> **Import**, and select `nginxplus_json_kibana.json`
* Open dashboard
    * Click on **Dashboard** tab and open `Sample Dashboard for Nginx Logs` dashboard

Voila! You should see the following dashboard. Enjoy!
![Kibana Dashboard Screenshot](https://cloud.githubusercontent.com/assets/1437560/11547099/4578e76a-9906-11e5-8650-5a386c82b201.png)
