## Ingest Data using Python scripts

If you want to ingest data into Elasticsearch starting with the raw data files from DonorsChoose.org, follow the instructions below:


##### 1. Download the following files: <br>
- `donorschoose_process_data.py` - Python script to process and join raw files
- `donorschoose_mapping.json` contains mapping for Elasticsearch index

##### 2. Download data from DonorsChoose.org website <br>
The DonorsChoose.org provide ~ decade's worth of donations, projects, resources, essay and gift card data. In this example, we will only use the donations, projects and resources datasets. Download the following datasets:
  - [Projects](https://s3.amazonaws.com/open_data/csv/opendata_projects.zip)
  - [Donations](https://s3.amazonaws.com/open_data/csv/opendata_donations.zip)
  - [Resources](https://s3.amazonaws.com/open_data/csv/opendata_resources.zip)

Copy the downloaded files to a sub-folder called `data`, and uncompress them. The `donorschoose_process_data.py` will read the `opendata_resources.csv`, `opendata_donations.csv` and `opendata_projects.csv` from the `data` folder.

##### 3. Run Python script to process, join data and index data<br>
Run `donorschoose_process_data.py` (requires Python 3). When the script is done running, you will have a `donorschoose` index in your Elasticsearch instance
```
  python3 donorschoose_process_data.py
```
NOTE: It might take ~ 30 minutes for this step.

##### 4. Check if data is available in Elasticsearch
Check to see if all the data is available in Elasticsearch. If all goes well, you should get a `count` response of `3506071` when you run the following command.

  ```shell
  curl -XGET localhost:9200/donorschoose/_count -d '{
  	"query": {
  		"match_all": {}
  	}
  }'
  ```
