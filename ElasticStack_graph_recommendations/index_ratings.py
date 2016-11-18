import csv
import elasticsearch
from elasticsearch import helpers

es = elasticsearch.Elasticsearch(http_auth=('elastic', 'changeme'))
movies_file = "./data/movies.csv"
ratings_file = "./data/ratings.csv"
mapping_file = "ratings.json"

def readMovies(filename):
    movie_dict = dict()
    with open(filename, encoding="utf-8") as f:
        f.seek(0)
        for x, row in enumerate(csv.DictReader(f, delimiter=',' ,quotechar='"' ,quoting=csv.QUOTE_MINIMAL)):
            movie_dict[row["movieId"]]={'title':row['title'],'genres':row['genres'].split('|')}
    return movie_dict

def readRatings(filename,movies):
    with open(filename, encoding="utf-8") as f:
        f.seek(0)
        for x, row in enumerate(csv.DictReader(f, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)):
            row.update(movies[row["movieId"]])
            yield row

es.indices.create(index="movie_lens", body=open(mapping_file,"r").read(), ignore=404)

for success, info in  helpers.bulk(es,readRatings(ratings_file,readMovies(movies_file)),index="movie_lens",doc_type="rating"):
    if not success:
        print('A document failed:', info)


es.indices.refresh()