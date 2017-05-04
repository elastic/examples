# Detect HTTP Data Exfiltration (Proxy) - Example

## Overview

In order to test and evaluate this recipe, a background dataset is required in addition to a subsequent HTTP Data Exfilfration signature.  The former can be collected using Packetbeat on any supported device generating HTTP traffic as part of normal operation e.g. a laptop or server.  

Several utility scripts are in turn provided which generate a suspicious signature for detection by the Machine Learning job.  These rely on creating a server and client over which a large HTTP upload is performed.  **The scripts themselves must be run on separate machines**.

### Note

The Packetbeat configuration provided with this script only collects HTTP traffic. In a practical case you would likely also collect SSL traffic through a proxy intercept device.

## Pre-requisites

- Packetbeat v5.3 (earlier versions may work but not tested)
- Elasticsearch v5.4
- X-Pack v5.4 with ML beta
- curl
- socat (available on OSX with `brew install socat`)

## Recipe Components

This example includes:

 * Minimal Packetbeat configuration for capturing HTTP traffic.
 * Scripts capable of generating an exfiltration signature - Either OSX or Linux.
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
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20analytics%20recipes/DNS_Data_Exfiltration/configs/packetbeat/packetbeat.yml
    ```

* Modify the packetbeat.yml file. Consider changing:

    - The elasticsearch username and password values if these have been modified from the defaults
    - The beat.name value generated for all DNS documents. This will be used to identify the source of the Packetbeat data. By default this is set to `test` and can be changed through the configuration parameter `name`.
    - The connection interface monitored - set to en0 by default for osx.

* Copy the modified packetbeat.yml file to the root installation folder of the Packetbeat installation, overwriting the default file i.e.

    ```cp packetbeat.yml <path_to_packetbeat_installation>/packetbeat.yml```

* Start packetbeat as described [here](https://www.elastic.co/guide/en/beats/packetbeat/current/packetbeat-starting.html).

* Test Packetbeat is capturing HTTP traffic by running the following commands.

    - Generate some traffic e.g.
        ```
        curl elastic.co
        ```
    - Confirm the data has been indexed i.e.
        ```
        curl localhost:9200/packetbeat-*/_refresh -u elastic:changeme
        curl localhost:9200/packetbeat-*/http/_count -u elastic:changeme
        ```

    The last command should return a count > 0, thus indicating HTTP traffic has been indexed e.g.

    ```
    {"count":2,"_shards":{"total":5,"successful":5,"failed":0}}
    ```

## Load the Recipe

The above steps should ensure HTTP traffic is captured from the local device into Elasticsearch.  In order to ensure sufficient data is captured for effective use by the Machine Learning algorithm, this process should be left to capture all HTTP activity for a minimum of 48 hours.

The Machine Learning Recipe can be loaded prior to the complete datacapture however for exploration purposes.

Download the following files to the **same directory**:

  ```
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20analytics%20recipes/HTTP_Data_Exfiltration/machine_learning/data_feed.json
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20analytics%20recipes/HTTP_Data_Exfiltration/machine_learning/job.json
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20analytics%20recipes/scripts/reset_job.sh
  ```

* Load the Job by running the supplied reset_job.sh script.

```
./reset_job.sh http_exfiltration
```

This script assumes the default Elasticsearch host, port, user and password. To supply alternatives, supply as arguments e.g.

```
./reset_job.sh http_exfiltration <host_port> <username> <password>
```

* Access Kibana by going to http://localhost:5601 in a web browser

* Select "Machine Learning" from the left tab. This should list the "HTTP Data Exfilfration" job e.g.

[http://localhost:5601/app/ml#/jobs?_g=()](http://localhost:5601/app/ml#/jobs?_g=())

![ML Job Listing Screenshot](https://cloud.githubusercontent.com/assets/12695796/25128941/cd3f6fa2-2433-11e7-9648-18d40da5acb5.png)

## Run the Recipe

On collection of a sufficiently sized background HTTP dataset a suspicious exfilfration signature should be generated. To assist with this, several utility scripts are provided.

### Important Note

These scripts produce a large outbound HTTP upload signature. The first script runs a simple server to which the second client script sends random bytes.  **This example thus currently requires 2 machines.**  The client script should be run from the machine on which data is being collected and on which Packetbeat is installed.  The server script can be run on a locally connected server.

* Download the server script to the machine which will represent the target.

```
https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20analytics%20recipes/HTTP_Data_Exfiltration/scripts/server.sh
```

* Run the server using the following command.  The port is optional and defaults to 3333. Ensure this is open and accessible from the client machine.

```
./server.sh [port]
```     


* Download the client script to the machine on which you have earlier installed Packetbeat.

```
https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20analytics%20recipes/HTTP_Data_Exfiltration/scripts/client.sh
```


* To generate the exfiltration signature, run the client script on your platform for several mins. The script accepts two parameters - the server host and the port.  The latter is optional and defaults to 3333.

```
./server.sh <host> [port]
```

**Note:** If changing the port from the default 3333 to a value other than one of [80, 8080, 8000, 5000, 8002, 3333], the Packetbeat configuration parameter `packetbeat.protocols.http.ports` should be modified and the instance restarted.

Terminate the both scripts using Ctl+C.

* Ensure all data is indexed and searchable i.e.

```
curl localhost:9200/packetbeat-*/_refresh -u elastic:changeme

```

* The Machine Learning job can be started. To start, either:

    - issue the following command to the ML API

        ```
        curl -s -X POST localhost:9200/_xpack/ml/datafeeds/datafeed-http_exfiltration/_start -u elastic:changeme
        ```  
    OR

    - Click the `>` icon for the job in the UI, followed by `Start`.

* On completion of the job execution navigate to the explorer results view for the job. An example anomaly is shown below:


![Example Explorer View for HTTP Exfiltration]()
