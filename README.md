# Recipe Search

This sample application demonstrates:
* Creating new recipes and saving them in Elasticsearch
* Searching for recipes by keyword

## Demonstration

Visit TODO: add hosted app URL

## Running this on your own machine

1. Download and install PHP.

2. Download and unzip Elasticsearch.

3. Start an Elasticsearch node.

   By default the node's REST API will be available at http://localhost:9200, unless port 9200 is already taken. In
   that case Elasticsearch will automatically choose another port. Read through the log messages emitted when you
   start the node, and look for a log message containing `http`. In this message, look for `bound_address` and note the
   port shown in the accompanying network address.

4. Download the code in this repo and unzip it.

    $ wget ''
    $ unzip 

5. Start the application using PHP's built-in web server.

    $ cd 
    $ php -S localhost:8000

   By default this application will communicate with the Elasticsearch API at http://localhost:9200. If, in step 3, you
   noted a different port than 9200 being used, you will need to pass this information to the application when starting
   it up via an environment variable:

    $ APP_ES_NODE_PORT=<PORT> php -S localhost:8000

6. Open your web browser and visit http://localhost:8000/index.php.
