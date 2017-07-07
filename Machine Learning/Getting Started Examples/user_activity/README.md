## Getting started with machine learning

This is a complementary resource to the examples shown in [Lab 3 - Advanced Job (detecting outliers in a population)](http://www.elastic.co/videos/machine-learning-lab-3-detect-outliers-in-a-population) video in the Getting Started with Machine Learning tutorial series.

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

   **NOTE:** The dataset included here is slightly different from the one used in the video, and you might see slightly different results when you follow along the steps in this video. The concepts and steps covered are still applicable.

   ```
   mkdir user-activity
   cd user-activity
   wget https://download.elasticsearch.org/demos/machine_learning/gettingstarted/user-activity.json
   ```

2. Download `ingest_data.sh` script in this repo, and copy it into the `user-activity` folder (created in the previous step) <br>

3. Run the `ingest_data.sh` script to index the data into Elasticsearch.  

   **WARNING**: This script  indexes the data into index, `user-activity` and creates a Kibana index pattern, `user-activity`. If your Elasticsearch instance already has a index or a index pattern with that name, it will be overwritten when you run this script.**

    ```  
    sh ingest-data.sh
    ```

5. Check data availability. Once the index is indexed you can check to see if all the data is available in Elasticsearch. You should get a `count` response greater than `3100` when you run the following command (assumes default user).

    ```shell
    curl -H "Content-Type: application/json" -XGET localhost:9200/user-activity/_count -d '{"query": {"match_all": {}}}' -u elastic:changeme
    ```

6. Check that `user-activity` pattern exists in Kibana

    Click on **Management** app in the left navigation > click **Index Patterns**. You should see `user-activity` listed in the index patterns list


7. Create machine learning jobs to spot anomalies in `user-activity`

   At this point, you are all set to follow the steps [Lab 3](http://www.elastic.co/videos/machine-learning-lab-3-detect-outliers-in-a-population) on your local installation of Elastic Stack. Enjoy!

### Got questions?

   Have trouble running this example, [file issue on this repo](https://github.com/elastic/examples/issues/new). Got questions or feedback about machine learning, [we would love to hear from you on our discuss forums](https://discuss.elastic.co/c/x-pack).
