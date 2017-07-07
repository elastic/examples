# DNS Tunnel Detection

This sample demonstrates using Packetbeat with Elasticsearch and Alerting to
detect DNS tunnels using the number of unique FQDNs per domain as an indicator
of compromise.

For a detailed walk-through of the watch and the aggregations used here, see the
Elastic blog post titled [_Detecting DNS Tunnels with Packetbeat and
Watcher_](https://www.elastic.co/blog/detecting_dns_tunnels_with_packetbeat_and_watcher).

This sample has been updated to reflect Elastic 5.0 and thus uses X-Pack with
Alerting, rather than Watcher. Principles are configuration remain largely the
same. Key Changes include:

* Use of Painless scripting instead of Groovy
* Installation of X-Pack plugin rather than Watcher
* Update of configuration options and API endpoints to reflect 5.0

## Running this on your own machine

1. Download and extract  [Packetbeat](https://www.elastic.co/downloads/beats/packetbeat).

    ```sh
    # Use the appropriate download link for your OS and architecture.  Assumes use of 5.x.
    $ curl -O https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-<version>-<os>-<arch>.tar.gz
    $ tar xf packetbeat-*.tar.gz
    $ mv packetbeat-<version>-<os>-<arch> packetbeat
    ```

1. Download and install Elasticsearch.

    Follow the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md)
    to install and test the elastic stack (*you can skip this step if you
    already have a working installation of the Elastic Stack*) Kibana and
    Logstash are not required for this example.

1. Install the Elastic Stack X-Pack containing Alerting (you can try them for 30
days).

    ```sh
    $ elasticsearch/bin/elasticsearch-plugin install -b x-pack
    ```

1. In addition to Alerting, this X-Pack will install shield thus requiring
security configuration.  For simplicity, this should be disabled for this demo
via:

    ```sh
    $ echo 'xpack.security.enabled: false' >> elasticsearch/config/elasticsearch.yml
    ```

1. Install the Painless scripts

    ```sh
    $ mkdir elasticsearch/config/scripts
    $ cp *.painless elasticsearch/config/scripts/
    ```

    The watch uses both and inline and file based scripts.

1. Start Elasticsearch

    ```sh
    $ elasticsearch/bin/elasticsearch
    ```

1. (Optional) From a terminal install the customized index template
`packetbeat-dns.template.json`. This template adds a new field to the index
called `dns.question.name.analyzed` that contains an analyzed copy of the
`dns.question.name` field. This allows you to search for parts of a domain like
`dns.question.name.analzyed: google` and get back results. This is not required
by the watch, but may be useful in exploring your data.

   ```sh
   $ curl -H "Content-Type: application/json" -XPUT http://localhost:9200/_template/packetbeat_1 -d@packetbeat-dns.template.json
   ```

1. Index the DNS tunnel data from the PCAP file. (`editcap` is part of Wireshark)

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
    # Start Packetbeat. You must specify the interface that you wish to monitor (e.g. eth0 or en0).
    $ ./packetbeat/packetbeat -c packetbeat.yml -e -v -d "dns" -E packetbeat.interfaces.device=<interface to monitor>
    ```

1. From a new terminal make some DNS requests

   ```sh
   $ dig www.google.com
   $ dig www.yahoo.com
   ```

1. Execute the watch. This does not install the watch, it only executes it. This
allows you to make changes to the watch and easily retest.

    ```sh
    $ curl -H "Content-Type: application/json" -XPUT http://localhost:9200/_watcher/watch/_execute?pretty -d@unique_hostnames_watch.json
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
