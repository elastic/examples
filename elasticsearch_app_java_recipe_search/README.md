# Elastic Recipe Search

This sample application demonstrates:
* Indexing recipes using the Java Client API *and*
* Using the Java Client API to searching for recipes by keywords


![Screenshot of search page](https://snag.gy/GqMvDB.jpg)

A simple recipe search UI constructed with Servlets, HTML, CSS, Javascript, JQuery Bootstrap, Bootstrap Table all served up from an embedded Jetty web server. 

Uses an IntelliJ developer environment to assist with getting familiar with Elasticsearch Java Client APIs.


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

3. Download and install IntelliJ IDEA (https://www.jetbrains.com/idea/download/#section=mac).

4. Clone the elastic/examples repo.

5. Start IntelliJ and Import project elastic/examples/elasticsearch_app_java_recipe_search and select all defaults (hit next).

6. Seed Elasticsearch index with initial recipe data. In IntelliJ Run the file IndexRecipesApp located in srs/main/java/com/elastic/recipe.

7. In IntelliJ Run the file SearchRecipesApp located in sr/main/java/com/elastic/recipe.
   
8. Open your web browser and visit [`http://localhost:8080/recipe/recipes.html`](http://localhost:8080/recipe/recipes.html).
