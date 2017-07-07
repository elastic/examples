# Filebeat Kafka Monitoring

Configuration files and sample kafka logs demonstrating kafka monitoring using
the Filebeat, Elasticsearch and Kibana.

For a detailed walk-through, see the Elastic blog post [Monitoring Kafka with Elastic Stack: Filebeat](https://www.elastic.co/blog/monitoring-kafka-with-elastic-stack-1-filebeat)

The above blog uses version 5.1.1 of the elastic stack. The `es_stack`
directory contains a docker compose configuration file to run elasticsearch and
kibana.

directory structure:
- `es`: Elasticsearch template mapping and pipeline configurations.
- `es_stack`: docker compose configuration to run Elasticsearch and Kibana
- `kibana`: sample kibana dashboards
- `logs`: sample kibana logs

## Getting started

1. Run Elasticsearch and Kibana by starting the docker containers:

```
    $ cd es_stack
    $ docker-compose up -d
```
    
Note: The default username and password is `elastic` and `changeme`.
    
2. Check Elasticsearch is running

```
    $ curl --user elastic:changeme http://localhost:9200
    {
      "name" : "-5AmhHF",
      "cluster_name" : "docker-cluster",
      "cluster_uuid" : "UHKcou0kRGaxGUJdXLWJ2Q",
      "version" : {
        "number" : "5.1.1",
        "build_hash" : "5395e21",
        "build_date" : "2016-12-06T12:36:15.409Z",
        "build_snapshot" : false,
        "lucene_version" : "6.3.0"
      },
      "tagline" : "You Know, for Search"
    }
```
    
3. Check Kibana running

```
    $ curl --user elastic:changeme -I http://localhost:5601
    HTTP/1.1 200 OK
    kbn-name: kibana
    kbn-version: 5.1.1
    kbn-xpack-sig: 3c0acb87f64a94dc20c59f377e610980
    cache-control: no-cache
    Date: Tue, 20 Dec 2016 12:00:31 GMT
    Connection: keep-alive
```
    
4. Install Elasticsearch template mapping and ingest pipelines

```
    $ cd es
    $ curl --user elastic:changeme -XPUT 'http://localhost:9200/_ingest/pipeline/kafka-logs'  -d@kafka-logs.json
    {"acknowledged" : true}
    $ curl --user elastic:changeme -XPUT 'http://localhost:9200/_ingest/pipeline/kafka-gc-logs'  -d@kafka-gc-logs.json
    {"acknowledged" : true}
    $ curl --user elastic:changeme -XPUT 'http://localhost:9200/_template/kafkalogs' -d@fb-kafka.template.json
    {"acknowledged" : true}
```

5. (Optional) Index sample log files (run each filebeat instance in a separate terminal)
    
```
    $ filebeat -e -v -c filebeat.yml -E filebeat.registry_file=kafka0.registry -E output.elasticsearch.hosts='localhost:9200' -E name=kafka0 -E kafka.home="$(pwd)/logs/kafka0"
    ...

    $ filebeat -e -v -c filebeat.yml -E filebeat.registry_file=kafka1.registry -E output.elasticsearch.hosts='localhost:9200' -E name=kafka1 -E kafka.home="$(pwd)/logs/kafka1"
    ...

    $ filebeat -e -v -c filebeat.yml -E filebeat.registry_file=kafka2.registry -E output.elasticsearch.hosts='localhost:9200' -E name=kafka2 -E kafka.home="$(pwd)/logs/kafka2"
    ...
```
    
6. Install Kibana dashboards

```
    $ scripts/import_dashbaords -es http://localhost:9200 -user elastic -pass changeme -dir kibana
```
