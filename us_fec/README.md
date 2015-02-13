US FEC Campaign Contributions Demo: 2013-2014 US Election cycle
=====

For some background information for this demo, please see the blog post here:
[#byodemos: us election campaign contributions](http://www.elasticsearch.org/blog/byodemos-new-york-city-traffic-incidents/)

#Installation

This demo includes a Vagrantfile that you can use to provision a local VM with the US FEC data pre-loaded. You must have Vagrant and VirtualBox already installed:

* http://www.vagrantup.com/
* https://www.virtualbox.org/

If you're reading this on your computer, you've probably already downloaded a release of the Elasticsearch demo repo .zip file.

After you've installed Vagrant and VirtualBox, go to the us\_fec subdirectory and run Vagrant up:

* git clone https://github.com/elasticsearch/demo.git (HTTPS) or git clone git@github.com:elasticsearch/demo.git (SSH)
* cd us\_fec
* vagrant up

Once this is complete (should take anywhere between 3-20 minutes to run, depending on your network connection speed), you should have an Elasticsearch instance running with the US FEC index and Kibana dashboard loaded. No further steps are necessary.  To ensure everything is up and running correctly, click on the Elasticsearch Marvel link below.

Marvel - [http://localhost:9200/_plugin/marvel/index.html](http://localhost:9200/_plugin/marvel/index.html)

You should then be able to load Kibana in a browser as well:

Kibana Dashboard - [http://localhost:5601/#/dashboard/elasticsearch/NYC%20Accidents%20v.2](http://localhost:5601/#/dashboard/elasticsearch/NYC%20Accidents%20v.2)

#Potential issues

The 'vagrant up' step may fail if you are running on Windows for a variety of reasons, some of which are listed here:

* BIOS not configured to enable Hardware Virtualization. \[Windows, Linux\]
* Ports 9200, 5200, 2222 blocked by firewall or other software. \[Any OS\]


##Vagrant port forwarding

The Vagrantfile is configured to forward requests from the host (laptop) to the VM using these rules:

* 9200 -> 9200 (Elasticsearch instance)
* 5601 -> 5601 (Kibana)

If you have another Vagrant VM or a local Elasticsearch instance using ports 9200 and/or 5601, you will need to shut down those services while running this demo.

#Next steps

The Vagrant/Puppet scripts provision a ready-to-use Elasticsearch index and Kibana dashboard for you but if you're interested in refreshing the dataset with the latest updates from the FEC, making tweaks to the Elasticsearch mapping config, enhancing the Logstash config and reindexing the data, or something else, this VM environment is ready for you to do that. 

##Raw data updates

The latest version of the source data set can be found here: [http://www.fec.gov/finance/disclosure/ftpdet.shtml#a2013_2014](http://www.fec.gov/finance/disclosure/ftpdet.shtml#a2013_2014).


##Mapping config

The Elasticsearch mapping configuration is defined in the index template file: index\_template.json. Documentation:

* [Mapping](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/mapping.html)
* [Index templates](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-templates.html)

##Logstash config

The Logstash configuration is defined in the file: logstash.conf. Documentation for Logstash plugins: [http://www.elasticsearch.org/guide/en/logstash/current/index.html](http://www.elasticsearch.org/guide/en/logstash/current/index.html).
