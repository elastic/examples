```
PUT _xpack/watcher/watch/my-watch1
{
  "trigger": {
    "schedule": {
      "interval": "30m"
    }
  },
  "input": {
    "http": {
      "request": {
        "scheme": "http",
        "host": "localhost",
        "port": 9200,
        "method": "get",
        "path": "/_nodes/stats/http",
        "params": {},
        "headers": {},
        "auth": {
          "basic": {
            "username": "elastic",
            "password" : "changeme"
          }
        }
      }
    }
  },
  "condition": {
    "compare": {
      "ctx.payload._nodes.failed": {
        "gte": 1
      }
    }
  },
  "actions": {
    "my-logging-action": {
      "logging": {
        "level": "info",
        "text": "There are {{ctx.payload._nodes.failed}} unresponsive nodes"
      }
    }
  }
}
```
```
POST _xpack/watcher/watch/my-watch1/_execute
```
