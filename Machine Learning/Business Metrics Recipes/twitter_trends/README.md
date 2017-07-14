# Detect Twitter Trends

## Theory

Increases in twitter activity in a series of hashtags or search keywords may indicate a brand or topic is trending, with the potential to impact a organization's business decisions. Rapidly identifying the change in tweet volume whilst easily attributing the activity to underlying influencers, allows businesses to be informed prior to initiating a response.

## Description

This use case recipe identifies an increase in twitter activity, assuming the user has collected tweets pertaining to specific hashtags or search keywords.  The recipe in turn identifies the responsible influencers for this increase in activity such as user, url, hashtag or location.

This recipe assumes the user has created a field indicating the "topic" of the tweet.  In its simplest form, this may represent a hashtag or set of search terms. More advanced use cases, in which users may wish to use classification techniques to identify the topic, are beyond the scope of this recipe.

## Effectiveness

This use case recipe is provided as a basic example of how automated anomaly detection can be used to detect potential business impact.  Other recipes, based upon alternative or more complex metrics than number of tweets, may produce more effective results.

For the purposes of this example, we look for high message counts with location, hashtags, urls and user mentions as potential influencers. Other influencers may be more appropriate for specific topics.

Users are encouraged to collect tweets for topics of interest over a significant time period, in order to allow Elastic's Machine Learning to identify any periodic trends. Whilst one week is sufficient to identify short daily spikes, larger datasets (e.g., greater than three weeks) are recommended.

## Use Case Type

Business KPI - This use case detects anomalies in key performance indicators (KPIs) that are directly associated with, or impact, business performance. Each detected anomaly is assigned a normalized Anomaly Score, and is annotated with values of other fields in the data that have statistical influence on the anomaly, called influencers.

## Use Case Data Source

Tweets collected using either:

1. Logstash Twitter input.
1. A custom method utilising the[twitter streaming/search API](https://dev.twitter.com/docs)

The recipe assumes the structure as delivered by the Twitter API.

## Use Case Recipe

    For:                Tweets
    Model:              Count of tweets relating to each topic
    Detect:             Topics with an unusually high number of tweets
    Compared to:        Baseline model/history of tweets for that topic
    Partition by:       topic
    Exclude:            None
    Duration:           Run analysis on tweets for a period of 1 week or longer
    Related recipes:    Run this Business KPI use case by itself, or in conjunction with other Business Metrics/OPS recipes
    Results:            Periods of unusually high activity for a twitter topic with an indication of causality through influencers

## Input Features and Candidate Influencers

    Required field                                  Description                                Example
    --------------------------                      --------------------------                 --------------------------
    topic                                           Topic assigned to tweet by the user        Elastic
     
     
    Suggested fields                                Description                                Example
    --------------------------                      --------------------------                 --------------------------
    entities.hashtags.text                          Hashtags assoicated with tweets            #elasticsearch, #logstash, #beats
    user.name                                       Tweeting user                              @elastic
    user.location                                   User location                              London, UK
    entities.user_mentions.name                     User mentions in tweets                    @kimchy
    entities.urls.display_url                       Urls in tweet                              elastic.co
    retweeted_status.user.location                  Retweeted location                         NYC, US
    retweeted_status.entities.user_mentions.name    Retweeted User Mention                     @kimchy
    retweeted_status.entities.hashtags.text         Retweeted Hashtags                         #apm
    retweeted_status.entities.urls.display_url      Retweeed URls                              elasticON.co      


The user may wish to adapt the above influencers depending on requirements.

## Example Elasticsearch Index Patterns:

    twitter-*
    
## Example Elasticsearch Query:

    query: { "match_all": { } }
    scroll_size: 1000,
    query_delay: 60s
    frequency: 150s

## Machine Learning Analysis / Detector Config:

    Detector(s): high_non_zero_count partitionfield=topic
    Bucketspan: 10m
    Influencers: topic, retweeted.user, retweeted.hashtags, user_mentions.name, user.location
    
## Recipe ID: TWT-BUS01

## Revision: v0.4

## Last updated: 14-JUL-2017

## Example Usage

see [EXAMPLE.md](https://github.com/elastic/examples/blob/master/Machine%20Learning/Business%20Metrics%20Recipes/twitter_trends/EXAMPLE.md)
