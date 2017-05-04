# Service Response Change - Example

## Overview

In order to demonstrate this recipe a dataset is provided in the form of apache logs.  These logs contain a service outage for an area of the site - /blog, for a period of 2 hrs.  This results in a an unusually high number of 500 errors specific to this site area.

## Usage Notes

* This recipe typically needs adjusting to be effective for different datasets.  Typically this means restricting the job to a specific dataset limited by an Elasticsearch query e.g. for web logs, consider restricting the job to pages resulting in a 4xx or 5xx response.  This is typically less required for application level data.
* For web sites the user may wish to consider adjusting the detector to look for `high_distinct_count(ip) by response`.  This avoids the detection of frequent 4xx codes that result from website attacks, thus focusing on operational outages only i.e. when a high number of IPs receive an unusual response code.
* This example uses `site_area` as an influencer. This represents the first level in the site being accessed, thus attempting to isolate where issues are occurring.  These specific influencers used will need adapting on a dataset by dataset basis.
* The user may wish to adjust the bucket_span of the job depending on the frequency of the data and desired responsiveness of the job.

## Pre-requisites

- Logstash v5.3 (earlier versions may work but have not been tested)
- Elasticsearch v5.4
- X-Pack v5.4 with ML beta
- curl

## Recipe Components

This example includes:

 * Logstash configuration for indexing apache logs.  The Grok patterns here represent the typical [apache log example](https://github.com/elastic/examples/blob/master/ElasticStack_apache/apache_logstash.conf). An additional pattern has been added which extracts the first level from the accessed url, into a field `site_area`.
 * Index template for the data
 * X-Pack Machine Learning job configuration files
 * Utility script to help with loading of the job

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

* Download the test dataset provided.

    ```
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/IT%20operations%20recipes/Service_Response_Change/data/apache_logs.log
    ```

* [Download and Install Logstash](https://www.elastic.co/guide/en/logstash/current/installing-logstash.html). **Do not start Logstash**.

* Download the provided Logstash configuration file and index template into the same folder.

    ```
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/IT%20operations%20recipes/Service_Response_Change/configs/logstash/apache_logstash.conf
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/IT%20operations%20recipes/Service_Response_Change/configs/logstash/apache_template.json
    ```

* Modify the `logstash.conf` file. Change:

    - The elasticsearch username and password values if these have been modified from the defaults

* Copy the modified filebeat.yml file to the root installation folder of the Filebeat installation, overwriting the default file i.e.

    ```cp filebeat.yml <path_to_filebeat_installation>/filebeat.yml```

* Ingest the data sample provided by running the following command:

    ```
    cat <path_to_data_sample>/apache_logs.log | <logstash_installation_directory>/bin/logstash -f apache_logstash.conf
    ```

* Once Logstash has completed indexing confirm the data has been successfully indexed, modifying the following command if you have changed the default username and password:

    ```
    curl localhost:9200/apache_logs/_refresh -u elastic:changeme
    curl localhost:9200/apache_logs/_count -u elastic:changeme
    ```

    The last command should return a count of 119801 if all data has been indexed e.g.

    ```
    {"count":119801,"_shards":{"total":5,"successful":5,"failed":0}}
    ```

## Load the Recipe

The above steps should index a sample set of apache logs into Elasticsearch.  To load ML the recipe, perform the following steps:

Download the following files to the **same directory**:

  ```
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/IT%20operations%20recipes/Service_Response_Change/machine_learning/data_feed.json
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/IT%20operations%20recipes/Service_Response_Change/machine_learning/job.json
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/IT%20operations%20recipes/scripts/reset_job.sh
  ```

* Load the Job by running the supplied reset_job.sh script.

```
./reset_job.sh service_response_change
```

This script assumes the default Elasticsearch host, port, user and password. To supply alternatives, supply as arguments e.g.

```
./reset_job.sh service_response_change <host_port> <username> <password>
```

* Access Kibana by going to http://localhost:5601 in a web browser

* Select "Machine Learning" from the left tab. This should list the "Service Response Change" job e.g.

[http://localhost:5601/app/ml#/jobs?_g=()](http://localhost:5601/app/ml#/jobs?_g=())

![ML Job Listing Screenshot](https://cloud.githubusercontent.com/assets/12695796/25525287/ff08b0c8-2c05-11e7-8d0f-26cc009a8513.png)

## Run the Recipe

* The Machine Learning job can be started. To start, either:

    - issue the following command to the ML API

        ```
        curl -s -X POST localhost:9200/_xpack/ml/datafeeds/datafeed-service_response_change/_start -u elastic:changeme
        ```  
    OR

    - Click the `>` icon for the job in the UI, followed by `Start`.

* On completion of the job execution navigate to the explorer results view for the job. The example anomaly is shown below:

![Example Explorer View for Service Response Change](https://cloud.githubusercontent.com/assets/12695796/25525451/e8228306-2c06-11e7-8aa9-3b7004489e1a.png)
