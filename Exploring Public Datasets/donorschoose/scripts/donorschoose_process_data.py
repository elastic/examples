# coding: utf-8

### Import Packages
import pandas as pd
import numpy as np
import elasticsearch
import re
import json
from datetime import datetime
from elasticsearch import helpers
from time import perf_counter
import concurrent
#from numba import jit

# Define elasticsearch class
es = elasticsearch.Elasticsearch()

### Hfelper Functions
# convert np.int64 into int. json.dumps does not work with int64
class SetEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, np.int64):
            return np.int(obj)
        # else
        return json.JSONEncoder.default(self, obj)

# Convert datestamp into ISO format
def str_to_iso(text):
    if text != '':
        for fmt in ('%Y-%m-%d %H:%M:%S.%f', '%Y-%m-%d %H:%M:%S', '%Y-%m-%d'):
            try:
                return datetime.isoformat(datetime.strptime(text, fmt))
            except ValueError:
                pass
        raise ValueError('no valid date format found')
    else:
        return None

# Custom groupby function
def concatdf(x):
    if len(x) > 1:  #if multiple values
        return list(x)
    else: #if single value
        return x.iloc[0]

### Import Data
# Load projects, resources & donations data
print("Loading datasets")
start = perf_counter()
projects = pd.read_csv('./data/opendata_projects000.gz', escapechar='\\', names=['projectid', 'teacher_acctid', 'schoolid', 'school_ncesid', 'school_latitude', 'school_longitude', 'school_city', 'school_state', 'school_zip', 'school_metro', 'school_district', 'school_county', 'school_charter', 'school_magnet', 'school_year_round', 'school_nlns', 'school_kipp', 'school_charter_ready_promise', 'teacher_prefix', 'teacher_teach_for_america', 'teacher_ny_teaching_fellow', 'primary_focus_subject', 'primary_focus_area' ,'secondary_focus_subject', 'secondary_focus_area', 'resource_type', 'poverty_level', 'grade_level', 'vendor_shipping_charges', 'sales_tax', 'payment_processing_charges', 'fulfillment_labor_materials', 'total_price_excluding_optional_support', 'total_price_including_optional_support', 'students_reached', 'total_donations', 'num_donors', 'eligible_double_your_impact_match', 'eligible_almost_home_match', 'funding_status', 'date_posted', 'date_completed', 'date_thank_you_packet_mailed', 'date_expiration'])
donations = pd.read_csv('./data/opendata_donations000.gz', escapechar='\\', names=['donationid', 'projectid', 'donor_acctid', 'cartid', 'donor_city', 'donor_state', 'donor_zip', 'is_teacher_acct', 'donation_timestamp', 'donation_to_project', 'donation_optional_support', 'donation_total', 'donation_included_optional_support', 'payment_method', 'payment_included_acct_credit', 'payment_included_campaign_gift_card', 'payment_included_web_purchased_gift_card', 'payment_was_promo_matched', 'is_teacher_referred', 'giving_page_id', 'giving_page_type', 'for_honoree', 'thank_you_packet_mailed'])
resources = pd.read_csv('./data/opendata_resources000.gz', escapechar='\\', names=['resourceid', 'projectid', 'vendorid', 'vendor_name', 'item_name', 'item_number', 'item_unit_price', 'item_quantity'])
end = perf_counter()
print(end - start)

### Data Cleanup
# replace nan with ''
print("Cleaning Data")
start = perf_counter()
projects = projects.fillna('')
donations = donations.fillna('')
resources = resources.fillna('')

#  Clean up column names: remove _ at the start of column name
donations.columns = donations.columns.map(lambda x: re.sub('^ ', '', x))
donations.columns = donations.columns.map(lambda x: re.sub('^_', '', x))
projects.columns = projects.columns.map(lambda x: re.sub('^_', '', x))
resources.columns = resources.columns.map(lambda x: re.sub('^ ', '', x))
resources.columns = resources.columns.map(lambda x: re.sub('^_', '', x))

# Add quotes around projectid values to match format in projects / donations column
resources['projectid'] = resources['projectid'].map(lambda x: '"' + x +'"')

# Add resource_prefix to column names
resources.rename(columns={'vendorid': 'resource_vendorid', 'vendor_name': 'resource_vendor_name', 'item_name': 'resource_item_name',
       'item_number' :'resource_item_number', "item_unit_price": 'resource_item_unit_price',
       'item_quantity': 'resource_item_quantity'}, inplace=True)
