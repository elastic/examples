### Overview
This **Getting Started with ELK** example provides sample code to ingest, analyze & visualize **Twitter stream** around a topic of interest using the ELK stack, i.e. Elasticsearch, Logstash and Kibana.

##### Version
Example has been tested in following versions:
- Elasticsearch 1.7.0
- Logstash 1.5.2
- Kibana 4.1.0

### Installation & Setup
* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the ELK stack (*you can skip this step if you have a working installation of the ELK stack*)

* Run Elasticsearch & Kibana
  ```shell
    <path_to_elasticsearch_root_dir>/bin/elasticsearch
    <path_to_kibana_root_dir>/bin/kibana
    ```

* Check that Elasticsearch and Kibana are up and running.
  - Open `localhost:9200` in web browser -- should return status code 200
  - Open `localhost:5601` in web browser -- should display Kibana UI.

  **Note:** By default, Elasticsearch runs on port 9200, and Kibana run on ports 5601. If you changed the default ports during installation, change the above calls to use appropriate ports.

### Download Example Files

Download the following files in this repo to a local directory:
- `twitter_logstash.conf` - Logstash config for ingesting data into Elasticsearch
- `twitter_template.json` - template for custom mapping of fields
- `twitter_kibana.json` - config file for creating Kibana dashboard
- `twitter_dashboard.png` - screenshot of final Kibana dashboard

Unfortunately, Github does not provide a convenient one-click option to download the entire content of a subfolder in a repo. Use sample code provided below to download the required files to a local directory:

```shell
mkdir  twitter_elk_example
cd twitter_elk_example
wget https://raw.githubusercontent.com/elastic/examples/master/ELK_twitter/twitter_logstash.conf
wget https://raw.githubusercontent.com/elastic/examples/master/ELK_twitter/twitter_template.json
wget https://raw.githubusercontent.com/elastic/examples/master/ELK_twitter/twitter_kibana.json
```

### Run Example
##### 1. Configure example to use your Twitter API keys
* Get Twitter API keys and Access Tokens

  This example uses the Twitter API to monitor Twitter feed in real time. To use this, you will first need
  to [create a Twitter app](https://apps.twitter.com/app/new) to get your Twitter API keys and Access Tokens.

* Modify Logstash config file to use your Twitter API credentials

  Modify the `input { twitter { } }` section in the `twitter_logstash.conf` file to use the API keys and Access tokens generated   in the previous step. While at it, feel free to modify the words you want to track in the `keywords` field (in this example,    we are tracking tweets mentioning popular Marvel Comic characters.
```
input {
  twitter {
    consumer_key       => "INSERT YOUR CONSUMER KEY"
    consumer_secret    => "INSERT YOUR CONSUMER SECRET"
    oauth_token        => "INSERT YOUR ACCESS TOKEN"
    oauth_token_secret => "INSERT YOUR ACCESS TOKEN SECRET"
    keywords           => [ "thor", "spiderman", "wolverine", "ironman", "hulk"]
    full_tweet         => true
  }
}
```

##### 2. Ingest data into Elasticsearch using Logstash
* Execute the following command to start ingesting tweets of interest into Elasticsearch. Since this example is a monitoring Twitter in real time, the tweet ingestion volume will depend on the popularity of the words being tracked. When you run the above command, you should see a trail of dots (`...`) in your shell as new tweets are ingested.

  ```shell
   <path_to_logstash_root_dir>/bin/logstash -f twitter_logstash.conf
  ```

* Verify that data is succesfully indexed into Elasticsearch

  Running `http://localhost:9200/twitter_elk_example/_count` should show a positive response for `count`.

  **Note:** Included `twitter_logstash.conf` configuration file assumes that you are running Elasticsearch on the same host as   Logstash and have not changed the defaults. Modify the `host` and `cluster` settings in the `output { elasticsearch { ... } }`   section of `twitter_logstash.conf`, if needed.


##### 3. Visualize data in Kibana

* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `twitter_elk_example` index in Elasticsearch (autocreated in step 2)
    * Click the **Settings** tab >> **Indices** tab >> ** Add New. Specify `twitter_elk_example` as the index pattern name and click **Create** to define the index pattern (Leave the **Use event times to create index names** box unchecked)
* Load sample dashboard into Kibana
    * Click the **Settings** tab >> **Objects** tab >> **Import**, and select `twitter_kibana.json`
<<<<<<< HEAD
* Open dashboard
    * Click on **Dashboard** tab and open `Sample Twitter Dashboard` dashboard

=======
>>>>>>> test-branch

Voila! You should see the following dashboards with real-time Twitter stream. Enjoy!
![Kibana Dashboard Screenshot](https://github.com/elastic/examples/blob/master/ELK_nginx-json/nginx_json_dashboard.png)

### We would love your feedback!
If you found this example helpful and would like to see more such getting started examples for other standard formats or web APIs, we would love your feedback. If you would like to contribute examples to this repo, we'd love that too!
