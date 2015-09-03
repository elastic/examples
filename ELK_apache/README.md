### Getting Started with ELK for Apache Logs
This **Getting Started with ELK** example provides sample files to ingest, analyze & visualize **Apache Access Logs** using the ELK stack, i.e. Elasticsearch, Logstash and Kibana. The sample logs in this example are in the default apache combined log format.

##### Version
Example has been tested in following versions:
- Elasticsearch 1.7.0
- Logstash 1.5.2
- Kibana 4.1.0

### Installation & Setup
* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the ELK stack (*you can skip this step if you have a working installation of the ELK stack,*)

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
- `apache_logs` - sample data (in apache combined log format)
- `apache_logstash.conf` - Logstash config for ingesting data into Elasticsearch
- `apache_template.json` - template for custom mapping of fields
- `apache_kibana.json` - config file to load prebuilt creating Kibana dashboard
- `apache_dashboard.png` - screenshot of final Kibana dashboard  

Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. Use sample code provided below to download the required files to a local directory:

```shell
mkdir  Apache_ELK_Example
cd Apache_ELK_Example
wget https://raw.githubusercontent.com/elastic/examples/master/ELK_apache/apache_logstash.conf
wget https://raw.githubusercontent.com/elastic/examples/master/ELK_apache/apache_template.json
wget https://raw.githubusercontent.com/elastic/examples/master/ELK_apache/apache_kibana.json
wget https://raw.githubusercontent.com/elastic/examples/master/ELK_apache/apache_logs
```

### Run Example
##### 1. Ingest data into Elasticsearch using Logstash
* Execute the following command to load sample logs into Elasticsearch. [Note: It takes a few minutes to ingest the entire file (~300,000 logs) into Elasticsearch]

```shell
cat apache_logs | <path_to_logstash_root_dir>/bin/logstash -f apache_logstash.conf
```

 * Verify that data is succesfully indexed into Elasticsearch

  Running `http://localhost:9200/apache_elk_example/_count` should return a response a `"count":10000`

 **Note:** Included `apache_logstash.conf` configuration file assumes that you are running Elasticsearch on the same host as Logstash and have not changed the defaults. Modify the `host` and `cluster` settings in the `output { elasticsearch { ... } }`   section of apache_logstash.conf, if needed.

##### 2. Visualize data in Kibana

* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `apache_elk_example` index in Elasticsearch (autocreated in step 1)
    * Click the **Settings** tab >> **Indices** tab >> **Create New**. Specify `apache_elk_example` as the index pattern name and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked)
* Load sample dashboard into Kibana
    * Click the **Settings** tab >> **Objects** tab >> **Import**, and select `apache_kibana.json`
* Open dashboard
    * Click on **Dashboard** tab and open `Sample Dashboard for Apache Logs` dashboard

Voila! You should see the following dashboard. Happy Data Exploration!

![Kibana Dashboard Screenshot](https://cloud.githubusercontent.com/assets/5269751/9672401/19fe21de-524f-11e5-86a6-49e76636c79a.png)

### We would love your feedback!
If you found this example helpful and would like more such Getting Started examples for other standard formats, we would love to hear from you. If you would like to contribute Getting Started examples to this repo, we'd love that too!
