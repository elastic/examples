# This example walks you through integrating with Prometheus in a Kubernetes environment
## Assumptions:
 - You have a Kubernetes environment
 - You have a Prometheus server deployed in that Kubernetes environment (if you want one, see the caveat below)
### Caveat: If you do not have a Prometheus Server, you can use the Prometheus Redis exporter that gets deployed with the sample application and it will get picked up by the Metricbeat autodiscover feature.

## Create an Elasticsearch Service deployment in Elastic Cloud
You can use Elastic Cloud ( http://cloud.elastic.co ), or a local deployment.  Whichever you choose, https://elastic.co/start will get you started.

If this is your first experience with the Elastic Stack I would recommend Elastic Cloud; and don't worry, you do not need a credit card.

Make sure that you take note of the CLOUD ID and Elastic Password if you use Elastic Cloud or Elastic Cloud Enterprise.

## Configure your Kubernetes environment
### Authorization
Create a cluster level role binding so that you can manipulate the system level namespace (this is where DaemonSets go)

```
kubectl create clusterrolebinding cluster-admin-binding \
 --clusterrole=cluster-admin --user=<your email associated with the Cloud provider account>
```

### Clone the YAML files
Either clone the entire Elastic examples repo or use the wget commands in download.txt (wget is required, if you do not have it just clone the repo):

```
mkdir scraping-prometheus-k8s-with-metricbeat
cd scraping-prometheus-k8s-with-metricbeat
wget https://raw.githubusercontent.com/elastic/examples/master/scraping-prometheus-k8s-with-metricbeat/download.txt
sh download.txt
```

OR

```
git clone https://github.com/elastic/examples.git
cd examples/scraping-prometheus-k8s-with-metricbeat
```
### Set the credentials
Set these with the values from the http://cloud.elastic.co deployment

Note: Follow the instructions in the files carefully, the k8s secret creation does not remove trailing whitespace as secrets should be copied exactly as you provide them.
```
vi ELASTIC_PASSWORD
vi CLOUD_ID
```
and create a secret in the Kubernetes system level namespace

```
kubectl create secret generic dynamic-logging \
  --from-file=./ELASTIC_PASSWORD --from-file=./CLOUD_ID \
  --namespace=kube-system
```

### Create the cluster role binding for Metricbeat
```
kubectl create -f metricbeat-clusterrolebinding.yaml
```

### Check to see if kube-state-metrics is running
```
kubectl get pods --namespace=kube-system | grep kube-state
```
and create it if needed (by default it will not be there)

```
git clone https://github.com/kubernetes/kube-state-metrics.git kube-state-metrics
kubectl create -f kube-state-metrics/kubernetes
kubectl get pods --namespace=kube-system | grep kube-state
```

## Deploy the Guestbook example
Note: This is mostly the default Guestbook example from https://github.com/kubernetes/examples/blob/master/guestbook/all-in-one/guestbook-all-in-one.yaml

Changes:
 - added annotations so that Prometheus and Metricbeat would autodiscover the Redis pods
 - added an ingress that preserves source IPs
 - added ConfigMaps for the Apache2 and Mod-Status configs to block the /server-status endpoint from outside the internal network
 - added a redis.conf to set the slowlog time criteria

```
kubectl create -f guestbook.yaml
```
Let's look at a couple of things in guestbook.yaml:
 - Annotations on the Redis pods.  These will be used by both Prometheus and Metricbeat to autodiscover the Redis pods:
![Annotations](https://github.com/DanRoscigno/scraping-prometheus-k8s-with-metricbeat/blob/master/images/annotations.png)
 - Prometheus exporter for Redis sidecar:
 ![sidecar](https://github.com/DanRoscigno/scraping-prometheus-k8s-with-metricbeat/blob/master/images/sidecar.png)

### Verify the guestbook external IP is assigned

```
kubectl get service frontend -w
```
Once the external IP address is assigned you can type CTRL-C to stop watching for changes and get the command prompt back (the -w is "watch for changes")

## Deploy Metricbeat
Normally deploying Metricbeat would be a single command, but the goal of this example is to show multiple ways of pulling metrics from Prometheus, so we will do things step by step.

### Pull metrics from a Prometheus server and kube-state-metrics
In this example we will pull:
 - self-monitoring metrics from the Prometheus server (using the /metrics endpoint)
 - all of the metrics that Prometheus collects from the various systems being monitored (using the /federate endpoint)
 - kube-state-metrics information including events and state of nodes, deployments, etc.

```
kubectl create -f metricbeat-kube-state-and-prometheus-server.yaml
```
Here is the YAML to connect Metricbeat to the Prometheus server /metrics endpoint (self-monitoring):
![scrape server /metrics endpoint](https://github.com/DanRoscigno/scraping-prometheus-k8s-with-metricbeat/blob/master/images/prometheus-self.png)

Here is the YAML to connect Metricbeat to the Prometheus server /federate endpoint:
![scrape server /federate endpoint](https://github.com/DanRoscigno/scraping-prometheus-k8s-with-metricbeat/blob/master/images/prometheus-federate.png)

We will look specifically at the kubernetes event metricset when we build a visualization.  The event metricset exposes information about scaling deployments (among other things) and the reason for the scaling.

While that deploys, look at the snippet below.  You can see that Metricbeat will connect to port 8080 on the kube-state-metrics pod and collect events and state information about nodes, deployments, etc.
![kube-state-metrics YAML](https://github.com/DanRoscigno/scraping-prometheus-k8s-with-metricbeat/blob/master/images/kube-state-metrics.png)

### Pull data from the Prometheus exporter for Redis.
Up above is a screenshot of the YAML to deploy a sidecar to export Redis metrics to Preometheus.  Metricbeat can pull metrics from Prometheus exporters also.  Deploy a Metricbeat DaemonSet to autodiscover and collect these metrics.

Note: Normally the Metricbeat DaeomonSet would autodiscover and collect all of the metrics about the k8s environment and the apps running in there, this config is simplified to show just one example.
```
kubectl create -f metricbeat-prometheus-auto-discover.yaml
```
Let's look at how autodiscover is configured.  Earlier we looked at the guestbook.yaml and that annotations were added to the Redis pods.  One of those annotations set prometheus.io/scrape to true, and the other set the port for the Redis metrics to 9121.  In the Metricbeat DaemonSet config we are configuring autodiscover to look for pods with the scrape and port annotations, which is exactly what Prometheus does.  
![Metricbeat autodiscover](https://github.com/DanRoscigno/scraping-prometheus-k8s-with-metricbeat/blob/master/images/metricbeat-autodiscover-exporters.png)
This autodiscover config is more abstract by not specifying port 9121, and substituting the value from the annotation provided by the k8s API so that a single autodiscover config could discover all exporters whether they are for Redis or another technology (the port numbers for exporters are based on the technology and are published in the [Prometheus wiki](https://github.com/prometheus/prometheus/wiki/Default-port-allocations).

If you are not familiar with the Prometheus autodiscover configuration, here is part of an example.  Notice that it uses the same annotations:
![Promethus autodiscover](https://github.com/DanRoscigno/scraping-prometheus-k8s-with-metricbeat/blob/master/images/prometheus-autodiscover-snippet.png)


## Visualize your data in Kibana

### Note: the link in the next line is not live yet, skip to the step by step if you happen to find this page before it goes live on April 3rd 2019.

Please see the video from the blog "[Elasticsearch Observability: Embracing Prometheus and OpenMetrics standards for metrics](https://elastic.co/blog/elasticsearch-observability-embracing-prometheus-and-openmetrics-standards-for-metrics)" for step by step instructions to build a visualization with the Redis metrics collected through Prometheus and the kube-state-metrics collected directly by Metricbeat.

1. Open Kibana
1. Open discover
1. Start typing the name of the metric `instantaneous_ops`
1. When Kibana offers you the list, choose `prometheus.metrics.redis_instantaneous_ops_per_sec`
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/001-kibana.png)
1. Open the Discover application
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/002-kibana.png)
1. In the search bar start typing in the name of a metric.  I chose instantaneous ops per second as I feel that this is an important performance metric for Redis.
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/003-kibana.png)
1. Add columns to the Discover view for the metric name and the pod name.  I always do this when I am going to create a visualization so that I have all of the Elasticsearch fields that I will use in the visualization handy.
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/004-kibana.png)
1. Copy the name of the metric (prometheus.metrics.redis_instantaneous_ops_per_sec)
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/005-kibana.png)
1. Open the Kibana Visualization application
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/006-kibana.png)
1. Add a new "Visual Builder" visualization
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/007-kibana.png)
1. Select the metricbeat-* index, as this points to where the metric data is stored
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/008-kibana.png)
1. Set the Y-axis to the max of prometheus.metrics.redis_instantaneous_ops_per_sec (paste it in, or type instantaneous and select the metric)
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/009-kibana.png)
1. Set the X-axis to a Date Histogram
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/010-kibana.png)
1. Split the series on the term kubernetes.pod.name
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/011-kibana.png)
1. Hit apply
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/012-kibana.png)
1. Follow
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/013-kibana.png)
1. Follow
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/014-kibana.png)
1. Follow
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/015-kibana.png)
1. Split the series on the term kubernetes.pod.name
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/016-kibana.png)
1. Hit apply
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/017-kibana.png)
1. Follow
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/018-kibana.png)
1. Follow
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/019-kibana.png)
1. Follow
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/020-kibana.png)
