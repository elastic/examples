Kibana Dashboard for Watcher
=====

If you are using [Watcher](https://www.elastic.co/products/watcher), this sample 
[Kibana](https://www.elastic.co/products/kibana) dashboard enables you to monitor the watch 
history and see visualizations of the watches that have executed over time. 

For more information about Watcher, see the 
[Watcher Reference](https://www.elastic.co/guide/en/watcher/current/index.html). For more 
information about Kibana, see the 
[Kibana User Guide](https://www.elastic.co/guide/en/kibana/current/index.html).

#Loading the Dashboard

To load the dashboard into Kibana:

1. Download the `watch_history_dashboard.json` file.
2. In Kibana, configure an index pattern for the watch history indices:
    1. Go to *Settings > Indices*.
    2. Select *Use event times to create index names*.
    3. Enter the index pattern `[.watch_history-]YYYY.MM.DD`.
    4. Select `trigger_event.triggered_time` as the time field.
    5. Click *Create*.
3. Go to *Settings > Objects*.
4. Click *Import* and select the downloaded dashboard file.








