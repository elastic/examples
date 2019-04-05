# GKE-on-Prem-logging-and-metrics

### Grab the configuration
`git clone https://github.com/DanRoscigno/GKE-on-Prem-logging-and-metrics.git`
or
Click the *Clone or Download* button at the top right of https://github.com/DanRoscigno/GKE-on-Prem-logging-and-metrics

All of the rest of the commands will be run from the directory `GKE-on-Prem-logging-and-metrics`

### Set the cluster-admin-binding
Logging and metrics tools like Filebeat, Fluentd, Metricbeat, Prometheus, etc. run as DameonSets.  To deploy DaemonSets you need the cluster role binding `cluster-admin-binding`.  Create it now:

```
kubectl create clusterrolebinding cluster-admin-binding  \
  --clusterrole=cluster-admin --user=$(gcloud config get-value account)
```

### Deploy example application
This uses the Guestbook app from the Kubernetes docs.  The YAML has been concatenated into a single manifest, and Apache HTTP mod Status has been enabled for metrics gathering.

Before you deploy the manifest have a look at the frontend service.  You may need to edit this service so that the service is exposed to your internal network.  The network topology of the lab where this example was developed has a load balancer in front of the GKE On-Prem environment, and so the service specifies an IP Address associated with the load balancer.  Your configuration will likely be different.

```
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  type: LoadBalancer
  ports:
  - port: 80
    protocol: TCP
  selector:
    app: guestbook
    tier: frontend
  loadBalancerIP: 10.0.10.42
---
```

Edit the guestbook.yaml manifest as appropriate and then deploy it.

`kubectl create -f guestbook.yaml`

### Verify
Check to see that the application is deployed and reachable on your network:

`kubectl get pods -n default`

`kubectl get services -n default`

Open a browser to the IP Address associated with the `frontend` service at port 80.
### Create secrets
Rather than putting the Elasticsearch and Kibana endpoints into the manifest files they are provided to the Filebeat pods as k8s secrets.  Edit the files `elasticsearch-hosts-ports` and `kibana-host-port` and then create the secret:

```
kubectl create secret generic elastic-stack \
  --from-file=./elasticsearch-hosts-ports \
  --from-file=./kibana-host-port --namespace=kube-system
```

### Deploy index patterns, visualizations, dashboards, and machine learning jobs
Filebeat and Metricbeat provide the configuration for things like web servers, caches, proxies, operating systems, container environments, databases, etc.  These are referred to as *Beats modules*.  By deploying these configurations you will be populating Elasticsearch and Kibana with visualizations, dashboards, machine learning jobs, etc.  

```
kubectl create -f filebeat-setup.yaml
kubectl create -f metricbeat-setup.yaml
```

### Verify
`kubectl get pods -n kube-system | grep beat`

Verify that the setup pods complete
Check the logs for the setup pods to ensure that they connected to Elasticsearch and Kibana (the setup pod connects to both)

### Deploy the Beat DaemonSets
```
kubectl create -f filebeat-kubernetes.yaml
kubectl create -f metricbeat-kubernetes.yaml
```
#### Note: Depending on your k8s Node configuration, you may not need to deploy Jounalbeat.  If your Nodes use journald for logging, then deploy Journalbeat, otherwise Filebeat will get the logs
`kubectl create -f journalbeat-kubernetes.yaml`

### Verify
`kubectl get pods -n kube-system | grep beat`

Verify that there is one filebeat, metricbeat, and journalbeat pod per k8s Node running.

Check the logs for and one of the DaemonSet pods to ensure that they connected to Elasticsearch. 

View your logs and metrics in Kibana.
