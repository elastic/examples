# Supplementary materials for "Machine learning in cybersecurity: Training supervised models to detect DGA activity"
This folder contains the supplementary materials for the blogpost["Machine learning in cybersecurity: Training supervised models to detect DGA activity](https://www.elastic.co/blog/machine-learning-in-cybersecurity-training-supervised-models-to-detect-dga-activity).

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

You can store it in Elasticsearch using the following Dev Console command


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
