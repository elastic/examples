US FEC Campaign Contributions Demo: 2013-2014 US Election cycle
=====

For some background information for this demo, please see the blog post here:
[#byodemos: us election campaign contributions](http://www.elasticsearch.org/blog/byodemos-new-york-city-traffic-incidents/)

#Installation

This demo consists of the following:

* Instructions for restoring index snapshot with pre-indexed campaign contributions data
* Python script for joining normalized files and outputting JSON
* Elasticsearch index template
* Logstash config


## Restoring index snapshot

After downloading and installing the ELK stack, you’ll need to download the index snapshot file for the campaign contributions data which can be obtained here (FYI it’s a 1.4GB file; we take no responsibility for this download eating up your monthly mobile tethering quota):

http://download.elasticsearch.org/demos/usfec/snapshot_demo_usfec.tar.gz 

Create a folder somewhere on your local drive called “snapshots” and uncompress the .tar.gz file into that directory. For example:
```
# Create snapshots directory
mkdir -p ~/elk/snapshots
# Copy snapshot download to your new snapshots directory
cp ~/Downloads/snapshot_demo_usfec.tar.gz ~/elk/snapshots
# Go to snapshots directory
cd ~/elk/snapshots
# Uncompress snapshot file
tar xf snapshot_demo_usfec.tar.gz
```
Once you have Elasticsearch running, restoring the index is a two-step process:

1) Register a file system repository for the snapshot (change the value of the “location” parameter below to the location of your usfec snapshot directory):
```
curl -XPUT 'http://localhost:9200/_snapshot/usfec' -d '{
    "type": "fs",
    "settings": {
        "location": "/tmp/snapshots/usfec",
        "compress": true,
        "max_snapshot_bytes_per_sec": "1000mb",
        "max_restore_bytes_per_sec": "1000mb"
    }
}'
```
2) Call the Restore API endpoint to start restoring the index data into your Elasticsearch instance:
```
curl -XPOST "localhost:9200/_snapshot/usfec/1/_restore"
```
At this point, go make yourself a [coffee](https://bluebottlecoffee.com/preparation-guides). When your delicious cup of single-origin, direct trade coffee has finished brewing, you can check to see if the restore operation is complete by calling the cat recovery API:
```
curl -XGET 'localhost:9200/_cat/recovery?v'
```
Or get a count of the documents in the expected indexes:
```
curl -XGET localhost:9200/usfec*/_count -d '{
	"query": {
		"match_all": {}
	}
}'
```
which should return a count of approximately 4250251.

## Python script

The raw FEC data is provided in a number of 7 files. In order to do some useful querying of the data in a search engine / NoSQL store like Elasticsearch, you typically have to go through a data modeling process of identifying how to join data from various tables. 

The Python script (in scripts/process_camfin.py) takes care of some of the obvious ways to join the various data files and produces four .json files which can then be loaded into Elasticsearch using Logstash. The script requires Python 3.

You don't need to run the Python script but it's here in case you want to modify how the data is joined, perform additional data cleansing/enrichment, re-process the latest raw data set from the FEC, etc.

##Elasticsearch index template config

The Elasticsearch mapping configuration is defined in the index template file: index\_template.json. Documentation:

* [Mapping](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/mapping.html)
* [Index templates](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-templates.html)

##Logstash config

The Logstash configuration is defined in the file: logstash.conf. Documentation for Logstash plugins: [http://www.elasticsearch.org/guide/en/logstash/current/index.html](http://www.elasticsearch.org/guide/en/logstash/current/index.html).
