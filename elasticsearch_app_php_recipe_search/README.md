# Recipe Search

This sample application demonstrates:
* Searching for recipes by keywords, *and*
* Creating new recipes and saving them in Elasticsearch

![Screenshot of search page](http://i.snag.gy/quVui.jpg)

This sample application deliberately uses plain PHP code (that is, no PHP frameworks), a little bit of 
[Bootstrap CSS](http://getbootstrap.com/css/) and even less [jQuery](https://jquery.com/). These minimalist choices
are deliberate. We want to keep non-Elasticsearch-related code to a minimum so it as easy as possible to focus on the
Elasticsearch-related code in this application.

## Running this on your own machine

1. Download and install PHP 7.0.

2. Download and unzip Elasticsearch.

* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the Elastic Stack (*you can skip this step if you have a working installation of the Elastic Stack*).  Additionaly for this demo there is no requirement to install either Kibana or Logstash.

* Run Elasticsearch
  ```shell
    <path_to_elasticsearch_root_dir>/bin/elasticsearch
    ```

* Check that Elasticsearch is up and running.
  - Open `localhost:9200` in web browser -- should return status code 200

  **Note:** By default, Elasticsearch runs on port 9200. If you changed the default ports during installation, change the above calls to use appropriate ports.


3. Download the code in this repo and unzip it.

   ```sh
   $ wget -O elastic-demo.zip 'https://github.com/elastic/demo/archive/master.zip'
   $ unzip elastic-demo.zip
   $ mv demo-master/recipe_search .
   $ rm -rf demo-master elastic-demo.zip
   $ cd recipe_search
   ```

4. Install application dependencies.

   ```sh
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
  * `js/` &mdash; *contains the jQuery and this project's Javascript files*
  * `add.php` &mdash; *script to add a new recipe to Elasticsearch*
  * `index.php` &mdash; *script to search for recipes in Elasticsearch*
  * `view.php` &mdash; *script to view a recipe from Elasticsearch*
* `composer.json` &mdash; *file describing application dependencies, including the [Elasticsearch PHP language client](http://www.elastic.co/guide/en/elasticsearch/client/php-api/current/index.html)*
