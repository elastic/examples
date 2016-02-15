
### Community Contribution

Contributed by [Rudi Starcevic](https://github.com/rudijs).

##### Product Versions:
Example has been tested in the following versions:
* Elasticsearch 2.1.1
* Logstash 2.1.1
* Kibana 4.3.1
* Docker 1.9.1

##### OS:
Example has been created for and tested in **Linux only** - Ubuntu 14.04. Contributions for OSX / Windows instructions, where applicable, would be appreciated.

If you have trouble running the example or have suggestions for improvement, please create a Github issue and copy Rudi Starcevic (@rudijs) in it.

..........................................................................................................................

## Overview

In this example, we'll look at a quick start 'how to' for setting up the ELK stack in Docker using version 2 or Elasticsearch and Logstash.

In just a few commands and configuration files, we'll have an ELK stack up and running in Docker containers.

## Installation

**Install Docker**

If you don't have docker installed already, go ahead and install it. You can find instructions for your computer at the [Official installation docs](https://docs.docker.com/installation/)

**Note**: Once you have docker installed, we'll be using the command line for all install and setup steps below. You will need to open a new shell window and type or copy and paste the following commands:

**Install Offical Docker Images**

A nice feature when using these Docker images to launch containers is that you can specify the exact versions you require.

The ELK stack is three pieces of software, each updating independently, so it's very nice to be able to set the exact versions you want.

**Install Elasticsearch**

- Download the [Latest Offical Elasticsearch Docker image](https://hub.docker.com/_/elasticsearch/): `sudo docker pull elasticsearch:2.1.1`

**Install Logstash**

- Download the [Latest Official Logstash Docker image](https://hub.docker.com/_/logstash/): `sudo docker pull logstash:2.1.1`

**Install Kibana**

- Download the [Latest Official Kibana Docker image](https://hub.docker.com/_/kibana/): `sudo docker pull kibana:4.3.1`

### Test Installation

**Elasticsearch**

- Create a directory to hold the persisted index data:
    `mkdir esdata`
- Run a Docker container, bind the esdata directory (volume) and expose port 9200 and listen on all IPs
```
sudo docker run -d --name elasticsearch -v "$PWD/esdata":/usr/share/elasticsearch/data -p 9200:9200 elasticsearch:2.1.1 -Des.network.bind_host=0.0.0.0
```

 You should see some output like: `5cbc37bc373b2c76f7149ecb69d6e543ce444609b279b151740c18de13467757`

- Check the container is running OK:`sudo docker ps`
- You should see output similar to:

```
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                              NAMES
5cbc37bc373b        elasticsearch:2.1.1   "/docker-entrypoint.s"   3 minutes ago       Up 3 minutes        0.0.0.0:9200->9200/tcp, 9300/tcp   elasticsearch
```
- We can also look at the start up output from the elasticsearch container:
  ```
  sudo docker logs elasticsearch
  ```

  You should see output like:
```
[2016-01-14 13:25:44,978][INFO ][node                     ] [The Wink] version[2.1.1], pid[1], build[40e2c53/2015-12-15T13:05:55Z]
[2016-01-14 13:25:44,979][INFO ][node                     ] [The Wink] initializing ...
[2016-01-14 13:25:45,079][INFO ][plugins                  ] [The Wink] loaded [], sites []
[2016-01-14 13:25:45,118][INFO ][env                      ] [The Wink] using [1] data paths, mounts [[/usr/share/elasticsearch/data (/dev/mapper/crypt2)]], net usable_space [97.9gb], net total_space [114gb], spins? [possibly], types [ext4]
[2016-01-14 13:25:47,241][INFO ][node                     ] [The Wink] initialized
[2016-01-14 13:25:47,241][INFO ][node                     ] [The Wink] starting ...
[2016-01-14 13:25:47,342][WARN ][common.network           ] [The Wink] publish address: {0.0.0.0} is a wildcard address, falling back to first non-loopback: {172.17.0.1}
[2016-01-14 13:25:47,343][INFO ][transport                ] [The Wink] publish_address {172.17.0.1:9300}, bound_addresses {[::]:9300}
[2016-01-14 13:25:47,357][INFO ][discovery                ] [The Wink] elasticsearch/4GEk77pBSXy72JXqBVSEqQ
[2016-01-14 13:25:50,404][INFO ][cluster.service          ] [The Wink] new_master {The Wink}{4GEk77pBSXy72JXqBVSEqQ}{172.17.0.1}{172.17.0.1:9300}, reason: zen-disco-join(elected_as_master, [0] joins received)
[2016-01-14 13:25:50,418][WARN ][common.network           ] [The Wink] publish address: {0.0.0.0} is a wildcard address, falling back to first non-loopback: {172.17.0.1}
[2016-01-14 13:25:50,418][INFO ][http                     ] [The Wink] publish_address {172.17.0.1:9200}, bound_addresses {[::]:9200}
[2016-01-14 13:25:50,419][INFO ][node                     ] [The Wink] started
[2016-01-14 13:25:50,453][INFO ][gateway                  ] [The Wink] recovered [0] indices into cluster_state
```

Elasticsearch should now be running on port 9200. To test, point your browser at port 9200: [http://localhost:9200](http://localhost:9200).

You should see output similar to the following with status code of 200.
```
{
  "name" : "The Wink",
  "cluster_name" : "elasticsearch",
  "version" : {
    "number" : "2.1.1",
    "build_hash" : "40e2c53a6b6c2972b3d13846e450e66f4375bd71",
    "build_timestamp" : "2015-12-15T13:05:55Z",
    "build_snapshot" : false,
    "lucene_version" : "5.3.1"
  },
  "tagline" : "You Know, for Search"
}
```

**Logstash**

- Create a directory for your logstash configuration files:
- `mkdir -p logstash/conf.d/`
- Create an **input** logstash configuration file `logstash/conf.d/input.conf` with this content:
```
input {
    file {
        type => "test"
        path => [
            "/host/var/log/test.log"
            ]
    }
}
```
- Create an **output** logstash configuration file `logstash/conf.d/output.conf` with this content:
```
output {
    elasticsearch {
        hosts => ["localhost"]
    }
}
```

- For our use case here, our Docker Logstash container will monitor a log file from our host machine. Create a directory for log files that our Logstash Docker container will monitor:
- `mkdir -p var/log`
- Start our logstash docker container. It will watch the `test.log` file from the `var/log` directory we just created:
 ```
 sudo docker run -d --name logstash -v $PWD/logstash/conf.d:/etc/logstash/conf.d:ro -v $PWD/var/log:/host/var/log:ro --net host logstash:2.1.1 logstash -f /etc/logstash/conf.d --debug
 ```
We've used the `--debug` flag so we can check logstash's start up processes and watch for any errors using:
- `sudo docker logs -f logstash`

- To test your Logstash to Elasticsearch installation, run the following command in a new shell:
- `echo 101 > var/log/test.log`
- Now lets check Elasticsearch
```
curl localhost:9200/logstash-*/_search?pretty=true
```
- You should see some json format output with a "_source" property with "message" 101.

```
{
  "took" : 25,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 1,
    "max_score" : 1.0,
    "hits" : [ {
      "_index" : "logstash-2016.01.14",
      "_type" : "test",
      "_id" : "AVJAXV1YGgMPVefiorW1",
      "_score" : 1.0,
      "_source":{"message":"101","@version":"1","@timestamp":"2016-01-14T13:40:05.353Z","host":"rudi-Lenovo-Y50-70","path":"/host/var/log/test.log","type":"test"}
    } ]
  }
}
```

**Kibana**
- Start Kibana:
 ```
 sudo docker run -d --name kibana -p 5601:5601 -e ELASTICSEARCH_URL=http://localhost:9200 --net host kibana:4.3.1
 ```
 Kibana should now be running on port 5601. To test, point your web browser at port 5601 [localhost:5601](http://localhost:5601). You should see the Kibana UI.

  <a href="images/docker-elk-quickstart/kibana1.jpg" target="_blank">
  <img src="images/docker-elk-quickstart/kibana1.jpg" width="800"/>
  </a>

- Click green *Create* button to create the Kibana index, then click *Discover* from the main top menu to load up the log entries from Elasticsearch.

  <a href="images/docker-elk-quickstart/kibana2.jpg" target="_blank">
  <img src="images/docker-elk-quickstart/kibana2.jpg" width="800"/>
  </a>

* We can now start to explore some more.<br>
  Lets start by setting up Kibana to auto-refresh, click up in the top right "Last 15 minutes". Click "Auto-refresh" and set it to '5 seconds'

* Now let's create a new log entry, switch to the terminal command line and enter in: `echo 201 >> var/log/test.log`

  Now back in Kibana after 5 or less seconds we should see the `201` log entry.

  <a href="images/docker-elk-quickstart/kibana3.jpg" target="_blank">
  <img src="images/docker-elk-quickstart/kibana3.jpg" width="800"/>
  </a>

## Summary

Once you know how to use Docker and are comfortable with it, building and deploying an ELK stack is very quick and easy. The steps described above are solid, but can be hardened for production use.

For example:
1. Docker has other features like linking containers, so you don't expose ports.
2. Using the '--net host' flag might also not be the best option for production.
3. If you have many machines, run your own [Docker Private Registry](https://docs.docker.com/registry/deploying/) so that your deployments are faster.

This example should get you up and running quickly and painlessly - ready to explore more of the power of the ELK stack.

**Feedback**

Comments and feedback are very much welcomed. If we've overlooked anything, if you can see room for improvement or if any errors please let us know.
