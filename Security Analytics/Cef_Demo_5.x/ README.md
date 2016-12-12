This Getting Started with Elastic Stack example provides sample files to ingest, analyze & visualize CEF data using the Elastic Stack, i.e. Elasticsearch, Logstash and Kibana. The sample files in this example are in the CEF format. The example provided illustrates indexing manually through the Logstash TCP input. This same configuration can be used to ingest events from Arcsight as described here[]:

Version

Example has been tested in following versions:

Elasticsearch 5.1.1
X-Pack 5.1.1
Logstash 5.1.1
Kibana 5.0
Arcsight (Optional)
Installation & Setup

For a quick setup you can download an example docker-compose.yml definition to help you to install all the elastic stack with x-plugin, then issue:

```
$ docker-compose up
```

But First, ensure that:
You have Docker Engine installed. https://docs.docker.com/engine/installation/
Your host meets the prerequisites.https://www.elastic.co/guide/en/elasticsearch/reference/5.1/docker.html#docker-cli-run-prod-mode
If you are on Linux, that docker-compose is installed.https://github.com/docker/compose/releases/tag/1.9.0

Check that Elasticsearch, Kibana and logstash are up and running.

Open localhost:9200 in web browser -- should return status code 200
Open localhost:5601 in web browser -- should display Kibana UI.
Open localhost:9600 in web browser -- should return status code 200


After you can send the cef data to logstash to the port 5000 


2. Visualize data in Kibana

Access Kibana by going to http://localhost:5601 in a web browser
Connect Kibana to the cef indices in Elasticsearch (autocreated in step 1)
Click the Management tab >> Index Patterns tab >> Create New. Specify cef-* as the index pattern name and click Create to define the index pattern. (Leave the Use event times to create index names box unchecked and use @timestamp as the Time Field)
Load sample dashboard into Kibana
Click the Management tab >> Saved Objects tab >> Import, and select cef_kibana.json
Open dashboard
Click on Dashboard tab and open Sample Dashboard Dashboard.json for Firewall CEF Logs dashboard
Voila! You should see the following dashboard. Happy Data Exploration!


We would love your feedback!

If you found this example helpful and would like more such Getting Started examples for other standard formats, we would love to hear from you. If you would like to contribute Getting Started examples to this repo, we'd love that too!
