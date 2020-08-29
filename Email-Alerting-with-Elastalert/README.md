# Email Alerts example :

Basically one needs a gold or platinum package to activate/send email alerts via ELK using X-pack watchers but in this example i'm going to demonstrate how to configure ELK stack(basic license) to send free email alerts using [ElastAlert](https://github.com/Yelp/elastalert).

`Note: This whole example is demostrated assuming that you are using Linux/Ubuntu based operating system.`

### Tested Enivironment:

* Ubuntu 18/20
* Elastic Stack 7.8.0
* ElastAlert (Latest Version)


### Dependencies you need have in your host :

* Java 8 or above 

To check which version you have 

```cmd
    java --version
```

Output : (In my case i'm having java 11)

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
The above output tells that python has been installed successfully.

* ElasticSearch 7.8.0 (Linux x86_64)  : [Download from here](https://www.elastic.co/downloads/past-releases/elasticsearch-7-8-0)


* Kibana 7.8.0 (Linux 64-bit)          : [Download from here](https://www.elastic.co/downloads/past-releases/kibana-7-8-0)


* Logstash 7.8.0 (TAR.GZ)               : [Download from here](https://www.elastic.co/downloads/past-releases/logstash-7-8-0)


Now visit the directory where you have cloned , downloaded and 
execute the below command to find your tar files
 
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
Now your directory should have the following files :

![Downloaded Dependencies](https://raw.githubusercontent.com/vvvk-gh/examples/master/Email-Alerting-with-Elastalert/Images/Downloads.png)


# Introduction 

Before making any new changes, let's understand why, where and how Elastalert is useful and configured.

## What is ElastAlert ?

ElastAlert is an opensource framework for alerting duplicates, system spikes and for many other patterns present in the data/documents of Elasticsearch.

## How it works ?

We define a rule in Elastalert (which is basically a query) -> if a match found in Elasticsearch data -> Elastalert sends an alert to your gmail  

# Configuration changes :

1. Elasticsearch :
    Replace your `elasticsearch-7.8.0-linux-x86_64/config/elasticsearch.yml` file with `elasticsearch.yml` 
    
    - Save it

    - Run it 
    ```cmd
        ./bin/elasticsearch
    ```
    - Verify it 
        by opening [localhost:9200](http://localhost:9200) in your browser
        which will be showing your cluster details

2. Kibana :
    Replace your `kibana-7.8.0-linux-x86_64/config/kibana.yml` file with `kibana.yml` 
    
    - Save it

    - Run it

    ```cmd
        ./bin/kibana
    ```
    
    - Verify it 
        by opening [localhost:5601](http://localhost:5601) in your browser
        which will open your kibana

3. ElastAlert 
    * go to cloned project

    ```cmd
        cd elastalert
    ```
    do the following

    ```cmd
        sudo pip3 install "setuptools>=11.3" 
        sudo pip3 install pyOpenSSL 
        sudo python3 setup.py install 
        sudo pip3 install "elasticsearch>=5.0.0" 
    ```
    
    * Copy config.yaml.example into config.yaml  
    
    ```cmd

        cp config.example.yaml config.yaml

    ```
    and replace new copied `config.yaml` with `config.yaml` in this project and save it.

    * Create Elastalert Indices 

        ```cmd
            elastalert-create-index
        ```
       Output :

        ```cmd
            Elastic Version: 7.8.0
            Reading Elastic 6 index mappings:
            Reading index mapping 'es_mappings/6/silence.json'
            Reading index mapping 'es_mappings/6/elastalert_status.json'
            Reading index mapping 'es_mappings/6/elastalert.json'
            Reading index mapping 'es_mappings/6/past_elastalert.json'
            Reading index mapping 'es_mappings/6/elastalert_error.json'
            New index elastalert_status created
            Done!
         ```

    * Writing the test rules  

        rules are defined in example_rules folder and we are going to use only `frequency based` test rule in this example which means

        > Alert an email if a match found at X events/documents in Y time 

        replace the `./example_rules/example_frequency.yaml` with `example_frequency.yaml` in this project and also download and add 'stmp_auth_file.txt' in the same directory `./example_rules/`

        Now, modify the both files in a way that serves your needs

    example_frequency.yaml

    ```YAML
        email:
            - "yourgmail@gmail.com"
        smtp_host: "smtp.gmail.com."
        smtp_port: 465
        smtp_ssl: true
        from_addr: "yourgmail@gmail.com"
        smtp_auth_file: '/path/to/file/smtp_auth_file.txt'
    ```
    smtp_auth_file.txt

    ```txt
        user : yourgmail@gmail.com
        password: yourgmailpassword
    ```

4. Logstash 

    Add the `elasalert_logstash.conf` into your `logstash-7.8.0/config/` and also
    download the sample logs file `cpustruck_syslogs.log` in the same path
    
    - Save it

    - Run it

    ```cmd
         ./bin/logstash -f /path/to/elastalert_logstash.conf
    ```
    
    This will push the sample logs to elasticsearch and also prints them to console

5. Test Run Elastalert 

    ```cmd
         elastalert-test-rule example_rules/example_frequency.yaml
    ```
    
    Output :

    ![Image of TestRun](https://raw.githubusercontent.com/vvvk-gh/examples/master/Email-Alerting-with-Elastalert/Images/Testrun.png)
 
6. Running ElastAlert

    ```teriminal
        python3 -m elastalert.elastalert --verbose --rule example_frequency.yaml
    ```

If you get a match it will alert to configured email.


![Emailnotification](https://raw.githubusercontent.com/vvvk-gh/examples/master/Email-Alerting-with-Elastalert/Images/Emailnotificatin.png)

![Image of EmailNotification](https://raw.githubusercontent.com/vvvk-gh/examples/master/Email-Alerting-with-Elastalert/Images/Emailalert.png)


Its additional supports alerts via 
   * Command
   * JIRA
   * OpsGenie
   * SNS
   * HipChat
   * Slack
   * Telegram
   * GoogleChat
   * Debug
   * Stomp
   * theHive

For more details 

visit the [documentation](https://elastalert.readthedocs.io/en/latest/elastalert.html)