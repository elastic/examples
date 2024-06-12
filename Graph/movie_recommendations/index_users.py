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
        for x, row in enumerate(csv.DictReader(f, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)):
            movie = {'title':row['title'],'genres':row['genres'].split('|')}
            t = row['title']
            try:
                year = int((row['title'][t.rfind("(") + 1: t.rfind(")")]).replace("-", ""))
                if year <= 2016 and year > 1900:
                    movie['year'] = year
            except:
                pass
            movie_dict[row["movieId"]] = movie
    return movie_dict

def read_users(filename, movies):
    with open(filename, encoding="utf-8") as f:
        f.seek(0)
        num_users = 0
        user = {"userId": 1, "liked": [], "disliked": [], "indifferent": [], "all_rated": [], "all_years": [], "liked_years":[]}
        for x, row in enumerate(csv.DictReader(f, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)):
            title = movies[row["movieId"]]["title"]
            rating = float(row["rating"])
            genres = movies[row["movieId"]]["genres"]
            if not int(row["userId"]) == user["userId"]:
                if len(user["liked_years"]) > 0:
                    user["most_liked_yr"] = max(set(user["liked_years"]), key=user["liked_years"].count)
                #de-dupe years
                user["liked_years"]=list(set(user["liked_years"]))
                user["all_years"] = list(set(user["all_years"]))
                yield user
                num_users += 1
                if num_users % 10000 == 0:
                    print("Indexed %s users" % (num_users))
                user.clear()
                user["userId"] = int(row["userId"])
                user["liked"] = []
                user["disliked"] = []
                user["indifferent"] = []
                user["all_rated"] = []
                user["all_years"] = []
                user["liked_years"] = []
            user["all_rated"].append(title)
            if "year" in movies[row["movieId"]]:
                user["all_years"].append(movies[row["movieId"]]["year"])
                if rating >= 4.0:
                    user["liked_years"].append(movies[row["movieId"]]["year"])
            user["liked"].append(title) if rating >= 4.0 else (
            user["indifferent"].append(title) if rating > 2.0 else user["disliked"].append(title))
        yield user

index_name = "movie_lens_users"
doc_name="user"
es.indices.delete(index=index_name, ignore=404)
es.indices.create(index=index_name, ignore=404)

# Add mapping
with open('movie_lens.json') as json_mapping:
    d = json.load(json_mapping)
es.indices.put_mapping(index=index_name, doc_type=doc_name, body=d, include_type_name=True)

print("Indexing users...")
deque(helpers.parallel_bulk(es, read_users(ratings_file, read_movies(movies_file)), index=index_name, doc_type=doc_name), maxlen = 0)
print("Indexing Complete")
es.indices.refresh()
