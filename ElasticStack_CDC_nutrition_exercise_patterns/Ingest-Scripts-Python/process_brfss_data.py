# In[19]:
import xport
import pandas as pd
import csv
import numpy as np
import re
import elasticsearch
import json
import pprint as pprint

es = elasticsearch.Elasticsearch()

# Import data and read into a dataframe
f = open('./LLCP2013.ASC', encoding='iso-8859-1')
cdc = f.read().splitlines()
t = pd.DataFrame({'Var': cdc})

# Data references:
# - Data: http://www.cdc.gov/brfss/annual_data/2013/files/LLCP2013ASC.ZIP
# - Data Codebook: http://www.cdc.gov/brfss/annual_data/2013/pdf/codebook13_llcp.pdf
# - Variable layout: http://www.cdc.gov/brfss/annual_data/2013/llcp_varlayout_13_onecolumn.html


# Each row in BRFSS data file correspondents to a respondent. The response to 321 questions is coded in
# a single 2365 character long numeric string. The variable_list.csv file contains a maps the column number
# to fields. For example, column 18-19 is a 2-digit code for the interview month
var = pd.read_csv('./variable_list.csv')

# We will only be looking at a subset of the columns in this analysis - these columns have been coded with a
# Keep = Yes value in the variable list.
varKeep = var[var['Keep'] == 'Yes']


# Decode the numeric response into feature.
for i, row in varKeep.iterrows():
    st = row['Starting Column'] - 1
    en = st + row['Field Length']
    #print(st, en)
    t[row['Variable Name']] = t['Var'].map(lambda x: x[st:en])
    #print(row['Variable Name'])

# Create deep copy of variable
t1 = t.copy(deep=True)

# Function to convert datetime
from datetime import datetime
def str_to_iso(text):
    if text != '':
        for fmt in (['%m%d%Y','%d%m%Y']):
            try:
                return datetime.isoformat(datetime.strptime(text, fmt))
            except ValueError:
                if text == '02292014':
                    return datetime.isoformat(datetime.strptime('02282014', fmt))
                elif text == '09312014':
                    return datetime.isoformat(datetime.strptime('09302014', fmt))
                print(text)
                pass
                raise ValueError('Changing date')
    else:

        return None


# id to state map
st = pd.read_csv('./State.csv')

# Convert state value from string to int
t1['_STATE'] = t1['_STATE'].map(lambda x: int(x))

# Map numeric value of stateto state name
st1 = st[['ID', 'State']].set_index('ID').to_dict('dict')['State']
t1['_STATE'] = t1['_STATE'].replace(st1)

# Grab avg coordinates for state
lat = st.set_index('State')[['Latitude']].to_dict()['Latitude']
lon = st.set_index('State')[['Longitude']].to_dict()['Longitude']
t1['Latitude'] = t1['_STATE'].replace(lat)
t1['Longitude'] = t1['_STATE'].replace(lon)

# Convert interview date values into numeric
t1['FMONTH'] = t1['FMONTH'].map(lambda x: int(x))
t1['IMONTH'] = t1['IMONTH'].map(lambda x: int(x))
t1['IDAY'] = t1['IDAY'].map(lambda x: int(x))
t1['IDATE'] = t1['IDATE'].map(lambda x: str_to_iso(x))


# Alcohol consumption
t1['AVEDRNK2'] = t1['AVEDRNK2'].map(lambda x: int(x) if not str.isspace(x) else None) # drinks per occasion
t1['DRNK3GE5'] = t1['DRNK3GE5'].map(lambda x: int(x) if not str.isspace(x) else None) # binge days
t1['MAXDRNKS'] = t1['MAXDRNKS'].map(lambda x: int(x) if not str.isspace(x) else None) # max drinks per occasion in last 30 days
t1['_DRNKDY4'] = t1['_DRNKDY4'].map(lambda x: int(x) if not str.isspace(x) else None) # drinks/day
t1['_DRNKMO4'] = t1['_DRNKMO4'].map(lambda x: int(x) if not str.isspace(x) else None) # drinks/month
t1['DROCDY3_'] = t1['DROCDY3_'].map(lambda x: int(x) if not str.isspace(x) else None) # drink occasions in last 30 days

