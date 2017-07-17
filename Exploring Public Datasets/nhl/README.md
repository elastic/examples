# NHL Play by Play -> Elasticsearch

Supporting example for the blog post [Kibana and a Custom Tile Server for NHL Data](https://www.elastic.co/blog/kibana-and-a-custom-tile-server-for-nhl-data).

This examples downloads data from live.nhl.com.  E.g http://live.nhl.com/GameData/20142015/2014021136/PlayByPlay.json, indexing it into Elasticsearch. Prepared dashboards are provided with the example, along with [instructions](https://github.com/elastic/examples/blob/master/Exploring%20Public%20Datasets/nhl/geo-arena/README.md) on geo-referencing the TIFF image described in the blog post.

## Version Requirements

The example has been tested against the following versions:

- Elasticsearch 5.0.0
- Logstash 5.0.0
- Kibana 5.0.0
- NodeJS

## Datasets

Datasets are collected from http://live.nhl.com.

Imports it into Elasticsearch by season or by game.

## Installation & Setup

- Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the Elastic Stack (*you can skip this step if you have a working installation of the Elastic Stack,*)

- Run Elasticsearch & Kibana

    ```shell
    <path_to_elasticsearch_root_dir>/bin/elasticsearch
    <path_to_kibana_root_dir>/bin/kibana
    ```

- Check that Elasticsearch and Kibana are up and running.
  - Open `localhost:9200` in web browser -- should return status code 200
  - Open `localhost:5601` in web browser -- should display Kibana UI.

**Note:** By default, Elasticsearch runs on port 9200, and Kibana run on ports 5601. If you changed the default ports, change   the above calls to use appropriate ports.

Download the following files:

```
    https://raw.githubusercontent.com/elastic/examples/master/Exploring%20Public%20Datasets/nhl/clean.sh
    https://raw.githubusercontent.com/elastic/examples/master/Exploring%20Public%20Datasets/nhl/go.js
```

##  Ingest Data

1. Run `npm install`
2. Run `./clean.sh` to erase any previous data and re-prepare the index (shows an error the first time it runs, that's ok)
3. Run `node go.js` to importing data as shown below
    
    Usage:
    ```
    node go.js <season> [gameid]
    ```
    
    Example, Import the whole 2014-2015 season:
    ```
    node go.js 2014
    ```
    
    Example, Import a specific game (once you know the id).  This is specific for updating real time during a game.
    ```
    node go.js 2014 2014030416

## Check data availability

Once the index is created using either of the above options, you can check to see if all the data is available in Elasticsearch. If all goes well, you should get a positive `count` response when you run the following command.

  ```shell
  curl -H "Content-Type: application/json" -XGET localhost:9200/nhl/_count -d '{
  	"query": {
  		"match_all": {}
  	}
  }'
  ```

## Visualize Data in Kibana

* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `nhl` index in Elasticsearch
    * Click the **Settings** tab >> **Indices** tab >> **Create New**. Specify `nhl` as the index pattern name, select `@timestamp` as the **Time-field name**, and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked)
* Load sample dashboard into Kibana
    * Click the **Settings** tab >> **Objects** tab >> **Import**, and select `dashboards.json`
* Open dashboard
    * Click on **Dashboard** tab and open `NHL` dashboard. Voila! You should see the following dashboard. Happy Data Exploration!

Top Hitters, Shooters, Scorers & Penalties per Game
![Kibana Dashboard Screenshot](https://github.com/elastic/examples/tree/master/Exploring%20Public%20Datasets/nhl/game.png?raw=true)

All Season Top Hitters, Shooters, and Scorers against the Habs
![Kibana Dashboard Screenshot](https://github.com/elastic/examples/tree/master/Exploring%20Public%20Datasets/nhl/against.png?raw=true)

### We would love to hear from you!

If you run into issues running this example or have suggestions to improve it, please use Github issues to let us know. Have an easy fix? Submit a pull request. We will try our best to respond in a timely manner!

Have you created interesting examples using the Elastic Stack? Looking for a way to share your amazing work with the community? We would love to include your awesome work here. For more information on how to contribute, check out the **[Contribution](https://github.com/elastic/examples#contributing)** section!

