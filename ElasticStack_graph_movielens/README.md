## Using Graph to Analyze Movie Ratings to Produce Recommendations

This example demonstrates how to use the Elastic Stack to analyze entity centric data for the purpose of producing recommendations - specifically the Graph plugin is used to produce recommendations for movie ratings. 
This dataset is provided with the permission of GroupLens Research and originates from data collected by [MovieLens](https://movielens.org) .  Further license details can be found [here](http://files.grouplens.org/datasets/movielens/ml-20m-README.html). 

This dataset provides the following:

1. A list of movies with an identifying id and genre/s.
2. A list of movie rating - each consisting of a user id, movie id and score of 1-5 (1 = dislike, 5 = liked).

In order for graph to be effective on this data set, it requires an entity centric structure where each user represents an entity.  Each user entity document in turn requires a list of the films liked, structure as a multi-value field.  
This structure allows Graph to explore the connections in data using the relevance statistics available in Elasticsearch. 

The demo aims to provide movie suggestions based on a user liking existing films. Rather than simply suggest movies which are universally popular e.g. Star Wars, and thus represent super connections, 
Graph aims to identify those films which are relevant to the user based on their previous preferences by exploiting the "wisdom of crowds" properties within the data set i.e. User A liked the Film "Rocky". Other users who liked "Rocky" also statistically liked "Rambo".

### Versions and Pre-requisites

Example has been tested in following versions:

- Elasticsearch 5.0
- X-Pack 5.0
- Kibana 5.0
- Python 3.x

### Installation & Setup

* Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the elastic stack (*you can skip this step if you already have a working installation of the Elastic stack*)

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


The following assumes the default username and password of "elastic" and "changeme".  These can be changed as detailed [here](https://www.elastic.co/guide/en/shield/current/native-realm.html).  If changed, ensure the Python Script file is updated accordingly to permit ingestion.

* Check that Elasticsearch and Kibana are up and running.
  - Open `localhost:9200` in web browser and authenticate with "elastic" and "changeme" -- should return status code 200
  - Open `localhost:5601` in web browser -- should display Kibana UI.

  **Note:** By default, Elasticsearch runs on port 9200, and Kibana run on ports 5601. If you changed the default ports, change   the above calls to use appropriate ports.

### Download & Ingest Data
 
  The following details the required steps:
  
1. Download the contents of this folder <br>
    
    - `download_data.py` - Python script to download the raw files.
    - `index_users.py` - Python script to index the raw files in an appropriate entry centric structure ie. a document per user.
    - `movie_lens.json` contains mapping for Elasticsearch index
    - `requirements.txt` - Python dependencies for above script
    - `index_ratings.py` - Python script to index the raw files in an event based structure i.e. a document per rating.
    
2. Setup Python environment

    Requires Python 3.  Install dependencies with pip i.e. `pip install -r requirements.txt`
    
3. Download the raw data from the [grouplens](http://grouplens.org/datasets/movielens/) website either [manually](http://files.grouplens.org/datasets/movielens/ml-20m.zip) or using the script `download_data.py`.  The script automatically extracts the zip into a sub folder `./data`.  The subsequent indexing
   script relies on this structure, so replicate if downloading the file manually.

    ```
      python3 download_data.py
    ```

4. Index the data using script provided. Caution: This script will **delete** the `movie_lens_users` on each execution prior to creating and indexing the data.  
    This script indexes the data in an entity centric structure i.e. one document per user.  Each document contains a list of the films "liked" by the user - a rating >= 4 has been used as the min score to denote the user has enjoyed the film.
 
    ```
      python3 index_users.py
    ```
   
5. Check data availability. Once the index is indexed you can check to see if all the data is available in Elasticsearch. You should get a `count` of `138493` when you run the following command (assumes default user).

    ```shell
    curl -XGET localhost:9200/movie_lens_users/_count -d '{"query": {"match_all": {}}}' -u elastic:changeme
    ```

### Configure Kibana for Index
  
  * Access Kibana by going to `http://localhost:5601` in a web browser
  * Connect Kibana to the `movie_lens_users` index in Elasticsearch
      * Click the **Management** tab >> **Index Patterns** tab >> **Create New**. Specify `movie_lens_users` as the index pattern name, ensuring **Index contains time-based events** is **not** selected, and click **Create** to define the index pattern.
  * Open graph
      * Click on **Graph** tab.
      
### Explore Recommendations
    
   * Select index `movie_lens_users` in the upper left. 
   * Add the field `liked` as graph nodes using the (+) icon.  Select an appropriate icon/colour for the node types. 
   * Search for a movie e.g. `Rocky`. Expand nodes to see recommendations for each film.  Try turning off **Settings** >> **Significant Links** to see the impact on recommendations.

The following illustrates a search for `Rocky`, using default Graph settings,movie followed by a series of selective node expansions.  

  ![Graph Screenshot](https://raw.githubusercontent.com/elastic/examples/master/ElasticStack_graph_movielens/movie_lens_graph.jpg)

### Data Insights - Structure, Challenges and Areas for Exploration

## Structure
In addition to the field "liked", the script produces a list of complementary fields including:

* all_rated - all films rated by the user
* indifferent - films the user considered "indifferent" i.e. rating > 2 && < 4.
* disliked - films disliked by the user i.e. rating <= 2.
* genres - list of genres watched by the user.
* liked_genres - list of genres liked by the user
* all_years - a list of the film years reviewed by the user - one entry per film reviewed.
* liked_years - film years liked by the user (years where the film was rated >= 4). 
* most_liked_yr - year most liked the by the user. Useful for diversification - see below.
   
Try using the above as nodes in the graph exploration..what insights can you find?

The script `index_ratings.py` allows the reader to index the data in a more traditional event based structure for analysis.  This creates a document per rating with details of the user, movie and score assigned.

## Challenges
   
You may notice recommendations cluster around common dates with an obvious bias towards more recent films. This maybe caused by a number of factors, including but not limited to:

* Users tend to watch and review more recent films. This "date clustering" is more pronounced on more recent reviews.  
* More recent films are typically reviewed more favourably - especially "blocker blusters".
* More recent films are reviewed more often and thus inherently have more connections, resulting in their bias in recommendations.
* The data set is inherently biased due to the method of data collection. MovieLens encourages users to select categories or genres of films in which they are interested, in order to assist recommeding content.  
The result is a "clustering" effect in the data set where users only review the films in which they are interested. We are basing recommendations on recommendations!

By indexing the data in an event based structure into the index `movies_lens_ratings`, using the script `index_ratings.py`, we are able to illustrate the some of the above hypothesise.
    
    
    
Multiple techniques to be used to improve recommendations, including but not limited to:

* Diversification - Graph provides the ability to diversify recommendations based on a field.  Consider diversifying on the user document's `most_liked_yr` field via **Settings** >> **Diversity Field**. This aims to avoid samples being dominated by a single "voice". What impact does this have on recommendations?
Increasing the value should consider more documents with the same date field, thus resulting in less diversification and more recommendations from the same year.  This may negatively impact recommendations and should be explored.
* Baseline scores - Beyond the scope of this example, but consider techniques to adjust ratings prior to ingestion to overcome systematic tendencies or some users to give higher ratings than others, and for some
movies to receive higher ratings than others e.g. http://www.netflixprize.com/assets/GrandPrize2009_BPC_BellKor.pdf
    
## Areas for Exploration    

Ideas for exploration:

* Try selecting multiple nodes and expanding the graph - to replicate users who would of liked more than one film.  Can you guide the recommendations to your taste?
* Consider exploring multiple leaps - these may not represent immedidately associated items but more "friends of friends" preferences.
 
### Using the API    

### We would love to hear from you!

If you run into issues running this example or have suggestions to improve it, please use Github issues to let us know. Have an easy fix? Submit a pull request. We will try our best to respond in a timely manner!

Have you created interesting examples using the Elastic Stack? Looking for a way to share your amazing work with the community? We would love to include your awesome work here. For more information on how to contribute, check out the **[Contribution](https://github.com/elastic/examples#contributing)** section!
