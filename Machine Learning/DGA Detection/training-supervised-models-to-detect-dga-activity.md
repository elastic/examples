# Supplementary materials for "Machine learning in cybersecurity: Training supervised models to detect DGA activity"
This folder contains the supplementary materials for the blogpost ["Machine learning in cybersecurity: Training supervised models to detect DGA activity](https://www.elastic.co/blog/machine-learning-in-cybersecurity-training-supervised-models-to-detect-dga-activity).

## Training the classification model

The raw data we used to train the model has the format

```
domain,dga_algorithm,malicious
pdtmstring,banjori,true
umfpstring,banjori,true
cmzmstring,banjori,true
hrynstring,banjori,true
nhdjstring,banjori,true
ppkustring,banjori,true
```

We are interested in extracting unigrams, bigrams and trigrams from the 
`domain` field. Thus, we have to first define a Painless script that is
capable of taking a string as an input and expanding the string
into a set of n-grams, for some value of `n`. 

The script is available in the file `ngram-extractor-reindex.json`, but is also
reproduced below. 

You can store it in Elasticsearch using the following Dev Console command.
As you can see, the script accepts one parameter which is `n`, the length
of the n-gram. 


```
POST _scripts/ngram-extractor-reindex
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
for (int i=0;i<ctx['domain'].length();i++){
  ctx[Integer.toString(params.ngram_count)+'-gram_field'+Integer.toString(i)] = nGramAtPosition(ctx['domain'], i, params.ngram_count)
}
 """
  }
}

```

We can then use the stored script to configure an Ingest Pipeline as follows.


```
PUT _ingest/pipeline/dga_ngram_expansion_reindex
{
    "description": "Expands a domain into unigrams, bigrams and trigrams",
    "processors": [
      {
        "script": {
          "id": "ngram-extractor-reindex",
          "params":{
            "ngram_count":1
          }
        }
      },
       {
        "script": {
          "id": "ngram-extractor-reindex",
          "params":{
            "ngram_count":2
          }
        }
      },
       {
        "script": {
          "id": "ngram-extractor-reindex",
          "params": {
            "ngram_count":3
          }
        }
      }
    ]
}
```

Once the Ingest Pipeline has been configured we can re-index
our original index with the raw data into a new index which will contain the 
n-gram expansion of each domain.


```
POST _reindex
{
  "source": {
    "index": "dga_raw"
  },
  "dest": {
    "index": "dga_ngram_expansion",
    "pipeline": "dga_ngram_expansion_reindex"
  }
}
```

Once you have all of the data re-indexed through the Ingest Pipeline, you can follow
the screenshots in the [blog post](https://www.elastic.co/blog/machine-learning-in-cybersecurity-training-supervised-models-to-detect-dga-activity) to configure your ML job. 