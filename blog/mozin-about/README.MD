# Mozi'n About

## Abstract
The Mozi botnet is an ongoing malware campaign targeting unsecured and vulnerable networking devices. This post will showcase the analyst journey of collecting, analyzing, and operationalizing threat data from the Mozi botnet.

## URL
https://www.elastic.co/blog/collecting-and-operationalizing-threat-data-from-the-mozi-botnet

## Usage

To load the sample data, you need a local instance of Elasticsearch and Kibana. If you are using anything beyond a default local deployment, you'll need to modify `collection.sh` to match your deployment.

```
git clone https://github.com/elastic/examples
cd examples/blog/mozin-about
sh clollection.sh
```
Log into your Kibana instance to explore the data in the `indicators` Index Pattern.

## Artifacts
Artifacts and code snippets from the blog post.

| Artifact | Description | Note |
| - | - | - |
| [Mozi Collection Script](./collection.sh) | Script to collect Mozi samples and send to Elasticsearch | 
| [Ingest Node Pipeline](./ingest-node-pipeline.json) | ThreatFox Ingest Node Pipeline |
| [Index Settings](./index-settings.json) | Settings for the Indicators index |
| [YARA Signature](./mozi-obfuscation-technique.yara) | Mozi obfuscation technique YARA signature | 
