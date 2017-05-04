# Detect Suspicious Login Activity (Volume)

## Theory

An unusually high number of login attempts from a client can be an indication of a brute force login attack.

## Description

This use case recipe identifies clients associated with unusual volumes of failed login attempts.

## Effectiveness

This use case recipe is provided as a basic example of how automated anomaly detection can be used to detect suspicious login activity.  Other recipes, based upon alternative or more complex approaches, may produce more effective detection results.

## Use Case Type

Elementary Attack Behavior (EAB) - This use case detects anomalies associated with elementary attack behaviors.  Each detected anomaly is assigned a normalized Anomaly Score, and is annotated with values of other fields in the data that have statistical influence on the anomaly.  Elementary attack behaviors that share common statistical Influencers are often related to a common attack progression.

## Use Case Data Source

Windows AD logs, or Linux system authentication logs

## Use Case Recipe

    For:            All relevant authentication log data (filtered as appropriate, possibly including only privileged user accounts, internal IP addresses, etc.)
    Model:          number of failed login attempts from each client
    Detect:         Unusually high numbers of failed login attempts
    Compared to:    Population of all clients
    Partition by:   targeted server
    Exclude:        None
    Prep time:      Run analysis authentication logs from a period of 2 weeks or longer
    Blend:          Run this EAB use case by itself, or along with other login-related EAB’s
    Serve Results:  Influencer clients are possible sources of brute force login attacks.  Influencer servers are victims.

## Input Features and Candidate Influencers

    Required field (or similar)     Description                                                                                                                                                             Example
    client                          A unique identifier for the client system initiating login attempts that is present in the authentication logs (e.g., src_ip, beat.name, system.auth.ssh.ip, etc.)      10.10.1.1, mikep, ent.eng.mbp.mikep
    user                            Username associated with login attempts (e.g., system.auth.user)                                                                                                        jdoe, johndoe, john.h.doe
    server                          The target server upon which the login attempts are made


## Example Elasticsearch Index Patterns:

    wsl-*
    ad-*
    filebeat-*
    winlogbeat-*
    cef-ssh-*

## Example Elasticsearch Query:

    query: {"terms":{"system.auth.ssh.event":["Failed","Invalid"],"boost":1}}
    query_delay: 60s
    frequency: 300s
    scroll_size: 1000

## Machine Learning Analysis / Detector Config:

    Detector(s): high_count over client partitionfield=server
    Bucketspan: 10m
    Influencer(s): client, user, server

## Notes
1. The partitionfield=server clause tailors this recipe for detecting brute force attacks targeting an individual server.  By removing this clause, the recipe is more likely to detect login attempts across a number of servers.

## Recipe ID: WSL-EAB28

## Revision:  v0.3

## Last updated: 4/20/2017

## Example Usage

see [EXAMPLE.md](https://github.com/elastic/examples/blob/master/Machine%20Learning/Security%20analytics%20recipes/Suspicious_Login_Activity/EXAMPLE.md)
