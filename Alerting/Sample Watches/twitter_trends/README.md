# Twitter Trend Detection

## Description

A watch which aims detect and to alert if a set of twitter results, defined by a search expression on the text, shows an increase in popularity in the last 5 mins.  This provides a simple viral detection mechanism for a companies twitter profile.  This approach has been tested with Elastic tweets only and should be tested on the user's own dataset.

## Mapping Assumptions

A template is provided in template.json.  As a minimum tweets must include:

* @timestamp (date field) - Date of the tweet message.
* text (analyzed string) - The complete tweet text.

## Data Assumptions

The watch assumes each document in Elasticsearch represents a tweet.  All tweets should be indexed into an index starting with "twitter" and use the type "doc".

## Other Assumptions

* The approach measures the 90th percentiles over the previous 8hrs of tweets, using a percentiles aggregation.  If the value in the last 5 minutes is greater than 3 std. deviations above this value an alert is raised.  This approach has been tested on Elasticsearch data, where volume is typically low and spikes during specific periods e.g. product releases, and may thus not be robust on other datasets.  Elastic would recommend the user modify this query as required.

## Configuration

The following watch metadata parameters influence behaviour:

* time_period - The period N (hrs) over which which the percentile and std. dev is calculated.  Defaults to 8hrs. Increase to make the trend less sensitive to recent changes.
* bucket_interval - The bucket width over which the number of tweets are counted and the percentiles/std. dev. calculated.  Increasing will make the trend detection less responsive to trends and mean alerts can be raised less infrequently.  Should always be equal to the schedule interval.
* query_string - Query string used to identify relevant tweets. Defaults to 'text:elasticsearch'.
