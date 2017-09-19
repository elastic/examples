Kibana Armed Bandit
===================

Logging is key in every setup: having useful logs from the components in your
environment is your best tool in diagnosing issues and keeping track of
the health of your applications.

Docker-based deployments are no exception of this rule. In this training we will evaluate kibana features, upon reaching an E*K stack.

This project is the workshop part of the [Kibana training](https://git.renault-digital.com/common/training/tree/master/kibana)

Dependencies
------------

- docker, docker-compose
- make
- ngrok (optional)

Installation
------------

Docker, the new trending containerization technique, is winning hearts with its lightweight, portable, "build once, configure once and run anywhere" functionalities.

To run this project on your computer you only need docker, you probably already
know this technology but in case you don't we have written a training [here](https://git.renault-digital.com/common/training/blob/master/docker/docker-intro-part1.md) and you can find the documentation about how to install the docker engine [here](https://docs.docker.com/engine/installation/) in the docker official website.

Everything Ok...? Let's start!

Usage
-----

Makefiles are a simple way to organize commands, to see this project usefull
system commands run `make help`

1 - Start the testing stack

This docker-based stack is compose with these components:

- simple ruby application
- elasticsearch container(s)
- logs shipper
- kibana

> Hum... I have to just run `make start` ?
>> Yeah!

2 - Open your kibana

If you use the docker compose file a configured container with kibana can be
find at this URL [http://localhost:5601/](http://localhost:5601/)

3 - Stress your application

4 - Create cool dashboards!

About the elastic stack
-----------------------
[Elastic](https://www.elastic.co/about) is the company behind the elastic stack, a product portfolio of popular open source
projects:

- [Kibana](https://www.elastic.co/products/kibana)
- [ElasticSearch](https://www.elastic.co/products/elasticsearch)
- [Logstash](https://www.elastic.co/products/logstash)
- [Beats](https://www.elastic.co/products/beats)
- [X-Pack](https://www.elastic.co/products/x-pack)

Elasticsearch is the heart of the elastic stack, it is a server using [Lucene](https://lucene.apache.org/core/) an ultra fast search library for indexing and retrieving data. It provides a distributed, multi-entity search engine through a REST interface. It is a free software written in Java and published in open source under Apache license.

It is associated with other free products, Kibana, Logstash, and now Beats which are respectively a data viewer and ETLs.

Elasticsearch is a solution built to be distributed and to use JSON via HTTP
requests, which makes the search engine usable with any programming language and also has **facet** and **percolation** search capabilities. If you want to know more about facet search, take a look at the very first implementation of facet with the berkeley [Flamenco project](http://flamenco.berkeley.edu/).

Sources
-------

- [Configuring Kibana on Docker](https://www.elastic.co/guide/en/kibana/current/_configuring_kibana_on_docker.html)

Contributing
------------

This project is a part of a collection of resources for people who want to learn how to run and contribute to improve projects quality at renault-digital.

If you find bugs or want to improve the documention, please feel free to
contribute!

Happy coding!


