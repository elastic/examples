## Using ELK to Analyze DonorsChoose.org data

This examples provides supplementary material to the blog post on [Hacking Education with Elastic stack ADD LINK]().

In this example, we will be analyzing the historical donations and projects data provided by [DonorsChoose.org](http://data.donorschoose.org/open-data/overview/) using Elasticsearch, Logstash and Kibana. DonorsChoose.org is an online charity that connect individuals with schools and teachers in need of resources. For additional background on this dataset, please refer to the accompanying [blog post ADD LINK]()

##### Version
Example has been tested in following versions:
- Elasticsearch 1.7.0
- Logstash 1.5.2
- Kibana 4.1.0

### Installation & Setup
* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the ELK stack (*you can skip this step if you already have a working installation of the ELK stack*)

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

You have 2 options to index the data into Elasticsearch. You can either use the Elasticsearch [snapshot and restore](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html) API to directly restore the `donorschoose` index from a snapshot. OR, you can download the raw data from the DonorsChoose.org website and then use the scripts in the [Scripts - Python](https://github.com/elastic/examples/tree/master/ELK_donorschoose/Scripts%20-%20Python) folder to process the raw files and index the data.

#### Option 1. Load data by restoring index snapshot
(Learn more about snapshot / restore [here]())

Using this option involves 4 easy steps:

  * Download and uncompress the index snapshot .tar.gz file into a local folder

  ```shell
  # Create snapshots directory
  mkdir elk_donorschoose
  cd elk_donorschoose
  # Download index snapshot to elk_donorschoose directory
  wget http://download.elasticsearch.org/demos/donorschoose/donorschoose_backup.tar.gz .
  # Uncompress snapshot file
  tar -xf donorschoose_backup.tar.gz
  ```
  This adds a `donorschoose_backup` subfolder containing the index snapshots.

  * Add `donorschoose_backup` dir to `path.repo` variable in the `elasticsearch.yml` in the `path_to_elasticsearch_root_dir/config/` folder. See example [here.](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_shared_file_system_repository). Restart elasticsearch for the change to take effect.

  * Register a file system repository for the snapshot *(change the value of the “location” parameter below to the location of your `donorschoose_backup` directory)*
  ```shell
  curl -XPUT 'http://localhost:9200/_snapshot/donorschoose_backup' -d '{
      "type": "fs",
      "settings": {
          "location": "<path_to_donorschoose_backup_dir>/",
          "compress": true,
          "max_snapshot_bytes_per_sec": "1000mb",
          "max_restore_bytes_per_sec": "1000mb"
      }
  }'
  ```

  * Restore the index data into your Elasticsearch instance:
    ```shell
    curl -XPOST "localhost:9200/_snapshot/donorschoose_backup/snapshot_1/_restore"
    ```

At this point, go make yourself a coffee. When you are done enjoying your cup of delicious coffee, check to see if the restore operation is complete.

#### Option 2: Process and load data using Python script

The raw DonorsChoose.org data is provided as 5 separate files. In order to do some useful querying of the data in a search engine / NoSQL store like Elasticsearch, you typically have to go through a data modeling process of identifying how to join data from various tables. The files and instructions provided in the [Scripts - Python](https://github.com/elastic/examples/tree/master/ELK_donorschoose/Scripts%20-%20Python) folder provide example of processing, modeling and ingesting data into Elasticsearch starting with the raw data.

We are providing this option in case you want to modify how the data is joined, perform additional data cleansing, enrich with additional data, etc. Follow the [ReadMe](https://github.com/elastic/examples/blob/master/ELK_donorschoose/Scripts%20-%20Python/README.md) in the [Scripts - Python](https://github.com/elastic/examples/tree/master/ELK_donorschoose/Scripts%20-%20Python) folder if you want to try this option.

#### Check data availability
Once the index is created using either of the above options, you can check to see if all the data is available in Elasticsearch. If all goes well, you should get a `count` response of approximately `3506071` when you run the following command.

  ```shell
  curl -XGET localhost:9200/donorschoose/_count -d '{
  	"query": {
  		"match_all": {}
  	}
  }'
  ```

#### Visualize Data in Kibana
* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `donorschoose` index in Elasticsearch
    * Click the **Settings** tab >> **Indices** tab >> **Create New**. Specify `donorschoose` as the index pattern name, select `donation_timestamp` as the **Time-field name**, and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked)
* Load sample dashboard into Kibana
    * Click the **Settings** tab >> **Objects** tab >> **Import**, and select `donorschoose_kibana.json`
* Open dashboard
    * Click on **Dashboard** tab and open `Donors Choose` dashboard. Voila! You should see the following dashboard. Happy Data Exploration!

![Kibana Dashboard Screenshot](https://cloud.githubusercontent.com/assets/5269751/10270320/679104f0-6aa2-11e5-869f-652e1bcfe0c1.png)

### We would love to hear from you!
If you run into issues running this example or have suggestions to improve it, please use Github issues to let us know. Have an easy fix? Submit a pull request. We will try our best to respond in a timely manner!

Have you created interesting examples using the ELK stack? Looking for a way to share your amazing work with the community? We would love to include your awesome work here. For more information on how to contribute, check out the **[Contribution](https://github.com/elastic/examples#contributing)** section!
