import datetime,requests,gzip,shutil
import os

from dateutil.relativedelta import *
from dateutil import parser

base_url="http://www.secrepo.com/self.logs/%s"
base_filename="access.log.%s.gz"
start_date="2015-01-17"
end_date = datetime.date.today()
output_folder="./data"
current_date = parser.parse(start_date)

def download_file(url,filename):
    r = requests.get(url, stream=True)
    if r.status_code == 200:
        with open(filename, 'wb') as f:
            for chunk in r.iter_content(chunk_size=1024):
                if chunk:
                    f.write(chunk)
        return filename
    print("Received %s code for %s"%(r.status_code,url))
    return None

def extract(filename):
    print ("Extracting file %s"%filename)
    with gzip.open(filename, 'rb') as f_in, open(output_folder+'/'+(os.path.splitext(filename)[0]), 'wb') as f_out:
        shutil.copyfileobj(f_in, f_out)

os.mkdir(output_folder)
while current_date.date() < end_date:
    filename=base_filename%current_date.strftime('%Y-%m-%d')
    url = base_url%filename
    print("Downloading %s"%url)
    filename = download_file(url,filename)
    if filename:
        extract(filename)
        os.remove(filename)
    else:
        print("Could not download %s. Skipping."%url)
    current_date = current_date+relativedelta(days=+1)









