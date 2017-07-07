import requests,shutil, zipfile

import os

url="http://files.grouplens.org/datasets/movielens/ml-20m.zip"
filename="data.zip"
output_folder="./data"

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
    with zipfile.ZipFile(filename, 'r') as zip_ref:
        zip_ref.extractall(output_folder)

os.mkdir(output_folder)
print("Downloading %s to %s"%(url,filename))
filename = download_file(url,filename)
print("Extracting %s to %s"%(filename,output_folder))
extract(filename)
os.remove(filename)









