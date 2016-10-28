## Using Elastic Stack to Analyze NYPD Motor Vehicle Collision Data
This example demonstrates how to analyze & visualize New York City traffic incident data using the Elastic Stack, i.e. Elasticsearch, Logstash and Kibana. The [NYPD Motor Vehicle Collision data](https://data.cityofnewyork.us/Public-Safety/NYPD-Motor-Vehicle-Collisions/h9gi-nx95?) analyzed in this example is from the [NYC Open Data](https://data.cityofnewyork.us/) initiative.

Feel free to read the [#byodemos: New York city traffic incidents](https://www.elastic.co/blog/byodemos-new-york-city-traffic-incidents) blog post for additional commentary on this analysis. A couple of notes on the blog. The screenshots in the blog post were created with an older version of Kibana. So, don't be alarmed if your Kibana UI looks a little different. Secondly, the good folks at [NYC Open Data](https://data.cityofnewyork.us/) are great at updating their dataset with latest information. So the visualization and metrics that you see might not match the ones highlighted in the blog post. But, that is the fun part of exploring a living & dynamic dataset, isn't it? 

##### Version
Example has been tested in following versions:
- Elasticsearch 5.0.0
- Logstash 5.0.0
- Kibana 5.0.0

### Contents
* [Installation & Setup](#installation--setup)
* [Download](#download-data--example-files)
* [Run Example](#run-example)
* [Feedback](#we-would-love-to-hear-from-you)

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

### Download Data & Example Files

-  **Download Data:**

    Download the CSV version of the NYPD Motor Vehicle Collision dataset from the [NYC Open Data Portal](https://data.cityofnewyork.us/Public-Safety/NYPD-Motor-Vehicle-Collisions/h9gi-nx95?). In this example, we are renaming the downloaded CSV file to `nyc_collision_data.csv`.
  ```
  mkdir nyc_collision
  cd nyc_collision
  wget https://data.cityofnewyork.us/api/views/h9gi-nx95/rows.csv?accessType=DOWNLOAD -O nyc_collision_data.csv
  ```

* **Download Example Files:**

  Download the following files to the folder containing the downloaded `nyc_collision_data.csv file`:
  - `nyc_collision_logstash.conf` - Logstash config for ingesting data into Elasticsearch
  - `nyc_collision_template.json` - template for custom mapping of fields
  - `nyc_collision_kibana.json` - config file to load prebuilt Kibana dashboard

  Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. You can either (a) [download](https://github.com/elastic/examples/archive/master.zip) or [clone](https://github.com/elastic/examples.git) the entire examples repo and navigate to `ElasticStack_nyc_traffic_accidents` subfolder, or (b) individually download the above files. The code below makes option (b) a little easier:
  ```shell
  wget https://raw.githubusercontent.com/elastic/examples/master/ElasticStack_nyc_traffic_accidents/nyc_collision_logstash.conf
  wget https://raw.githubusercontent.com/elastic/examples/master/ElasticStack_nyc_traffic_accidents/nyc_collision_template.json
  wget https://raw.githubusercontent.com/elastic/examples/master/ElasticStack_nyc_traffic_accidents/nyc_collision_kibana.json
  ```

### Run Example
##### 1. Ingest data into Elasticsearch using Logstash
* Execute the following command to `nyc_collision_data.csv` data into Elasticsearch.

    ```shell
    cat nyc_collision_data.csv | <path_to_logstash_root_dir>/bin/logstash -f nyc_collision_logstash.conf
    ```

* Verify that data is successfully indexed into Elasticsearch

  Running `http://localhost:9200/nyc_visionzero/_count` should return positive `count` value

 **Note:** Included `nyc_collision_logstash.conf` configuration file assumes that you are running Elasticsearch on the same host as Logstash and have not changed the defaults. Modify the `host` and `cluster` settings in the `output { elasticsearch { ... } }`   section of apache_logstash.conf, if needed.

##### 2. Visualize data in Kibana

* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `nyc_visionzero` index in Elasticsearch (autocreated in step 1)
    * Click the **Management** tab >> **Index Patterns** tab >> **Create New**. Specify `nyc_visionzero` as the index pattern name and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked and the Time Field as @timestamp)
* Load sample dashboard into Kibana
    * Click the **Management** tab >> **Saved Objects** tab >> **Import**, and select `nyc_collision_kibana.json`
* Open dashboard
    * Click on **Dashboard** tab and open `NYC Motor Vehicles Collision` dashboard

Voila! You should see the following dashboard. Happy Data Exploration!
![Kibana Dashboard Screenshot](https://cloud.githubusercontent.com/assets/5269751/10008565/f548dc28-6084-11e5-9956-b29c2ca043ee.png)

### We would love to hear from you!
If you run into issues running this example or have suggestions to improve it, please use Github issues to let us know. Have an easy fix, submit a pull request. We will try our best to respond in a timely manner!

Have you created interesting examples using the Elastic Stack? Looking for a way to share your amazing work with the community? We would love to include your awesome work here. For more information on how to contribute, check out the **[Contribution](https://github.com/elastic/examples#contributing) section!**
