# Review data 
From https://github.com/ygokirmak/elasticsearch-entity-centric-demo

## Add data

```
python ReviewIndexer.py
```

Query data:

```
curl -XGET "http://localhost:9200/anonreviews/_search"
```

Results:

```
  "hits": {
    "total": 578805,
    "max_score": 1,
    "hits": [
      {
        "_index": "anonreviews",
        "_type": "review",
        "_id": "moIXi2IBff_K6KrBbZmg",
        "_score": 1,
        "_source": {
          "reviewerId": "7272",
          "vendorId": "5",
          "rating": 5,
          "date": "2006-05-25 16:23"
        }
      },
      {
        "_index": "anonreviews",
        "_type": "review",
        "_id": "m4IXi2IBff_K6KrBbZmg",
        "_score": 1,
        "_source": {
          "reviewerId": "67390",
          "vendorId": "5",
          "rating": 4,
          "date": "2006-05-25 16:20"
        }
      },
```

## Pivot Data

Example aggregate query:

```
curl -XGET "http://localhost:9200/anonreviews/_search" -H 'Content-Type: application/json' -d'
{
  "size": 0, 
  "aggs": {
    "reviewerId": {
      "terms": {
        "field": "reviewerId"
      },
      "aggs": {
        "avg_rating": {
          "avg": {
            "field": "rating"
          }
        },
        "dc_vendors": {
          "cardinality": {
            "field": "vendorId"
          }
        }
      }
    }
  }
}'
```

Results:

```
  "aggregations": {
    "reviewerId": {
      "doc_count_error_upper_bound": 0,
      "sum_other_doc_count": 577781,
      "buckets": [
        {
          "key": "4964",
          "doc_count": 168,
          "dc_vendors": {
            "value": 14
          },
          "avg_rating": {
            "value": 1.130952380952381
          }
        },
        {
          "key": "16494",
          "doc_count": 123,
          "dc_vendors": {
            "value": 32
          },
          "avg_rating": {
            "value": 4.991869918699187
          }
        },
```
