import argparse
import random
from elasticsearch import Elasticsearch
from elasticsearch.helpers import streaming_bulk

lat_lower = 9.0
lat_upper = 18.0
lon_upper = 41.0
lon_lower = 12.0


parser = argparse.ArgumentParser()
parser.add_argument("--es_host", default="localhost:9200", help="ES Connection String")
parser.add_argument("--es_user", default="elastic", help="ES User")
parser.add_argument("--es_password", default="changeme", help="ES Password")
parser.add_argument("--num_centroids", default=10, type=int, help="Number of Centroids")
parser.add_argument("--min_per_centroid", default=10, type=int, help="Min doc per centroid")
parser.add_argument("--max_per_centroid", default=5000, type=int, help="Max doc per centroid")

options = parser.parse_args()

mapping = {
  "mappings": {
    "point": {
      "properties": {
        "location": {
          "type": "geo_point"
        }
      }
    }
  },
  "settings": {
      "index": {
        "number_of_shards": "1",
        "number_of_replicas": "0",
        "refresh_interval":"1s"
      }
    }
}

def generate_documents(num_centroids,min_docs,max_docs):
    for i in range(num_centroids):
        print("Producing docs for centroid %s"%i)
        lat =  random.uniform(lat_lower,lat_upper)
        lon = random.uniform(lon_lower,lon_upper)
        num_docs = random.randint(min_docs,max_docs)
        print("%s docs in centroid %s"%(i,num_docs))
        for i in range(num_docs):
            yield {
                "location":{
                    "lat":lat,
                    "lon":lon
                }
            }

es = Elasticsearch(hosts=[options.es_host], http_auth = (options.es_user, options.es_password))
if es.indices.exists("elastic_on_simple"):
    es.indices.delete("elastic_on_simple")
es.indices.create("elastic_on_simple",body=mapping)

cnt = 0
print("Indexing docs for %s centroids"%options.num_centroids)
for _ in streaming_bulk(
        es,
        generate_documents(options.num_centroids,options.min_per_centroid,options.max_per_centroid),
        chunk_size=1,
        doc_type='point',
        index='elastic_on_simple'
):
    cnt += 1
    if cnt % 1000 == 0:
        print("Indexed %s"%cnt)
print("Indexed %s"%cnt)
