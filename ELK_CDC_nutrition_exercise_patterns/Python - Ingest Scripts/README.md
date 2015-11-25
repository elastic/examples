## Ingest Data using Python scripts

If you want to ingest data into Elasticsearch starting with the raw data files from [www.cdc.gov](http://www.cdc.gov/brfss/annual_data/annual_2013.html), follow the instructions below:


##### 1. Download files in this folder: <br>

##### 2. Download 2013 BRFSS data from cdc.gov website <br>

  - [2013 BRFSS ASCII.zip](http://www.cdc.gov/brfss/annual_data/2013/files/LLCP2013ASC.ZIP)

Unzip and copy the files into the folder containing the files downloaded in step 1.

##### 3. Run Python script to process and index data<br>
Run `process_brfss_data.py` (requires Python 3). When the script is done running, you will have a `brfss` index in your Elasticsearch instance
```
  python3 process_brfss_data.py
```
NOTE:
- It might take ~ 30-60 minutes for this step (depending on your machine)
- We have also included a iPython Notebook version of the script `process_brfss_data.ipynb` in case you prefer running in a cell-by-cell mode.

##### 4. Check if data is available in Elasticsearch
Check to see if all the data is available in Elasticsearch. If all goes well, you should get a `count` response of `` when you run the following command.

  ```shell
  curl -XGET localhost:9200/brfss/_count -d '{
  	"query": {
  		"match_all": {}
  	}
  }'
  ```
