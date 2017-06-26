# Detect Twitter Trends - Example

## Overview

In order to demonstrate this recipe the following examples are provided:
 
1. **Static Dataset** - A test dataset consisting of collected tweets over the period of a week for the topic of "Application Performance Monitoring".  To collect these tweets the hashtags `'#apm', "#APMT", "#apmt", "#APM"` were monitored. These tweets have been pre-enriched with the field `topic` and value `APM`.  For purposes of example, this dataset only contains a single topic for ingestion using Filebeat.
1. **Self Collection** -  A Logstash configuration for reference that can be used to collect tweets per pertaining to a set of topics.  Here a topic is defined as a set of keywords.  **For reference only.**

## Pre-requisites

- Filebeat 5.4
- Logstash v5.4 
- Elasticsearch v5.4
- X-Pack v5.4 with ML beta
- curl

Note: Earlier versions may work but have not been tested

## Recipe Components

This example includes:
 
 * Minimal Filebeat configuration for ingesting tweet data
 * Minimal Logstash configuration for collecting tweets if desired
 * X-Pack machine learning job configuration files
 * Utility scripts to help with loading of the job

## Installation and Setup

* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the Elastic Stack (*you can skip this step if you have a working installation of the Elastic Stack,*)

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

* Check that Elasticsearch and Kibana are up and running.

  - Open `localhost:9200` in web browser -- should return a json message indicating ES is running.
  - Open `localhost:5601` in web browser -- should display Kibana UI.

  **Note:** By default, Elasticsearch runs on port 9200, and Kibana run on ports 5601. If you changed the default ports, change the above calls to use the appropriate ports.  

  The cluster will be secured using basic auth. If changing the default credentials of `elastic` and `changeme` as described [here](https://www.elastic.co/guide/en/x-pack/current/security-getting-started.html), ensure the logstash configuration file is updated.


### Example 1 - Static Dataset

* Download the test dataset provided.

    ```
    curl -O https://github.com/elastic/examples/tree/master/Machine%20Learning/Business%20metrics%20recipes/twitter_tends/data/tweets.csv
    ```

* [Download and Install Filebeat](https://www.elastic.co/guide/en/beats/filebeat/5.4/filebeat-installation.html). **Do not start Filebeat**.

* Download the provided Filebeat configuration file and twitter ES template.

    ```
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Business%20Metrics%20recipes/twitter_trends/configs/filebeat/filebeat.yml
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Business%20Metrics%20recipes/twitter_trends/configs/templates/twitter.json
    ```

* Modify the filebeat.yml` file. One one mandatory change is required:

        - Under `filebeast.prospectors.paths` specify the location to the test dataset file downloaded above.

    Also consider changing:
    
        - The elasticsearch username and password values if these have been modified from the defaults
        - The elasticsearch host and port if they are not running locally.
        - The beat.name value generated for all filebeat documents. This will be used to identify the source of the Filebeat data. By default this is set to `test` and can be changed through the configuration parameter `name`.

* Copy the modified `filebeat.yml` file to the root installation folder of the Filebeat installation, overwriting the default file i.e.

    ```
    cp filebeat.yml <path_to_filebeat_installation>/filebeat.yml
    cp twitter.json <path_to_filebeat_installation>/twitter.json
    ```

* Start filebeat as described [here](https://www.elastic.co/guide/en/beats/filebeat/5.4/filebeat-starting.html).

* Test Filebeat is indexing the data by running the following commands.

    ```
    curl localhost:9200/twitter-*/_refresh -u elastic:changeme
    curl localhost:9200/twitter-*/_count -u elastic:changeme
    ```

    When indexing is complete last command should return a count of 3563, thus indicating tweets have been indexed (this should take a few mins) i.e.

    ```
    {"count":3563,"_shards":{"total":2,"successful":2,"failed":0}}
    ```

### Example 2 - Self Collection

If collecting your own twitter data, it is recommend a minimum of 1 week per topic is indexed prior to running any machine learning jobs. This value is subject to the specific topic - some obviously generate more traffic than others.  To take advantage of any seasonal trend detection larger quantities will be required.

* [Download and Install Logstash](https://www.elastic.co/guide/en/logstash/current/installing-logstash.html). **Do not start Logstash**.

* Download the provided Logstash configuration file and twitter ES template.

    ```
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Business%20Metrics%20recipes/twitter_trends/configs/logstash/logstash.conf
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Business%20Metrics%20recipes/twitter_trends/configs/templates/twitter.json
    ```

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
    add_field => { "fields.topic" => "super_heroes" }
  }
}
```

Note: Notice how above we add the field `topic` to the data.  This configuration effectively proposes a twitter input per topic the user wishes to index.  Filters which add the topic field based on the contents of the tweet maybe preferable in cases of a large number of topics.

* Execute the following command to start ingesting tweets of interest into Elasticsearch. Since this example is a monitoring Twitter in real time, the tweet ingestion volume will depend on the popularity of the words being tracked. When you run the above command, you should see a trail of dots (`...`) in your shell as new tweets are ingested.

  ```shell
   <path_to_logstash_root_dir>/bin/logstash -f logstash.conf
  ```

* Verify that data is successfully indexed into Elasticsearch

  Running `http://localhost:9200/twitter_example/_count` should show a positive response for `count`.

  **Note:** Included `logstash.conf` configuration file assumes that you are running Elasticsearch on the same host as   Logstash and have not changed the defaults. Modify the `host` and `cluster` settings in the `output { elasticsearch { ... } }`   section of `twitter_logstash.conf`, if needed.


## Load the Recipe

Download the following files to the same directory:

  ```
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Business%20metrics%20recipes/twitter_trends/machine_learning/data_feed.json
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Business%20metrics%20recipes/twitter_trends/machine_learning/job.json
    curl -O https://github.com/elastic/examples/blob/master/Machine%20Learning/Business%20metrics%20recipes/scripts/reset_job.sh
  ```


* Load the Job by running the supplied reset_job.sh script.

```
    ./reset_job.sh twitter_trends
```

This script assumes the default Elasticsearch host, port, user and password. To supply alternatives, supply as arguments e.g.

```
    ./reset_job.sh twitter_trends <host_port> <username> <password>
```

* Access Kibana by going to http://localhost:5601 in a web browser

* Select "machine learning" from the left tab. This should list the "Twitter Trends" job e.g.

[http://localhost:5601/app/ml#/jobs?_g=()](http://localhost:5601/app/ml#/jobs?_g=())

![ML Job Listing Screenshot](https://user-images.githubusercontent.com/12695796/27547794-f4714b9a-5a8e-11e7-8f86-ccfe940a811c.png)

## Run the Recipe

To start the machine learning job, either:

1. issue the following command to the ML API

        ```
        curl -s -X POST localhost:9200/_xpack/ml/datafeeds/datafeed-twitter_trends/_start -u elastic:changeme
        ```  
    **OR**
1. Click the `>` icon for the job in the UI, followed by `Start`.


## View Results

On completion of the job execution navigate to the explorer results view for the job. Example anomalies are shown below.
More specifically this shows the spike in #APM activity around the announcment of Elastic's opbeat acquisition. Additional activity highlights the WebRTCSummit summit in Santa Clara. 

![Example Explorer View for Twitter Trends](https://user-images.githubusercontent.com/12695796/27547566-5a5e0dfe-5a8e-11e7-9649-fb9758dd941a.png)
