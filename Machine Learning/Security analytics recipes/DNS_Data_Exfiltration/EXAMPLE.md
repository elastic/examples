# Detect DNS Data Exfilfration - Example

## Overview

In order to test and evaluate this recipe, a background dataset is required in addition to a subsequent DNS exfilfration signature.  The former can be collected using Packetbeat on any supported device performing DNS queries as part of normal operation e.g. a laptop or server.  A utility script is in turn provided which generates a suspicious signature for detection by the Machine Learning job.

## Pre-requisites

- Packetbeat v5.3 (earlier versions may work but not tested)
- Elasticsearch v5.4
- X-Pack v5.4 with ML beta
- curl
- dig

## Recipe Components

This example includes:

 * Minimal Packetbeat configuration for capturing DNS traffic.
 * Ingest pipeline for extracting subdomain from DNS documents
 * Script capable of generating an exfiltration signature - Either OSX or Linux.
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

* [Download and Install Packebeat](https://www.elastic.co/guide/en/beats/packetbeat/current/packetbeat-installation.html). **Do not start Packetbeat**.

* Download the provided Packetbeat configuration file.

    ```
    curl -O https://raw.githubusercontent.com/elastic/examples/master/Machine%20Learning/Security%20analytics%20recipes/DNS_Data_Exfiltration/configs/packetbeat/packetbeat.yml
    ```

* Modify the packetbeat.yml file. Consider changing:

    - The elasticsearch username and password values if these have been modified from the defaults
    - The beat.name value generated for all DNS documents. This will be used to identify the source of the Packetbeat data. By default this is set to `test` and can be changed through the configuration parameter `name`.
    - The connection interface monitored - set to en0 by default.

* Copy the modified packetbeat.yml file to the root installation folder of the Packetbeat installation, overwriting the default file i.e.

    ```cp packetbeat.yml <path_to_packetbeat_installation>/packetbeat.yml```

* Download & Install the required ingest processor  

  ```
    curl -O https://raw.githubusercontent.com/elastic/examples/master/Machine%20Learning/Security%20analytics%20recipes/DNS_Data_Exfiltration/configs/ingest/extract_subdomain.json
    curl -XPUT -H 'Content-Type: application/json' 'localhost:9200/_ingest/pipeline/extract_subdomain' -d @extract_subdomain.json -u elastic:changeme
  ```

* Start packetbeat as described [here](https://www.elastic.co/guide/en/beats/packetbeat/current/packetbeat-starting.html).

* Test Packetbeat is capturing DNS traffic by running the following commands.

    - Generate some traffic e.g.
        ```
        nslookup elastic.co
        ```
    - Confirm the data has been indexed i.e.
        ```
        curl localhost:9200/packetbeat-*/_refresh -u elastic:changeme
        curl localhost:9200/packetbeat-*/dns/_count -u elastic:changeme
        ```

    The last command should return a count > 0, thus indicating DNS traffic has been indexed e.g.

    ```
    {"count":2,"_shards":{"total":5,"successful":5,"failed":0}}
    ```

## Load the Recipe

The above steps should ensure DNS traffic is captured from the local device into Elasticsearch.  In order to ensure sufficient data is captured for effective use by the Machine Learning algorithm, this process should be left to capture all DNS activity for a miniumum of 48 hours.

The Machine Learning Recipe can be loaded prior to the complete datacapture however for exploration purposes.

Download the following files to the same directory:

  ```
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20analytics%20recipes/DNS_Data_Exfiltration/machine_learning/data_feed.json
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20analytics%20recipes/DNS_Data_Exfiltration/machine_learning/job.json
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20analytics%20recipes/scripts/reset_job.sh
  ```

* Load the Job by running the supplied reset_job.sh script.

```
./reset_job.sh dns_exfiltration
```

This script assumes the default Elasticsearch host, port, user and password. To supply alternatives, supply as arguments e.g.

```
./reset_job.sh unusual_process <host_port> <username> <password>
```

* Access Kibana by going to http://localhost:5601 in a web browser

* Select "Machine Learning" from the left tab. This should list the "DNS Exfilfration" job e.g.

[http://localhost:5601/app/ml#/jobs?_g=()](http://localhost:5601/app/ml#/jobs?_g=())

![ML Job Listing Screenshot](https://cloud.githubusercontent.com/assets/12695796/24838000/e273814a-1d37-11e7-8262-c6a2fcea93b2.png)

## Run the Recipe

On collection of a sufficiently sized background DNS dataset a suspicious exfilfration signature should be generated. To assist with this, a utility script is provided.

* Download the following scripts depending on your platform:

    - OSX

      ```
        https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20analytics%20recipes/DNS_Data_Exfiltration/scripts/dns_exfil_random_osx.sh
      ```

    - Linux Based
      ```
        https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20analytics%20recipes/DNS_Data_Exfiltration/scripts/dns_exfil_random.sh
      ```

* To generate the exfiltration signature, run the appropriate script for your platform for approximately 1 min. The script accepts two parameters - the DNS sever to use and the domain to simulate exfilfration for e.g.

```
./dns_exfil_random_osx.sh 8.8.8.8 elastic.co
```

Terminate the Script using Ctl+C.

* Ensure all data is indexed and searchable i.e.

```
curl localhost:9200/packetbeat-*/_refresh -u elastic:changeme

```

* The Machine Learning job can be started. To start, either:

    - issue the following command to the ML API

        ```
        curl -s -X POST localhost:9200/_xpack/ml/datafeeds/datafeed-dns_exfiltration/_start -u elastic:changeme
        ```  
    OR

    - Click the `>` icon for the job in the UI, followed by `Start`.

* On completion of the job execution navigate to the explorer results view for the job. An example anomoly is shown below:


![Example Explorer View for DNS Exfiltration](https://cloud.githubusercontent.com/assets/12695796/24838139/f91f6db2-1d39-11e7-96b0-2c41a6aabfea.png)
