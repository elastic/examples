# DNS Tunnel Detection

This sample demonstrates using Packetbeat with Elasticsearch and Alerting to
detect DNS tunnels using the number of unique FQDNs per domain as an indicator
of compromise.

For a detailed walk-through of the watch and the aggregations used here, see the
Elastic blog post titled [_Detecting DNS Tunnels with Packetbeat and
Watcher_](https://www.elastic.co/blog/detecting_dns_tunnels_with_packetbeat_and_watcher).

The above blog utilises an earlier version of the Elastic Stack.  This sample has been updated to reflect Elastic 5.0 and thus uses X-Pack with Alerting, rather than Watcher.  Principles are configuration remain largely the same.
Key Changes include:

* Use of Painless scripting instead of Groovy
* Installation of X-Pack plugin rather than Watcher
* Update of configuration options and API endpoints to reflect 5.0

## Running this on your own machine

1. Download and extract  [Packetbeat](https://www.elastic.co/downloads/beats/packetbeat).

    ```sh
    # Use the appropriate download link for your OS and architecture.  Assumes use of 5.x.
    $ curl -O https://download.elastic.co/beats/packetbeat/packetbeat-<version>-<arch>.tgz
    $ tar xf packetbeat-*.tgz
    $ mv packetbeat-<version>-<arch> packetbeat
    ```

1. Download and install Elasticsearch.

    Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md) to install and test the elastic stack (*you can skip this step if you already have a working installation of the Elastic Stack*)
    Kibana and Logstash are not required for this example.

1. Install the Elastic Stack X-Pack containing Alerting (you can try them for 30 days).

    ```sh
    $ elasticsearch/bin/elasticsearch-plugin install x-pack
    ```


1. In addition to Alerting, this X-Pack will install shield thus requiring security configuration.  For simplicity, this should be disabled for this demo via:

    ```sh
    $ echo 'xpack.security.enabled: false' >> elasticsearch/config/elasticsearch.yml
    ```

    The example additionally uses painless scripts which require regex support, which should be enabled through:

    ```sh
    $ echo 'script.painless.regex.enabled: true' >> elasticsearch/config/elasticsearch.yml
    ```

1. Install the Painless scripts

    ```sh
    $ cp *.painless elasticsearch/config/scripts
    ```

    The watch uses both and inline and file based script for purposes of example.  The scripts will differ from the above blog post due to the use of the 5.0 painless scripting language.

1. Start Elasticsearch

    ```sh
    $ elasticsearch/bin/elasticsearch
    ```

1. From a new terminal install the copy the customized template `packetbeat-dns.template.json` for Packetbeat.
This enhances the default template by using a custom analyzer for the dns.question.name field and will be installed by Packetbeat at run time.

   ```sh
   $ cp packetbeat-dns.template.json <packetbeat base directory>/packetbeat.template.json
   ```

1. Index the DNS tunnel data from the PCAP file.

   ```sh
   # Set the timestamps in the PCAP to the current time. The timestamp of the
   # last packet is 1282356664 seconds since epoch.
   $ offset=$(($(date +"%s") - 1282356664))
   $ editcap -t +${offset} dns-tunnel-iodine.pcap dns-tunnel-iodine-timeshifted.pcap
   $ ./packetbeat/packetbeat -e -v -waitstop 10 -t -I dns-tunnel-iodine-timeshifted.pcap
   # Verify that data was indexed:
   $ curl http://localhost:9200/packetbeat-*/_count?pretty
   ```

1. Copy the provided config file to to the base directory.  Be sure to backup any existing configuration files. You may also need to change the interface monitored based on your environment using the parameter 'packetbeat.interfaces.device'

   ```sh
   $ cp packetbeat.yml <packetbeat base directory>/packetbeat.yml
   ```

1. Index DNS traffic from your own machine.

    ```sh
    # Set the interface that you wish to monitor in packetbeat.yml
    $ ./packetbeat/packetbeat -e -v -d "dns"
    ```

1. From a new terminal make some DNS requests

   ```sh
   $ nslookup www.google.com
   $ nslookup www.yahoo.com
   ```

1. Execute the watch. This does not install the watch, it only executes it. This
allows you to make changes to the watch and easily retest.

    ```sh
    $ curl -XPUT http://localhost:9200/_watcher/watch/_execute?pretty -d@unique_hostnames_watch.json
    ```

1. Verify the output

   ```json
   ...
   "condition" : {
     "type" : "script",
     "status" : "success",
     "met" : true
   },
   "transform" : {
     "type" : "script",
     "status" : "success",
     "payload" : {
       "alerts" : {
         "pirate.sea." : {
           "total_requests" : 212,
           "unique_hostnames" : 211,
           "total_bytes_in" : 14235.0,
           "total_bytes_out" : 35212.0,
           "total_bytes" : 49447.0
         }
       }
     }
   },
   ...
   ```
