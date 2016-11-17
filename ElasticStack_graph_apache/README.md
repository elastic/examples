## Using the Elastic Stack to Analyze NYC Restaurant Inspection Data
This example demonstrates how to analyze & visualize New York City restaurant inspection data using Kibana. The [NYC Restaurant Inspection data](https://data.cityofnewyork.us/Health/DOHMH-New-York-City-Restaurant-Inspection-Results/43nn-pn8j) analyzed in this example is from the [NYC Open Data](https://data.cityofnewyork.us/) initiative.

This example was used as a part of the [Kibana 101: Getting Started with Visualization webinar](https://www.elastic.co/webinars/kibana-101-get-started-with-visualizations). Please check out the webinar for more context on the data and the story.

Visualizations in the above webinar may look different due to use of an earlier Kibana version.

##### Version
Example has been tested in following versions:
- Elasticsearch 5.0
- Kibana 5.0

### Contents
* [Installation & Setup](#installation--setup)
* [Download](#download-data--example-files)
* [Run Example](#run-example)
* [Feedback](#we-would-love-to-hear-from-you)

### Installation & Setup
* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the elastic stack (*you can skip this step if you already have a working installation of the Elastic stack*)

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

  You have 2 options to index the data into Elasticsearch. You can either use the Elasticsearch [snapshot and restore](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html) API to directly restore the `nyc_restaurants` index from a snapshot. OR, you can download the raw data from the data.cityofnewyork.us website and then use the scripts in the [Scripts-Python](https://github.com/elastic/examples/tree/master/kibana_nyc_restaurants/Scripts-Python) folder to process the raw files and index the data.

  #### Option 1. Load data by restoring index snapshot
  (Learn more about snapshot / restore [here](https://www.elastic.co/guide/en/elasticsearch/reference/5.0/modules-snapshots.html) )

  Using this option involves 4 easy steps:

    * Download and uncompress the index snapshot .tar.gz file into a local folder <br>
    ```shell
    # Create snapshots directory
    mkdir elastic_restaurants
    cd elastic_restaurants
    # Download index snapshot to elastic_restaurants directory
    wget http://download.elasticsearch.org/demos/nyc_restaurants/nyc_restaurants-5-0.tar.gz .
    # Uncompress snapshot file
    tar -xf nyc_restaurants-5-0.tar.gz
    ```
    This adds a `nyc_restaurants` subfolder containing the index snapshots.

    * Add `nyc_restaurants` dir to `path.repo` variable in the `elasticsearch.yml` in the `path_to_elasticsearch_root_dir/config/` folder. See example [here.](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_shared_file_system_repository). Restart elasticsearch for the change to take effect.

    * Register a file system repository for the snapshot *(change the value of the “location” parameter below to the location of your `restaurants_backup` directory)*
    ```shell
    curl -XPUT 'http://localhost:9200/_snapshot/restaurants_backup' -d '{
        "type": "fs",
        "settings": {
            "location": "<path_to_nyc_restaurants>/",
            "compress": true,
            "max_snapshot_bytes_per_sec": "1000mb",
            "max_restore_bytes_per_sec": "1000mb"
        }
    }'
    ```

    * Restore the index data into your Elasticsearch instance:
      ```shell
      curl -XPOST "localhost:9200/_snapshot/restaurants_backup/snapshot_1/_restore"
      ```

  #### Option 2: Process and load data using Python script

  The raw NYC Restaurants Inspection data is provided as a CSV file. For this example, we ingested the data into Elasticsearch using the Python Elasticsearch client. See [Scripts-Python](https://github.com/elastic/examples/tree/master/kibana_nyc_restaurants/Scripts-Python)

  We are providing this option in case you want to modify how the data is processed before ingest. Follow the [ReadMe](https://github.com/elastic/examples/blob/master/kibana_nyc_restaurants/Scripts-Python/README.md) in the [Scripts-Python](https://github.com/elastic/examples/tree/master/kibana_nyc_restaurants/Scripts-Python) folder if you want to try this option.

  #### Check data availability
  Once the index is created using either of the above options, you can check to see if all the data is available in Elasticsearch. If all goes well, you should get a `count` response of approximately `473039` when you run the following command.

    ```shell
    curl -XGET localhost:9200/nyc_restaurants/_count -d '{
    	"query": {
    		"match_all": {}
    	}
    }'
    ```

  #### Visualize Data in Kibana
  * Access Kibana by going to `http://localhost:5601` in a web browser
  * Connect Kibana to the `nyc_restaurants` index in Elasticsearch
      * Click the **Management** tab >> **Index Patterns** tab >> **Create New**. Specify `nyc_restaurants` as the index pattern name, select `Inspection_Date` as the **Time-field name**, and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked)
  * Load sample dashboard into Kibana
      * Click the **Management** tab >> **Saved Objects** tab >> **Import**, and select `restaurants_kibana.json`
  * Open dashboard
      * Click on **Dashboard** tab and open `DOHMH: Overview` dashboard. Voila! You should see the following dashboard. Happy Data Exploration!

  ![Kibana Dashboard Screenshot](https://github.com/elastic/examples/blob/master/kibana_nyc_restaurants/restaurants_kibana.jpg?raw=true)

  ### We would love to hear from you!
  If you run into issues running this example or have suggestions to improve it, please use Github issues to let us know. Have an easy fix? Submit a pull request. We will try our best to respond in a timely manner!

  Have you created interesting examples using the Elastic Stack? Looking for a way to share your amazing work with the community? We would love to include your awesome work here. For more information on how to contribute, check out the **[Contribution](https://github.com/elastic/examples#contributing)** section!
