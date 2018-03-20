# GDPR Pseudonymization Examples

This example provides a supporting example to the blog post [Pseudonymization and the Elastic Stack - Part 1](http://elastic.co/blog/X), focusing on the pseudonymization of data using the [Logstash Fingerprint](https://www.elastic.co/guide/en/logstash/current/plugins-filters-fingerprint.html) filter and [Ruby Filter](https://www.elastic.co/guide/en/logstash/current/plugins-filters-ruby.html#_using_a_ruby_script_file).

In order to provide a convenient means to execute the example we utilise a dockerised approach. This example includes two approaches to pseudonymizing field data:

1. The first approach demonstrates pseudonymization using purely logstash configuration and the existing Logstash Fingerprint filter.
2. The second approach, as discussed in the blog, aims to simplify the configuration using a generic file Ruby based script.

These two approaches are deployed as separate Logstash pipelines, both accepting data through a tcp input on different ports. For both examples we pseudonymize the fields `username` and `ip`, although this could be reconfigured by the user.

#### Versions

This example has been tested in following versions:

- Docker 17.12.0
- Docker Compose 1.18.0
- netcat
- curl
- jq (preferred)

#### Important Notes

* The second example utilises a file based script. This script is vulnerable to a [bug identified](https://github.com/logstash-plugins/logstash-filter-ruby/issues/41) in the filter, due for resolution in 6.3. We therefore distribute a custom Dockerfile for Logstash which extends the 6.2.2 distribution with a fix for the filter.  This will be removed on release of 6.3.
* The second scripted approach in no way represents a final solution - the script is missing tests, doesn’t handle complex data structures and only supports SHA256! It does, however, highlight one possible approach and provides a starting point for those needing to pseudonymize their data.   The use of a script here allows the user to potentially explore other hashing algorithms not exposed in the fingerprint filter, or even do many hash rotations to add additional complexity and resilience to attack.
* The compose file is no way a production ready Elasticsearch configuration. Memory and cluster configuration settings are minimal and are applicable to an example only. See [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html) for further details.
* The approaches represent examples only. All data is indexed using the `elastic` user - this does not represent realistic access controls in a production environment.
* The hash key is currently passed as a environment variable. In a production environment we would recommend storing this value in the [Logstash secret store](https://www.elastic.co/guide/en/logstash/current/keystore.html).  This could be rotated without restarting Logstash by adding a new key and modifying configurations - assuming [automatic reload is enabled](https://www.elastic.co/guide/en/logstash/current/reloading-config.html). 

### Download Example Files

Download the following files in this repo to a local directory:

- `docker-compose.yml` - compose file to run the installation
- `logstash_fingerprint.conf` - logstash configuration for pseudonymization of fields using Fingerprint filter
- `logstash_script_fingerprint.conf` - logstash configuration for pseudonymization of fields using a file based Ruby script
- `pipelines.yml` - logstash configuration to define a separate pipeline for each of the examples
- `pseudonymise.rb` - ruby script used by the above Logstash pipeline
- `Dockerfile` - docker file for Logstash installation - see "Important Notes". Required for 6.2.2 only.
- `sample_docs` - 200 sample docs with which to test the pipelines. The field values for the `username` and ip` fields are unique.

Unfortunately, Github does not provide a convenient one-click option to download entire contents of a subfolder in a repo. 

You can either (a) [download](https://github.com/elastic/examples/archive/master.zip) or [clone](https://github.com/elastic/examples.git) the entire examples repo and navigate to `Miscellaneious/gdpr/pseudonymization` subfolder, or (b) individually download the above files. The code below makes option (b) a little easier:
    
```shell
curl -O https://raw.githubusercontent.com/elastic/examples/master/Miscellaneous/gdpr/pseudonymization/docker-compose.yml
curl -O https://raw.githubusercontent.com/elastic/examples/master/Miscellaneous/gdpr/pseudonymization/logstash_fingerprint.conf
curl -O https://raw.githubusercontent.com/elastic/examples/master/Miscellaneous/gdpr/pseudonymization/logstash_script_fingerprint.conf
curl -O https://raw.githubusercontent.com/elastic/examples/master/Miscellaneous/gdpr/pseudonymization/pipelines.yml
curl -O https://raw.githubusercontent.com/elastic/examples/master/Miscellaneous/gdpr/pseudonymization/pseudonymise.rb
curl -O https://raw.githubusercontent.com/elastic/examples/master/Miscellaneous/gdpr/pseudonymization/Dockerfile
curl -O https://raw.githubusercontent.com/elastic/examples/master/Miscellaneous/gdpr/pseudonymization/sample_docs

```

### Installation and Setup

The included compose file starts both Logstash and Elasticsearch. The former is started with 2 Logstash pipelines: one for each of the approaches. Each pipeline uses a tcp input, using distinct ports, to accept data - 5000 for the Fingerprint filter approach, 6000 for the Ruby script approach.

1. Ensure the directory containing the downloaded files is shared with docker - for OSX and Windows see [here](https://docs.docker.com/docker-for-mac/#file-sharing-tab) and [here](https://docs.docker.com/docker-for-windows/#shared-drives) respectively.

1. Navigate to the directory containing the downloaded files and execute the following command: 
    
    `ELASTIC_PASSWORD=changeme TAG=6.2.2 docker-compose up`. 
    
    Feel free to change the value of ES_PASSWORD.

2. The following log line should indicate when Logstash has started and is ready to accept data

    `logstash_1       | [2018-03-20T12:40:33,638][INFO ][logstash.agent           ] Pipelines running {:count=>2, :pipelines=>["fingerprint_filter", "ruby_filter"]}`


#### Fingerprint Filter Approach

3. To utilise the first approach, based on the FingerPrint Filter execute the following command:

    `cat sample_docs | nc localhost 5000`
    
    This should also take a few seconds to execute and index the 100 documents from the sample file.
    


#### Ruby Script File Approach
    
4. To utilise the second approach, based on the Ruby File Script execute the following command:

    `cat sample_docs | nc localhost 6000`
   
   This should also take a few seconds to execute and index the 100 documents from the sample file.


#### Inspecting and using the data

5. Pseudonymized Documents will be indexed to an `events` index.  These can be accessed through the following query:

    `curl "http://localhost:9200/events/_search" -u elastic:changeme | jq`
    
    Example pseudonymized document below:
    
    ```shell
        {
            "_index": "events",
            "_type": "doc",
            "_id": "tQOjQ2IBED8Jv9YVVDxs",
            "_score": 1,
            "_source": {
              "host": "gateway",
              "user_agent": "Mozilla/5.0 (Macintosh; PPC Mac OS X 10_6_7) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.790.0 Safari/535.1",
              "job_title": "Electrical Engineer",
              "username": "95b88d8d477e18a8acca833e7bcbd2c5d5f646b29e2d1c9604a1d930e2f63313",
              "@timestamp": "2018-03-20T13:39:59.799Z",
              "ip": "e85022a9801b356dd8c3ed6b2e02f0061a3aeea5bbad15a9ff4aed35b5bb3a42",
              "source": "ruby_pipeline",
              "city": "Komsomol’skiy",
              "title": "Mr",
              "country_code": "UZ",
              "@version": "1",
              "gender": "Female",
              "country": "Uzbekistan",
              "port": 41126
            }
         }
    ```
    
    "Identity documents" (effectively key-value pair lookups), are indexed into a `pseudonyms` index.  These can be accessed through the following query:
    
    `curl "http://localhost:9200/pseudonyms/_search" -u elastic:changeme | jq`
    
    Again we assume jq is available for display of results.
    
    ```shell
      {
        "_index": "pseudonyms",
        "_type": "doc",
        "_id": "1924d02bd98a46c795cb2a925b98a22ae59c563e0de49f4ba4aa49e6cab072ad",
        "_score": 1,
        "_source": {
          "key": "1924d02bd98a46c795cb2a925b98a22ae59c563e0de49f4ba4aa49e6cab072ad",
          "value": "174.145.248.21",
          "tags": [
            "pseudonyms"
          ],
          "@timestamp": "2018-03-20T13:39:59.957Z",
          "@version": "1",
          "source": "ruby_pipeline"
        }
      } 
      ```
    
    The data produced by both examples is identical. If running both examples once, you will end up with a duplicate of each document in the `events` index - total 200, and 100 thereafter for each execution.
    
    The `pseudonyms` index should always contain 200 documents no matter how many times you index the data - a document for each unique field value of username` and `ip`.
    
    All indexed documents contain a field `source` indicating their originating pipeline.
    
    In order to lookup a pseudonymized value, the user can simply do a lookup by id on the `pseudonyms` index. For example, if needing the original value for `6efda88d5338599ef1cc29df5dad8da681984580dc1f7f495dcf17ebcf7191f8` simply execute:
    
    `curl "http://localhost:9200/pseudonyms/doc/6efda88d5338599ef1cc29df5dad8da681984580dc1f7f495dcf17ebcf7191f8" -u elastic:changeme | jq`
    

#### Shutdown

Use `ctl+c` to exit the compose terminal. The following command will remove all containers and associated data:

`ELASTIC_PASSWORD=changeme TAG=6.2.2 docker-compose down -v`

### Extending and Modifying

The user may wish to modify the environment. Common requirements and approaches:

1. Modify the Hash key - This is passed through the environment variable `FINGERPRINT_KEY` to the Logstash instance and can be modified as required. In a production environment we would recommend storing this value in the [Logstash secret store](https://www.elastic.co/guide/en/logstash/current/keystore.html).
1. Modify the Logstash pipelines e.g. to pseudonymize other fields. Modify the respective `.conf` file as described in the blog post.





