import csv
from collections import deque
import statistics
import elasticsearch
import math
from elasticsearch import helpers

es = elasticsearch.Elasticsearch(http_auth=('elastic', 'changeme'))
movies_file = "./data/movies.csv"
ratings_file = "./data/ratings.csv"
mapping_file = "movie_lens.json"

def round_down(x):
    return int(math.floor(x / 10.0)) * 10

def get_decade(years):
    median_yr = statistics.median(years)
    popular_yr = max(set(years), key=years.count)
    decades = [round_down(year) for year in years]
    median_decade = statistics.median(decades)
    popular_decade = max(set(decades), key=decades.count)
    return median_yr,popular_yr,median_decade,popular_decade

def read_movies(filename):
    movie_dict = dict()
    with open(filename, encoding="utf-8") as f:
        f.seek(0)
        for x, row in enumerate(csv.DictReader(f, delimiter=',' ,quotechar='"' ,quoting=csv.QUOTE_MINIMAL)):
            t=row['title']
            movie={'title':t,'genres':row['genres'].split('|')}
            try:
                movie['year']=int((row['title'][t.rfind("(") + 1:t.rfind(")")]).replace("-", ""))
            except:
                pass
            movie_dict[row["movieId"]]=movie
    return movie_dict

def read_users(filename,movies):
    with open(filename, encoding="utf-8") as f:
        f.seek(0)
        num_users=0
        user = {"userId":1,"liked":[],"disliked":[],"indifferent":[],"all_rated":[],"years":[]}
        for x, row in enumerate(csv.DictReader(f, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)):
            title = movies[row["movieId"]]["title"]
            rating = float(row["rating"])
            if not int(row["userId"]) == user["userId"]:
                median_yr, popular_yr, median_decade, popular_decade=get_decade(user["years"])
                user["median_yr"]=median_yr
                user["popular_yr"]=popular_yr
                user["median_decade"] = median_decade
                user["popular_decade"]=popular_decade
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
                user["years"]=[]
            user["all_rated"].append(title)
            if "year" in movies[row["movieId"]]:
                user["years"].append(movies[row["movieId"]]["year"])
            user["liked"].append(title) if rating >= 4.0 else (
            user["indifferent"].append(title) if rating > 2.0 else user["disliked"].append(title))
        yield user

index="movie_lens_users"
doc_type="user"
es.indices.delete(index=index,ignore=404)
es.indices.create(index=index, body=open(mapping_file,"r").read(), ignore=404)
print("Indexing users...")
deque(helpers.parallel_bulk(es, read_users(ratings_file, read_movies(movies_file)), index=index, doc_type=doc_type), maxlen=0)
print ("Indexing Complete")
es.indices.refresh()