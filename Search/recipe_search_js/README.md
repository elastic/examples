# Recipe Search with NodeJS

This sample application demonstrates:
* Indexing recipes using the NodeJS Client API *and*
* Using the NodeJS Client API to searching for recipes by keywords

## Running this on your own machine

1. Download and install Java Version 8.

2. Download and unzip Elasticsearch.

* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the Elastic Stack (*you can skip this step if you have a working installation of the Elastic Stack*).  Additionaly for this demo there is no requirement to install either Kibana or Logstash.

* Run Elasticsearch
  ```shell
    <path_to_elasticsearch_root_dir>/bin/elasticsearch
    ```

* Check that Elasticsearch is up and running.
  - Open `localhost:9200` in web browser -- should return status code 200

  **Note:** By default, Elasticsearch runs on port 9200. If you changed the default ports during installation, change the above calls to use appropriate ports.

3. Clone the elastic/examples repo.

4. Download [NodeJS] (https://nodejs.org/en/download/) 

5. Index our recipe sample data into Elasticsearch.

* Change directory to `Search/recipe_search_js/recipes`
  - Run using the command `npm start`

6. Start server side application.

* Change directory to `Search/recipe_search_js/server
  - Run using the command `npm start`

## TODO

* Server side API to query Elasticsearch
* Client side Angular to request data from API 
* Complete README

## Completed

* Code to index data into ES
* Server side skeleton