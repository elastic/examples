# Ingest Data using Python scripts

If you want to ingest data into Elasticsearch starting with the raw data files from DonorsChoose.org, follow the instructions below.
You will need **64GB** of memory to run the ingestion while running ES on a local machine. 
The ingestion python has been modified to manipulate the data with 8 parallel processes.

There are two options. 
1. There is a single script that will do everything .
1. You can follow the step-by-step.

## Run the single script
`bash 1-download-and-index.bash`

## Download Step by Step
### Download the following files if you haven't cloned the repo

- `donorschoose_process_data.py` - Python script to process and join raw files
- `donorschoose_mapping.json` contains mapping for Elasticsearch index
- `requirements.tx` - Python requirements file

i.e.

```shell
wget https://raw.githubusercontent.com/elastic/examples/master/Exploring%20Public%20Datasets/donorschoose/scripts/donorschoose_mapping.json
wget https://raw.githubusercontent.com/elastic/examples/master/Exploring%20Public%20Datasets/donorschoose/scripts/donorschoose_process_data.py
wget https://raw.githubusercontent.com/elastic/examples/master/Exploring%20Public%20Datasets/donorschoose/scripts/requirements.txt
```

### Download data from DonorsChoose.org website 

The DonorsChoose.org provide ~ decade's worth of donations, projects, resources, essay and gift card data. In this example, we will only use the donations, projects and resources datasets. Download the following datasets:
  - [Projects](http://s3.amazonaws.com/open_data/opendata_projects000.gz)
  - [Donations](http://s3.amazonaws.com/open_data/opendata_donations000.gz)
  - [Resources](http://s3.amazonaws.com/open_data/opendata_resources000.gz)

Copy the downloaded files to a sub-folder called `data` - no need to decompress. The `donorschoose_process_data.py` is configured to read `opendata_resources000.gz`, `opendata_donations000.gz` and `opendata_projects000.gz` from the `data` folder. If you saved the data files to a different folder, be sure to modify the path in the Python script.

## Run the imports
### Setup Python Environment

Requires Python 3.  Install dependencies with pip i.e. `pip install -r requirements.txt`

### Run Python script to process, join data and index data

Run `donorschoose_process_data.py` (requires Python 3). When the script is done running, you will have a `donorschoose` index in your Elasticsearch instance
```
  python3 donorschoose_process_data.py
```
NOTE:
- It might take ~ 30 minutes for this step. 
- We have also included a iPython Notebook version of the script `donorschoose_process_data.ipynb` in case you prefer running in a cell-by-cell mode.

## 4. Check if data is available in Elasticsearch

Check to see if all the data is available in Elasticsearch. If all goes well, you should get a `count` response of `6211956` when you run the following command.

  ```shell
  curl -XGET localhost:9200/donorschoose/_count -d '{
  	"query": {
  		"match_all": {}
  	}
  }'
  ```
