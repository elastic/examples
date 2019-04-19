# Introduction

Beats are lightweight "shippers" that send logs and metrics about your environment (Kubernetes in this case), the hosts the environment is running on (the Kubernetes nodes), your application(s), and the network.  In this tutorial three Beats will be deployed:
* Filebeat (you know, for logs)
* Metricbeat (for metrics)
* Packetbeat (for network related metrics)

Here is the order we will follow:

1. Configure the Kubernetes cluster
1. Download the example files
1. Setup credentials and connectivity details for the Elasticsearch and Kibana servers
1. Deploy a sample application
1. Deploy Beats
1. Look at dashboards and records in Kibana
1. Learn how to add more applications

# Authorization
Create a cluster level role binding so that you can manipulate the system level namespace

```
kubectl create clusterrolebinding cluster-admin-binding \
 --clusterrole=cluster-admin --user=<your email associated with the k8s provider account>
```

# Clone the YAML files
Either clone the entire Elastic examples repo or use the wget commands in download.txt:

```
mkdir beats-k8s-send-anywhere
cd beats-k8s-send-anywhere
wget https://raw.githubusercontent.com/elastic/examples/master/beats-k8s-send-anywhere/download.txt
sh download.txt
```

OR

```
git clone https://github.com/elastic/examples.git
cd examples/beats-k8s-send-anywhere
```

# Elasticsearch and Kibana

At this point you will need to have the URL(s) and credentials for an existing Elasticsearch cluster and Kibana server, or deploy Elasticsearch and Kibana.

Decide if you will use the managed service, Elasticsearch Service in Elastic Cloud, or use self managed Elasticsearch and Kibana either in your Kubernetes cluster (with the Elastic Helm Charts), or outside of your Kubernetes Cluster with files from the Elastic download page.  You can use any of these three methods, and the Beats will send data to any of them.

### Managed service: 
Set the credentials and create the Kubernetes secret as detailed in [README-Cloud.md](README-Cloud.md)

### Self managed: 
Deploy in k8s via Helm Charts, or downloaded files running on servers, or running on your own workstation.  Set the credentials and create the Kubernetes secret as detailed in [README-Self-Managed.md](README-Self-Managed.md)

