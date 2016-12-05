# Introduction

This is a collection of examples to help you get familiar with the Elastic Stack and X-Pack. Each example folder includes a README with detailed instructions for getting up and running with the  particular example. The following information pertains to the [examples](https://github.com/elastic/examples) repo as a whole.

### Contents

- [Quick start](#quick-start)
- [Contributing](#contributing)
- [Example catalog](#example-catalog)

### Quick start

You have a few options to get started with the examples:

- If you want to try them all, you can [download the entire repo ](https://github.com/elastic/examples/archive/master.zip). Or, if you are familiar with Git, you can [clone the repo](https://github.com/elastic/examples.git). Then, simply follow the instructions in the individual README of the examples you're interested in to get started.

- If you are only interested in a specific example or two, you can download the contents of just those examples (by following instructions in the individual READMEs or using this [extension] (https://github.com/charany1/GHSDD)).

### Contributing

See [here](https://github.com/elastic/examples/blob/master/CONTRIBUTING.md)

### Example catalog

Below is the list of examples available in this repo:

#### Getting Started with Elastic Stack:

- [NGINX - JSON](https://github.com/elastic/examples/tree/master/ElasticStack_NGINX-json)
- [NGINX - common format](https://github.com/elastic/examples/tree/master/ElasticStack_NGINX)
- [NGINX Plus - JSON](https://github.com/elastic/examples/tree/master/ElasticStack_NGINX)
- [Twitter](https://github.com/elastic/examples/tree/master/ElasticStack_twitter)
- [Apache access logs](https://github.com/elastic/examples/tree/master/ElasticStack_apache)
- [Simple recipe search app in PHP](https://github.com/elastic/examples/tree/master/elasticsearch_app_php_recipe_search)

#### Analyzing Public Datasets

Examples using the Elastic Stack for analyzing public dataset.
- [DonorsChoose.org donations](https://github.com/elastic/examples/tree/master/ElasticStack_donorschoose)
- [NCEDC earthquakes data](https://github.com/elastic/examples/tree/master/ElasticStack_earthquakes)
- [NYC traffic accidents](https://github.com/elastic/examples/tree/master/ElasticStack_nyc_traffic_accidents)
- [US FEC campaign contributions](https://github.com/elastic/examples/tree/master/ElasticStack_usfec)
- [CDC health behavior survey](https://github.com/elastic/examples/tree/master/ElasticStack_CDC_nutrition_exercise_patterns)
- [NYC restaurant health grades](https://github.com/elastic/examples/tree/master/kibana_nyc_restaurants)


#### Alerting on Elastic Stack

X-Pack lets you set up watches (or rules) to detect and alert on changes in your Elasticsearch data. Below is a list of examples watches that configured to detect and alert on a few common scenarios:

- [High I/O wait on CPU] (https://github.com/elastic/examples/tree/master/Alerting/cpu_iowait_hosts)
- [Critical error  in logs] (https://github.com/elastic/examples/tree/master/Alerting/errors_in_logs)
- [High filesystem usage] (https://github.com/elastic/examples/tree/master/Alerting/filesystem_usage)
- [Lateral movement in user communication] (https://github.com/elastic/examples/tree/master/Alerting/lateral_movement_in_user_comm)
- [New process started on hosts] (https://github.com/elastic/examples/tree/master/Alerting/new_process_started)
- [Port scan detected] (https://github.com/elastic/examples/tree/master/Alerting/port_scan)
- [Interrupted log flow from hosts] (https://github.com/elastic/examples/tree/master/Alerting/system_fails_to_provide_data)
- [Trending hashtag on twitter] (https://github.com/elastic/examples/tree/master/Alerting/twitter_trends)
- [Unexpected account activity] (https://github.com/elastic/examples/tree/master/Alerting/unexpected_account_activity)
- [Detecting DNS tunnels](https://github.com/elastic/examples/tree/master/packetbeat_dns_tunnel_detection)
- Watch history dashboard


#### Getting Started with Graph exploration

- [Exploring attack vectors in Apache logs using Graph] (https://github.com/elastic/examples/tree/master/ElasticStack_graph_apache)
- [Powering recommendation using Graph](https://github.com/elastic/examples/tree/master/ElasticStack_graph_movielens)


#### Miscellaneous
- [Setting up Elastic Stack on Docker](https://github.com/elastic/examples/tree/master/ElasticStack_docker_setup/)
- [Creating a custom realm in Shield](https://github.com/elastic/examples/tree/master/shield_custom_realm_example)
