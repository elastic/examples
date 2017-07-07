### Install Elasticsearch, Logstash & Kibana

**Check Versions**

All examples should target 5.x of the Elastic Stack.

**Check Java version**

Elasticsearch and Logstash require Java 8 or later. Install or update as needed - use the [official Oracle distribution](http://www.oracle.com/technetwork/java/javase/downloads/index.html) or an open-source distribution such as [OpenJDK](http://openjdk.java.net/). To check your Java version, run the following command: `java -version`.

**Install Elasticsearch**
*	Download the [Elasticsearch binary package](https://www.elastic.co/downloads/elasticsearch) for your platform.
*	Extract the `.zip` or `tar.gz` archive file

(see [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/_installation.html) for more help)

**Install Logstash**
* Download the [Logstash binary package](https://www.elastic.co/downloads/logstash) for your platform.
* Extract the `.zip` or `tar.gz` archive file 

(see [here](https://www.elastic.co/guide/en/logstash/current/getting-started-with-logstash.html) for more help)

**Install Kibana**
-	Download the [Kibana 5 binary package](https://www.elastic.co/downloads/kibana) for your platform.
-	Extract the `.zip` or `tar.gz` archive file.

(see [here](https://www.elastic.co/guide/en/kibana/current/setup.html) for more help)

### Test Installation

**Elasticsearch**

Open a new shell window and run Elasticsearch. 
```Shell
<path_to_elasticsearch_root_dir>/bin/elasticsearch 
```
Elasticsearch should now be running on port 9200. To test, point your browser at port 9200 (`http://localhost:9200`). You should see output similar to the following with status code of 200. 

```
{
  "status" : 200,
  "name" : "James Howlett",
  "cluster_name" : "elasticsearch",
     ... truncated output 
}
```

**Logstash**

To test your Logstash installation, run the following command in a new shell:
```shell
<path_to_logstash_root_dir>/bin/logstash -e 'input { stdin { } } output { stdout {} }'
```

Type `checking logstash!` at the command prompt. If Logstash is correctly installed, you should see:

```shell
checking logstash!
2015-06-21T01:22:14.405+0000 0.0.0.0 checking logstash!
```
Exit Logstash using `CTRL-D` command.

**Kibana**

Open a new shell window and run Kibana. 
```Shell
<path_to_kibana_root_dir>/bin/kibana 
```
Kibana should now be running on port 5601. To test, point your web browser at port 5601 (`localhost:5601`). You should see the Kibana UI.





