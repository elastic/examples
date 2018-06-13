#### Note: These instructions have been tested in Google Cloud Platform Kubernetes Engine and IBM Cloud Kubernetes Service.  I hope that they work everywhere else, and I will test them in other places as I am able.

### Create an Elastic Cloud deployment
You can use Elastic Cloud ( http://cloud.elastic.co ), or a local deployment, or deploy containers from https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html

If this is your first experience with the Elastic stack I would recommend Elastic Cloud; and don't worry, you do not need a credit card.

Make sure that you take note of the CLOUD ID and Elastic Password if you use Elastic Cloud or Elastic Cloud Enterprise.

### Connect to your Kubernetes environment
In Google I use the web based console provided by Google.  In IBM Cloud I use an Ubuntu VM running in Virtualbox and connect to IBM Cloud Container service.

### Authorization
Create a cluster level role binding so that you can manipulate the system level namespace

```
kubectl create clusterrolebinding cluster-admin-binding \
 --clusterrole=cluster-admin --user=<your email associated with the Cloud provider account>
```

### Clone the YAML files
Either clone the entire Elastic examples repo or use the wget commands in download.txt:

```
mkdir MonitoringKubernetes
cd MonitoringKubernetes
wget https://raw.githubusercontent.com/elastic/examples/master/MonitoringKubernetes/download.txt
sh download.txt
```

OR

```
git clone https://github.com/elastic/examples.git
cd examples/MonitoringKubernetes
```
### Set the credentials
Set these with the values from the http://cloud.elastic.co deployment

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

### Check to see if kube-state-metrics is running
```
kubectl get pods --namespace=kube-system | grep kube-state
```
and create it if needed (by default it will not be there)

```
go get k8s.io/kube-state-metrics
cd ${USER}/gopath/src/k8s.io/kube-state-metrics # Note: you may not have a gopath dir, it may be ${USER}/go/ instead, or ?
make container
kubectl create -f kubernetes
kubectl get pods --namespace=kube-system | grep kube-state 
```

### Deploy the Guestbook example
Note: This is mostly the default Guestbook example from https://github.com/kubernetes/examples/blob/master/guestbook/all-in-one/guestbook-all-in-one.yaml

I added an ingress that preserves source IPs and added ConfigMaps for the Apache2 and Mod-Status configs so that I could block the /server-status endpoint from outside the internal network (actually apache2.conf is unedited, but I may need it later).  I also added a redis.conf to set the slowlog time criteria.

```
kubectl create -f guestbook.yaml 
```
Verify the external IP is assigned

```
kubectl get service frontend -w
```
Once the external IP address is assigned you can type CTRL-C to stop watching for changes and get the command prompt back (the -w is "watch for changes")

### Deploy the Elastic Beats
```
kubectl create -f filebeat-kubernetes.yaml 
kubectl create -f metricbeat-kubernetes.yaml 
kubectl create -f packetbeat-kubernetes.yaml 
```

### View in Kibana

Open your Kibana URL and look under the Dashboard link, verify that the Apache and Redis dashboards are populating.

### Scale your deployments and see new pods being monitored
List the existing deployments:
```
kubectl get deployments

NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
frontend       3         3         3            3           3m
redis-master   1         1         1            1           3m
redis-slave    2         2         2            2           3m
```

Scale the frontend down to two pods:
```
kubectl scale --replicas=2 deployment/frontend

deployment "frontend" scaled
```

Check the frontend deployment:
```
kubectl get deployment frontend

NAME       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
frontend   2         2         2            2           5m
```

### View the changes in Kibana
See the screenshot, add the indicated filters and then add the columns to the view.  You can see the ScalingReplicaSet entry that is marked, following from there to the top of the list of events shows the image being pulled, the volumes mounted, the pod starting, etc.
![Kibana Discover](https://raw.githubusercontent.com/elastic/examples/master/MonitoringKubernetes/scaling-discover.png)
