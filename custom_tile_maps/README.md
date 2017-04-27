## Custom Tile Map

This example provides supporting files for the blog post [Operational Analytics at ElasticON 2017 - Part 2](https://elastic.co/blog/operational-analytics-at-elasticon-2017-part-2).  This blog post describes the steps for creating a custom tile map for rendering in Kibana e.g. A server room.

### Contents

The files including in this folder include:

* [elastic{ON}_simplified.svg](https://github.com/elastic/examples/blob/master/custom_tile_maps/elastic%7BON%7D_simplified.svg) - A simplified svg for the Elastic{ON} floor plan. This svg is used in the blog post.
* [styles](https://github.com/elastic/examples/tree/master/custom_tile_maps/styles) - A folder of styles for the sample layers created in the blog post.
* [shape_files](https://github.com/elastic/examples/tree/master/custom_tile_maps/shape_files) - A folder of shape files representing the layers created in the blog post. Allows the reader to skip step 1.
* [generate_random_data.py](https://github.com/elastic/examples/blob/master/custom_tile_maps/generate_random_data.py) - A script to generate random data for the floor plan. See below for further details.
* [elastic{ON}_full_floor_plan.pdf](https://github.com/elastic/examples/blob/master/custom_tile_maps/elastic%7BON%7D_full_floor_plan.pdf) - A full pdf of the Elastic{ON} floor plan. This can be used to reproduce the demo at Elastic{ON}. This includes a style tablet.

### Data Generator

The script [generate_random_data.py](https://github.com/elastic/examples/blob/master/custom_tile_maps/generate_random_data.py) allows random data to be generated for the floor plan. By creating document clusters, with a random number of documents, the script aims to produce a range of data clusters for the tile map. Improvements welcome.

#### Version Requirements

The example has been tested in the following versions (earlier versions may work but have not been tested):

- Elasticsearch 5.3.0 or greater 
- Python 3.5.x

#### Python dependencies

See [requirements.txt](https://github.com/elastic/examples/blob/master/custom_tile_maps/requirements.txt). Install via pip e.g. `pip install -r requirements.txt`

#### Script options

This script accepts the following **optional** parameters:

* `es_host` - Elasticsearch host and port. Defaults to `localhost:9200`
* `es_user` - Elasticsearch user if X-Pack is installed with basic auth (https not supported). Defaults to `elastic`.
* `es_password` - Elasticsearch password if X-Pack is installed with basic auth (https not supported). Defaults to `changeme`.
* `num_centroids` - Number of clusters/centroids to generate on the floor plan i.e. sources of datapoints. Defaults to `10`.
* `min_per_centroid` - Minimum docs per centroid. Defaults to 10.
* `max_per_centroid` - Maximum docs per centroid. Defaults to 5000.

#### Example

`python generate_random_data.py --es_host localhost:9200 --es_user elastic --es_password changeme --num_centroids 20 -- 0 --max_per_centroid 10000`
