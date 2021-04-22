# Supplementary materials for "ProblemChild in the Elastic Stack"

This folder contains the supplementary materials for the blogpost ["ProblemChild in the Elastic Stack"](insert link here). These configurations have been tested on Elasticsearch version 7.10 and above.

## Extracting features for the classification model

The goal of this model is to classify Windows process events as either malicious or benign. We used a dataset of labeled (benign or malicious) Windows process events to train the model. The model supports Elastic Endpoint, Elastic Endgame and Winlogbeat events by normalizing the feature names across the three configurations into a common set of feature names for the model to work with (some field names have not been converted to a common ECS format yet and could vary across the three configurations). 

An ingest pipeline is used to featurize raw Windows process events upon ingest, which is available in the file `problemchild_features.json`. The ingest pipeline consists of various processors, which are broken down as follows:

* Script processors to extract fields from raw events based on agent type into a common set of fields for the model to work with: Scripts available in `features_endgame.json`, `features_endpoint.json`, `features_winlogbeat.json` for Elastic Endgame, Elastic Endpoint and Winlogbeat respectively.


```
{
    "script": {
      "if": "ctx['agent']['type']=='endgame'",
      "id": "features_endgame"
    }
  },
  {
    "script": {
      "if": "ctx['agent']['type']=='endpoint'",
      "id": "features_endpoint"
    }
  },
  {
    "script": {
      "if": "ctx['agent']['type']=='winlogbeat'",
      "id": "features_winlogbeat"
  }
}
```

* Script processors to extract features from the common fields: The scripts for these are in-line within the ingest pipeline configuration, except `normalize_ppath.json`.

Eg: The following script processor sets the feature `feature_ends_with_exe` to `true` if the process name associated with the event ends with ".exe" and `false` otherwise.


```
{
    "script": {
        "lang": "painless",
        "source": """
    if(ctx.feature_process_name.contains(".exe")) {
      ctx.feature_ends_with_exe = true
        }
    else {
      ctx.feature_ends_with_exe = false
        }
  """
    }
}
```

* Lowercase processors to convert certain fields like paths and commandline arguments to lowercase.

Eg: The following processor converts the field `feature_command_line` to lowercase.


```
{
    "lowercase": {
        "field": "feature_command_line"
    }
}
```

* Gsub processors to replace certain patterns in the commandline arguments with a normalized value.

Eg: The following processor replaces the pattern defined by the `pattern` field, by the string "process_id" in the `feature_command_line` field.


```
{
    "gsub": {
        "field": "feature_command_line",
        "pattern": "[0-9a-f]{4,}-[0-9a-f]{4,}-[0-9a-f]{4,}-[0-9a-f-]{4,}",
        "replacement": "process_id"
    }
}
```

* Script processors to extract bigram features from certain fields: Script avilable in `ngram_extractor.json`.

Eg: The following processor gets the first 100 bigrams for the field `feature_process_name`.


```
{
    "script": {
        "id": "ngram-extractor",
        "params": {
            "ngram_count": 2,
            "field": "feature_process_name",
            "max_length": 100
        }
    }
}
```

You can set the ingest pipeline configuration defined in `problemchild_features.json` as follows:


```
PUT _ingest/pipeline/problemchild_features
{
INSERT PIPELINE CONFIGURATION HERE
}
```

Once the ingest pipeline has been configured, we can re-index our original index with labeled raw Windows process events into a new index which will contain the featurized documents for the events with their corresponding labels.


```
POST _reindex
{
  "source": {
    "index": "problemchild_raw"
  },
  "dest": {
    "index": "problemchild_featurized",
    "pipeline": "problemchild_features"
  }
}
```

Once you have all of your data re-indexed through the ingest pipeline, you can follow the steps in the [blog post](insert link here) to configure your Data Frame Analytics job to train an ML model.


## Inference on new Windows process events

Once we have trained a model, we can use it to predict/infer on new Windows process events. In order to do this, we will have to extract the same features as above on the new events. Hence, before passing the events through an inference processor, we first have to pass them through the same series of processors as discussed in the previous section and make sure all the required scripts are stored in the cluster state.

Users also have the option of using a blocklist to override the model's benign verdict after inference. The blocklist marks events as malicious if certain keywords are present in the commandline arguments associated with the event. This is done using a script processor that is invoked after the inference processor in the ingest pipeline. Ofcourse, this is optional and you can choose not to use the blocklist, in which case, you can leave the script processor out of your ingest pipeline.

Script invoked by the blocklist script processor:


```
POST _scripts/blocklist
{
  "script": {
    "lang": "painless",
    "source": """
    for(item in params.blocklist){
      if(ctx['feature_command_line'].contains(item)){
        ctx.blocklist_label = 1
      }
    }
   
 """
  }
}
```

