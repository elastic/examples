# Detect System Metric Change (CPU Utilization)

## Theory

Unusual values of system CPU metrics could indicate a problem with that system or one of its component subsystems.

## Description

This use case recipe identifies hosts on which a processor core exhibits an unusually high average CPU utilization.  It also detects the core with the high utilization.

## Effectiveness

This use case recipe is provided as a basic example of how automated anomaly detection can be used to detect potential system issues.  Other recipes, based upon alternative or more complex changes than CPU utilization, may produce more effective detection results.  For example, modifying this recipe to also detect unusual values of  I/O operations and/or memory usage would be more likely to represent behavior worthy of alerting.

## Use Case Type

IT Operations - This use case detects anomalies associated with errors, slowdowns, and interruptions in the operation of a system or service. Each detected anomaly is assigned a normalized Anomaly Score, and is annotated with values of other fields in the data that have statistical influence on the anomaly, called influencers.

## Use Case Data Source

Metricbeat system logs (containing CPU utilization metrics)

## Use Case Recipe
    For:                Metricbeat system logs
    Model:              Mean value of CPU utilization on each CPU core
    Detect:             CPU cores with unusually high mean CPU utilization
    Compared to:        Baseline model/history of CPU utilization for that core
    Partition by:       Host
    Exclude:            None
    Duration:           Run analysis on Metricbeat logs from period of 2 weeks or longer
    Related recipes:    Run this Ops use case by itself, or along with other OPS recipes
    Results:            Hosts with unusual cores may be experiencing issues


## Input Features and Candidate Influencers

    Required field (or similar)     Description                                                     Example
    cpu_core_util                   CPU utilization metric per core                                 0, 50, 99, 100
    cpu_core_ID                     A unique identifier for the system CPU core                     A, 1, 4.2
    host_ID                         A unique id for the system producing analyzed CPU metrics       10.10.1.1, mikep, ent.web.apache.server107


## Example Elasticsearch Index Patterns:

    metricbeat-*
    system-*
    cef-*

## Example Elasticsearch Query:

    query: { "term": { "metricset.name": {"value": "cpu_core_ID"}
    scroll_size: 1000,
    query_delay: 60s
    frequency: 150s

## Machine Learning Analysis / Detector Config:

    Detector(s): high_mean(cpu_core_util) by cpu_core_ID partitionfield=host_ID
    Bucketspan: 1m
    Influencer(s): cpu_core_ID, host_ID


## Recipe ID: SYS-OPS01

## Revision: V0.2

## Last updated: 17-MAY-2017

## Example Usage

see [EXAMPLE.md](https://github.com/elastic/examples/blob/master/Machine%20Learning/IT%20operations%20recipes/Service_Response_Change/EXAMPLE.md)
