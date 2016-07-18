## Ingest Data using Python & Logstash

If you want to ingest data into Elasticsearch starting with the raw data files from US FEC, follow the instructions below:


##### 1. Download the contents of this folder  <br>
- `usfec_process_data.py` - Python script to process and join raw files
- `US.txt` and `zip_codes.csv` files - zip code to lat/long mapping files which the Python script uses to enrich zip codes in the raw data with a lat/long that Elasticsearch can use for geo queries.
- `usfec_template.json` contains mapping for Elasticsearch index
- `usfec_logstash.conf` - Logstash config file to ingest data

##### 2. Download raw data from US FEC website <br>
  Download and unzip all 7 .zip file in [2013-2014](http://www.fec.gov/finance/disclosure/ftpdet.shtml#a2013_2014) section of the US FEC data portal. Once you unzip the files, you should have the following .txt files: `cm.txt`, `ccl.txt`, `cn.txt`, `itcont.txt`, `itpas2.txt`, `itoth.txt` and `oppexp.txt`. Make sure that unzipped data files are in the same directory used in Step. 1

##### 3. Run Python script to process and join data <br>
Run `usfec_process_data.py` (requires Python 3). When the script is done running, you will have a `data` subfolder with 4 `.json` files containing the processed data
```shell
  python3 usfec_process_data.py
```
##### 4. Index data into Elasticsearch using Logstash
  Run the following command to index data from `.json` files (created in step 3) into your Elasticsearch instance.

  ```
  cat ./data/*.json | <path_to_logstash_root_dir>/logstash -f usfec_logstash.conf

  ```

##### 5. Check if data is available in Elasticsearch
Check to see if all the data is available in Elasticsearch. If all goes well, you should get a `count` response of ~4250251 when you run the following command.

  ```shell
  curl -XGET localhost:9200/usfec*/_count -d '{
  	"query": {
  		"match_all": {}
  	}
  }'
  ```
