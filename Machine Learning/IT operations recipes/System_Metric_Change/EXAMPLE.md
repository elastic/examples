# System Metric Change - Example

## Overview

In order to test and evaluate this recipe, a background dataset is required in addition to a subsequent high system metric signature. For the purposes of a simple example we choose to detect high CPU usage per core, using Metricbeat.  This recipes requires the user to run Metricbeat for a sufficient period greater than 2 hours, to collect a background dataset. The tool [stress](https://people.seas.harvard.edu/~apw/stress/) is in turn used to produce a high CPU signature, detectable using Machine Learning.

** This examples should be run on linux. Whilst all tooling works on OSX, all cores must be placed under high load to induce an anomaly.**

This example represents the simple case of detecitng a high system metric. In practice, high CPU alone rarely warrants either concern or an alert. This detector would typically be combined with others to detect unusual behaviour e.g high disk writes, memory usage and cpu might represent a behaviour worthy of investigation.

## Pre-requisites

- Metricbeat v5.3 (earlier versions may work but not tested)
- Elasticsearch v5.4
- X-Pack v5.4 with ML beta
- curl
- taskset - linux tool for process affinity. Distributed by default with most distributions.
- [stress](https://people.seas.harvard.edu/~apw/stress/). This can be installed on linux using most both yum and apt-get e.g. `apt-get install stress.`.
- Ideally a minimum of 2 cores

**Linux Recommendation**

Whilst the stress tool is provided on OSX via brew (i.e. `brew install stress`), it is not currently possible to ensure a process has affinity with a core easily unlike linux. Running stress will distribute the workload across all cores. If attempting to replicate this example on OSX, stress will need to be started with the number of cores available - rather than a specific core.  This will produce anomalies across all cores and place the host system under considerable load.

## Recipe Components

This example includes:

 * Minimal Metricbeat configuration for capturing core usage information.
 * Ingest pipeline for creating core_id keyword field - for the purposes of partitioning in ML.
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

* [Download and Install Metricbeat](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-installation.html). **Do not start Metricbeat**.

* Download the provided Metricbeat configuration file.

    ```
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/IT%20operations%20recipes/System_Metric_Change/configs/metricbeat/metricbeat.yml
    ```

* Modify the metricbeat.yml file. Consider changing:

    - The elasticsearch username and password values if these have been modified from the defaults
    - The elasticsearch host and port if they are not running locally.
    - The beat.name value generated for all metricset documents. This will be used to identify the source of the Metricbeat data. By default this is set to `test` and can be changed through the configuration parameter `name`.

* Copy the modified metricbeat.yml file to the root installation folder of the Metricbeat installation, overwriting the default file i.e.

    ```cp metricbeat.yml <path_to_metricbeat_installation>/metricbeat.yml```

* Download & Install the required ingest processor  

  ```
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/IT%20operations%20recipes/System_Metric_Change/configs/ingest/core_id.json
    curl -XPUT -H 'Content-Type: application/json' 'localhost:9200/_ingest/pipeline/core_id' -d @core_id.json -u elastic:changeme
  ```

* Start metricbeat as described [here](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-starting.html).

* Test Metricbeat is capturing Core data by running the following commands.

    ```
    curl localhost:9200/metricbeat-*/_refresh -u elastic:changeme
    curl localhost:9200/metricbeat-*/_count -u elastic:changeme
    ```

    The last command should return a count > 0, thus indicating metricbeat traffic has been indexed e.g.

    ```
    {"count":120,"_shards":{"total":5,"successful":5,"failed":0}}
    ```

## Load the Recipe

The above steps should ensure CPU Core statistics are captured from the local device into Elasticsearch.  In order to ensure sufficient data is captured for effective use by the Machine Learning algorithm, this process should be left to capture data for **at least 2 hrs**

The Machine Learning Recipe can be loaded prior to the complete data capture however for exploration purposes.

Download the following files to the same directory:

  ```
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/IT%20operations%20recipes/System_Metric_Change/machine_learning/data_feed.json
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/IT%20operations%20recipes/System_Metric_Change/machine_learning/job.json
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/IT%20operations%20recipes/scripts/reset_job.sh
  ```

* Load the Job by running the supplied reset_job.sh script.

```
./reset_job.sh system_metric_change
```

This script assumes the default Elasticsearch host, port, user and password. To supply alternatives, supply as arguments e.g.

```
./reset_job.sh system_metric_change <host_port> <username> <password>
```

* Access Kibana by going to http://localhost:5601 in a web browser

* Select "Machine Learning" from the left tab. This should list the "System Metric Change" job e.g.

[http://localhost:5601/app/ml#/jobs?_g=()](http://localhost:5601/app/ml#/jobs?_g=())

![ML Job Listing Screenshot](https://cloud.githubusercontent.com/assets/12695796/25635046/f740bc26-2f63-11e7-86b2-988868fb5218.png)

## Run the Recipe

Once collection of a sufficiently sized background dataset has been collected (bare minimum is 2.5 hours), a high CPU signature on 1 core can be generated. To assist with this, we use the stress tool.  To ensure the usage of one core we use process affinity via taskset, terminating the command after 2 mins automatically.

* To generate the high core signature, run the the following command:

```
date && timeout -sHUP 2m taskset -c 0 stress -c 1
```

If attempting to use OSX execute the following, setting the value of `N` to the number of available cores.


```
date && timeout -sHUP 2m stress -c 1
```

The above command will automatically terminate after 2 minutes.

* Ensure all data is indexed and searchable i.e.

```
curl localhost:9200/metricbat-*/_refresh -u elastic:changeme

```

* The Machine Learning job can be started. To start, either:

    - issue the following command to the ML API

        ```
        curl -s -X POST localhost:9200/_xpack/ml/datafeeds/datafeed-system_metric_change/_start -u elastic:changeme
        ```  
    OR

    - Click the `>` icon for the job in the UI, followed by `Start`.

* On completion of the job execution navigate to the explorer results view for the job. An example anomoly is shown below.  Here we have captured data across 3 machines, inserting anomalies in each.

![Example Explorer View for System Metric Change](https://cloud.githubusercontent.com/assets/12695796/25635025/e00677bc-2f63-11e7-9412-d881ba4776f7.png)
