# Supplementary materials for "Machine learning in cybersecurity: Detecting DGA activity in network data"

This folder contains the supplementary materials for the blogpost "Machine learning in cybersecurity: Detecting DGA activity in network data"

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
