import csv
from collections import deque
import elasticsearch
from elasticsearch import helpers
import json

#Change if not using default credentials
es = elasticsearch.Elasticsearch(http_auth=('elastic', 'changeme'))
movies_file = "./data/ml-25m/movies.csv"
ratings_file = "./data/ml-25m/ratings.csv"
mapping_file = "movie_lens.json"

def read_movies(filename):
    movie_dict = dict()
    with open(filename, encoding="utf-8") as f:
        f.seek(0)
        for x, row in enumerate(csv.DictReader(f, delimiter=',' ,quotechar='"' ,quoting=csv.QUOTE_MINIMAL)):
            movie={'title':row['title'],'genres':row['genres'].split('|')}
            t = row['title']
            try:
                year = int((row['title'][t.rfind("(") + 1: t.rfind(")")]).replace("-", ""))
                if year <= 2016 and year > 1900:
                    movie['year'] = year
            except:
                pass
            movie_dict[row["movieId"]]=movie
    return movie_dict

def read_ratings(filename,movies):
    with open(filename, encoding="utf-8") as f:
        f.seek(0)
        num_ratings=0
        for x, row in enumerate(csv.DictReader(f, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)):
            row.update(movies[row["movieId"]])
            num_ratings += 1
            if num_ratings % 100000 == 0:
                print("Indexed %s ratings" % (num_ratings))
            yield row

index_name="movie_lens_ratings"
doc_name="rating"
es.indices.delete(index=index_name, ignore=404)
es.indices.create(index=index_name, ignore=404)

# Add mapping
with open('movie_lens.json') as json_mapping:
    d = json.load(json_mapping)
es.indices.put_mapping(index=index_name, doc_type=doc_name, body=d, include_type_name=True)

print("Indexing ratings...")
deque(helpers.parallel_bulk(es, read_ratings(ratings_file, read_movies(movies_file)), index=index_name, doc_type=doc_name), maxlen=0)
print ("Indexing Complete")
es.indices.refresh()
