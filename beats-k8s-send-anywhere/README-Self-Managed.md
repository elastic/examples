# Create an Elasticsearch cluster and install Kibana

You can use the [Elastic Helm Charts](https://github.com/elastic/helm-charts), or a [local deployment](https://www.elastic.co/guide/en/elastic-stack/current/installing-elastic-stack.html).  

# Set the credentials
There are four files to edit to create a k8s secret when you are connectign to self managed Elasticsearch and Kibana (self managed is effectively anything other than the managed Elasticsearch Service in Elastic Cloud).  The files are:

1. ELASTICSEARCH_HOSTS
1. ELASTICSEARCH_PASSWORD
1. ELASTICSEARCH_USERNAME
1. KIBANA_HOST

Set these with the information for your Elasticsearch cluster and your Kibana host.  Here are some examples

## ELASTICSEARCH_HOSTS
1. A nodeGroup from the Elastic Elasticseach Helm Chart: 
    ```
    ["http://elasticsearch-master.default.svc.cluster.local:9200"]
    ```
1. A single Elasticsearch node running on a Mac where your Beats are running in Docker for Mac: 
    ```
    ["http://host.docker.internal:9200"]
    ```
1. Two Elasticsearch nodes running in VMs or on physical hardware:
    ```
    ["http://host1.example.com:9200", "http://host2.example.com:9200"]
    ```


## ELASTICSEARCH_PASSWORD
Just the password, no whitespace or quotes:
```
changeme
```

## ELASTICSEARCH_USERNAME
Just the username, no whitespace or quotes:
```
elastic
```

## KIBANA_HOST

1. The Kibana instance from the Elastic Kibana Helm Chart.  The subdomain `default` refers to the default namespace.  If you have deployed the Helm Chart using a different namespace, then your subdomain will be different: 
    ```
    "kibana-kibana.default.svc.cluster.local:5601"
    ```
1. A Kibana instance running on a Mac where your Beats are running in Docker for Mac: 
    ```
    "host.docker.internal:5601"
    ```
1. Two Elasticsearch nodes running in VMs or on physical hardware:
    ```
    "host1.example.com:5601"
    ```

# Edit the required files:
```
vi ELASTICSEARCH_HOSTS
vi ELASTICSEARCH_PASSWORD
vi ELASTICSEARCH_USERNAME
vi KIBANA_HOST
```
# Create a Kubernetes secret
This command creates a secret in the Kubernetes system level namespace (kube-system) based on the files you just edited:

    kubectl create secret generic dynamic-logging \
      --from-file=./ELASTICSEARCH_HOSTS \
      --from-file=./ELASTICSEARCH_PASSWORD \
      --from-file=./ELASTICSEARCH_USERNAME \
      --from-file=./KIBANA_HOST \
      --namespace=kube-system

# Continue with the install
Open [README-Main.md](README-Main.md) and complete the tutorial