choice = {'1':'No', '2':'Yes', '9': 'Missing'}
t1['_RFBING5'] = t1['_RFBING5'].replace(choice) #  binge drinker?

choice = {'1':'Yes', '2':'No', '7':'Don\'t know' , '9': 'Refused'}
t1['DRNKANY5'] = t1['DRNKANY5'].replace(choice) # any drinks in last 30 days?



# Activity & exercise
# Refer to the codebook ( http://www.cdc.gov/brfss/annual_data/2013/pdf/codebook13_llcp.pdf) for variable meaning

t1['METVL11_'] = t1['METVL11_'].map(lambda x: int(x) if not str.isspace(x) else None)/10
t1['METVL21_'] = t1['METVL21_'].map(lambda x: int(x) if not str.isspace(x) else None)/10
t1['MAXVO2_'] = t1['MAXVO2_'].map(lambda x: int(x) if not str.isspace(x) else None) / 100
t1['FC60_'] = t1['FC60_'].map(lambda x: int(x) if not str.isspace(x) else None) / 100
t1['PADUR1_'] = t1['PADUR1_'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['PADUR2_'] = t1['PADUR2_'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['PAFREQ1_'] = t1['PAFREQ1_'].map(lambda x: int(x) if not str.isspace(x) else None) / 1000
t1['PAFREQ2_'] = t1['PAFREQ2_'].map(lambda x: int(x) if not str.isspace(x) else None) / 1000
t1['STRFREQ_'] = t1['STRFREQ_'].map(lambda x: int(x) if not str.isspace(x) else None) / 1000
t1['PAMIN11_'] = t1['PAMIN11_'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['PAMIN21_'] = t1['PAMIN21_'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['PA1MIN_'] = t1['PA1MIN_'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['PAVIG11_'] = t1['PAVIG11_'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['PAVIG21_'] = t1['PAVIG21_'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['PA1VIGM_'] = t1['PA1VIGM_'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['EXERHMM1'] = t1['EXERHMM1'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['EXERHMM2'] = t1['EXERHMM2'].map(lambda x: int(x) if not str.isspace(x) else None)

#t1['EXEROFT1'] = t1['EXEROFT1'].map(lambda x: exerFcn(x))
#t1['EXEROFT2'] = t1['EXEROFT2'].map(lambda x: exerFcn(x))
#t1['STRENGTH'] = t1['STRENGTH'].map(lambda x: exerFcn(x))

choice = {'1':'Yes', '2':'No', '7':'Don\'t know' , '9': 'Refused'}
t1['EXERANY2'] = t1['EXERANY2'].replace(choice)

choice={'1': 'Had exercise in last 30 days',
        '2': 'No exercise in last 30 days',
        '9': 'Don’t know/Not sure/Missing'}

t1['_TOTINDA'] = t1['_TOTINDA'].replace(choice)


choice = { '0' : 'Not Moderate / Vigorous or No Activity',
           '1' : 'Moderate',
           '2' : 'Vigorous'}

t1['ACTIN11_'] = t1['ACTIN11_'].replace(choice)
t1['ACTIN21_'] = t1['ACTIN21_'].replace(choice)


choice = {'1' : 'Highly Active',
          '2' : 'Active',
          '3' : 'Insufficiently Active',
          '4' : 'Inactive',
          '9' : 'Don’t know' }

t1['_PACAT1'] = t1['_PACAT1'].replace(choice)

choice = {'1' : 'Met aerobic recommendations',
          '2' : 'Did not meet aerobic recommendations',
          '9' : 'Don’t know' }

t1['_PAINDX1'] = t1['_PAINDX1'].replace(choice)

choice = {'1' : 'Meet muscle strengthening recommendations',
          '2' : 'Did not meet muscle strengthening recommendations',
          '9' : 'Missing'}

t1['_PASTRNG'] = t1['_PASTRNG'].replace(choice)

choice = {'1' : 'Met both guidelines',
          '2' : 'Met aerobic guidelines only',
          '3' : 'Met strengthening guidelines only',
          '4' : 'Did not meet either guideline',
          '9' : 'Missing' }

t1['_PAREC1'] = t1['_PAREC1'].replace(choice)


choice = {'1' : 'Met both guidelines',
          '2' : 'Did not meet both guideline',
          '9' : 'Missing' }

#t1['_PASTAE1'] = t1['_PASTAE1'].replace(choice)

# Map activity code to activity names
act = pd.read_csv('./activity.csv', encoding='iso-8859-1')
act['Activity'] = act['Activity'].map(lambda x: re.sub(r'\s*$','', x))

t1['EXRACT11'] = t1['EXRACT11'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['EXRACT11'] = t1['EXRACT11'].replace(act.set_index('ID').to_dict()['Activity'])

t1['EXRACT21'] = t1['EXRACT21'].map(lambda x: int(x) if not str.isspace(x) else '')
t1['EXRACT21'] = t1['EXRACT21'].replace(act.set_index('ID').to_dict()['Activity'])




# Height, Weight, Age, BMI
t1['_BMI5'] = t1['_BMI5'].map(lambda x: int(x) if not str.isspace(x) else None)/100

choice={'1': 'Underweight',
        '2': 'Normal weight',
        '3': 'Overweight',
        '4':'Obese'}

t1['_BMI5CAT'] = t1['_BMI5CAT'].replace(choice)

# Height & Weight
t1['WTKG3'] = t1['WTKG3'].map(lambda x: int(x) if not str.isspace(x) else None)/100
t1['HTM4'] = t1['HTM4'].map(lambda x: int(x) if not str.isspace(x) else None)/100
t1['HTIN4'] = t1['HTIN4'].map(lambda x: int(x) if not str.isspace(x) else None)


# Nutrition
## NOTE:  Values include two implied decimal places
# Vegetable & Fruit intake per day
t1['_FRUTSUM'] = t1['_FRUTSUM'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['_VEGESUM'] = t1['_VEGESUM'].map(lambda x: int(x) if not str.isspace(x) else None)

# Food intake - times per day
t1['FRUTDA1_'] = t1['FRUTDA1_'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['VEGEDA1_'] = t1['VEGEDA1_'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['GRENDAY_'] = t1['GRENDAY_'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['ORNGDAY_'] = t1['ORNGDAY_'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['FTJUDA1_'] = t1['FTJUDA1_'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['BEANDAY_'] = t1['BEANDAY_'].map(lambda x: int(x) if not str.isspace(x) else None)

# Salt intake and advice
choice = {'1':'Yes', '2':'No', '7':'Don\'t know' , '9': 'Refused'}
t1['WTCHSALT'] = t1['WTCHSALT'].replace(choice)
t1['DRADVISE'] = t1['DRADVISE'].replace(choice)


# In[13]:

# Demographics
choice = {'1' : 'Did not graduate High School',
          '2' : 'Graduated High School',
          '3' : 'Attended College or Technical School',
          '4' : 'Graduated from College or Technical School',
          '9' : 'Don’t know/Not sure/Missing'}

t1['_EDUCAG'] = t1['_EDUCAG'].replace(choice)

choice = {'1' : 'Male',
          '2' : 'Female'}
t1['SEX'] = t1['SEX'].replace(choice)

choice = {'1' : '< $15000',
          '2' : '$15,000 - $25,000',
          '3' : '$25,000 - $35,000',
          '4' : '$35,000 - $50,000',
          '5' : '> $50,000',
          '9' : 'Don’t know/Not sure/Missing'}

t1['_INCOMG'] = t1['_INCOMG'].replace(choice)

choice = {'1':'Employed for wages', '2':'Self-employed', '3': 'Unemployed < 1 year', '4': 'Unemployed > 1 year', '5': 'Homemaker', '6' : 'Student', '7': 'Retired' , '8': 'Unable to work', '9': 'Refused'}
t1['EMPLOY1'] = t1['EMPLOY1'].replace(choice)

choice = {'1':'< Kindergarden', '2':'Elementary', '3': 'Some high-school', '4': 'High-school graduate', '5': 'College / tech school', '6' : 'College grade', '9': 'Refused'}
t1['EDUCA'] = t1['EDUCA'].replace(choice)

choice = {'1':'Married', '2':'Divored', '4': 'Separated', '3': 'Separated',  '5': 'Never Married', '6':'Unmarried couple' , '9': 'Refused'}
t1['MARITAL'] = t1['MARITAL'].replace(choice)

choice = {'1':'Yes', '2':'No', '7':'Don\'t know' , '9': 'Refused'}
t1['VETERAN3'] = t1['VETERAN3'].replace(choice)

# Age
choice = {
'01' : 'Age 18 to 24',
    '02' : 'Age 25 to 29',
    '03' : 'Age 30 to 34',
    '04' : 'Age 35 to 39',
    '05': 'Age 40 to 44',
    '06' : 'Age 45 to 49',
    '07':  'Age 50 to 54',
    '08':  'Age 55 to 59',
    '09': 'Age 60 to 64',
    '10':  'Age 65 to 69',
    '11': 'Age 70 to 74',
    '12': 'Age 75 to 79' ,
    '13':  'Age 80 or older',
    '14':  'Don’t know/Refused/Missing'}

t1['_AGEG5YR'] = t1['_AGEG5YR'].replace(choice)


# General health
choice = {'5':'Poor', '3':'Good', '1':'Excellent', '2':'Very Good', '4':'Fair', '7':'Don\'t know' , '9': 'Refused'}
t1['GENHLTH'] = t1['GENHLTH'].replace(choice)

choice = {'1':'Yes', '2':'No', '7':'Don\'t know' , '9': 'Refused'}
t1['QLACTLM2'] = t1['QLACTLM2'].replace(choice)
t1['USEEQUIP'] = t1['USEEQUIP'].replace(choice)
t1['DECIDE']   = t1['DECIDE'].replace(choice)
t1['DIFFWALK'] = t1['DIFFWALK'].replace(choice)
t1['DIFFDRES'] = t1['DIFFDRES'].replace(choice)
t1['DIFFALON'] = t1['DIFFALON'].replace(choice)


t1['MENTHLTH'] = t1['MENTHLTH'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['POORHLTH'] = t1['POORHLTH'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['SLEPTIM1'] = t1['SLEPTIM1'].map(lambda x: int(x) if not str.isspace(x) else None)
t1['PHYSHLTH'] = t1['PHYSHLTH'].map(lambda x: int(x) if not str.isspace(x) else None)


# Map variable names to more descriptive names
varDict = var[['Variable Name', 'DESC']].to_dict('split')
varDict = dict(varDict['data'])
t1.rename(columns=varDict, inplace=True)

# Replace space / special characters with underscore
t1.rename(columns=lambda x: re.sub(' ', '_', x), inplace=True)
t1.rename(columns=lambda x: re.sub(r'\(|\-|\/|\|\>|\)|\#', '', x), inplace=True)
t1.rename(columns=lambda x: re.sub(r'\>', 'GT', x), inplace=True)

# Delete original row
del(t1['Var'])

t1.fillna('', inplace=True)

### Create and configure Elasticsearch index
# Name of index and document type
index_name = 'brfss';
doc_name = 'respondent'

# Delete donorschoose index if one does exist
if es.indices.exists(index_name):
    es.indices.delete(index_name)

# Create donorschoose index
es.indices.create(index_name)

# Add mapping
with open('brfss_mapping.json') as json_mapping:
    d = json.load(json_mapping)

es.indices.put_mapping(index=index_name, doc_type=doc_name, body=d)

### Index Data into Elasticsearch

for subj_id, subject in t1.iterrows():
    if subj_id % 1000 == 0:
        print(subj_id)
    thisResp = subject.to_dict()
    thisResp['Coordinates'] = [thisResp['Longitude'], thisResp['Latitude']]
    thisDoc = json.dumps(thisResp);
    #pprint.pprint(thisDoc)

    # write to elasticsearch
    es.index(index=index_name, doc_type=doc_name, id=subj_id, body=thisDoc)
