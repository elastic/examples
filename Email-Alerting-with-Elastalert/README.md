# Email ALerts example :

Basically one needs a gold or platinum package to activate/send email alerts via ELK using X-pack watchers but in this example i'm going to demonstrate how to configure ELK stack of basic license to send free email alerts for life time.
We can do this using [ElastAlert](https://github.com/Yelp/elastalert).

`Note: This whole example is demostrated assuming that you are using Linux/Ubuntu based operating system.`

### Tested Enivironment:

* Ubuntu 18/20
* Elastic Stack 7.8.0
* ElastAlert (Latest Version)


### Dependencies you need have in your host

* Java 8 or above 

To check which version you have 

```cmd
    java --version
```

output : (In my case i'm having java 11)

```cmd 
    openjdk 11.0.8 2020-07-14
    OpenJDK Runtime Environment (build 11.0.8+10-post-Ubuntu-0ubuntu120.04)
    OpenJDK 64-Bit Server VM (build 11.0.8+10-post-Ubuntu-0ubuntu120.04, mixed mode, sharing)
```

* Python (version 3+ recommended)

```cmd
    sudo apt-get install -y python3 
    sudo apt-get install -y python3-pip python3-dev libffi-dev libssl-dev 
```
To verify the installation 

```cmd
        python3 --version

```
Output :  

``` cmd 
        Python 3.8.2 (version no can be varied) 
```
The above output tells that python has been installed successfully

* ElasticSearch 7.8.0 (Linux x86_64)  : [Download from here](https://www.elastic.co/downloads/past-releases/elasticsearch-7-8-0)

* Kibana 7.8.0 (Linux 64-bit)          : [Download from here](https://www.elastic.co/downloads/past-releases/kibana-7-8-0)

* Logstash 7.8.0 (TAR.GZ)               : [Download from here](https://www.elastic.co/downloads/past-releases/logstash-7-8-0)

Now visit the directory where you have cloned and downloaded and execute the command to find your tar files
 
```cmd 
ls -lh | grep tar.gz
```

Output :

```cmd
-rwxrwxrwx 1 vvk vvk 305M Jul  7 19:38 elasticsearch-7.8.0-linux-x86_64.tar.gz
-rwxrwxrwx 1 vvk vvk 319M Jul  7 19:39 kibana-7.8.0-linux-x86_64.tar.gz
-rwxrwxrwx 1 vvk vvk 160M Jul  7 19:39 logstash-7.8.0.tar.gz
```

Extract them one by one :

```cmd 
    Format :  tar -xvf <tar file>
    tar -xvf elasticsearch-7.8.0-linux-x86_64.tar.gz
    tar -xvf kibana-7.8.0-linux-x86_64.tar.gz
    tar -xuf logstash-7.8.0.tar.gz
```

* ElastAlert (Download Latest code) :

```cmd 
     git clone https://github.com/Yelp/elastalert.git
```
Now your directory should have the following files





# Intro

## What is ElastAlert ?

ElastAlert is an opensource framework for alerting duplicates, system spikes and for many other patterns present in the data of Elasticsearch.

## How it works ?

We define a rule in Elastalert (which is basically a query) -> if a match found in Elasticsearch data -> Elastalert sends an alert to your gmail  

