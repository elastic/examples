## Using Elasticsearch & Kibana to Analyze DonorsChoose.org data

This examples provides supplementary material to the Movember Data Dives. [blog 1]() and [blog 2]()

In this example, we will analyze the [Behavioral Risk Factor Surveillance System data] (http://www.cdc.gov/brfss/annual_data/annual_2013.html) from 2013.  using the Elastic stack. Every year, the Centers for Disease Control and Prevention (CDC) conducts approximately 500,000 telephone surveys to collect data on a variety of personal health-related topics, such as nutrition, drinking habits, physical activity and health history. We explored the exercise and nutrition patterns in the US. For additional commentary on the analysis and insights, refer to the accompanying blogs. see [here]() for analysis of physical activity and exercise patterns, and [here]() for analysis of eating and drinking patterns.

##### Version
Example has been tested in following versions:
- Elasticsearch 1.7.0
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

In this example, we ingest the data into Elasticsearch using the Elasticsearch Python client.
Follow the instructions in the  [ReadMe]() in the [Scripts - Python](https://github.com/elastic/examples/tree/master/ELK_donorschoose/Scripts%20-%20Python) folder if you want to try this option.

#### Check data availability
Once the index is created using either of the above options, you can check to see if all the data is available in Elasticsearch. If all goes well, you should get a `count` response of approximately `TO DO` when you run the following command.

  ```shell
  curl -XGET localhost:9200/brfss/_count -d '{
  	"query": {
  		"match_all": {}
  	}
  }'
  ```

#### Visualize Data in Kibana
* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `brfss` index in Elasticsearch
    * Click the **Settings** tab >> **Indices** tab >> **Create New**. Specify `brfss` as the index pattern name, select `interview_date` as the **Time-field name**, and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked)
* Load sample dashboard into Kibana
    * Click the **Settings** tab >> **Objects** tab >> **Import**, and select `brfss_kibana.json`
* Open dashboard(S)
    * Click on **Dashboard** tab and open either the `BRFSS Nutrition Dashboard` or `BRFSS Exercise Dashboard` dashboard. Voila! You should see one of the following dashboards. Happy Data Exploration!

![Kibana Dashboard Screenshot]()
![Kibana Dashboard Screenshot]()

### We would love to hear from you!
If you run into issues running this example or have suggestions to improve it, please use Github issues to let us know. Have an easy fix? Submit a pull request. We will try our best to respond in a timely manner!

Have you created interesting examples using the ELK stack? Looking for a way to share your amazing work with the community? We would love to include your awesome work here. For more information on how to contribute, check out the **[Contribution](https://github.com/elastic/examples#contributing)** section!
