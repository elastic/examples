import csv
from collections import deque
import elasticsearch
import string
from elasticsearch import helpers

es = elasticsearch.Elasticsearch(http_auth=('elastic', 'changeme'))
books_file = "./data/BX-Books.csv"
mapping_file="book_crossing.json"
ratings_file="./data/BX-Book-Ratings.csv"



def read_books(filename):
    book_dict = dict()
    translator = str.maketrans({key: None for key in string.punctuation})
    with open(filename, encoding="iso-8859-1") as f:
        f.seek(0)
        for x, row in enumerate(csv.DictReader(f, delimiter=';' ,quotechar='"' ,quoting=csv.QUOTE_ALL)):
            book_dict[row["ISBN"]]={'title':row['Book-Title'].translate(translator).lower(),'author':row['Book-Author']}
    return book_dict

def read_ratings(filename, books):
    with open(filename, encoding="iso-8859-1") as f:
        f.seek(0)
        num_users=0
        user = {"userId":276725,"liked":[],"disliked":[],"indifferent":[],"implicit":[],"authors":set()}

        for x, row in enumerate(csv.DictReader(f, delimiter=';', quotechar='"', quoting=csv.QUOTE_ALL)):
            if row["ISBN"] in books:
                title = books[row["ISBN"]]["title"]
                rating = int(row["Book-Rating"])
                author = books[row["ISBN"]]["author"]
                if not int(row["User-ID"]) == user["userId"]:
                    user["authors"]=list(user["authors"])
                    yield user
                    num_users+=1
                    if num_users % 10000 == 0:
                        print("Indexed %s users"%(num_users))
                    user.clear()
                    user["userId"] = int(row["User-ID"])
                    user["liked"]=[]
                    user["disliked"]=[]
                    user["implicit"]=[]
                    user["indifferent"]=[]
                    user["authors"]=set()
                user["authors"].add(author)
                user["liked"].append(title) if rating >= 7.0 else (
                user["indifferent"].append(title) if rating >= 4.0 else (user["disliked"].append(title) if rating > 0 else user["implicit"].append(title)))
        print("Final User: %s"%user["userId"])
        num_users+=1
        yield user
        print("Indexed %s users"%num_users)

es.indices.delete(index="book_crossing_users",ignore=404)
es.indices.create(index="book_crossing_users", body=open(mapping_file,"r").read(), ignore=404)
print("Indexing users...")
deque(helpers.parallel_bulk(es, read_ratings(ratings_file, read_books(books_file)), index="book_crossing_users", doc_type="user"), maxlen=0)
print ("Indexing Complete")
es.indices.refresh()