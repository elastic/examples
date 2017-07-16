### Getting Started with Elastic Stack for CEF Data

This example provides sample files to ingest, analyze & visualize **CEF data** using the Elastic Stack, i.e. Elasticsearch, Logstash and Kibana.

This example provides the supporting material to blog post [Integrating the Elastic Stack with ArcSight SIEM - Part 1](https://www.elastic.co/blog/integrating-elastic-stack-with-arcsight-siem-part-1)

#### Versions

Example has been tested in following versions:
- Elasticsearch 5.1
- Logstash 5.1
- Kibana 5.1

### Manual Installation & Setup

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

* Download and install Logstash as described [here](https://www.elastic.co/guide/en/logstash/5.1/installing-logstash.html#installing-binary). Do not start Logstash.

### Docker Installation & Setup

A [docker-compose.yml](https://github.com/elastic/examples/tree/master/Common%20Data%20Formats/cef/docker-compose.yml) file is provided to recreate in instance of the Elastic Stack (Elasticsearch and Kibana). This assumes:

* You have [Docker Engine](https://docs.docker.com/engine/installation/) installed.
* Your host meets the [prerequisites](https://www.elastic.co/guide/en/elasticsearch/reference/5.1/docker.html#docker-cli-run-prod-mode).
* If you are on Linux, that [docker-compose](https://github.com/docker/compose/releases/latest) is installed.

Additionally a [docker file](https://github.com/elastic/examples/master/Common%20Data%20Formats/cef/logstash/Dockerfile) is provided for ingestion of CEF data with Logstash.


### Configure & Start Logstash

If using the docker file described above, the following can be ignored.

Download the following files to the **root installation** directory of Logstash:

- [logstash/pipeline/logstash.conf](https://github.com/elastic/examples/tree/master/Common%20Data%20Formats/cef/logstash/pipeline/logstash.conf) - Logstash config for ingesting CEF data into Elasticsearch
- [logstash/pipeline/cef_template.json](https://github.com/elastic/examples/tree/master/Common%20Data%20Formats/cef/logstash/pipeline/cef_template.json)` - CEF template for custom mapping of fields

Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. Use sample code provided below to download the required files to a local directory:

```
wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/cef/logstash/pipeline/logstash.conf
wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/cef/logstash/pipeline/cef_template.json
```

Start Logstash from the commnad line as described [here](https://www.elastic.co/guide/en/logstash/5.1/running-logstash-command-line.html), using the configuration file download above.

### Configure ArcSight

1. Configure ArcSight connectors to send data to Logstash
1. Run the command ..<installdir>\current\bin\arcsight agentsetup
1. Choose yes to start the `wizardmode`
1. Choose `I want to add/remove/modify ArcSight Manager destinations`
1. Choose `add new destination`
1. Choose `CEF syslog`
1. Add the information of the logstash host and port 5000 you prepared and choose the TCP protocol.


### Visualize data in Kibana

Download the [dashboard.json](https://github.com/elastic/examples/master/Common%20Data%20Formats/cef/dashboard.json) file provided e.g.

```
wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/cef/dashboard.json
```

* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `cef-*` index in Elasticsearch
    * Click the **Management** tab >> **Index Patterns** tab >> **Add New**. Specify `cef-*` as the index pattern name and click **Create** to define the index pattern with the field @timestamp
* Load sample dashboard into Kibana
    * Click the **Management** tab >> **Saved Objects** tab >> **Import**, and select `dashboard.json`
* Open dashboard
    * Click on **Dashboard** tab and open `FW-Dashboard` dashboard

Voila! You should see the following dashboards. Enjoy!
![Kibana Dashboard Screenshot](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/cef/cef_dashboard.png?raw=true)

### We would love your feedback!
If you found this example helpful and would like to see more such Getting Started examples for other standard formats, we would love to hear from you. If you would like to contribute examples to this repo, we'd love that too!
