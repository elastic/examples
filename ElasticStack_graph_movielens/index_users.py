import csv
from collections import deque

import elasticsearch
from elasticsearch import helpers

es = elasticsearch.Elasticsearch(http_auth=('elastic', 'changeme'))
movies_file = "./data/movies.csv"
ratings_file = "./data/ratings.csv"
mapping_file = "movie_lens.json"

def read_movies(filename):
    movie_dict = dict()
    with open(filename, encoding="utf-8") as f:
        f.seek(0)
        for x, row in enumerate(csv.DictReader(f, delimiter=',' ,quotechar='"' ,quoting=csv.QUOTE_MINIMAL)):
            movie_dict[row["movieId"]]={'title':row['title'],'genres':row['genres'].split('|')}
    return movie_dict

def read_users(filename,movies):
    with open(filename, encoding="utf-8") as f:
        f.seek(0)
        num_users=0
        user = {"userId":1,"liked":[],"disliked":[],"indifferent":[],"all_rated":[]}
        for x, row in enumerate(csv.DictReader(f, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)):
            title = movies[row["movieId"]]["title"]
            rating = float(row["rating"])
            if not int(row["userId"]) == user["userId"]:
                yield user
                num_users+=1
                if num_users % 10000 == 0:
                    print("Indexed %s users"%(num_users))
                user.clear()
                user["userId"] = int(row["userId"])
                user["liked"]=[]
                user["disliked"]=[]
                user["indifferent"]=[]
                user["all_rated"]=[]
            user["all_rated"].append(title)
            user["liked"].append(title) if rating >= 4.0 else (
            user["indifferent"].append(title) if rating > 2.0 else user["disliked"].append(title))
        yield user

es.indices.delete(index="movie_lens_users",ignore=404)
es.indices.create(index="movie_lens_users", body=open(mapping_file,"r").read(), ignore=404)
print("Indexing users...")
deque(helpers.parallel_bulk(es,read_users(ratings_file,read_movies(movies_file)),index="movie_lens_users",doc_type="user"), maxlen=0)
print ("Indexing Complete")
es.indices.refresh()