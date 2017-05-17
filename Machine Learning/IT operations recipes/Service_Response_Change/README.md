# Detect Service Response Change (Response Code)

## Theory

An unusual count of service response error code values produced by a service could indicate a problem with that service or one of its component subsystems.

## Description

This use case recipe identifies hosts from which an unusual count of error response codes of certain values are sent.  It also detects the logical site area to which the response code applies, and country code of source generating the requests that cause the responses.

## Effectiveness

This use case recipe is provided as a basic example of how automated anomaly detection can be used to detect potential system issues.  Other recipes, based upon alternative or more complex changes than error response codes, may produce more effective detection results.

## Use Case Type

IT Operations - This use case detects anomalies associated with errors, slowdowns, and interruptions in the operation of a system or service. Each detected anomaly is assigned a normalized Anomaly Score, and is annotated with values of other fields in the data that have statistical influence on the anomaly, called influencers.

## Use Case Data Source

Apache Web Logs (containing HTTP response codes)

## Use Case Recipe
    For:                Apache web logs (filtered for error codes such as 400, 500)
    Model:              Count of log messages containing each value of HTTP response code
    Detect:             Hosts with unusually high counts of messages containing certain error codes
    Compared to:        Baseline model/history of message counts for that host
    Partition by:       host
    Exclude:            None
    Duration:           Run analysis over multiple days of data.  Two weeks or more will yield best results.
    Related recipes:    Run this OPS use case by itself, or along with other OPS recipes
    Results:           Unusual hosts may be experiencing an outage

## Input Features and Candidate Influencers


    Required field (or similar)     Description                                                                                                         Example
    response                        The HTTP response code contained in the web log                                                                     200, 405, 503
    host_ID                         A unique identifier for the system initiating the web logs (could be src_ip, beat.name, etc.)                       10.10.1.1, mikep, ent.web.apache.server107
    site_area                       An attribute in the web log that indicates the logical area of the web site applicable to the response              /blog, /legal, /register
    geoip.country_name              Name of country associated with the HTTP request that generated the HTTP response contained in the web log          China, USA, Russia


## Example Elasticsearch Index Patterns:

    apache-*
    cef-*

## Example Elasticsearch Query:

    query: {"match_all": { }}
    scroll_size: 1000,
    query_delay: 60s
    frequency: 150s

## Machine Learning Analysis / Detector Config:

    Detector(s): high_count by response partitionfield=host_ID
    Bucketspan: 30m
    Influencer(s): response, site_area, geoip.country_name

## Recipe ID: SVC-OPS01

## Revision: v0.3

## Last updated: 17-MAY-2017

## Example Usage

see [EXAMPLE.md](https://github.com/elastic/examples/blob/master/Machine%20Learning/IT%20operations%20recipes/Service_Response_Change/EXAMPLE.md)
