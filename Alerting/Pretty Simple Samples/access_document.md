*** This watcher sample allows you to access content in first 5 hits.

```
{
  "trigger": {
    "schedule": {
      "interval": "30m"
    }
  },
  "input": {
    "search": {
      "request": {
        "search_type": "query_then_fetch",
        "indices": [
          "hotel"
        ],
        "types": [],
        "body": {
          "size": 5,
          "query": {
            "match_all": {}
          }
        }
      }
    }
  },
  "condition": {
    "compare": {
      "ctx.payload.hits.total": {
        "gte": 10
      }
    }
  },
  "actions": {
    "my-logging-action": {
      "logging": {
        "level": "info",
        "text": "{{ctx.payload.hits.hits.4._source}} and {{ctx.payload.hits.hits.4._source.country}} "
      }
    }
  }
}
```
