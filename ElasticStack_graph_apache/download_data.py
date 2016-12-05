import datetime,requests,gzip,shutil,os,argparse
from dateutil.relativedelta import *
from dateutil import parser as date_parser
parser = argparse.ArgumentParser(description='Download Secrepo Logs')
parser.add_argument('--start_date', dest="start_date", default="2015-01-17",help='start date')
parser.add_argument('--output_folder', dest="output_folder", default="./data",help='output folder')
parser.add_argument('--overwrite', dest="overwrite",type=bool, default=False,help='overwrite previous files')
args = parser.parse_args()
base_url="http://www.secrepo.com/self.logs/%s"
base_filename="access.log.%s.gz"
end_date = datetime.date.today()
output_folder=args.output_folder
current_date = date_parser.parse(args.start_date)

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

def extract(filename,overwrite):
    #only extract if it doesn't exist
    output_file=output_folder+'/'+(os.path.splitext(filename)[0])
    if not os.path.exists(output_file) or overwrite:
        print ("Extracting file %s"%filename)
        with gzip.open(filename, 'rb') as f_in, open(output_file, 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)
    else:
        print("Skipping Extraction File Exists")

if not os.path.exists(output_folder):
    os.mkdir(output_folder)
while current_date.date() < end_date:
    filename=base_filename%current_date.strftime('%Y-%m-%d')
    url = base_url%filename
    print("Downloading %s"%url)
    filename = download_file(url,filename)
    if filename:
        extract(filename,overwrite=args.overwrite)
        os.remove(filename)
    else:
        print("Could not download %s. Skipping."%url)
    current_date = current_date+relativedelta(days=+1)