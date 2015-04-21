# Recipe Search - Simple

This sample application demonstrates:
* Searching for recipes by keywords, *and*
* Creating new recipes and saving them in Elasticsearch

![Screenshot of search page](../../blob/gh-pages/images/screenshot.png)

This application uses vanilla PHP (that is, no PHP frameworks) and minimal [Bootstrap CSS](http://getbootstrap.com/css/) to make things pretty. There is no Javascript in use either. These choices are deliberate to keep non-Elasticsearch-related code to a minimum and make it as easy as possible to focus on the Elasticsearch-related code in this application.

## Running this on your own machine

1. Download and install PHP.

1. Download and unzip Elasticsearch.

   ```sh
   $ wget 'https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.5.1.zip'
   $ unzip elasticsearch-1.5.1.zip
   ```

1. Start a 1-node Elasticsearch cluster.

   ```sh
   $ cd elasticsearch-1.5.1
   $ ./bin/elasticsearch # The process started by this command corresponds to a single Elasticsearch node
   ```

   By default the node's REST API will be available at `http://localhost:9200`, unless port 9200 is already taken. In
   that case Elasticsearch will automatically choose another port. Read through the log messages emitted when you
   start the node, and look for a log message containing `http`. In this message, look for `bound_address` and note the
   port shown in the accompanying network address.

1. Download the code in this repo and unzip it.

   ```sh
   $ wget -O recipe-search-simple.zip 'https://github.com/ycombinator/recipe-search-simple/archive/master.zip'
   $ unzip recipe-search-simple.zip
   ```

1. Install application dependencies.

   ```sh
   $ cd recipe-search-simple-master
   $ composer install
   ```

1. Seed Elasticsearch index with initial recipe data.

   ```sh
   $ php data/seed.php
   ```

1. Start the application using PHP's built-in web server.

   ```sh
   $ cd public
   $ php -S localhost:8000
   ```

   By default this application will communicate with the Elasticsearch API at `http://localhost:9200`. If, in step 3, you
   noted a different port than 9200 being used, you will need to pass this information to the application when starting
   it up via an environment variable:

   ```sh
   $ APP_ES_PORT=<PORT> php -S localhost:8000
   ```

1. Open your web browser and visit [`http://localhost:8000`](http://localhost:8000).

## Code Organization
The code in this project is organized as follows, starting at the root directory level (only relevant files and folders listed):

* `data/` &mdash; *contains seed data and loader script*
  * `seed.txt` &mdash; *contains seed data in [bulk index](http://www.elastic.co/guide/en/elasticsearch/guide/master/bulk.html) format*
  * `seed.php` &mdash; *script to load seed data*
* `public/` &mdash; *contains files served by web server*
  * `css/` &mdash; *contains the Bootstrap CSS file*
  * `add.php` &mdash; *script to add a new recipe to Elasticsearch*
  * `index.php` &mdash; *script to search for recipes in Elasticsearch*
* `composer.json` &mdash; *file describing application dependencies, including the [Elasticsearch PHP language client](http://www.elastic.co/guide/en/elasticsearch/client/php-api/current/index.html)*
