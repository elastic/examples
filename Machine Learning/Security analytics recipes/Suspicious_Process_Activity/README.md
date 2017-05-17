# Detect Suspicious Process Activity (Host)

## Theory
Unusual process names for a host may indicate attack activity.

## Description
This use case identifies unusual process names for a host.

## Effectiveness
This use case recipe is provided as a basic example of how automated anomaly detection can be used to detect suspicious host process activity.  Other recipes, based upon alternative or more complex approaches, may produce more effective detection results.

## Use Case Type
Elementary Attack Behavior (EAB) - This use case detects anomalies associated with elementary attack behaviors.  Each detected anomaly is assigned a normalized Anomaly Score, and is annotated with values of other fields in the data that have statistical influence on the anomaly.  Elementary attack behaviors that share common statistical Influencers are often related to a common attack progression.

## Use Case Data Source
Endpoint Detection and Response (EDR) sources such as: Symantec SEP12 logs, RSA ECAT, Carbon Black/Bit9 Logs, or similar data, such as auditd logs containing host names and  names of processes started on an endpoint

## Use Case Recipe
    For:                All relevant endpoint data [filtered as appropriate, to control the number of people in the host population, including only high-value target (HVT) hosts]
    Model:              Processes started by a host
    Detect:             Rare process names
    Compared to:        Baseline model/history for each host
    Partition by:       None
    Exclude:            None
    Duration:           Run analysis over multiple days of data.  Two weeks or more will yield best results.
    Related recipes:    Run this EAB use case by itself, or include in additional security searches
    Results:            Look for endpoint host names with rare process_names

## Input Features and Candidate Influencers

    Required field (or similar)     Description               Example
    host_id, beat.name              Endpoint host name        WIN2008R3-ADMIN
    process_name, audit.log.a0      Endpoint process name     svchost.exe

## Example Elasticsearch Index Patterns

    filebeat-*
    auditd-*
    cef-*

## Example Elasticsearch Query:

    query: { "term": {"auditd.log.record_type":{"value":"EXECVE"}}}
    query_delay: 60s
    frequency: 150s
    scroll_size: 1000

## Machine Learning Analysis / Detector Config:

    Detector: rare by process_name partitionfield=beat.name
    Bucketspan: 600s
    Influencer(s): process_name, beat.name

## Recipe ID: EDR-EAB09

## Revision:  v0.5

## Last updated: 5/17/2017

## Example Usage

see [EXAMPLE.md](https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20analytics%20recipes/Suspicious_Process_Activity/EXAMPLE.md)
