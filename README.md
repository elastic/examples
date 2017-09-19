Kibana Armed Bandit
===================

Logging is key in every setup: having useful logs from the components in your
environment is your best tool in diagnosing issues and keeping track of
the health of your applications.

Docker-based deployments are no exception of this rule. In this training we will
evaluate kibana features, upon reaching an E*K stack.

This project is the workshop part of the [Kibana training](https://git.renault-digital.com/common/training/tree/master/kibana)

Dependencies
------------

- [docker](https://docs.docker.com/engine/installation/)
- [docker-compose](https://docs.docker.com/compose/install/)
- [make](https://en.wikipedia.org/wiki/Make_(software))
- [ngrok](https://ngrok.com/download) (optional)
- [your brain](https://imgur.com/gallery/tX8UN) (not optional)

### Supported Docker versions
The images have been tested on Docker 17.09.0-ce-rc1 and docker-compose 1.16.1

Installation
------------

Docker, the new trending containerization technique, is winning hearts with its
lightweight, portable, "build once, configure once and run anywhere" functionalities.

To run this project on your computer you only need docker, you probably already
know this technology but in case you don't we have written a training
[here](https://git.renault-digital.com/common/training/blob/master/docker/docker-intro-part1.md)
and you can find the documentation about how to install the docker engine
[here](https://docs.docker.com/engine/installation/) in the docker official website.

Everything Ok...? Let's start!

Usage
-----

Makefiles are a simple way to organize commands, to see this project usefull
system commands run `make help`

1 - Start the testing stack

This docker-based stack is compose with these components:

- simple ruby application (rack webserver)
- elasticsearch as a single node
- filebeat (logs shiper)
- kibana

> Hum... I have to just run `make start` ?
>> Yeah!

So, the ruby rack based application can be reach with curl and give a random
arrays of fruits!

![screen](screens/screen-rack-app.png)

If you want to learn how to start an elasticsearch cluster with Docker, take a look at
this [page](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html).
The [docker-compose-dev.yml](docker-compose-dev.yml) file start Elasticsearch
as single node mode and without Xpack activation.

Filebeat will ship your logs to this Elasticsearch container, to know Filebeat
works and how to configire your `harvesters` and `prospectors` take a look at
this [page](https://www.elastic.co/guide/en/beats/filebeat/current/how-filebeat-works.html)

2 - Open your kibana

If you use the docker compose file a configured container with kibana can be
find at this URL [http://localhost:5601/](http://localhost:5601/)

You can give optionnaly a internet acces to your local kibana with the [ngrok](https://ngrok.com/).
If ngrok is installed on your laptop and you want to share dashboard, just run `make proxy-kibana`.

3 - Stress your application

To generate logs and stress the ruby sample application, I use [artillery](https://artillery.io/).
It's a modern load testing toolkit written in nodejs. It's easy to define
scenarii with the `yaml` syntax. If you’re new to Artillery, [Getting Started](https://artillery.io/docs/getting-started)
is a good place to start, followed by an overview of [how Artillery works](https://artillery.io/docs/basic-concepts).
I wrap all the things you need to run the load tests in Docker containers.

```
cd artillery
make build # generate an artillery container
make ping # start a very minimal ping scenario
```

![stress](screens/screen-stress.png)

More infos in the [README](artillery/README.md) and commands in the `Makefile`

4 - Create cool dashboards!

About the elastic stack
-----------------------
[Elastic](https://www.elastic.co/about) is the company behind the elastic stack,
a product portfolio of popular open source projects:

- [Kibana](https://www.elastic.co/products/kibana)
- [ElasticSearch](https://www.elastic.co/products/elasticsearch)
- [Logstash](https://www.elastic.co/products/logstash)
- [Beats](https://www.elastic.co/products/beats)
- [X-Pack](https://www.elastic.co/products/x-pack)

Elasticsearch is the heart of the elastic stack, it is a server using
[Lucene](https://lucene.apache.org/core/) an ultra fast search library for
indexing and retrieving data. It provides a distributed, multi-entity search
engine through a REST interface. It is a free software written in Java and
published in open source under Apache license.

It is associated with other free products, Kibana, Logstash, and now Beats which
are respectively a data viewer and ETLs.

Elasticsearch is a solution built to be distributed and to use JSON via HTTP
requests, which makes the search engine usable with any programming language
and also has **facet** and **percolation** search capabilities. If you want to
know more about facet search, take a look at the very first implementation of
facet with the berkeley [Flamenco project](http://flamenco.berkeley.edu/).

Must-Read Sources
-----------------

- [Configuring Kibana on Docker](https://www.elastic.co/guide/en/kibana/current/_configuring_kibana_on_docker.html)
- [Install Elasticsearch with Docker](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html)
- [Official Beats Docker images](https://github.com/elastic/beats-docker)
- [How Filebeat works](https://www.elastic.co/guide/en/beats/filebeat/current/how-filebeat-works.html)
- [Running Logstash on docker](https://www.elastic.co/guide/en/logstash/current/docker.html)
- [Rack, the ruby webserver interface](https://rack.github.io/)
- [Ruby an elegant and dynamic language](https://www.ruby-lang.org/en/)

Contributing
------------

This project is a part of a collection of resources for people who want to learn
how to run and contribute to improve projects quality at renault-digital.

If you find bugs or want to improve the documention, please feel free to
contribute!

Happy coding!


