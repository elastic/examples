# DNS Tunnel Detection

This sample demonstrates using Packetbeat with Elasticsearch and Watcher to
detect DNS tunnels using the number of unique FQDNs per domain as an indicator
of compromise.

For a detailed walk-through of the watch and the aggregations used here, see the
Elastic blog post titled [_Detecting DNS Tunnels with Packetbeat and
Watcher_](https://www.elastic.co/blog/detecting_dns_tunnels_with_packetbeat_and_watcher).

## Running this on your own machine

1. Download and extract  [Packetbeat](https://www.elastic.co/downloads/beats/packetbeat).

    ```sh
    # Use the appropriate download link for your OS and architecture.
    $ curl -O https://download.elastic.co/beats/packetbeat/packetbeat-1.1.1-darwin.tgz
    $ tar xf packetbeat-*.tgz
    $ mv packetbeat-1.1.1-darwin packetbeat
    ```

1. Download and unzip Elasticsearch.

    ```sh
    $ curl -O https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/zip/elasticsearch/2.2.0/elasticsearch-2.2.0.zip
    $ unzip elasticsearch-*.zip
    $ mv elasticsearch-2.2.0 elasticsearch
    ```

1. Install the License and Watcher plugins (you can try them for 30 days).

    ```sh
    $ elasticsearch/bin/plugin install -b license
    $ elasticsearch/bin/plugin install -b watcher
    ```

1. Enable dynamic scripting in Elasticsearch.

    ```sh
    $ echo 'script.inline: true
    script.indexed: true
    script.file: true' >> elasticsearch/config/elasticsearch.yml
    ```

1. Install the Groovy scripts

    ```sh
    $ cp *.groovy elasticsearch/config/scripts
    ```

1. Start Elasticsearch

    ```sh
    $ elasticsearch/bin/elasticsearch
    ```

1. From a new terminal install the index templates for Packetbeat

   ```sh
   $ curl -XPUT http://localhost:9200/_template/packetbeat?pretty -d@packetbeat/packetbeat.template.json
   $ curl -XPUT http://localhost:9200/_template/packetbeat_1?pretty -d@packetbeat-dns.template.json
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
