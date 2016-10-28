## Ingest Data using Python scripts

If you want to ingest data into Elasticsearch starting with the raw CSV data files follow the instructions below:

##### 1. Download the following files: <br>
- `ingestRestaurantData.py` - Python script to process and ingest
- `inspection_mapping.json` contains mapping for Elasticsearch index

##### 2. Run Python script to process, join data and index data<br>
Run `ingestRestaurantData.py` (requires Python 3). When the script is done running, you will have a `nyc_restaurants` index in your Elasticsearch instance
```
  python3 ingestRestaurantData.py
```
NOTE:
- The script makes a call to Google geocoding API to get the lat/lon information for restaurants addresses. (a) You might need to sign up for a API key to avoid hitting usage limits. (b) Depending on your internet connection and the size of the inspection dataset, this step might take a 30 minutes to a few hours to complete.
- We have also included a iPython Notebook version of the script `ingestRestaurantData.ipynb` in case you prefer running in a cell-by-cell mode.

##### 3. Check if data is available in Elasticsearch
Check to see if all the data is available in Elasticsearch. If all goes well, you should get a `count` response of `473039` when you run the following command.

  ```shell
  curl -XGET localhost:9200/nyc_restaurants/_count -d '{
  	"query": {
  		"match_all": {}
  	}
  }'
  ```
