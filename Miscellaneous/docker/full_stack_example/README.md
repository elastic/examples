# Full Stack Example

This example complements the blog post ["A full stack in one command"](TODO), providing the docker compose files responsible for deploying an example architecture of the Elastic Stack.  
This architecture utilises Logstash and Beat modules for data sources, populating a wide range of dashboards to provide a simple experience for new users to the Elastic Stack.
 
## Pre-requisites

1. Docker for Mac, Linux or OSX
1. Docker version > v17.07.0 (Earlier versions may work but have not been tested)
1. Docker-Compose > 1.15.0
1. Ensuring the following ports are free on the host, as they are mounted by the containers:

    - `80` (Nginx)
    - `8000` (Apache2)
    - `5601` (Kibana)
    - `9200` (Elasticsearch)
    - `3306` (Mysql)
    - `5000`, `6000` (Logstash)
    
The example file uses docker-compose v2 syntax.

**We assume prior knowledge of docker**

## Versions

All Elastic Stack components are version 5.5.1

## Architecture 

The following illustrates the architecture deployed by the compose file.  All components are deployed to a single machine.

![Architecture Diagram](https://user-images.githubusercontent.com/12695796/29225431-2a3a7a2a-7ec6-11e7-9215-769063681e10.png)

Summarising the above, the following containers are deployed:

* `Elasticsearch`
* `Kibana`
* `Logstash` - configured for netflow module as well as a pipeline for sample apache logs. Sample data included.
* `Filebeat` - Collecting logs from the apache2, nginx and mysql containers. Also responsible for indexing the host's system and docker logs.
* `Packetbeat` - Monitoring communication between all containers with respect to http, flows, dns and mysql.
* `Heartbeat` - Pinging all other containers over icmp. Additionally monitoring Logstash, Elasticsearch, Kibana, Nginx and Apache over http. Monitors mysql over TCP.
* `Metricbeat` - Monitors nginx, apache2 and mysql containers using status check interfaces. Additionally, used to monitor the host system with respect cpu, disk, memory and network. Monitors the hosts docker statistics with respect to disk, cpu, health checks, memory and network.
* `Nginx` - Supporting container for Filebeat (access+error logs) and Metricbeat (server-status)
* `Apache2` - Supporting container for Filebeat (access+error logs) and Metricbeat (server-status)
* `Mysql` - Supporting container for Filebeat (slow+error logs), Metricbeat (status) and Packetbeat data.

In addition to the above containers, a `configure_stack` container is deployed at startup.  This is responsible for:

* Setting the Elasticsearch passwords
* Importing any dashboards
* Creating a Logstash pattern in Kibana for the netflow and apache logs
* Ìnserting any custom templates and ingest pipelines

This container uses the Metricbeat images as it contains the required dashboards.

## Modules & Data

The following Beat and Logstash modules are utilised in this stack example to provide data and dashboards:

1. Packetbeat, capturing traffic on all interfaces:
    - `dns` - port `53`
    - `http` - ports `9200`, `80`, `8080`, `8000`, `5000`, `8002`, `5601`
    - `icmp`
    - `flows`
    - `mysql` - port `3306`
1. Metricbeat
    - `apache` module with `status` metricset
    - `docker` module with `container`, `cpu`, `diskio`, `healthcheck`, `info`, `memory` and `network` metricsets 
    - `mysql` module with `status` metricset
    - `nginx` module with `stubstatus` metricset
    - `system` module with `core`,`cpu`,`load`,`diskio`,`filesystem`,`fsstat`,`memory`,`network`,`process`,`socket`
1. Heartbeat
    - `http` - monitoring Logstash (9600), Elasticsearch (9200), Kibana (5601), Nginx (80)
    - `tcp` - monitoring Mysql (3306)
    - `icmp` - monitoring all containers
1. Filebeat
    - `system` module with `syslog` metricset
    - `mysql` module with `access` and `slowlog` `metricsets`
    - `nginx` module with `access` and `error` `metricsets` 
    - `apache` module with `access` and `error` `metricsets`

## Step by Step Instructions - Deploying the Stack

1. Download the `full_stack_example.tar.gz` file for the package here.  This is provided as there is no easy way to download a sub folder of this repository.  This represents the folders within this directory zipped.
    
    ```shell
    curl -O https://raw.githubusercontent.com/elastic/examples/master/Miscellaneous/docker/full_stack_example/full_stack_example.tar.gz
    ```

1. Extract the directory
    
    ```shell
    tar -xvf full_stack_example.tar.gz
    ```

1. The above command should result in a `full_stack_example` folder. For OSX and Windows ensure that this folder is bind mounted and thus available to the docker containers.  Further instructions on achieving this:

    * [Windows](https://docs.docker.com/docker-for-windows/#shared-drives)
    * [OSX](https://docs.docker.com/docker-for-mac/#file-sharing)

1. Navigate into the full_stack_example folder and issue the following command, adjusting for your host operating system as shown.

    ```shell
    cd full_stack_example.tar.gz
    ```
    
    For osx
    
    ```shell
    docker-compose -f docker-compose-osx.yml
    ```
    
    For windows
    
    ```shell
    docker-compose -f docker-compose-windows.yml
    ```
    
    For linux
    
    ```shell
    docker-compose -f docker-compose-linux.yml
    ```

**The above command may take some time if you don't have the base centos7 images**

1. Confirm the containers are available, by issuing the following command:
    
    ```shell
    docker ps -a
    ```

    this will return a response such as the following:

    ```shell
    CONTAINER ID        IMAGE                                                 COMMAND                  CREATED             STATUS                     PORTS                                          NAMES
    618c9f2e7a5c        docker.elastic.co/beats/filebeat:5.5.1                "filebeat -e -E ou..."   4 minutes ago       Up 4 minutes                                                              filebeat
    d35f1b864980        docker.elastic.co/beats/packetbeat:5.5.1              "packetbeat -e -E ..."   4 minutes ago       Up 4 minutes                                                              packetbeat
    8a569ed62837        docker.elastic.co/beats/heartbeat:5.5.1               "heartbeat -e -E o..."   4 minutes ago       Up 4 minutes                                                              heartbeat
    076e40495ef8        docker.elastic.co/beats/metricbeat:5.5.1              "metricbeat -e -E ..."   4 minutes ago       Up 4 minutes                                                              metricbeat
    89e13314c279        docker.elastic.co/logstash/logstash:5.5.1             "/usr/local/bin/do..."   4 minutes ago       Up 4 minutes               5044/tcp, 127.0.0.1:5000->5000/tcp, 9600/tcp   logstash
    946a5034e37a        docker.elastic.co/beats/metricbeat:5.5.1              "/bin/bash -c 'cat..."   5 minutes ago       Exited (0) 4 minutes ago                                                  configure_stack
    c6173ed51209        docker.elastic.co/kibana/kibana:5.5.1                 "/bin/sh -c /usr/l..."   5 minutes ago       Up 5 minutes (healthy)     127.0.0.1:5601->5601/tcp                       kibana
    7ee2b178416e        fullstackexample_nginx                                "nginx -g 'daemon ..."   5 minutes ago       Up 5 minutes (healthy)     127.0.0.1:80->80/tcp, 443/tcp                  nginx
    6ebdd87fccd8        fullstackexample_mysql                                "docker-entrypoint..."   5 minutes ago       Up 5 minutes (healthy)     127.0.0.1:3306->3306/tcp                       mqsql
    198afa6b6325        docker.elastic.co/elasticsearch/elasticsearch:5.5.1   "/bin/bash bin/es-..."   5 minutes ago       Up 5 minutes (healthy)     127.0.0.1:9200->9200/tcp, 9300/tcp             elasticsearch
    2c61e37a554b        fullstackexample_apache2                              "httpd-foreground"       5 minutes ago       Up 5 minutes (healthy)     127.0.0.1:8000->80/tcp                         apache2`
    ```
    
    Whilst the container ids will be unique, other details should be similar. Note the `configure_stack` container will have exited on completion of the configuration of stack.  This occurs before the beat containers start.  Other containers should be "Up".

1. On confirming the stack is started, navigate to kibana at http://localhost:5601.  Assuming you haven't changed the default password, see [Customising the Stack](TODO), the default credentials of `elastic` and `changeme` should appear.

## Dashboards with data

The following dashboards are accessible and populated. Other dashboards, whilst loaded, will not have data due to the absence of an appropriate container e.g. Packetbeat Cassandra.

* CPU/Memory per container
*
*
*
*
*

## Technical notes

The following summarises some important technical considerations:

1. The Elasticsearch instances uses a named volume `esdata` for data persistence between restarts. It exposes HTTP port 9200 for communication with other containers. 
1. Environment variable defaults can be found in the file .env`
1. The Elasticsearch container has its memory limited to 2g. This can be adjusted using the environment parameter `ES_MEM_LIMIT`. Elasticsearch has a heap size of 1g. This can be adjusted through the environment variable `ES_JVM_HEAP` and should be set to 50% of the `ES_MEM_LIMIT`.  **Users may wish to adjust this value on smaller machines**.
1. The Elasticsearch password can be set via the environment variable `ES_PASSWORD`. This sets the password for the `elastic`, `logstash_system` and `kibana` user.
1. The Kibana container exposes the port 5601.
1. All configuration files can be found in the extracted folder `./config`.
1. In order for the containers `nginx`, `apache2` and `mysql` to share their logs with the Filebeat container, they mount the folder `./logs` relative to the extracted directory. Filebeat additionally mounts this directory to read the logs.
1. The Filebeat container mounts the host directories `/private/var/log` (osx) and `/var/log` (linux) in order to read the host's system logs. **This feature is not available in Windows**
1. The Filebeat container mounts the host directory `/var/lib/docker/containers` in order to access the container logs.  These are ingested using a custom [prospector](TODO) and processed by an ingest pipeline loaded by the container `configure_stack`.
1. The Filebeat registry file is persisted to the named volume `fbdata`, thus avoiding data duplication during restarts
1. In order to collect docker statistics, Metricbeat mounts the hosts `/var/run/docker.sock` directory.  For windows and osx, this directory exists on the VM hosting docker.
1. Packetbeat is configured to use the hosts network, in order to capture traffic on the host system rather than that between the containers.
1. Logstash exposes ports `5000` and `6000` for data ingestion. See [Adding Logstash Data](TODO)
1. For data persistence between restarts the `mysql` container uses a named volume `mysqldata`.
1. The nginx, msql and apache containers expose ports 80, 8000 and 3306 respectively on the host. **Ensure these ports are free prior to starting**
1. The Metricbeat container mounts both `/proc` and `/sys/fs/cgroup` on linux.  This allows Metricbeat to use the `system` module report on disk, memory, network and cpu of the host.  **This is only performed on linux.  For windows and osx the stats of the VM hosting docker will be reported.**
1. In for Filebeat to index the docker logs it mounts `/var/lib/docker/containers`. These JSON logs are ingested into the index `docker-logs-<yyyy-MM-dd>`

## Adding Logstash Data

The examples includes a few simple Logstash pipelines to allow ingestion of Netflow data (using the module) and a sample getting started Apache log file. To ingest these simply run the following commands:

***For Apache data***

```shell
cat sample_data/apache | nc localhost 5000
```

***For Netflow***

```shell
TODO
```


## Customising the Stack


## We would love your feedback!
If you found this example helpful and would like to see more such Getting Started examples for other standard formats, we would love to hear from you. If you would like to contribute examples to this repo, we'd love that too!
