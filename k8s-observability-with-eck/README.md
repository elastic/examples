# Goal
Collect logs, metrics, and APM data from a Kubernetes environment, and the application(s) running in that environment and store, analyze, and visualize the resulting information in Elastic Cloud on Kubernetes, which provides a Kubernetes Operator to deploy and manage Elasticsearch and Kibana in k8s.

# About GKE
GKE == Google Kubernetes Engine. If you have never used GKE, you might want to go through the [GKE quickstart](https://cloud.google.com/kubernetes-engine/docs/quickstart).  

# Deploy a k8s cluster in GKE

## Create your k8s cluster
Open https://console.cloud.google.com/kubernetes/ and create a cluster.  You can accept the defaults with these exceptions:

- Give the cluster a good name
- Use the latest `Master Version` (at the time of writing, this is 1.13.6-gke.6)
- 2 vCPUs per node (this will change the Memory to 7.5GB)
- Under `Availability, networking, security, and additional features` disable `Stackdriver legacy features` as we will be collecting our own logs and metrics.

## Connect to your k8s cluster
When the cluster is ready click on the `Connect` button in the [console](https://console.cloud.google.com/kubernetes/).  If you have the `gcloud` utilities and `kubectl` installed on your workstation you can click the button to copy the connection string and work from your own shell.  Otherwise click `Run in cloud shell` (generally my preference).

If you do use the cloud shell change your prompt, I use:
```
export PS1='\[\033[01;32m\]\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '
```

## Grab the elastic/examples GitHub repo
This README and the files needed for the demo app are in elastic/examples.  Clone the repo:
```
mkdir k8s-observability-with-eck
cd k8s-observability-with-eck
git clone https://github.com/elastic/examples.git
cd examples/k8s-observability-with-eck
```

# Deploy your Elasticsearch cluster and Kibana Server
First you will deploy the Elastic Cloud on Kubernetes operator, and then use the operator to deploy Elasticsearch and Kibana
## Deploy the Elastic Cloud on Kubernetes Operator

```bash
kubectl apply -f https://download.elastic.co/downloads/eck/0.8.1/all-in-one.yaml
```

You will see several `CRDs` deployed, these are Custom Resource Definitions which extend the Kubernetes API to allow best practice Elasticsearch clusters and Kibana servers to be deployed.  The operator will then be started in its own k8s namespace, `elastic-system`.  

Check the logs:
```
kubectl logs -f elastic-operator-0 -n elastic-system
```
When you see `starting the webhook server` you can `CTRL-C` from the log tail and continue.

# Setup persistent storage
Elasticsearch should have persistent storage, and it should be fast.  Google allows SSDs to be used, and this bit of YAML will create a `Storage Class` that uses SSDs:

```
cat <<EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ssd
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
EOF
```

Once this is applied, SSD based persistent storage can be requested by adding this little bit to the YAML used to request an Elasticsearch cluster (you will see this in context when the cluster gets deployed):

```
...
volumeClaimTemplates:
- metadata:
    name: data
  spec:
    accessModes: [ "ReadWriteOnce" ]
    storageClassName: "ssd"
    resources:
      requests:
        storage: 200Gi
```

# Deploy the Elastic Stack

## Elasticsearch cluster

Rather than have you apply a YAML file on disk, this is copied and pasted so that you look at it and see what is involved.  Starting at the top:

- The type of thing being deployed is Elasticsearch
- The name of the cluster is `elasticsearch-sample`
- Use version 7.1.1
- Make this a three node cluster
- Mount a 200Gi volume `data` on each node using the storage class `ssd` that we just created

```
cat <<EOF | kubectl apply -f -
apiVersion: elasticsearch.k8s.elastic.co/v1alpha1
kind: Elasticsearch
metadata:
  name: elasticsearch-sample
spec:
  version: "7.1.1"
  nodes:
  - nodeCount: 3
    volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: [ "ReadWriteOnce" ]
        storageClassName: "ssd"
        resources:
          requests:
            storage: 200Gi
EOF
```

### Check status

You may want to run `kubectl get pods -w` and watch until the Elasticsearch pods get to the ready state, and then use the following command to see if the healthcheck passes:
```bash
kubectl get elasticsearch
```

Look for **green**:
```bash
NAME                   HEALTH   NODES   VERSION   PHASE         AGE
elasticsearch-sample   green    3       7.1.1     Operational   3m
```

## Kibana

### LoadBalancer discussion
Because the Kibana server is secured with a non-default password a LoadBalancer can be deployed with Kibana.  If you do not want to deploy a LoadBalancer because of cost or policy, then simply remove the `http` section of the below YAML.

Next deploy Kibana.  Detailing the YAML below:

- Deploy Kibana
- Name it kibana-sample
- Use version 7.1.1
- A single node
- (this is the important bit) Associate it with the Elasticsearch cluster `elasticsearch-sample`
- Deploy a LoadBalancer service pointing to Kibana

```
cat <<EOF | kubectl apply -f -
apiVersion: kibana.k8s.elastic.co/v1alpha1
kind: Kibana
metadata:
  name: kibana-sample
spec:
  version: "7.1.1"
  nodeCount: 1
  elasticsearchRef:
    name: "elasticsearch-sample"
  http:
    service:
      spec:
        type: LoadBalancer
EOF
```

Check the progress with `kubectl get pods -w` and then verify the health check with:

```bash
kubectl get kibana
```

Look for **green**:
```bash
NAME            HEALTH   NODES   VERSION   AGE
kibana-sample   green    1       7.1.1     3m
```

# Deploy Beats

The operators perform many tasks for the user.  Included in the list is setting up TLS certs and securing
the Elasticsearch cluster.  To connect Filebeat and Metricbeat you need to setup a Kubernetes secret.

## Get the credentials

You will need:
* The CA cert for TLS
* Service names
* User name and password

## Get the CA cert

The Elasticsearch cluster that has been deployed is configured with TLS enabled, so we need to provide
the cert to the Beats in order to connect.  The cert is added to a secret, let's grab that:

### List the secrets

```bash
kubectl get secrets| grep ca
```

```bash
elasticsearch-sample-ca                     Opaque                                1      5h
elasticsearch-sample-ca-private-key
```
We need the ca.crt or ca.pem, not the private key

### Find the name of the cert:

```bash
kubectl get secret elasticsearch-sample-ca -o=json
```
This should be ca.pem


### Extract the ca:

Make sure to escape the dot in ca.pem
```bash
kubectl get secret elasticsearch-sample-ca -o=jsonpath='{.data.ca\.pem}' | base64 --decode
```

### Create a Kubernetes ConfigMap with the cert

Edit the manifest `vi cert.yaml` and replace the sample with the decoded ca.pem.
Note: Indent the cert like it is in the sample.

Create the ConfigMap
```bash
kubectl create -f cert.yaml
```

# Extract the username and password:

## Username
```bash
kubectl get secrets | grep user
```

The output will be similar to this
```bash
elasticsearch-sample-elastic-user                               Opaque                                1      4h
elasticsearch-sample-es-roles-users                             Opaque                                3      4h
elasticsearch-sample-internal-users                             Opaque                                3      4h
```

Look at the secret for the `elasticsearch-sample-elastic-user` to find the username

```bash
kubectl get secret elasticsearch-sample-elastic-user -o=json
```

You will see output like this.  In this example the username is `elastic`:
```bash
{
    "apiVersion": "v1",
    "data": {
        "elastic": "Mjh0aGxmYm1wZDk2a3A1eG56NWs3a2Rt"
    },
...
```

### Record the username

```bash
echo elastic > ELASTICSEARCH_USERNAME
```

## Password
Decode and record the password:

```bash
echo \
  `kubectl get secret elasticsearch-sample-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode` \
  > ELASTICSEARCH_PASSWORD
```

# Service names

## Servicename and namespace for the Elasticsearch cluster

```bash
kubectl get services
```

Returns:
```bash
NAME                                TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
elasticsearch-sample-es             ClusterIP      10.23.241.250   <none>          9200/TCP       2h
elasticsearch-sample-es-discovery   ClusterIP      None            <none>          9300/TCP       2h
kibana-sample-kibana                ClusterIP      10.23.240.17    <none>          5601/TCP       2h
kubernetes                          ClusterIP      10.23.240.1     <none>          443/TCP        3h
```

The service name for Elasticsearch is `elasticsearch-sample-es`.  The namespace is
`default`, so the FQDN is `elasticsearch-sample-es.default.svc.cluster.local` and
the port is 9200.  The cluster is setup for TLS, so the URL is
`https://elasticsearch-sample-es.default.svc.cluster.local:9200`.  The
elasticsearch.hosts setting expects an array, the the full string is:
```bash
["https://elasticsearch-sample-es.default.svc.cluster.local:9200"]
```

### Record this in ELASTICSEARCH_HOSTS

The single quotes around this are needed if using echo to write the file.

```bash
echo '["https://elasticsearch-sample-es.default.svc.cluster.local:9200"]' > ELASTICSEARCH_HOSTS
```

The Kibana service name is `kibana-sample-kibana`, the namespace is `default`, and
the port is 5601.  The protocol is http.  The Kibana entry is not an array, so the
full string is:
```bash
"http://kibana-sample-kibana.default.svc.cluster.local:5601"
```

### Record this in KIBANA_HOST

The single quotes around this are needed if using echo to write the file.

```bash
echo '"http://kibana-sample-kibana.default.svc.cluster.local:5601"' > KIBANA_HOST
```

## Create the Kubernetes Secret

```bash
kubectl create secret generic dynamic-logging \
   --from-file=./ELASTICSEARCH_HOSTS \
   --from-file=./ELASTICSEARCH_PASSWORD \
   --from-file=./ELASTICSEARCH_USERNAME \
   --from-file=./KIBANA_HOST \
   --namespace=kube-system
```

# Deploy kube-state-metrics if it is not already there
```bash
kubectl get pods --namespace=kube-system | grep kube-state
git clone https://github.com/kubernetes/kube-state-metrics.git kube-state-metrics
kubectl create -f kube-state-metrics/kubernetes
kubectl get pods --namespace=kube-system | grep kube-state  
```

# Deploy Filebeat

```bash
kubectl create -f filebeat-kubernetes.yaml
```

# Deploy Metricbeat

```bash
kubectl create -f metricbeat-kubernetes.yaml
```

# Deploy Heartbeat

```bash
kubectl create -f heartbeat-kubernetes.yaml
```

# Verify
```bash
kubectl get pods --namespace=kube-system -w
```

# Deploy a sample app
```bash
kubectl create -f guestbook.yaml
```

# Verify
```bash
kubectl get pods -w -n guestbook
```

# Access Kibana
Kibana is available through a LoadBalancer service, get the details:
```bash
kubectl get service kibana-sample-kibana
```

Output:
```bash
NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)          AGE
kibana-sample-kibana   LoadBalancer   10.10.10.105   34.66.51.175   5601:31229/TCP   20m
```

In the above sample, the Kibana URL is `http://34.66.51.175:5601`.  You also need the password for the Elastic user, this is stored in the file ELASTICSEARCH_PASSWORD:

```bash
cat ELASTICSEARCH_PASSWORD
```

## Set a default Index Pattern
Open Kibana, and navigate to the Management -> Kibana -> Index Patterns page, click on filebeat-* or metricbeat-* and make one the default (click on the star)

## Create a Heartbeat index pattern
- In the same Index Pattern page click on **Create index pattern** 
- Set the index pattern name to `heartbeat-*`
- Set the time field to @Timestamp

## Enable Monitoring
Navigate to Monitoring and enable monitoring.

# Access the sample application
The Guestbook application has an APache / PHP frontend, and a Redis backend.  It is also available behind a GKE LoadBalancer.  Get the details like so:
```bash
kubectl get service frontend -n guestbook
```

Output:
```bash
NAME       TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)        AGE
frontend   LoadBalancer   10.76.7.248   35.224.82.103   80:32594/TCP   16m
```

Access the application at http://<EXTERNAL-IP from output>

Add some entries, and then add some fake paths so that some 404's show up in the Kibana dashboard for Apache.

## Open dashboards
Here are some dashboards that will be populated:
- [Filebeat Apache2] Access and error logs
- [Metricbeat Apache] Overview
- [Filebeat Redis] Overview
- [Metricbeat Redis] Overview
- [Metricbeat Kubernetes] Overview
- [Metricbeat System] Overview

## Open Uptime
To Do: Need to add the sample app to the Heartbeat config

## Navigate from Infrastructure app to Metrics and Logs

Note: When you open the Infrastructure UI follow these steps so that you will be sure to have logs:
* Navigate to Kubernetes
* Group by Namespace
* click on `guestbook`

All of the guestbook pods will have logs and metrics.


## Look at details in Monitoring app

