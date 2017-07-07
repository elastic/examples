# coding: utf-8

# In[ ]:

import pandas as pd
import elasticsearch
import json
import re

es = elasticsearch.Elasticsearch()

# In this example, we use the [Google geocoding API](https://developers.google.com/maps/documentation/geocoding/) to translate addresses into geo-coordinates. Google imposes usages limits on the API. If you are using this script to index data, you many need to sign up for an API key to overcome limits.

# In[ ]:

from geopy.geocoders import GoogleV3

geolocator = GoogleV3()
# geolocator = GoogleV3(api_key=<your_google_api_key>)


# # Import Data
# Import restaurant inspection data into a Pandas dataframe 

# In[ ]:

t = pd.read_csv('https://data.cityofnewyork.us/api/views/43nn-pn8j/rows.csv?accessType=DOWNLOAD', header=0, sep=',',
                dtype={'PHONE': str, 'INSPECTION DATE': str});

# In[ ]:

## Helper Functions
from datetime import datetime


def str_to_iso(text):
    if text != '':
        for fmt in (['%m/%d/%Y']):
            try:
                # print(fmt)
                # print(datetime.strptime(text, fmt))
                return datetime.isoformat(datetime.strptime(text, fmt))

            except ValueError:
                # print(text)
                pass
                # raise ValueError('Changing date')
    else:

        return None


def getLatLon(row):
    if row['Address'] != '':
        location = geolocator.geocode(row['Address'], timeout=10000, sensor=False)
        if location != None:
            lat = location.latitude
            lon = location.longitude
            # print(lat,lon)
            return [lon, lat]

    elif row['Zipcode'] != '' or location != None:
        location = geolocator.geocode(row['Zipcode'], timeout=10000, sensor=False)

        if location != None:
            lat = location.latitude
            lon = location.longitude
            # print(lat,lon)
            return [lon, lat]
    else:
        return None


def getAddress(row):
    if row['Building'] != '' and row['Street'] != '' and row['Boro'] != '':
        x = row['Building'] + ' ' + row['Street'] + ' ' + row['Boro'] + ',NY'
        x = re.sub(' +', ' ', x)
        return x
    else:
        return ''


def combineCT(x):
    return str(x['Inspection_Date'][0][0:10]) + '_' + str(x['Camis'])


# # Data preprocessing

# In[ ]:

# process column names: remove spaces & use title casing
t.columns = map(str.title, t.columns)
t.columns = map(lambda x: x.replace(' ', '_'), t.columns)

# replace nan with ''
t.fillna('', inplace=True)

# Convert date to ISO format
t['Inspection_Date'] = t['Inspection_Date'].map(lambda x: str_to_iso(x))
t['Record_Date'] = t['Record_Date'].map(lambda x: str_to_iso(x))
t['Grade_Date'] = t['Grade_Date'].map(lambda x: str_to_iso(x))
# t['Inspection_Date'] = t['Inspection_Date'].map(lambda x: x.split('/'))

# Combine Street, Building and Boro information to create Address string
t['Address'] = t.apply(getAddress, axis=1)

# Create a dictionary of unique Addresses. We do this to avoid calling the Google geocoding api multiple times for the same address

# In[ ]:

addDict = t[['Address', 'Zipcode']].copy(deep=True)
addDict = addDict.drop_duplicates()
addDict['Coord'] = [None] * len(addDict)

# Get address for the geolocation for each address. This step can take a while because it's calling the Google geocoding API for each unique address.

# In[ ]:

for item_id, item in addDict.iterrows():
    if item_id % 100 == 0:
        print(item_id)
    if addDict['Coord'][item_id] == None:
        addDict['Coord'][item_id] = getLatLon(item)
        # print(addDict.loc[item_id]['Coord'])

# Save address dictionary to CSV
# addDict.to_csv('./dict_final.csv')



# In[ ]:

# Merge coordinates into original table
t1 = t.merge(addDict[['Address', 'Coord']])

# Keep only 1 value of score and grade per inspection 
t2 = t1.copy(deep=True)
t2['raw_num'] = t2.index
t2['RI'] = t2.apply(combineCT, axis=1)
yy = t2.groupby('RI').first().reset_index()['raw_num']

t2['Unique_Score'] = None
t2['Unique_Score'].loc[yy.values] = t2['Score'].loc[yy.values]
t2['Unique_Grade'] = None
t2['Unique_Grade'].loc[yy.values] = t2['Grade'].loc[yy.values]

del (t2['RI'])
del (t2['raw_num'])
del (t2['Grade'])
del (t2['Score'])

t2.rename(columns={'Unique_Grade': 'Grade', 'Unique_Score': 'Score'}, inplace=True)
t2['Grade'].fillna('', inplace=True)

# In[ ]:

t2.iloc[1]

# # Index Data

# In[ ]:

### Create and configure Elasticsearch index

# Name of index and document type
index_name = 'nyc_restaurants';
doc_name = 'inspection'

# Delete donorschoose index if one does exist
if es.indices.exists(index_name):
    es.indices.delete(index_name)

# Create donorschoose index
es.indices.create(index_name)

# In[ ]:

# Add mapping
with open('./inspection_mapping.json') as json_mapping:
    d = json.load(json_mapping)

es.indices.put_mapping(index=index_name, doc_type=doc_name, body=d)

# Index data
for item_id, item in t2.iterrows():
    if item_id % 1000 == 0:
        print(item_id)
    thisItem = item.to_dict()
    # thisItem['Coord'] = getLatLon(thisItem)
    thisDoc = json.dumps(thisItem);
    # pprint.pprint(thisItem)

    # write to elasticsearch
    es.index(index=index_name, doc_type=doc_name, id=item_id, body=thisDoc)


# In[ ]:
