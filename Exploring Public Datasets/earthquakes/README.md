# Earthquakes Demo

This example provides sample files to ingest, analyze and visualize **earthquake data** using the Elastic Stack. You may refer to [Earthquake data with the Elastic Stack](https://www.elastic.co/blog/earthquake-data-with-the-elastic-stack) blog post to find out your own story behind the data.

Since its initial publishing, this example has been modified to use Filebeat+Ingest Node instead of Logstash for data ingestion.  The data distributed with this example is for 2016. More recent data can be obtained from the links below.

## Version Requirements

The example has been tested in the following versions:

- Elasticsearch 6.0
- Filebeat 6.0
- Kibana 6.0

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

- Download and install Filebeat as described [here](https://www.elastic.co/guide/en/beats/filebeat/5.4/filebeat-installation.html). **Do not start Filebeat**


### Download Example Files

Download the following files in this repo to a local directory:

- `ncedc-earthquakes-dataset.tar.gz` - sample data (in csv format)
- `ncedc-earthquakes-filebeat.yml` - Filebeat config for ingesting data into Elasticsearch
- `ncedc-earthquakes-template.json` - template for custom mapping of fields
- `ncedc-earthquakes-pipeline.json` - ingest pipeline for processing documents produced by Filebeat
- `ncedc-earthquakes-dashboards.json` - config file to load prebuilt creating Kibana dashboard

Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. You can either (a) [download](https://github.com/elastic/examples/archive/master.zip) or [clone](https://github.com/elastic/examples.git) the entire examples repo and navigate to `Exploring Public Datasets/earthquakes` subfolder, or (b) individually download the above files. The code below makes option (b) a little easier:
    
```shell
wget https://raw.githubusercontent.com/elastic/examples/master/Exploring%20Public%20Datasets/earthquakes/ncedc-earthquakes-dataset.tar.gz
wget https://raw.githubusercontent.com/elastic/examples/master/Exploring%20Public%20Datasets/earthquakes/ncedc-earthquakes-template.json
wget https://raw.githubusercontent.com/elastic/examples/master/Exploring%20Public%20Datasets/earthquakes/ncedc-earthquakes-pipeline.json
wget https://raw.githubusercontent.com/elastic/examples/master/Exploring%20Public%20Datasets/earthquakes/ncedc-earthquakes-dashboards.json
wget https://raw.githubusercontent.com/elastic/examples/master/Exploring%20Public%20Datasets/earthquakes/ncedc-earthquakes-filebeat.yml
```

### Ingest Data


1. Extract the dataset archive with `tar -zxf ncedc-earthquakes-dataset.tar.gz` from the terminal.
1. Install the earthquakes ingest pipeline i.e.

    ```shell
    curl -XPUT -H 'Content-Type: application/json' 'localhost:9200/_ingest/pipeline/ncedc-earthquakes' -d @ncedc-earthquakes-pipeline.json
    ```

1. Install the index template i.e.

    ```shell
    curl -XPUT -H 'Content-Type: application/json' 'localhost:9200/_template/ncedc-earthquakes' -d @ncedc-earthquakes-template.json
    ```

1. Modify the `ncedc-earthquakes-filebeat.conf` file as follows:

    * The parameter `hosts: ["localhost:9200"]` in case your are not running Elasticsearch node on your local host
    * The files path to each of the data files extracted above i.e.
    
        ```shell
          paths:
            - ./ncedc-earthquakes-dataset/earthquakes.txt
        ```
    
        **and**
        
        ```shell
          paths:
            - ./ncedc-earthquakes-dataset/blasts.txt
        ```    
    
1. Move the file `ncedc-earthquakes-filebeat.yml` to the Filebeat installation directory i.e.
    
     ```shell
    mv ncedc-earthquakes-filebeat.yml <filebeat_installation_dir>/ncedc-earthquakes-filebeat.yml
    ```

1. Start Filebeat to begin ingesting data to Elasticsearch

    ```shell
    cd <filebeat_installation_dir>
    ./filebeat -e -c ncedc-earthquakes-filebeat.yml
    ```

    Note: Expect the following error to be repeated twice 
    
    ` WARN Can not index event (status=400): {"type":"mapper_parsing_exception","reason":"failed to parse","caused_by":{"type":"number_format_exception","reason":"empty String"}}`
    
    This simply represents the csv headers not conforming to the required field types. These documents are not required and the above can be safely ignored.

1. After several minutes repeat the following commands until a count of 38315 is returned:

    ```shell
    curl http://localhost:9200/ncedc-earthquakes-*/_refresh
    curl http://localhost:9200/ncedc-earthquakes-*/_count
    ```

### Importing Kibana Visuals and Dashboards

* Access Kibana by going to `http://localhost:5601` in a web browser
* Connect Kibana to the `ncedc-earthquakes-*` indices in Elasticsearch (autocreated in step 1)
    * Click the **Management** tab >> **Index Patterns** tab >> **Create New**. Specify `ncedc-earthquakes-*` as the index pattern name and click **Create** to define the index pattern. (Leave the **Use event times to create index names** box unchecked and use @timestamp as the Time Field)
    * If this is the only index pattern declared, you will also need to select the star in the top upper right to ensure a default is defined. 
* Load sample dashboard into Kibana
    * Click the **Management** tab >> **Saved Objects** tab >> **Import**, and select `ncedc-earthquakes-dashboard.json`. 
    * On import you will be asked to overwrite existing objects - select "Yes, overwrite all". Additionally, select the index pattern "ncedc-earthquakes-*" when asked to specify a index pattern for the dashboards.
* Open dashboard
    * Click on **Dashboard** tab and open the `Earthquake` dashboard

![Dashboard Screenshot](https://user-images.githubusercontent.com/12695796/32793826-f29e4a22-c95e-11e7-9e86-cd19685c3df5.png)
