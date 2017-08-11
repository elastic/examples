# Full Stack Example

This example complements the blog post ["A full stack in one command"](TODO), providing the docker compose files responsible for deploying an example architecture of the Elastic Stack.  
This architecture utilises Logstash and Beat modules for data sources, populating a wide range of dashboards to provide a simple experience for new users to the Elastic Stack.
 
 
## Pre-requisites

1. Docker for Mac, Linux or OSX
1. Docker version > v17.07.0 (Earlier versions may work but have not been tested)
1. Docker-Compose > 1.15.0
1. Ensuring the following ports are free on the host, as they are mounted by the containers:
    - 80 (Nginx)
    - 8000 (Apache2)
    - 5601 (Kibana)
    - 9200 (Elasticsearch)
    - 3306 (Mysql)
    - 5000, 6000 (Logstash)
    
The example file uses docker-compose v2 syntax.

We assume prior knowledge of docker.

## Versions

All Elastic Stack components are version 5.5.1

## Architecture 

The following illustrates the architecture deployed by the compose file.  All components are deployed to a single machine.


TODO


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


1. 



## Technical notes

The following summarises some important technical considerations:

1. The Elasticsearch instances uses a named volume `esdata` for data persistence between restarts. It exposes HTTP port 9200 for communication with other containers. 
1. Environment variable defaults can be found in the file .env`
1. The Elasticsearch container has its memory limited to 2g. This can be adjusted using the environment parameter `ES_MEM_LIMIT`. Elasticsearch has a heap size of 1g. This can be adjusted through the environment variable `ES_JVM_HEAP` and should be set to 50% of the `ES_MEM_LIMIT`.  **Users may wish to adjust this value on smaller machines**.
1. The Elasticsearch password can be set via the environment variable `ES_PASSWORD`
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

## Adding Logstash Data


## Customising the Stack



## Hints and Tips

packteat data

memory considerations
Share folders
shut down mysql if reunning locally