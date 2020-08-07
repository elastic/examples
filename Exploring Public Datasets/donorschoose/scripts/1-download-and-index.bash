#!/bin/bash

# this script will download all the data files.  
# We're kind of assuming you cloned the example github repo or at least this directory on down
# You can run ES/KB locally in docker with  "docker-compose up" from the parent directory 

# increase docker memory something or other
# sudo sysctl -w vm.max_map_count=262144

# This assumes elasticsearch is running locally on port 9200 - 
echo testing to see elasticsearch is running locally
curl http://localhost:9200/ > /dev/null 
# grab GET exit code
exit_code=$?
# if exit code is not 0 (failed), then return it
test $exit_code -eq 0 || exit $exit_code
echo elasticsearch is running locally

# Download the raw data to a data directory
if [ ! -d data ];then
    mkdir data
fi
cd data
# Download index snapshot to elastic_donorschoose directory
if [ ! -f opendata_projects000.gz ]; then
    wget http://s3.amazonaws.com/open_data/opendata_projects000.gz
fi
if [ ! -f opendata_donations000.gz ]; then
    wget http://s3.amazonaws.com/open_data/opendata_donations000.gz
fi
if [ ! -f opendata_resources000.gz ]; then
    wget http://s3.amazonaws.com/open_data/opendata_resources000.gz
fi
cd ..

# install require python libraries - assumes pip3 installed
# sudo apt install python3-pip
# assumes that pip is installed
echo "Installing Python dependencies"
pip3 install -r requirements.txt
# grab install's exit code
exit_code=$?
# if exit code is not 0 (failed), then return it
test $exit_code -eq 0 || exit $exit_code

# load elasticsearch - could abort here and use the Jypter notebook script.
python3 donorschoose_process_data.py

# install Kibana visualizaton dashboard
# probably better to do this manually
#curl --data ../donorschoose_dashboard.ndjson http://localhost:5601/api/kibana/dashboards/import