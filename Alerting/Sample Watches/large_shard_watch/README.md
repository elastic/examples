# Monitoring for Large Shards

## Description

This is a watch that creates a helper index (large_shards), and it uses it to alert one time (per shard) based off the size of the shards defined in the metadata.

It queries the cat/shards api call to get the information first, and then ingests it into large-shards


# Configuration

* Metadata is where the threshold_in_bytes is set.
