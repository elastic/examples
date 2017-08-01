## Ingest Data using Python scripts

If you want to ingest data into Elasticsearch starting with the raw CSV data
files follow the instructions below:

#### 1. Download the following files:

- `ingestRestaurantData.py` - Python script to process and ingest.  Note that this script downloads the required dataset.
- `inspection_mapping.json` contains mapping for Elasticsearch index

#### 2. Install and Configure Python

Requires Python 3.
Install Dependencies using pip i.e. 
```console
pip install -r requirements.txt
```

Note that MacOS users may need to `brew install python3`, 
which would change the pip command to 
```console
pip3 install -r requirements.txt
```
#### 3. Optionally, configure the Python script for SSL

If your instance of Elasticsearch requires SSL, is not running locally, or both,
you can tweak the script to enable it.

Inside the script you will notice the connection string for Elasticsearch:

```code
 es = elasticsearch.Elasticsearch(
 #     ['host1'],
 #     http_auth=('myuser', 'mypassword'),
 #     port=443,
 #     use_ssl=True
)
```

Replace the host entry with the name of your Elasticsearch endpoint (if more
than one endpoint you can use a comma-separated list).  For additional arguments
see the Elasticsearch Python Client documentation
(https://elasticsearch-py.readthedocs.io/en/master/api.html)

#### 4. Run Python script to process, join data and index data

Run `ingestRestaurantData.py` (requires Python 3). When the script is done
running, you will have a `nyc_restaurants` index in your Elasticsearch instance
```
  python3 ingestRestaurantData.py
```
NOTE:
- The script makes a call to Google geocoding API to get the lat/lon information for restaurants addresses. (a) You might need to sign up for a API key to avoid hitting usage limits. (b) Depending on your internet connection and the size of the inspection dataset, this step might take a 30 minutes to a few hours to complete.
- We have also included a iPython Notebook version of the script `ingestRestaurantData.ipynb` in case you prefer running in a cell-by-cell mode.

#### 5. Check if data is available in Elasticsearch

Check to see if all the data is available in Elasticsearch. If all goes well, you should get a `count` response of `473039` when you run the following command.

  ```shell
  curl -H "Content-Type: application/json" -XGET localhost:9200/nyc_restaurants/_count -d '{
  	"query": {
  		"match_all": {}
  	}
  }'
  ```

note that if you are using https you will likely need to also use the
`--user username:password` with your curl command