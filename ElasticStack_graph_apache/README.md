## Using Graph to Analyze Apache Logs and Potential Points of Compromise

This example demonstrates how to analyze & visualize Apache Log data using the Graph capability of the Elastic Stack. The data analyzed in this example is from the [Secrep.com](http://www.secrepo.com/) and represents the sites apache logs.
This data, published by Mike Sconzo, is licensed under a Creative Commons Attribution 4.0 International License.

### Versions and Pre-requisites

Example has been tested in following versions:

- Elasticsearch 5.0
- X-Pack 5.0
- Kibana 5.0
- Logstash 5.0
- Python 3.x

### Installation & Setup

* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the elastic stack (*you can skip this step if you already have a working installation of the Elastic stack*)

* Install the X-Pack in Kibana and Elasticsearch 

  ```shell
  <path_to_elasticsearch_root_dir>/elasticsearch-plugin install x-pack
  <path_to_kibana_root_dir>/bin/kibana-plugin install x-pack
  ```

* Run Elasticsearch & Kibana
  ```shell
  <path_to_elasticsearch_root_dir>/bin/elasticsearch
  <path_to_kibana_root_dir>/bin/kibana
  ```


The following assumes the default username and password of "elastic" and "changeme".  These can be changed as detailed [here](https://www.elastic.co/guide/en/shield/current/native-realm.html).  If changed, ensure the Logstash.conf file is updated accordingly to permit ingestion.

* Check that Elasticsearch and Kibana are up and running.
  - Open `localhost:9200` in web browser and authenticate with "elastic" and "changeme" -- should return status code 200
  - Open `localhost:5601` in web browser -- should display Kibana UI.

  **Note:** By default, Elasticsearch runs on port 9200, and Kibana run on ports 5601. If you changed the default ports, change   the above calls to use appropriate ports.

### Download & Ingest Data

  Download the raw data from the secrepo website using the script `download_data.py` before processing and indexing the raw files using the provided Logstash configuration.

  The following details the required steps:
  
1. Download the contents of this folder <br>
    
    - `download_data.py` - Python script to download the raw files.
    - `secrepo.json` contains mapping for Elasticsearch index
    - `secrepo_logstash.conf` - Logstash config file to ingest data
    - `requirements.txt` - Python dependencies for above script
    - `patterns/` - Grok patterns for processing file
    - `secrepo_kibana.json` - Configuration for graph
    
1. Setup Python environment

Requires Python 3.  Install dependencies with pip i.e. `pip install -r requirements.txt`

1. Run Python script to download data. This will download all data starting from 2015-01-17 to the current day.  These script parameters can be modified as required.

```
  python3 download_data.py
```
    
This script will create a subfolder `data` into which a log file for each day will be extracted.  Some days may not be available.

1. Index the data using Logstash and the configuration provided.
 
```
  cat ./data/* | /opt/elastic-5-0/logstash-5.0.0/bin/logstash -f secrepo_logstash.conf
```
   
1. Check data availability
  
  Once the index is indexed you can check to see if all the data is available in Elasticsearch. If you have downloaded all of the data from 2015-01-17 to the current day, you should get a `count` response greater than `300840` when you run the following command.

    ```shell
    curl -XGET localhost:9200/secrepo/_count -d '{
    	"query": {
    		"match_all": {}
    	}
    }'
    ```

### Visualize Data in Kibana
  
  * Access Kibana by going to `http://localhost:5601` in a web browser
  * Connect Kibana to the `secrepo` index in Elasticsearch
      * Click the **Management** tab >> **Index Patterns** tab >> **Create New**. Specify `secrepo` as the index pattern name, using the default field `@timestamp` as the **Time-field name**, and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked)
  * Load sample dashboard into Kibana
      * Click the **Management** tab >> **Saved Objects** tab >> **Import**, and select `secrepo_kibana.json`
  * Open graph
      * Click on **Graph** tab and open ``.
      
  ![Kibana Dashboard Screenshot](https://github.com/elastic/examples/blob/master/ElasticStack_graph_apache/secrepo_graph.jpg?raw=true)

### We would love to hear from you!

If you run into issues running this example or have suggestions to improve it, please use Github issues to let us know. Have an easy fix? Submit a pull request. We will try our best to respond in a timely manner!

Have you created interesting examples using the Elastic Stack? Looking for a way to share your amazing work with the community? We would love to include your awesome work here. For more information on how to contribute, check out the **[Contribution](https://github.com/elastic/examples#contributing)** section!
