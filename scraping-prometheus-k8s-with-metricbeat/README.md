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

Open Kibana

0. Open discover

1. Start typing the name of the metric `instantaneous_ops`

1. When Kibana offers you the list, choose `prometheus.metrics.redis_instantaneous_ops_per_sec`
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/001-kibana.png)

1. Choose `exists in any form` and press Enter
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/002-kibana.png)

1. Expand one record
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/003-kibana.png)

1. Add columns to the Discover view for the metric name and the pod name.  I always do this when I am going to create a visualization so that I have all of the Elasticsearch fields that I will use in the visualization handy.
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/004-kibana.png)

1. This is what the view will look like, the full records are available by expanding them with the `>`, and the columns make it easier to scan through the data visually. Copy the name of the metric (`prometheus.metrics.redis_instantaneous_ops_per_sec`) to paste into the visualization builder.
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/005-kibana.png)

1. Open the Kibana Visualization application
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/006-kibana.png)

1. Add a new visualization
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/007-kibana.png)

1. Select Visual Builder
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/008-kibana.png)

1. Set the Aggregation to the Average of prometheus.metrics.redis_instantaneous_ops_per_sec (paste it in, or type instantaneous and select the metric)
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/009-kibana.png)

1. The above shows the average of the metric across all Redis pods, to show the individual pods group by `Terms` `kubernetes.pod.name`
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/010-kibana.png)

1. Let's tweak some things in the visualization, open Options
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/011-kibana.png)

1. Name the time series, and if you want to change the number format you can type a format in.  There is a link to the format string details just under the format box.  If there are pods in the list that you do not want, you can filter using the k8s metadata, in the screenshot we are filtering by k8s label `app`
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/012-kibana.png)

1. At this point the time series is done, but let's kick it up a notch.  Why not add some event data as an annotation?  This could be a specific log message that might be a clue to a performance change.  In this example we will use a message that tells us the Redis deployment has scaled.  You might choose to use a crash loop backoff, or a log message that indicates a config change.  Scale a deployment to make sure you have some of the relevant events (`kubectl scale --replicas=1 deployment/redis-slave`) 

1. Switch browser tabs to the Visual Builder and click on the Annotations tab:

1. Open Discover in a new tab, and filter on kubernetes.event.reason:
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/015-kibana.png)

1. Click on `exists in any form` and press enter
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/016-kibana.png)

1. Open a record and add the fields `kubernetes.event.message`, `kubernetes.event.reason`, and `kubernetes.event.involved_object_name` to the tabular view.
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/017-kibana.png)

1. If you do not have any `kubernetes.event.reason` `ScalingReplicaSet` records you can scale the `redis-slave` deployment (`kubectl scale --replicas=1 deployment/redis-slave`) and then click on refresh in Discover to see them.

1. Switch browser tabs to the Visual Builder and click on the Annotations tab:
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/013-kibana.png)

1. Add a data source for the annotation.  This can be any index pattern in your system.  In the example we will be using events from k8s, and we grab those form kube-state-metrics via Metricbeat.
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/014-kibana.png)

1. Set the annotation up as shown. All of the details come from the Discover window which is open in another tab.  Numbers 3 - 6 below deserve a little detail:

   - 3, 4: This is a list of all fields used in the annotation message.

   - 5, 6: This is a JSON formatted string that will be displayed on hover over.  Put field names in `{{ }}` and add other text as needed.  When you add the row template the annotations will pop up, hover over them to verify.
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/018-kibana.png)

1. Save the visualization
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/019-kibana.png)

1. Give it a name
![1](https://github.com/elastic/examples/blob/master/scraping-prometheus-k8s-with-metricbeat/images/020-kibana.png)