Sample script processor invoking the blocklist script with a blocklist consisting of keywords "suspicious" and "evil":


```
{
  "script" : {
    "if": "ctx.containsKey('problemchild') && ctx['problemchild'].containsKey('prediction') && ctx['problemchild']['prediction'] == 0",
    "id": "blocklist",
    "params":{
      "blocklist": ["suspicious", "evil"]
    }
  }
}
```

The blocklist script is available in the file `blocklist.txt`. You can add to the list of keywords as needed but a starter list is available in the file `blocklist_keywords.txt`.

Finally, since we don't want the features that are created for inference to be ingested together with our event data, we will also configure a script processor to remove these features. This script processor will be invoked in the ingest pipeline after the blocklist processor (or after the inference processor if you are not using the blocklist). Of course, if you wish, you can leave the features in the documents, in which case, you can leave this script processor out of your ingest pipeline configuration. 


```
{
    "script" : {
      "lang": "painless",
      "source": """
        ctx.entrySet().removeIf(field -> field.getKey() =~ /feature_.*/);
        ctx['problemchild'].remove('prediction_score');
        ctx['problemchild'].remove('model_id');
      """
    }
  }
``` 

## Ingest pipeline configuration for Windows process events

Once we have stored all the required Painless scripts, we can move on to configuring the Ingest Pipeline for new Windows process events. Since we are only interested in performing classification on Windows process events, we will later in this document show you how to make the Ingest Pipeline below execute conditionally only for process events if the host OS is Windows. For now, let's assume the document redirected to the pipeline is a Windows process event. 

First, let's get the model ID. We will need this to configure our Inference processor. You can obtain the model ID by using the Kibana Dev Console and running the command 


```
GET _ml/inference
```

You can then scroll through the response to find the model you trained. Make note of the model ID value. Below is a snippet of the model data showing the `model_id` field. 


```
   {
      "model_id" : "problemchild_713-1617395767841",
      "created_by" : "_xpack",
      "version" : "7.11.2",
      "description" : "",
      "tags" : [
        "problemchild_713"
      ]
```

If you have many models in your cluster, it can be easier to use part of your ML job's name in a search pattern like this

```
GET _ml/inference/problemchild_713_*
```

Once, we have the model id, we can configure the Ingest pipeline for new Windows Process events similar to how we did prior to training the model, but with the inference processor, blocklist processor and the featural removal script processor included in the list of processors. This updated ingest pipeline is available in the file `problemchild_inference.json`

In the pipeline configured in `problemchild_inference.json`, we first have all the processors that were used in the training ingest pipeline. They are followed by the inference processor which references our trained model (your model id will be different), followed by the blocklist processor. Finally, we have the script processor which removes the features the were added for inference. 

## Conditional Ingest pipeline execution

Not every event ingested will be a Windows process event. There are other OS (macOS, Linux) as well as different types of events (network, registry) for each OS. Hence, it would be ideal to make the pipeline we configured above execute conditionally only when our document contains the desired fields. We will use a pipeline processor and check for the presence of specific fields in the document before deciding whether or not to direct it to the pipeline that contains our inference processor. 


```
PUT _ingest/pipeline/problemchild_pipeline
{
  "description": "A pipeline of pipelines for ProblemChild detection",
  "processors": [
    {
      "pipeline": {
        "if": "ctx.containsKey('event') && ctx['event'].containsKey('kind')  && ctx['event'].containsKey('category') && ctx['event']['kind'] == 'event' && ctx['event']['category'] == 'process' && ctx.containsKey('host') && ctx['host'].containsKey('os') && (ctx['host']['os'].containsKey('family') || ctx['host']['os'].containsKey('type')) && (ctx['host']['os']['family'] == 'windows' || ctx['host']['os']['type'] == 'windows') && ctx.containsKey('agent') && ctx['agent'].containsKey('type') && !ctx['agent']['type'].empty",
        "name": "problemchild_inference"
      }
    }
  ]
}

```

In the conditional above, we first check whether the document being ingested contains the nested structure `event.kind` and make sure it is equal to "event". We then look for the nested structure `event.category` and make sure it is equal to "process". We also ensure that either `host.os.type` or `host.os.family` equal "windows". Finally, we check that the events we will infer on have a valid agent type ("endgame", "endpoint" or "winlogbeat") associated with them.

For a production usecase, please also make sure you think about error handling in the ingest pipeline. 

## Second-order analytics using the Anomaly Detection module

You can also setup unsupervised ML jobs to pick out the most suspicious events out of those detected by the supervised model (or blocklist if you have used it). This can be done using the Anomaly detection module in the Stack. We have made several anomaly detection job configurations available in the `job_configs` directory. You also need to configure datfeeds that will feed these jobs. The datafeeds are available in the `datafeeds` directory and are named as `datafeed_JOB_NAME` to identify the appropriate datafeed for each job.
