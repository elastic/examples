# Suspicious Login Activity (Volume) - Example

## Overview

In order to test and evaluate this recipe, a test dataset is provided in the form of linux authorization logs collected over a 3 week period. This dataset, which contains a suspicious signature, is indexed to Elasticsearch using a Filebeat equipped with the System module.  

This ML recipe and Filebeat configuration can be applied to any linux system with authorization logs. Further details on using the Filebeat module to index authorization logs can be found [here](https://www.elastic.co/blog/grokking-the-linux-authorization-logs) .

## Pre-requisites

- Filebeat v5.4
- Elasticsearch v5.4
- [ingest-geoip plugin](https://www.elastic.co/guide/en/elasticsearch/plugins/master/ingest-geoip.html)
- X-Pack v5.4 with ML beta
- curl

## Recipe Components

This example includes:

 * Minimal Filebeat configuration for indexing linux authorisation logs.
 * X-Pack Machine Learning job configuration files
 * Utility scripts to help with loading of the job

## Installation and Setup

* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the Elastic Stack (*you can skip this step if you have a working installation of the Elastic Stack,*)

* Install the X-Pack in Kibana and Elasticsearch

  ```shell
  <path_to_elasticsearch_root_dir>/elasticsearch-plugin install x-pack
  <path_to_kibana_root_dir>/bin/kibana-plugin install x-pack
  ```

* Run Elasticsearch & Kibana

  ```shell
    <path_to_elasticsearch_root_dir>/bin/elasticsearch
    <path_to_kibana_root_dir>/bin/kibana

  ```

* Check that Elasticsearch and Kibana are up and running.

  - Open `localhost:9200` in web browser -- should return a json message indicating ES is running.
  - Open `localhost:5601` in web browser -- should display Kibana UI.

  **Note:** By default, Elasticsearch runs on port 9200, and Kibana run on ports 5601. If you changed the default ports, change the above calls to use the appropriate ports.  

  The cluster will be secured using basic auth. If changing the default credentials of `elastic` and `changeme` as described [here](https://www.elastic.co/guide/en/x-pack/current/security-getting-started.html), ensure the logstash configuration file is updated.

* Install the ingest-geoip plugin for Elasticsearch. This is pre-requisite for the filebeat auth module.

    ```
    sudo <path_to_elasticsearch_root_dir>/bin/elasticsearch-plugin install ingest-geoip
    ```


* Download the test dataset provided.

    ```
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20Analytics%20Recipes/suspicious_login_activity/data/auth.log
    ```


* [Download and Install Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation.html). **Do not start Filebeat**.

* Download the provided Filebeat configuration file.

    ```
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20Analytics%20Recipes/suspicious_login_activity/configs/filebeat/filebeat.yml
    ```

* Modify the filebeat.yml file. Change:

    - The path to the sample data file downloaded above in the setting `var.paths`
    - The elasticsearch username and password values if these have been modified from the defaults
    - The beat.name value generated for all Auth documents. This will be used to identify the source of the Filebeat data. By default this is set to `test` and can be changed through the configuration parameter `name`.

* Copy the modified filebeat.yml file to the root installation folder of the Filebeat installation, overwriting the default file i.e.

    ```cp filebeat.yml <path_to_filebeat_installation>/filebeat.yml```

* Start filebeat as described [here](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-starting.html).

* Wait several minutes before confirming the data has been indexed.

    - Confirm the data has been indexed i.e.
        ```
        curl localhost:9200/filebeat-*/_refresh -u elastic:changeme
        curl localhost:9200/filebeat-*/doc/_count -u elastic:changeme
        ```

    The last command should return a count of 7121 if all data has been indexed e.g.

    ```
    {"count":7121,"_shards":{"total":5,"successful":5,"failed":0}}
    ```

## Load the Recipe

The above steps should index a sample set of auth logs into Elasticsearch.  To load ML the recipe, perform the following steps:

Download the following files to the **same directory**:

  ```
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20Analytics%20Recipes/suspicious_login_activity/machine_learning/data_feed.json
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20Analytics%20Recipes/suspicious_login_activity/machine_learning/job.json
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20Analytics%20Recipes/scripts/reset_job.sh
  ```

* Load the Job by running the supplied reset_job.sh script.

```
./reset_job.sh suspicious_login_activity
```

This script assumes the default Elasticsearch host, port, user and password. To supply alternatives, supply as arguments e.g.

```
./reset_job.sh suspicious_login_activity <host_port> <username> <password>
```

* Access Kibana by going to http://localhost:5601 in a web browser

* Select "Machine Learning" from the left tab. This should list the "Suspicious Login Activity" job e.g.

[http://localhost:5601/app/ml#/jobs?_g=()](http://localhost:5601/app/ml#/jobs?_g=())

![ML Job Listing Screenshot](https://cloud.githubusercontent.com/assets/12695796/25242318/1b64f652-25f1-11e7-88f3-441aac6844e9.png)

## Run the Recipe

* The Machine Learning job can be started. To start, either:

    - issue the following command to the ML API

        ```
        curl -s -X POST localhost:9200/_xpack/ml/datafeeds/datafeed-suspicious_login_activity/_start -u elastic:changeme
        ```  
    OR

    - Click the `>` icon for the job in the UI, followed by `Start`.

* On completion of the job execution navigate to the explorer results view for the job. The example anomaly is shown below:

![Example Explorer View for Suspicious Login Activity](https://cloud.githubusercontent.com/assets/12695796/25242381/4795b0fe-25f1-11e7-81f4-f46aa3880e95.png)
