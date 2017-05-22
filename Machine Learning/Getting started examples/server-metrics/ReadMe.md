## Getting started with machine learning - creating a single metric job

This is a complementary resource to the examples shown in [Lab 1 - Create a single metric job](https://www.elastic.co/videos/machine-learning-tutorial-creating-a-single-metric-job) and [Lab 2 - Create a multi metric job](https://www.elastic.co/videos/machine-learning-tutorial-creating-a-single-metric-job) video in the Getting Started with Machine Learning tutorial series.

  In this ReadMe, we will provide the instructions for (a) installing Elastic Stack & X-Pack, and (b) indexing the dataset used in the getting started videos into Elasticsearch. Once you have the data indexed, you can follow along the steps shown in the video to setup machine learning jobs on this dataset.   

### Versions and Pre-requisites

Example has been tested in following versions:

- Elasticsearch 5.4
- X-Pack 5.4
- Kibana 5.4

### Installation & Setup

* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the Elastic Stack (*you can skip this step if you already have a working installation of the Elastic Stack, version 5.4 or higher*)

* Install X-Pack into Kibana and Elasticsearch

  ```shell
  <path_to_elasticsearch_root_dir>/elasticsearch-plugin install x-pack
  <path_to_kibana_root_dir>/bin/kibana-plugin install x-pack
  ```

* Run Elasticsearch & Kibana

  ```shell
  <path_to_elasticsearch_root_dir>/bin/elasticsearch
  <path_to_kibana_root_dir>/bin/kibana
  ```

The following assumes the default username and password of "elastic" and "changeme".  These can be changed as detailed [here](https://www.elastic.co/guide/en/shield/current/native-realm.html).  If changed, ensure the `ingest_data.sh` file is updated accordingly to permit ingestion.

* Check that Elasticsearch and Kibana are up and running.
  - Open `localhost:9200` in web browser and authenticate with "elastic" and "changeme" -- should return status code 200
  - Open `localhost:5601` in web browser -- should display Kibana UI.


  **Note:** By default, Elasticsearch runs on port 9200, and Kibana run on ports 5601. If you changed the default ports, change the above calls to use appropriate ports.

### Download & Ingest Data

1. Download and unpack the dataset.

   ```
   mkdir server_metrics
   cd server_metrics
   wget https://download.elasticsearch.org/demos/machine_learning/gettingstarted/server_metrics.tar.gz
   tar -xvf server_metrics.tar.gz
   ```

2. Download `ingest-data.sh` script in this repo, and copy it into the `server_metrics` folder (created in the previous step) <br>

3. Run the `ingest-data.sh` script to index the data into Elasticsearch.  

   **WARNING**: This script  indexes the data into index, `server-metrics`, and creates a Kibana index pattern, `server-*`. If your Elasticsearch instance already has a index or or index pattern with that name, it will be overwritten when you run this script.**

    
   ```
   sh ingest-data.sh
   ```
   

5. Check data availability. Once the index is indexed you can check to see if all the data is available in Elasticsearch. You should get a `count` response greater than `905940` when you run the following command (assumes default user).

    ```shell
    curl -XGET localhost:9200/server-*/_count -d '{"query": {"match_all": {}}}' -u elastic:changeme
    ```

6. Check that server-* pattern exists in Kibana

    Click on **Management** app in the left navigation > click **Index Patterns**. You should see `server-*` listed in the index patterns list


7. Create machine learning jobs to spot anomalies in `server-*`

   At this point, you are all set to follow the steps [Lab 1](https://www.elastic.co/videos/machine-learning-tutorial-creating-a-single-metric-job) and [Lab 2](https://www.elastic.co/videos/machine-learning-tutorial-creating-a-single-metric-job)  on your local installation of Elastic Stack. Enjoy!

### Got questions?

   Have trouble running this example, [file issue on this repo](https://github.com/elastic/examples/issues/new). Got questions or feedback about machine learning, [we would love to hear from you on our discuss forums](https://discuss.elastic.co/c/x-pack).
