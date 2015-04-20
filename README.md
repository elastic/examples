# Recipe Search - Simple

This sample application demonstrates:
* Creating new recipes and saving them in Elasticsearch
* Searching for recipes by keyword

## Demonstration

Visit TODO: add hosted app URL

## Running this on your own machine

1. Download and install PHP.

2. Download and unzip Elasticsearch.

   ```sh
   $ wget 'https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.5.1.zip'
   $ unzip elasticsearch-1.5.1.zip
   ```

3. Start one Elasticsearch node.

   ```sh
   $ cd elasticsearch-1.5.1
   $ ./bin/elasticsearch
   ```

   By default the node's REST API will be available at `http://localhost:9200`, unless port 9200 is already taken. In
   that case Elasticsearch will automatically choose another port. Read through the log messages emitted when you
   start the node, and look for a log message containing `http`. In this message, look for `bound_address` and note the
   port shown in the accompanying network address.

4. Download the code in this repo and unzip it.

   ```sh
   $ wget -O recipe-search-simple.zip 'https://github.com/ycombinator/recipe-search-simple/archive/master.zip'
   $ unzip recipe-search-simple.zip
   ```

5. Start the application using PHP's built-in web server.

   ```sh
   $ cd recipe-search-simple-master
   $ php -S localhost:8000
   ```

   By default this application will communicate with the Elasticsearch API at `http://localhost:9200`. If, in step 3, you
   noted a different port than 9200 being used, you will need to pass this information to the application when starting
   it up via an environment variable:

   ```sh
   $ APP_ES_NODE_PORT=<PORT> php -S localhost:8000
   ```

6. Open your web browser and visit [`http://localhost:8000`](http://localhost:8000).
