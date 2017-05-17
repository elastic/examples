# Detect DNS Data Exfiltration (Tunneling)

## Theory

An unusual amount of entropy (called “information content”) present in the subdomain field of DNS Query Requests can be an indication of exfiltration of data over the DNS protocol.

## Description

This use case recipe identifies domains to which DNS query requests containing unusually high values of “information content” are sent, and IP addresses that generate these anomalous requests.

## Effectiveness

This use case recipe is provided as a basic example of how automated anomaly detection can be used to detect DNS data exfiltration.  Other recipes, based upon alternative or more complex approaches, may produce more effective detection results.

## Use Case Type

Elementary Attack Behavior (EAB) - This use case detects anomalies associated with elementary attack behaviors.  Each detected anomaly is assigned a normalized Anomaly Score, and is annotated with values of other fields in the data that have statistical influence on the anomaly.  Elementary attack behaviors that share common statistical Influencers are often related to a common attack progression.

## Use Case Data Source

DNS query logs (from client to DNS Server)

## Use Case Recipe

    For:                DNS query requests (filtered for questiontypes: A, AAAA, TXT)
    Model:              Calculated Entropy (Information content) within the subdomain string
    Detect:             Unusually high amounts of information content
    Compared to:        Population of all (highest registered) domains in query results
    Partition by:       None
    Exclude:            domains that occur frequently in the analysis
    Duration:           Run analysis on DNS queries from period of 2 weeks or longer
    Related recipes:    Run this EAB use case by itself, or along with DNS-EAB01 DNS DGA Activity
    Results:            Influencer hosts are likely sources of DNS Tunneling activity

## Input Features and Candidate Influencers

    Required field (or similar)     Description                                                                                                                               Example
    domain                          Highest level registered domain contained within the domain field of the DNS question coming from analyzed clients                          my.support.BASE.NET
    subdomain                       Portion of domain field exclusive of highest registered domain of the DNS question coming from analyzed clients exclusive of domain         MY.SUPPORT.base.net
    host ID                         A unique identifier for the client system initiating the analyzed DNS Queries (could be src_ip, beat.name, etc.)                        10.10.1.1, mikep, ent.eng.mbp.mikep


## Example Elasticsearch Index Patterns:

    packetbeat-*
    bind9-*
    cef-*

## Example Elasticsearch Query:

    query: {"match_all":{"boost":1}}
    query_delay: 60s
    frequency: 150s
    scroll_size: 1000

## Machine Learning Analysis / Detector Config:

    Detector(s): high_info_content(sub_domain) over domain exclude_frequent=all
    Bucketspan: 5m
    Influencer(s): client_ip, beat.name, domain

## Notes: <delete label if none>
1. This analysis requires fields that contain the highest registered domain (domain) and the subdomain portion (subdomain) of each DNS query.  If these fields are not available in the source data, a transformation must be applied to create them.

## Recipe ID: DNS-EAB02

## Revision:  v0.6

## Last updated: 17-MAY-2017

## Example Usage

see [EXAMPLE.md](https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20analytics%20recipes/DNS_Data_Exfiltration/EXAMPLE.md)
