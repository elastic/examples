# Detect HTTP Data Exfiltration (Proxy)

## Theory

An unusually high volume of data being transferred in the outbound direction as reported by proxy logs can be an indication of exfiltration of data over the HTTP protocol.

## Description

This use case recipe identifies HTTP host domains to which HTTP requests containing unusually high data volume are sent, and clients that generate these anomalous requests.

## Effectiveness

This use case recipe is provided as a basic example of how automated anomaly detection can be used to detect HTTP Data Exfiltration.  Other recipes, based upon alternative or more complex approaches, may produce more effective detection results.

## Use Case Type

Elementary Attack Behavior (EAB) - This use case detects anomalies associated with elementary attack behaviors.  Each detected anomaly is assigned a normalized Anomaly Score, and is annotated with values of other fields in the data that have statistical influence on the anomaly.  Elementary attack behaviors that share common statistical Influencers are often related to a common attack progression.

## Use Case Data Source

Web proxy logs, firewall logs, or similar data containing logs of HTTP requests which include the number of bytes transferred in the outbound direction and the destination HTTP host domain of the transaction.

## Use Case Recipe

    For:          All outbound HTTP requests (optionally filtered for allowed requests)
    Model:        Sum of outbound bytes contained in HTTP requests
    Detect:       Unusually high sum of bytes
    Compared to:  Population of all host domains in HTTP requests
    Partition by: source system initiating the HTTP requests
    Exclude:      domains that occur frequently in the analysis
    Prep time:    Run analysis on HTTP queries from period of 2 weeks or longer
    Blend:        Run this EAB use case by itself, or along with other data exfiltration EAB’s
    Serve Results:Influencer clients are likely sources of HTTP exfiltration activity

## Input Features and Candidate Influencers

    Required field (or similar)     Description                                                                                                           Example
    HTTP_host                       HTTP host name usually contained within the HTTP request header host field                                            elastic.co
    client                          A unique identifier for the client system initiating the analyzed HTTP requests (could be src_ip, beat.name, etc.)    10.10.1.1, mikep, ent.eng.mbp.mikep
    bytes_out                       Size of outbound request in bytes                                                                                     983764

## Example Elasticsearch Index Patterns:

    bluecoat-*
    squid-*
    packetbeat-*
    pan_traffic-*
    cef-*

## Example Elasticsearch Query:

    query: { "term": { "direction": { "value": "bytes_out" } } }
    query_delay: 60s
    frequency: 150s
    scroll_size: 1000

## Machine Learning Analysis / Detector Config:

    Detector(s): high_sum(bytes_out) over HTTP_host partitionfield=client exclude_frequent=all
    Bucketspan: 5m
    Influencer(s): HTTP_host, client

## Notes: <delete label if none>
1. The partitionfield=client clause is optional for this analysis
1. The exclude_frequent directive is used to focus the analysis on less-common domains


## Recipe ID: PXY-EAB11

## Revision:  v0.4

## Last updated: 4/19/2017

## Example Usage

see [EXAMPLE.md](https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20analytics%20recipes/HTTP_Data_Exfiltration/EXAMPLE.md)