end = perf_counter()
print(end - start)

### Merge multiple resource row per projectid into a single row
# NOTE: section may take a few minutes to execute
print("Grouping Data by ProjectId")
start = perf_counter()

concat_resource = pd.DataFrame()
# a DataFrameGroupBy
resources_grouped_by_projectid = resources.groupby('projectid')

# try and set this up for parallel operations later
def do_concat(one_group_by):
    return one_group_by.apply(lambda x: concatdf(x))

for a in resources.columns.values:
    # Iterate across the DataFrameGroupBy operating on one SeriesGroupBy at a time
    print("column "+ a)
    concat_resource[a]=do_concat(resources_grouped_by_projectid[a])
    # print(concat_resource[a])

concat_resource['projectid'] = concat_resource.index;
concat_resource.reset_index(drop=True);
concat_resource.index.name = None
concat_resource.set_index('projectid', inplace=True, drop=True)

end = perf_counter()
print(end - start)

### Rename Project columns
print("Renaming project columns")
start = perf_counter()

projects.rename(columns=lambda x: "project_" + x, inplace=True)
projects.rename(columns={"project_projectid": "projectid"}, inplace=True)
projects.columns.values
projects.index.name = None
projects.set_index('projectid', inplace=True, drop=True)

end = perf_counter()
print(end - start)

#### Merge data into single frame
print("Merging datasets")
start = perf_counter()
data = pd.merge(projects, concat_resource, how='left', right_on='projectid', left_on='projectid')
data = pd.merge(donations, data, how='left', right_on='projectid', left_on='projectid')
data = data.fillna('')
end = perf_counter()
print(end - start)

#### Process columns
# Modify date formats
print("Modifying Date Formats")
start = perf_counter()
data['project_date_expiration'] = data['project_date_expiration'].map(lambda x: str_to_iso(x));
data['project_date_posted'] = data['project_date_posted'].map(lambda x: str_to_iso(x))
data['project_date_thank_you_packet_mailed'] = data['project_date_thank_you_packet_mailed'].map(lambda x: str_to_iso(x))
data['project_date_completed'] = data['project_date_completed'].map(lambda x: str_to_iso(x))
data['donation_timestamp'] = data['donation_timestamp'].map(lambda x: str_to_iso(x))
end = perf_counter()
print(end - start)

# Create location field that combines lat/lon information
data['project_location'] = data[['project_school_longitude','project_school_latitude']].values.tolist()
del(data['project_school_latitude'])  # delete latitude field
del(data['project_school_longitude']) # delete longitude
end = perf_counter()
print(end - start)


### Create and configure Elasticsearch index
print("Preparing to Index to ES")
start = perf_counter()
# Name of index and document type
index_name = 'donorschoose'
doc_name = 'donation'

# Delete donorschoose index if one does exist
if es.indices.exists(index_name):
    es.indices.delete(index_name)

# Create donorschoose index
es.indices.create(index_name)

# Add mapping
with open('donorschoose_mapping.json') as json_mapping:
    d = json.load(json_mapping)

es.indices.put_mapping(index=index_name, doc_type=doc_name, body=d, include_type_name=True)
end = perf_counter()
print(end - start)

### function used by all below
def read_data(df):
    for don_id, thisDonation in df.iterrows():
        # print every 10000 iteration
        if don_id % 10000 == 0:
            print('{} / {}'.format(don_id, len(df.index) ))
        doc={}
        doc["_index"]=index_name
        doc["_id"]=thisDonation['donationid']
        doc["_type"]=doc_name
        doc["_source"]=thisDonation.to_dict()
        yield doc

### Index Data into Elasticsearch - parallel bulk - default parallel_bulk thread_count = 4
print("Indexing parallel_bulk")
start = perf_counter()
# parallel_bulk returns generators which must be consumed https://elasticsearch-py.readthedocs.io/en/master/helpers.html
# default request_timeout=10
# 1000 may have timeout
for success, info in helpers.parallel_bulk(es, read_data(data),thread_count=8, request_timeout=20.0, chunk_size=500, index=index_name,doc_type=doc_name):
    if not success:
        print('A document failed:', info)

# non parallel bulk - can run this instead - parallel takes about 40% of the time
# helpers.bulk(es,read_data(data), index=index_name,doc_type=doc_name)
end = perf_counter()
print(end - start)
