# Introduction

This is a collection of examples to help you get familiar with the Elastic Stack. Each example folder includes a README with detailed instructions for getting up and running with the  particular example. The following information pertains to the [examples](https://github.com/elastic/examples) repo as a whole.

### Contents

- [Quick start](#quick-start)
- [Contributing](#contributing)
- [Example catalog](#example-catalog)

### Quick start

You have a few options to get started with the examples:

- If you want to try them all, you can [download the entire repo ](https://github.com/elastic/examples/archive/master.zip). Or, if you are familiar with Git, you can [clone the repo](https://github.com/elastic/examples.git). Then, simply follow the instructions in the individual README of the examples you're interested in to get started.

- If you are only interested in a specific example or two, you can download the contents of just those examples - follow instructions in the individual READMEs OR you can use some of the [options mentioned here](http://stackoverflow.com/questions/7106012/download-a-single-folder-or-directory-from-a-github-repo).

### Contributing

See [here](https://github.com/elastic/examples/blob/master/CONTRIBUTING.md)

### Example catalog

Below is the list of examples available in this repo:

#### Common Data Formats

- [Apache Logs](https://github.com/elastic/examples/tree/master/Common%20Data%20Formats/apache_logs)
- [NGINX Logs](https://github.com/elastic/examples/tree/master/Common%20Data%20Formats/nginx_logs)
- [NGINX JSON Logs](https://github.com/elastic/examples/tree/master/Common%20Data%20Formats/nginx_json_logs)
- [NGINX JSON Plus Logs](https://github.com/elastic/examples/tree/master/Common%20Data%20Formats/nginx_json_plus_logs)
- [Twitter](https://github.com/elastic/examples/tree/master/Common%20Data%20Formats/twitter)
- [CEF](https://github.com/elastic/examples/tree/master/Common%20Data%20Formats/cef)

#### Exploring Public Datasets

Examples using the Elastic Stack for analyzing public dataset.

- [DonorsChoose.org donations](https://github.com/elastic/examples/tree/master/Exploring%20Public%20Datasets/donorschoose)
- [NCEDC earthquakes data](https://github.com/elastic/examples/tree/master/Exploring%20Public%20Datasets/earthquakes)
- [NYC traffic accidents](https://github.com/elastic/examples/tree/master/Exploring%20Public%20Datasets/nyc_traffic_accidents)
- [US FEC campaign contributions](https://github.com/elastic/examples/tree/master/Exploring%20Public%20Datasets/usfec)
- [CDC health behavior survey](https://github.com/elastic/examples/tree/master/Exploring%20Public%20Datasets/cdc_nutrition_exercise_patterns)
- [NYC restaurant health grades](https://github.com/elastic/examples/tree/master/Exploring%20Public%20Datasets/nyc_restaurants)
- [NHL Match Data](https://github.com/elastic/examples/tree/master/Exploring%20Public%20Datasets/nhl)

#### Getting Started with Graph exploration

- [Exploring attack vectors in Apache logs using Graph](https://github.com/elastic/examples/tree/master/Graph/apache_logs_security_analysis)
- [Powering recommendation using Graph](https://github.com/elastic/examples/tree/master/Graph/movie_recommendations)

#### Alerting on Elastic Stack

Alerting lets you set up watches (or rules) to detect and alert on changes in your Elasticsearch data. Below is a list of examples watches that configured to detect and alert on a few common scenarios:

- [High I/O wait on CPU](https://github.com/elastic/examples/tree/master/Alerting/Sample%20Watches/cpu_iowait_hosts)
- [Critical error  in logs](https://github.com/elastic/examples/tree/master/Alerting/Sample%20Watches/errors_in_logs)
- [High filesystem usage](https://github.com/elastic/examples/tree/master/Alerting/Sample%20Watches/filesystem_usage)
- [Lateral movement in user communication](https://github.com/elastic/examples/tree/master/Alerting/Sample%20Watches/lateral_movement_in_user_comm)
- [Alerting on Machine Learning](https://github.com/elastic/examples/tree/master/Alerting/Sample%20Watches/ml_examples)
- [Monitoring Cluster Health](https://github.com/elastic/examples/tree/master/Alerting/Sample%20Watches/monitoring_cluster_health)
- [Monitoring Free Disk Space](https://github.com/elastic/examples/tree/master/Alerting/Sample%20Watches/monitoring_free_disk_space)
- [New process started on hosts](https://github.com/elastic/examples/tree/master/Alerting/Sample%20Watches/new_process_started)
- [Port scan detected](https://github.com/elastic/examples/tree/master/Alerting/Sample%20Watches/port_scan)
- [Interrupted log flow from hosts](https://github.com/elastic/examples/tree/master/Alerting/Sample%20Watches/system_fails_to_provide_data)
- [Trending hashtag on twitter](https://github.com/elastic/examples/tree/master/Alerting/Sample%20Watches/twitter_trends)
- [Unexpected account activity](https://github.com/elastic/examples/tree/master/Alerting/Sample%20Watches/unexpected_account_activity)
- [Watch history dashboard](https://github.com/elastic/examples/tree/master/Alerting/watcher_dashboard)
- [Alert on Large Shards](https://github.com/elastic/examples/tree/master/Alerting/Sample%20Watches/large_shard_watch)

#### Machine learning

- [Getting started tutorials](https://github.com/elastic/examples/tree/master/Machine%20Learning/Getting%20Started%20Examples)
- [IT operations recipes](https://github.com/elastic/examples/tree/master/Machine%20Learning/IT%20Operations%20Recipes)	
- [Security analytics recipes](https://github.com/elastic/examples/tree/master/Machine%20Learning/Security%20Analytics%20Recipes)
- [Business metrics recipes](https://github.com/elastic/examples/tree/master/Machine%20Learning/Business%20Metrics%20Recipes)

#### Search & API Examples

- [Recipe Search with Java](https://github.com/elastic/examples/tree/master/Search/recipe_search_java)
- [Recipe Search with PHP](https://github.com/elastic/examples/tree/master/Search/recipe_search_php)	

#### Security Analytics

- [Audit Analysis](https://github.com/elastic/examples/tree/master/Security%20Analytics/auditd_analysis)
- [CEF with Kafka](https://github.com/elastic/examples/tree/master/Security%20Analytics/cef_with_kafka)	
- [DNS Tunnel Detection](https://github.com/elastic/examples/tree/master/Security%20Analytics/dns_tunnel_detection)
- [Malware Analysis](https://github.com/elastic/examples/tree/master/Security%20Analytics/malware_analysis)	
- [SSH Analysis](https://github.com/elastic/examples/tree/master/Security%20Analytics/ssh_analysis)
- [Elastic SIEM at Home](https://github.com/elastic/examples/tree/master/Security%20Analytics/SIEM-at-Home)


#### Miscellaneous

- [Custom Tile Maps](https://github.com/elastic/examples/tree/master/Miscellaneous/custom_tile_maps)
- [Monitoring Kafka](https://github.com/elastic/examples/tree/master/Miscellaneous/kafka_monitoring)
- [Kibana with Geoserver](https://github.com/elastic/examples/tree/master/Miscellaneous/kibana_geoserver)
- [The ElasticStack on Docker](https://github.com/elastic/examples/tree/master/Miscellaneous/docker)
