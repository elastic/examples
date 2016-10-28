## Using Elastic Stack to Analyze US FEC Campaign Contribution data

This example demonstrates how to analyze & visualize US Federal Election Commission (FEC) campaign contribution data from the 2013-2014 election cycle data using Elasticsearch and Kibana. The [data](http://www.fec.gov/finance/disclosure/ftpdet.shtml#a2013_2014) analyzed in this example is taken from the [Federal Election Commission](http://www.fec.gov/finance/disclosure/ftpdet.shtml) site.

For some background information for this demo, please see the blog post here:
[Kibana 4 for investigating PACs, Super PACs, and who your neighbor might be voting for](http://www.elasticsearch.org/blog/kibana-4-for-investigating-pacs-super-pacs-and-your-neighbors/). Note that the screenshots in the blog were created with Kibana 4.0 - your dashboard may look a little different depending on the Kibana version you are using.

##### Version
Example has been tested in following versions:
- Elasticsearch 5.0
- Logstash 5.0
- Kibana 5.0

### Installation & Setup
* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the Elastic Stack (*you can skip this step if you already have a working installation of the Elastic Stack*)

* Run Elasticsearch & Kibana
  ```shell
  <path_to_elasticsearch_root_dir>/bin/elasticsearch
  <path_to_kibana_root_dir>/bin/kibana
  ```

* Check that Elasticsearch and Kibana are up and running.
  - Open `localhost:9200` in web browser -- should return status code 200
  - Open `localhost:5601` in web browser -- should display Kibana UI.

  **Note:** By default, Elasticsearch runs on port 9200, and Kibana run on ports 5601. If you changed the default ports, change   the above calls to use appropriate ports.


### Download & Ingest Data

You have 2 options to index the data into Elasticsearch. You can either use the Elasticsearch [snapshot and restore](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html) API to directly restore the `usfec` index from a snapshot. OR, you can download the raw data from the USFEC site and then use the scripts in the [Scripts-Python+Logstash](https://github.com/elastic/examples/tree/master/ElasticStack_usfec/Scripts-Python+Logstash) folder to process the raw files and index the data.


#### Option 1. Load data by restoring index snapshot
(Learn more about snapshot / restore [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html))

Using this option involves 4 easy steps:

  * Download and uncompress the index snapshot .tar.gz file into a local folder
  
  ```shell
  # Create snapshots directory
  mkdir ./elastic_usfec
  cd elastic_usfec
  # Download index snapshot to your new snapshots directory
  wget http://download.elasticsearch.org/demos/usfec/snapshot_demo_usfec_5_0.tar.gz .
  # Uncompress snapshot file (uncompressed to usfec subfolder)
  tar -xf snapshot_demo_usfec_5_0.tar.gz
  ```
  * Add the location of the uncompressed snapshot dir to `path.repo` variable in the `elasticsearch.yml` in the `path_to_elasticsearch_root_dir/config/` folder. See example [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_shared_file_system_repository). You will need to restart Elasticsearch for the settings to take effect. 

  * Register a file system repository for the snapshot *(change the value of the “location” parameter below to the location of your uncompressed snapshot directory)*
  ```shell
  curl -XPUT 'http://localhost:9200/_snapshot/usfec' -d '{
      "type": "fs",
      "settings": {
          "location": "<path_to_uncompressed_folder>",
          "compress": true,
          "max_snapshot_bytes_per_sec": "1000mb",
          "max_restore_bytes_per_sec": "1000mb"
      }
  }'
  ```

  * Restore the index data into your Elasticsearch instance:
    ```shell
    curl -XPOST "localhost:9200/_snapshot/usfec/snapshot_1/_restore"
    ```

At this point, go make yourself a [coffee](https://bluebottlecoffee.com/preparation-guides). When your delicious cup of single-origin, direct trade coffee has finished brewing, check to see if the restore operation is complete.


#### Option 2: Process and load data using Python script

The raw FEC data is provided as 7 separate files. In order to do some useful querying of the data in a search engine / NoSQL store like Elasticsearch, you typically have to go through a data modeling process of identifying how to join data from various tables. The files and instructions provided in the `Scripts-Python+Logstash` folder provide example of processing, modeling and ingesting data into Elasticsearch starting with the raw data file.

We are providing this option in case you want to modify how the data is joined, perform additional data cleansing/enrichment, re-process the latest raw data set from the FEC, etc. Follow the [ReadMe](https://github.com/elastic/examples/blob/master/ElasticStack_usfec/Scripts-Python+Logstash/README.md) if you want to try this option.

#### Check data availability
Once the index is created using either of the above options, you can check to see if all the data is available in Elasticsearch. If all goes well, you should get a `count` response of approximately 4398435 when you run the following command.

  ```shell
  curl -XGET localhost:9200/usfec*/_count -d '{
  	"query": {
  		"match_all": {}
  	}
  }'
  ```

#### Visualize Data in Kibana
* Access Kibana by going to `http://localhost:5601` in a web browser
* Download `usfec_kibana.json` 
* Connect Kibana to the `usfec*` index in Elasticsearch
    * Click the **Management** tab >> **Index Patterns** tab >> **Create New**. Specify `usfec*` as the index pattern name and click **Create** to define the index pattern using the @timestamp field as the Time-field. (Leave the **Use event times to create index names** box unchecked)
* Load sample dashboard into Kibana
    * Click the **Management** tab >> **Saved Objects** tab >> **Import**, and select `usfec_kibana.json`
* Open dashboard
    * Click on **Dashboard** tab and open `USFEC: Overview` dashboard

    Voila! You should see the following dashboard. Happy Data Exploration!

    ![Kibana Dashboard Screenshot](https://github.com/elastic/examples/blob/master/ElasticStack_usfec/usfec_dashboard.jpg?raw=true)

### We would love to hear from you!
If you run into issues running this example or have suggestions to improve it, please use Github issues to let us know. Have an easy fix? Submit a pull request. We will try our best to respond in a timely manner!

Have you created interesting examples using the Elastic Stack? Looking for a way to share your amazing work with the community? We would love to include your awesome work here. For more information on how to contribute, check out the **[Contribution](https://github.com/elastic/examples#contributing)** section!
