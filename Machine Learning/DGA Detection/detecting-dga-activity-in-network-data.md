# Supplementary materials for "Machine learning in cybersecurity: Detecting DGA activity in network data"

This folder contains the supplementary materials for the blogpost "Machine learning in cybersecurity: Detecting DGA activity in network data".
These configurations have been tested on Elasticsearch version 7.6.2

## Painless Script for Extracting Unigrams, Bigrams and Trigrams from Packetbeat data

Because our model was trained on unigrams, bigrams and trigrams, we have to extract these same features from any new domains we wish to score using the model. Hence, before passing the domains from packetbeat DNS requests into the inference processor, we first have to pass them through a Painless script processor that invokes the stored script below.

```
POST _scripts/ngram-extractor-packetbeat
{
  "script": {
    "lang": "painless",
    "source": """
String nGramAtPosition(String fulldomain, int fieldcount, int n){

  String domain = fulldomain.splitOnToken('.')[0];
  if (fieldcount+n>=domain.length()){
    return ''
  }
  else 
{
  return domain.substring(fieldcount, fieldcount+n)
}
}
for (int i=0;i<ctx['dns']['question']['registered_domain'].length();i++){
  ctx['field_'+Integer.toString(params.ngram_count)+'_gram_'+Integer.toString(i)] = nGramAtPosition(ctx['dns']['question']['registered_domain'], i, params.ngram_count)
}"""
  }
}
```

## Painless Script for Removing Unigrams, Bigrams and Trigrams from Packetbeat data

Since we don't want the extra unigrams, bigrams and trigrams to be ingested together with our packetbeat data, we will also configure a script to remove these features. This script will be invoked in the ingest pipeline after the inference processor. Of course, if you wish, you can leave the features in the documents, in which case, you can leave out this script from your ingest pipeline configuration. 


```
POST _scripts/ngram-remover-packetbeat
{
  "script": {
    "lang": "painless",
    "source": """
for (int i=0;i<ctx['dns']['question']['registered_domain'].length();i++){
  ctx.remove('field_'+Integer.toString(params.ngram_count)+'_gram_'+Integer.toString(i))
}
"""
  }
}
```

## Ingest Pipeline Configuration for Packetbeat DNS Data

Once we have stored both of the Painless scripts above, we can move on to configuring the Ingest Pipeline for the DNS data. Since we are only interested in performing classification on DNS data, we will, later in this document, show you how to make the Ingest Pipeline below execute conditionally only if the required DNS fields are present in the packetbeat document. For now, let's assume the document redirected to the pipeline has the required DNS fields. 

First, let's get the model ID. We will need this to configure our Inference processor. 
You can obtain the model ID by using the Kibana Dev Console and running the command 

```
GET _ml/inference
```

You can then scroll through the response to find the model you trained for DGA detection. 
Make note of the model ID value. Below is a snippet of the model data showing the
`model_id` field. 

```
   {
      "model_id" : "dga-ngram-job-1587729368929",
      "created_by" : "_xpack",
      "version" : "7.6.2",
      "description" : "",
      "create_time" : 1587729368929,
      "tags" : [
        "dga-ngram-job"
      ],
```

If you have many models in your cluster, it can be easier to use part of your ML job's name in a search pattern like this

```
GET _ml/inference/dga-ngram-job*
```

Once, we have the model id, we can configure the Ingest pipeline for DNS data as below

```
PUT _ingest/pipeline/dga_ngram_expansion_inference
{
    "description": "Expands a domain into unigrams, bigrams and trigrams and makes a prediction of maliciousness",
    "processors": [
      {
        "script": {
          "id": "ngram-extractor-packetbeat",
          "params":{
            "ngram_count":1
          }
        }
      },
       {
        "script": {
          "id": "ngram-extractor-packetbeat",
          "params":{
            "ngram_count":2
          }
        }
      },
       {
        "script": {
          "id": "ngram-extractor-packetbeat",
          "params": {
            "ngram_count":3
          }
        }
      },
              {
  "inference": {
    "model_id": "dga-ngram-job-1587729368929",
    "target_field": "predicted_label",
    "field_mappings":{},
    "inference_config": { "classification": {"num_top_classes": 2} }
  }
},
      {
        "script": {
          "id": "ngram-remover-packetbeat",
          "params":{
            "ngram_count":1
          }
        }
      },
       {
        "script": {
          "id": "ngram-remover-packetbeat",
          "params":{
            "ngram_count":2
          }
        }
      },
       {
        "script": {
          "id": "ngram-remover-packetbeat",
          "params": {
            "ngram_count":3
          }
        }
      }
    ]
}

```

In the pipeline above, the first three processor invoke the same Painless script `ngram-extractor-packetbeat` to extract unigrams, bigrams and trigrams respectively (see the parameter `ngram_count` which varies in each processor). They are followed by the Inference processor which references our trained model (your model id will be different). Finally, we have three Painless script processor, which reference the script `ngram-remover-packetbeat` to remove the features required by the model. 

## Conditional Ingest pipeline execution


