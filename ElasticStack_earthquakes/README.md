# Earthquakes Demo

This example provides sample files to ingest, analyze and visualize **earthquake data** using the Elastic Stack. You may refer to [Earthquake data with the Elastic Stack](https://www.elastic.co/blog/earthquake-data-with-the-elastic-stack) blog post to find out your own story behind the data.

## Version Requirements

The example has been tested in the following versions:

- Elasticsearch 5.0.0
- Logstash 5.0.0
- Kibana 5.0.0

## Datasets

The earthquake datasets are gathered from the Northern California Earthquake Data Center through the [ANSS Composite Catalog Search](http://www.ncedc.org/anss/catalog-search.html).

**Acknowledgement**

"Waveform data, metadata, or data products for this study were accessed through the Northern California Earthquake Data Center (NCEDC), doi:10.7932/NCEDC."

### Earthquakes

Filename: earthquakes.txt  
Search parameters: `catalog=ANSS, start_time=2016/01/01,00:00:00, end_time=2016/11/14,13:29:52, minimum_magnitude=1, maximum_magnitude=10, event_type=E`  
Size: 38095 lines (3031148 bytes)

### Blasts (Quarry or Nuclear)

Filename: blasts.txt  
Search parameters: `catalog=ANSS, start_time=2016/01/01,00:00:00, end_time=2016/11/14,13:30:59, minimum_magnitude=1, maximum_magnitude=10, event_type=B`  
Size: 222 lines (17837 bytes)

## Installation & Setup

- Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the Elastic Stack (*you can skip this step if you have a working installation of the Elastic Stack,*)

- Run Elasticsearch & Kibana
```shell
<path_to_elasticsearch_root_dir>/bin/elasticsearch
<path_to_kibana_root_dir>/bin/kibana
```

- Check that Elasticsearch and Kibana are up and running.
  - Open `localhost:9200` in web browser -- should return status code 200
  - Open `localhost:5601` in web browser -- should display Kibana UI.

**Note:** By default, Elasticsearch runs on port 9200, and Kibana run on ports 5601. If you changed the default ports, change   the above calls to use appropriate ports.

### Download Example Files

Download the following files in this repo to a local directory:
- `ncedc-earthquakes-dataset.tar.gz` - sample data (in csv format)
- `ncedc-earthquakes-logstash.conf` - Logstash config for ingesting data into Elasticsearch
- `ncedc-earthquakes-template.json` - template for custom mapping of fields
- `ncedc-earthquakes-dashboards.json` - config file to load prebuilt creating Kibana dashboard
- `ncedc-earthquakes-screenshot.png` - screenshot of final Kibana dashboard  

### Ingest Data

Extract the dataset archive with `tar zxf ncedc-earthquakes-dataset.tar.gz` from the terminal. Run the below commands to ingest the data into your Elasticsearch cluster. Please note, you may need to configure `ncedc-earthquakes-logstash.conf` file in case your are not running Elasticsearch node on your local host.

```shell
tail -n +2 earthquakes.txt | EVENT="earthquake" logstash/bin/logstash -f ncedc-earthquakes-logstash.conf
tail -n +2 blasts.txt | EVENT="blast" logstash/bin/logstash -f ncedc-earthquakes-logstash.conf
```

### Importing Kibana Visuals and Dashboards

1. Open Kibana and go to Settings > Indices. Type in `ncedc-earthquakes` as the index name and create the index pattern.
2. Go to Objects tab and click on Import, and select `ncedc-earthquakes-dashboard.json` by the file chooser.
3. Go to Dashboard and click on `Earthqueke` from the list of the dashboards.

![Dashboard Screenshot](ncedc-earthquakes-screenshot.png?raw=true)
