# Suspicious Process Activity - Example

## Overview

In order to test and evaluate this recipe, a background dataset is required in addition to a subsequent rare process signature.  The former can be collected using Filebeat on any supported device performing auditd.  A utility script is in turn provided which generates a suspicious signature for detection by the Machine Learning job.

**This example is currently linux only**

## Pre-requisites

- Filebeat v5.4
- Elasticsearch v5.4
- X-Pack v5.4 with Machine Learning
- Auditd

## Recipe Components

This example includes:

 * Minimal Filebeat configuration for capturing Auditd logs.
 * Script capable of generating a suspicious process signature.
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

  The cluster will be secured using basic auth. If changing the default credentials of `elastic` and `changeme` as described [here](https://www.elastic.co/guide/en/x-pack/5.4/security-getting-started.html), ensure the logstash configuration file is updated.

* Ensure [auditd](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Security_Guide/chap-system_auditing.html) is installed

* Ensure auditd is capturing record_type `EXECVE` e.g.

    ```
    auditctl -a exit,always -S execve
    ```

    To ensure these rules are permitted between restarts add via `/etc/audit/audit.rules`

* [Download and Install Filebeat](https://www.elastic.co/guide/en/beats/filebeat/5.4/filebeat-installation.html). **Do not start Filebeat**.

* Download the provided Filebeat configuration file. This configuration utilises the [Auditd filebeat module](https://www.elastic.co/guide/en/beats/filebeat/5.4/filebeat-module-auditd.html) .

    ```curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20Analytics%20Recipes/suspicious_process_activity/configs/filebeat/filebeat.yml```

* Modify the filebeat.yml file. Consider changing:

    - The elasticsearch username and password values if these have been modified from the defaults
    - The beat.name value generated for all Auditd documents. This will be used to identify the source of the Filebeat data. By default this is set to `test` and can be changed through the configuration parameter `name`.

* Copy the modified filebeat.yml file to the root installation folder of the Filebeat installation, overwriting the default file i.e.

    ```cp filebeat.yml <path_to_filebeat_installation>/filebeat.yml```

* Initialise the auditd module.

    ```./filebeat -e -modules=auditd -setup```

* Start Filebeat as described [here](https://www.elastic.co/guide/en/beats/filebeat/5.4/filebeat-starting.html).

* Test Filebeat is capturing Auditd log data by running the following commands.

    - Generate some auditd data by executing any process e.g. `top`
    - Confirm the data has been indexed i.e.

        ```
        curl localhost:9200/filebeat-*/_refresh -u elastic:changeme
        curl localhost:9200/filebeat-*/doc/_count -u elastic:changeme
        ```

    The last command should return a count > 0, thus indicating Auditd data has been indexed e.g.

    ```
    {"count":2,"_shards":{"total":5,"successful":5,"failed":0}}
    ```

## Load the Recipe

The above steps should ensure Auditd logs are captured from the local device into Elasticsearch.  In order to ensure sufficient data is captured for effective use by the Machine Learning algorithm, this process should be left to capture all Auditd for a miniumum of 48 hours.

The Machine Learning Recipe can be loaded prior to the complete data capture however for exploration purposes.

Download the following files to the same directory:

  ```
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20Analytics%20Recipes/suspicious_process_activity/machine_learning/data_feed.json
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20Analytics%20Recipes/suspicious_process_activity/machine_learning/job.json
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20Analytics%20Recipes/scripts/reset_job.sh
  ```

* Load the Job by running the supplied reset_job.sh script.

```
./reset_job.sh unusual_process
```

This script assumes the default Elasticsearch host, port, user and password. To supply alternatives, supply as arguments e.g.

```
./reset_job.sh unusual_process <host_port> <username> <password>
```

* Access Kibana by going to http://localhost:5601 in a web browser

* Select "Machine Learning" from the left tab. This should list the "Unusual Process" job e.g.

[http://localhost:5601/app/ml#/jobs?_g=()](http://localhost:5601/app/ml#/jobs?_g=())

![ML Job Listing Screenshot](https://cloud.githubusercontent.com/assets/12695796/25095014/a384c664-2391-11e7-8b25-e4026fa370c0.png)

## Run the Recipe

On collection of a sufficiently sized background Auditd dataset a suspicious process signature should be generated. To assist with this, a utility script is provided.

* Download the following script:

      ```
        https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20Analytics%20Recipes/suspicious_process_activity/scripts/start_random_process.sh
      ```

* To generate the process signature, execute the script i.e.

```
./start_random_process.sh
```

The script will output a hex code.  This should later appear as the process name and in turn a suspicious signature.

* Ensure all data is indexed and searchable i.e.

```
curl localhost:9200/filebeat-*/_refresh -u elastic:changeme

```

* The Machine Learning job can be started. To start, either:

    - issue the following command to the ML API, changing the default username and password as required.

        ```
        curl -s -X POST localhost:9200/_xpack/ml/datafeeds/datafeed-unusual_process/_start -u elastic:changeme
        ```  
    OR

    - Click the `>` icon for the job in the UI, followed by `Start`.

* On completion of the job execution navigate to the explorer results view for the job. An example anomaly is shown below:

![Example Explorer View for Suspicious Process Activity](https://cloud.githubusercontent.com/assets/12695796/25095074/e9ca1660-2391-11e7-8a1d-6063b75f3e6b.png)
