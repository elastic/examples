# Docker Examples

## Official Images

Elastic maintains official docker images for all components in the stack. Please refer to official documentation for these images, more specifically:


### Elasticsearch 

https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html

### Kibana

https://www.elastic.co/guide/en/kibana/current/docker.html

### Logstash

https://www.elastic.co/guide/en/logstash/current/docker.html


## Full Stack Examples

A full stack example, which installs Logstash, Beats and Elasticsearch can be found [here](https://github.com/elastic/examples/tree/master/Miscellaneous/docker/full_stack_example).
This includes the following, each deployed as a seperate docker container:

* Elasticsearch
* Logstash - configured for netflow module as well as a pipeline for sample apache logs. Sample data included.
* Kibana
* Filebeat - Collecting logs from apache2, nginx, mysql and the host system.
* Packetbeat - Monitoring communication between all containers with respect to http, flows and dns.
* Heartbeat - Pinging all other containers over icmp. Additionally monitoring Logstash, Elasticsearch, Kibana, Nginx and Apache over http.
* Metricbeat - Monitors nginx, apache2 and mysql containers using status check interfaces. Additionally, used to monitor the host system with respect cpu, disk, memory and network. Monitors the hosts docker statistics with respect to disk, cpu, health checks, memory and network.
* Nginx - Supporting container for Filebeat (access+error logs) and Metricbeat (server-status)
* Apache2 - Supporting container for Filebeat (access+error logs) and Metricbeat (server-status)
* Mysql - Supporting container for Filebeat (slow+error logs) and Metricbeat (status)