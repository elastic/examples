# Online Search Relevance Metrics

A simulation and set of configurations for calculating and exploring online search relevance metrics.

## Prerequisites

This project requires and expects:
 - Python 3.7+ (try [pyenv](https://github.com/pyenv/pyenv) to manage multiple Python versions)
 - `virtualenv` (install with `pip install virtualenv`)

## Get started

Use the `Makefile` for all setup, building, testing, etc.

```bash
# install project dependencies (from requirements.txt)
make init

# cleanup environment
make clean

# run tests
make test

# generate ECS schema
make ecs

# run Jupyter Lab (notebooks)
make jupyter
```

## Run simulation

To simulate data and run all transforms, use the `bin/simulate` script. Most likely, you will want to index events directly into an Elasticsearch instance:

```bash
bin/simulate elasticsearch
```

The simulation will ensure that the right configuration in Elasticsearch is setup.

Explore the command using `-h` or `--help`.

## Generate a custom ECS schema

Given a subset of ECS fields that we need, plus custom fields that we want to add, we can generate an ECS compatible schema from a clone of the ECS repository. We want to stick to a specific commit in the HEAD of master for now, so we also checkout a specific commit.

``` bash
git clone git@github.com:elastic/ecs.git && \
    cd ecs && \
    git checkout 994f7777b53ba31fe55dffd0667b347fb8afdfee
```

Now run the `generator.py` script to generate a new schema. This will use the configuration in `config/ecs` to define which ECS fields to use and the definition of custom fields. Please make to set the `SIM_DIR` variable before running this to reference this codebase on your local drive.

```bash
export SIM_DIR=...
echo $SIM_DIR
```

```bash
make ve && \
    build/ve/bin/python scripts/generator.py \
        --ref v1.5.0 \
        --subset $SIM_DIR/config/ecs/subset.yml \
    	--include $SIM_DIR/config/ecs/custom \
    	--out generated_custom
``` 

After generating the custom schema, you can find the new schema in `generated_custom/generated/elasticsearch/7/template.json`. This will have to be changed again, manually, to set the index settings appropriate for the simulation. The easiest thing to do is just copy the `properties` of the `mappings` and replace that in the existing schema. All the index settings don't need to be copied.

## Kibana visualizations

To recreate the visualisations in Kibana, you need to first make sure you have data in your Elasticsearch instance using the above `simulate` command.

Once you have data in Kibana, create an index pattern on the Management page with the same name as the metrics index: `ecs-search-metrics_transform_queryid`. When creating the index pattern, use the `query_event.@timestamp` field as the timestamp field of the index pattern. Once the index pattern has been created, click on a link to the index pattern and find the index pattern ID in the URL of the page. It'll be the long UUID almost at the end of the URL, that looks something like this: `d84e0c50-8aec-11ea-aa75-e59eded2bd43`.

With the Kibana saved objects template as input, a location for the saved object output file, and the index pattern ID, you can use the `bin/kibana` script to generate a valid set of Kibana visualizations linked to the correct index pattern. Here's an example invocation:

```bash
bin/kibana \
  --input config/kibana/saved_objects.template.ndjson \
  --output ~/Downloads/kibana.ndjson \
  d84e0c50-8aec-11ea-aa75-e59eded2bd43
```

Open up Kibana again and select the Saved Objects page from Management, and Import (top right corner). Drag the newly created `kibana.ndjson` file with the saved objects in it and drop it into the "Import saved objects" dialog, and hit "Import".

You're all set! Have a look at the Dashboard and Visualizations pages now and you should see a large set of ready-made visualizations. 
