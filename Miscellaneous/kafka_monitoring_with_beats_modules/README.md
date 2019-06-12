# Monitoring Kafka with the Elastic Stack and Beats Modules.

Contains a sample environment for monitoring Kafka via the Beats Kafka modules.

For a detailed walk-through, see the Elastic blog post [Monitoring Kafka with the Elastic Stack and Beats Modules](https://www.elastic.co/blog/monitoring-kafka-with-the-elastic-stack-and-beats-modules)

The above blog uses version 7.1.1 of the Elastic Stack, hosted on Elastic Cloud.
The environment here expects the following variables to be exported:

```
CLOUD_AUTH=elastic:<password>
CLOUD_ID=<cloud_id>
```

## Getting started

1. Setup Vagrant


Install [Vagrant](https://www.vagrantup.com/docs/installation/) and the `vagrant-hosts` plugin.

```
vagrant plugin install vagrant-hosts
```

2. Create the Kafka VM's

```
vagrant up
```

3. Start Kafka on each of those VM's

```
vagrant ssh kafka2 -c "bash /vagrant/run-kafka.sh"
vagrant ssh kafka1 -c "bash /vagrant/run-kafka.sh"
vagrant ssh kafka0 -c "bash /vagrant/run-kafka.sh"
```

At this point there should be a working Zookeeper ensemble, Kafka cluster and both
Filebeat and Metricbeat shipping data to the linked Elastic Cloud deployment.
