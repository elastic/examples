# Query Optimization

In the following example code and notebooks we present a principled, data-driven approach to tuning queries based on a search relevance metric. We use the [Rank Evaluation API](https://www.elastic.co/guide/en/elasticsearch/reference/7.10/search-rank-eval.html) and [search templates](https://www.elastic.co/guide/en/elasticsearch/reference/7.10/search-template.html) to build a black-box optimization function and parameter space over which to optimize. This relies on the [skopt](https://scikit-optimize.github.io/) library for Bayesian optimization, which is one of the techniques used. All examples use the [MS MARCO](https://msmarco.org/) Document ranking datasets and metric, however all scripts and notebooks can easily be run with your own data and metric of choice. See the [Rank Evaluation API](https://www.elastic.co/guide/en/elasticsearch/reference/7.10/search-rank-eval.html) for a description of [supported metrics](https://www.elastic.co/guide/en/elasticsearch/reference/7.10/search-rank-eval.html#_available_evaluation_metrics).

In the context of the MS MARCO Document ranking task, we believe this provides a stronger baseline for comparison with neural ranking approaches. It can also be tuned for recall to provide a strong "retriever" component of a Q&A pipeline. What is often not talked about on leaderboards is also the latency of queries. You may achieve a higher relevance score (MRR@100) with neural ranking approaches but at what cost to real performance? This technique allows us to get the most relevance out of a query while maintaining high scalability and low latency search queries.   

For a high-level overview of the motivation, prerequisite knowledge and summary, please see the accompanying [blog post](https://www.elastic.co/blog/improving-search-relevance-with-data-driven-query-optimization).

## Results

Based on a series of evaluations with various analyzers, query types, and optimization, we’ve achieved the following results on the MS MARCO Document "Full Ranking" task as measured by MRR@100 on the "development" dataset. All experiments with full details and explanations can be found in the referenced Jupyter notebook. The best scores from each experiment are highlighted.

| Reference notebook | Experiment | MRR@100 |
|---|---|---|
| [0 - Analyzers](notebooks/0%20-%20Analyzers.ipynb) | Default analyzers, combined per-field `match`es | 0.2403 |
| [0 - Analyzers](notebooks/0%20-%20Analyzers.ipynb) | Custom analyzers, combined per-field `match`es | 0.2504 |
| [0 - Analyzers](notebooks/0%20-%20Analyzers.ipynb) | Default analyzers, `multi_match` `cross_fields` (default params) | 0.2475 |
| [0 - Analyzers](notebooks/0%20-%20Analyzers.ipynb) | Default analyzers, `multi_match` `cross_fields` (default params) | 0.2683 |
| [0 - Analyzers](notebooks/0%20-%20Analyzers.ipynb) | Default analyzers, `multi_match` `best_fields` (default params) | 0.2714 |
| [0 - Analyzers](notebooks/0%20-%20Analyzers.ipynb) | Default analyzers, `multi_match` `best_fields` (default params) | **0.2873** |
| [1 - Query tuning](notebooks/1%20-%20Query%20tuning.ipynb) | `multi_match` `cross_fields` baseline: default params | 0.2683 |
| [1 - Query tuning](notebooks/1%20-%20Query%20tuning.ipynb) | `multi_match` `cross_fields` tuned (step-wise): `tie_breaker`, `minimum_should_match` | 0.28419 |
| [1 - Query tuning](notebooks/1%20-%20Query%20tuning.ipynb) | `multi_match` `cross_fields` tuned (step-wise): all params | **0.3007** |
| [1 - Query tuning](notebooks/1%20-%20Query%20tuning.ipynb) | `multi_match` `cross_fields` tuned (all-in-one v1): all params | 0.2945 |
| [1 - Query tuning](notebooks/1%20-%20Query%20tuning.ipynb) | `multi_match` `cross_fields` tuned (all-in-one v2, refined parameter space): all params | 0.2993 |
| [1 - Query tuning](notebooks/1%20-%20Query%20tuning.ipynb) | `multi_match` `cross_fields` tuned (all-in-one v3, random): all params | 0.2966 |
| [2 - Query tuning - best_fields](notebooks/2%20-%20Query%20tuning%20-%20best_fields.ipynb) | `multi_match` `best_fields` baseline: default params | 0.2873 |
| [2 - Query tuning - best_fields](notebooks/2%20-%20Query%20tuning%20-%20best_fields.ipynb) | `multi_match` `best_fields` tuned (all-in-one): all params | **0.3079** |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `url`: `standard` analyzer; default params | 0.1843 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `url`: `standard` analyzer; tuned params | 0.1876 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `url`: non-word tokenizer, english filters, english+url stopwords; default params | 0.2060 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `url`: non-word tokenizer, english filters, english+url stopwords; tuned params | 0.2139 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `url`: non-word tokenizer, english filters, english+question+url stopwords; default params | 0.2094 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `url`: non-word tokenizer, english filters, english+question+url stopwords; tuned params | **0.2187** |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `title`: `standard` analyzer; default params | 0.2012 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `title`: `standard` analyzer; tuned params | 0.2000 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `title`: `english` analyzer; default params | 0.2280 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `title`: `english` analyzer; tuned params | 0.2305 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `title`: `standard` tokenizer, english filters, english+question stopwords; default params | 0.2298 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `title`: `standard` tokenizer, english filters, english+question stopwords; tuned params | **0.2349** |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `title.bigrams`: `standard` analyzer; default params | 0.1080 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `title.bigrams`: `standard` analyzer; tuned params | 0.1084 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `title.bigrams`: `standard` tokenizer, english bigrammer, no stopwords; default params | 0.1176 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `title.bigrams`: `standard` tokenizer, english bigrammer, no stopwords; tuned params | 0.1166 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `title.bigrams`: `standard` tokenizer, english bigrammer, english+question stopwords; default params | **0.1295** |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `title.bigrams`: `standard` tokenizer, english bigrammer, english+question stopwords; tuned params | 0.1280 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `body`: `standard` analyzer; default params | 0.2503 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `body`: `standard` analyzer; tuned params | 0.2617 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `body`: `english` analyzer; default params | 0.2463 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `body`: `english` analyzer; tuned params | 0.2617 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `body`: `standard` tokenizer, english filters, english+question stopwords; default params | 0.2568 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `body`: `standard` tokenizer, english filters, english+question stopwords; tuned params | **0.2645** |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `body.bigrams`: `standard` analyzer; default params | 0.1575 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `body.bigrams`: `standard` analyzer; tuned params | 0.1580 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `body.bigrams`: `standard` tokenizer, english bigrammer, no stopwords; default params | 0.1675 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `body.bigrams`: `standard` tokenizer, english bigrammer, no stopwords; tuned params | 0.1674 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `body.bigrams`: `standard` tokenizer, english bigrammer, english stopwords; default params | 0.2013 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `body.bigrams`: `standard` tokenizer, english bigrammer, english stopwords; tuned params | 0.2040 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `body.bigrams`: `standard` tokenizer, english bigrammer, english+question stopwords; default params | 0.2015 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `body.bigrams`: `standard` tokenizer, english bigrammer, english+question stopwords; tuned params | **0.2041** |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `expansions`: `standard` analyzer; default params | 0.3066 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `expansions`: `standard` analyzer; tuned params | 0.3123 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `expansions`: `english` analyzer; default params | 0.3078 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `expansions`: `english` analyzer; tuned params | 0.3199 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `expansions`: `standard` tokenizer, english filters, english+question stopwords; default params | 0.3081 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `expansions`: `standard` tokenizer, english filters, english+question stopwords; tuned params | **0.3220** |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `expansions.bigrams`: `standard` analyzer; default params | 0.2596 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `expansions.bigrams`: `standard` analyzer; tuned params | 0.2596 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `expansions.bigrams`: `standard` tokenizer, english bigrammer, no stopwords; default params | 0.2679 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `expansions.bigrams`: `standard` tokenizer, english bigrammer, no stopwords; tuned params | 0.2679 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `expansions.bigrams`: `standard` tokenizer, english bigrammer, english stopwords; default params | 0.2795 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `expansions.bigrams`: `standard` tokenizer, english bigrammer, english stopwords; tuned params | 0.2793 |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `expansions.bigrams`: `standard` tokenizer, english bigrammer, english+question stopwords; default params | **0.2837** |
| [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb) | `expansions.bigrams`: `standard` tokenizer, english bigrammer, english+question stopwords; tuned params | 0.2837 |
| [doc2query - 2 - best_fields](notebooks/doc2query%20-%202%20-%20best_fields.ipynb) | Base fields; default params | 0.2873 |
| [doc2query - 2 - best_fields](notebooks/doc2query%20-%202%20-%20best_fields.ipynb) | Base fields; tuned params | 0.3079 |
| [doc2query - 2 - best_fields](notebooks/doc2query%20-%202%20-%20best_fields.ipynb) | Base fields + bigrams; default params | 0.2582 |
| [doc2query - 2 - best_fields](notebooks/doc2query%20-%202%20-%20best_fields.ipynb) | Base fields + bigrams; tuned params | 0.3036 |
| [doc2query - 2 - best_fields](notebooks/doc2query%20-%202%20-%20best_fields.ipynb) | Base fields + expansions; default params | 0.3229 |
| [doc2query - 2 - best_fields](notebooks/doc2query%20-%202%20-%20best_fields.ipynb) | Base fields + expansions; tuned params | 0.3400 |
| [doc2query - 2 - best_fields](notebooks/doc2query%20-%202%20-%20best_fields.ipynb) | Base fields + expansions + bigrams; default params | 0.3240 |
| [doc2query - 2 - best_fields](notebooks/doc2query%20-%202%20-%20best_fields.ipynb) | Base fields + expansions + bigrams; tuned params | **0.3419** |
| [doc2query - 3 - most_fields](notebooks/doc2query%20-%203%20-%20most_fields.ipynb) | Base fields; default params | 0.2828 |
| [doc2query - 3 - most_fields](notebooks/doc2query%20-%203%20-%20most_fields.ipynb) | Base fields; tuned params |  |
| [doc2query - 3 - most_fields](notebooks/doc2query%20-%203%20-%20most_fields.ipynb) | Base fields + bigrams; default params | 0.2677 |
| [doc2query - 3 - most_fields](notebooks/doc2query%20-%203%20-%20most_fields.ipynb) | Base fields + bigrams; tuned params | 0.2999 |
| [doc2query - 3 - most_fields](notebooks/doc2query%20-%203%20-%20most_fields.ipynb) | Base fields + expansions; default params | 0.3236 |
| [doc2query - 3 - most_fields](notebooks/doc2query%20-%203%20-%20most_fields.ipynb) | Base fields + expansions; tuned params | 0.3363 |
| [doc2query - 3 - most_fields](notebooks/doc2query%20-%203%20-%20most_fields.ipynb) | Base fields + expansions + bigrams; default params | 0.3204 |
| [doc2query - 3 - most_fields](notebooks/doc2query%20-%203%20-%20most_fields.ipynb) | Base fields + expansions + bigrams; tuned params | **0.3416** |
| [doc2query - 4 - linear combo](notebooks/doc2query%20-%204%20-%20linear%20combo.ipynb) | Base fields; default params |  |
| [doc2query - 4 - linear combo](notebooks/doc2query%20-%204%20-%20linear%20combo.ipynb) | Base fields; tuned params |  |
| [doc2query - 4 - linear combo](notebooks/doc2query%20-%204%20-%20linear%20combo.ipynb) | Base fields + bigrams; default params |  |
| [doc2query - 4 - linear combo](notebooks/doc2query%20-%204%20-%20linear%20combo.ipynb) | Base fields + bigrams; tuned params |  |
| [doc2query - 4 - linear combo](notebooks/doc2query%20-%204%20-%20linear%20combo.ipynb) | Base fields + expansions; default params |  |
| [doc2query - 4 - linear combo](notebooks/doc2query%20-%204%20-%20linear%20combo.ipynb) | Base fields + expansions; tuned params |  |
| [doc2query - 4 - linear combo](notebooks/doc2query%20-%204%20-%20linear%20combo.ipynb) | Base fields + expansions + bigrams; default params |  |
| [doc2query - 4 - linear combo](notebooks/doc2query%20-%204%20-%20linear%20combo.ipynb) | Base fields + expansions + bigrams; tuned params |  |

## Setup

### Prerequisites

To run the simulation, you will first need:

 - Elasticsearch 7.10+ **
   - Cloud [Elasticsearch Service](https://www.elastic.co/elasticsearch/service) (free trials available)
   - [Local installations](https://www.elastic.co/start)
 - `make`
 - Python 3.7+ (try [pyenv](https://github.com/pyenv/pyenv) to manage multiple Python versions)
 - `virtualenv` (installed with `pip install virtualenv`)

** Instructions and code have been tested on versions: 7.8.0, 7.9.3, 7.10.0. There is a slight relevance improvement in 7.9.3 over 7.8.x so we would recommend 7.9.3 at a minimum, but prefer always the latest release.

### Project and environment

Use the `Makefile` for all setup, building, testing, etc. Common commands (and targets) are:

 - `make init`: install project dependencies (from requirements.txt)
 - `make clean`: cleanup environment
 - `make test`: run tests
 - `make jupyter`: run Jupyter Lab (notebooks)

Most operations are performed using scripts in the `bin` directory. Use `-h` or `--help` on the commands to explore their functionality and arguments such as number of processes to use (for parallelizable tasks), URL for Elasticsearch, etc.

Start off by running just `make init` to setup the project.

Start an Elasticsearch instance locally or use a [Cloud](https://cloud.elastic.co) instance. For this demo, we recommend allocating at least 8GB of memory to the Elasticsearch JVM and having at least 16 GB total available on the host.

```bash
ES_JAVA_OPTS="-Xmx8g -Xms8g" ./bin/elasticsearch
```

### Data

We use [MS MARCO](https://msmarco.org) as a large-scale, public benchmark. Before you use data from MS MARCO, you must accept the dataset license as seen on the main [MS MARCO](https://msmarco.org) page. Download files from the [document ranking task](https://github.com/microsoft/MSMARCO-Document-Ranking#document-ranking-dataset) and make them available in `data/msmarco-document`. Specifically, we need the following files:

 * Corpus: [`msmarco-docs.tsv`](https://msmarco.blob.core.windows.net/msmarcoranking/msmarco-docs.tsv.gz)
 * Training queries: [`msmarco-doctrain-queries.tsv`](https://msmarco.blob.core.windows.net/msmarcoranking/msmarco-doctrain-queries.tsv.gz)
 * Training labeled results ("qrels"): [`msmarco-doctrain-qrels.tsv`](https://msmarco.blob.core.windows.net/msmarcoranking/msmarco-doctrain-qrels.tsv.gz)
 * Development queries (holdout set): [`msmarco-docdev-queries.tsv`](https://msmarco.blob.core.windows.net/msmarcoranking/msmarco-docdev-queries.tsv.gz)
 * Development labeled results ("qrels"): [`msmarco-docdev-qrels.tsv`](https://msmarco.blob.core.windows.net/msmarcoranking/msmarco-docdev-qrels.tsv.gz) 
 * Development top 100 baseline results: [`msmarco-docdev-top100.gz`](https://msmarco.blob.core.windows.net/msmarcoranking/msmarco-docdev-top100.gz)
 * Evaluation queries (for leaderboard submission): [`docleaderboard-queries.tsv`](https://msmarco.blob.core.windows.net/msmarcoranking/docleaderboard-queries.tsv.gz)

Convert the corpus into indexable documents (~5 mins):

```bash
time bin/convert-msmarco-document-corpus \
  data/msmarco/document/msmarco-docs.tsv \
  data/msmarco-document-index-actions.jsonl
```

Bulk index documents into two indices (with different analyzers) (~30 mins):

```bash
time bin/bulk-index \
  --index msmarco-document.defaults \
  --config config/msmarco-document-index.defaults.json \
  data/msmarco-document-index-actions.jsonl
```

```bash
time bin/bulk-index \
  --index msmarco-document \
  --config config/msmarco-document-index.custom.json \
  data/msmarco-document-index-actions.jsonl
```

For debugging, experimentation and the final optimization process, sample the query training dataset into smaller datasets:

```bash
bin/split-and-sample \
  --input data/msmarco/document/msmarco-doctrain-queries.tsv \
  --output \
    data/msmarco-document-sampled-queries.10.tsv,10 \
    data/msmarco-document-sampled-queries.100.tsv,100 \
    data/msmarco-document-sampled-queries.1000.tsv,1000 \
    data/msmarco-document-sampled-queries.10000.tsv,10000
```

At this point, you can choose to either carry on running things from the command line, or you can jump to the notebooks and walk through a more detailed set of examples. We recommend the notebooks first, then come back and use the command line scripts when you have larger scale experimentation or evaluation that you'd like to perform. If you need to perform the doc2query examples, please continue to the next section first.

### Data - doc2query

In order to perform the doc2query experiments, we need to download pre-generated expansion text (predicted queries) from and generate the index actions with a new mapping to support extra fields.

We're interested in performing the plain expansion on a document level so you can also follow along on the [castorini/docTTTTTquery](https://github.com/castorini/docTTTTTquery#replicating-ms-marco-document-ranking-results-with-anserini) repo.

From the above repo, use the links there to download two files:

 - `predicted_queries_doc.tar.gz` - contains the actual predicted queries, per passage
 - `msmarco_doc_passage_ids.txt` - contains the mappings of passages to documents (which we will index)

Next, follow the instructions for [Per-Document Expansion](https://github.com/castorini/docTTTTTquery#per-document-expansion) and stop at the step to generate index actions using the command `convert_msmarco_doc_to_anserini.py` and make sure to output to `data/doc2query`. Before we run this command, we will want to adjust the output. Open that file and edit the top to output JSONL with the fields separated:

```python
def generate_output_dict(doc, predicted_queries):
    doc_id, doc_url, doc_title, doc_body = doc[0], doc[1], doc[2], doc[3]
    doc_body = doc_body.strip()
    predicted_queries = predicted_queries.strip()
    return {
        '_id': doc_id,
        '_source': {
            'id': doc_id,
            'url': doc_url,
            'title': doc_title,
            'body': doc_body,
            'expansions': predicted_queries,
        }
    }
```

Now generate the action commands that we will use for indexing.

```bash
python3 convert_msmarco_doc_to_anserini.py \
  --original_docs_path=data/msmarco/document/msmarco-docs.tsv.gz \
  --doc_ids_path=data/doc2query/msmarco_doc_passage_ids.txt \
  --predictions_path=data/doc2query/doc-predictions/predicted_queries_doc_sample_all.txt \
  --output_docs_path=data/msmarco-document-index-actions.doc2query.jsonl
```

Last, you can index the fields with the mapping which includes an `expansions` field.

```bash
time bin/bulk-index \
  --index msmarco-document.doc2query \
  --config config/msmarco-document-index.doc2query.json \
  data/msmarco-document-index-actions.doc2query.jsonl
```


## Notebooks

The notebooks are structured as teaching walkthroughs and contain a lot of detail on the process. We recommend going through the notebooks in the following order:

- [0 - Analyzers](notebooks/0%20-%20Analyzers.ipynb)
- [1 - Query tuning](notebooks/1%20-%20Query%20tuning.ipynb)
- [2 - Query tuning - best_fields](notebooks/2%20-%20Query%20tuning%20-%20best_fields.ipynb)
- [Appendix A - BM25 tuning](notebooks/Appendix%20A%20-%20BM25%20tuning.ipynb)
- [Appendix B - Combining queries](notebooks/Appendix%20B%20-%20Combining%20queries.ipynb)
- [doc2query - 1 - BM25 tuning](notebooks/doc2query%20-%201%20-%20BM25%20tuning.ipynb)
- [doc2query - 2 - best_fields](notebooks/doc2query%20-%202%20-%20best_fields.ipynb)
- [doc2query - 3 - most_fields](notebooks/doc2query%20-%203%20-%20most_fields.ipynb)
- [doc2query - 4 - linear combo](notebooks/doc2query%20-%204%20-%20linear%20combo.ipynb)

To start the Jupyter Labs (notebooks) server, use `make jupyter`.

## Command line scripts

All of the code that powers the notebooks is also available through command line scripts. These scripts can be more convenient to run on a server in a `screen` session, for example, if your jobs take hours to run.

### Run evaluation

Using some baseline/default parameter values, run an evaluation. This uses the `dev` dataset, which contains about 3,200 queries.

```bash
time bin/eval \
  --index msmarco-document \
  --metric config/metric-mrr-100.json \
  --templates config/msmarco-document-templates.json \
  --template-id best_fields \
  --queries data/msmarco/document/msmarco-docdev-queries.tsv \
  --qrels data/msmarco/document/msmarco-docdev-qrels.tsv \
  --params config/params.best_fields.baseline.json
```

### Run query optimization

Build a configuration file based on the kind of optimization you want to do. This uses one of the sampled `train` datasets, which contains 10,000 queries. (Note that in the notebooks, we typically only use 1,000 queries for training and that's usually sufficient.) This will save the output of the final parameters to a JSON config file that can be used by evaluation.

```bash
time bin/optimize-query \
  --index msmarco-document \
  --metric config/metric-mrr-100.json \
  --templates config/msmarco-document-templates.json \
  --template-id best_fields \
  --queries data/msmarco-document-sampled-queries.10000.tsv \
  --qrels data/msmarco/document/msmarco-doctrain-qrels.tsv \
  --config config/optimize-query.best_fields.json \
  --output data/params.best_fields.optimal.json
```

Run the evaluation again to compare results on the same `dev` dataset, but this time with the optimal parameters.

```bash
time bin/eval \
  --index msmarco-document \
  --metric config/metric-mrr-100.json \
  --templates config/msmarco-document-templates.json \
  --template-id best_fields \
  --queries data/msmarco/document/msmarco-docdev-queries.tsv \
  --qrels data/msmarco/document/msmarco-docdev-qrels.tsv \
  --params data/params.best_fields.optimal.json
```

See the accompanying Jupyter notebooks for more details and examples.

### Run TREC evaluation

Download the official TREC evaluation tool. The current version as of publish date is `9.0.7`.

```bash
wget https://trec.nist.gov/trec_eval/trec_eval-9.0.7.tar.gz
tar -xzvf trec_eval-9.0.7.tar.gz
cd trec_eval-9.0.7
make
cd ..
```

Run the evaluation on the provided top 100 results from the `dev` set, and validate the output.

```bash
trec_eval-9.0.7/trec_eval -c -mmap -M 100 \
    data/msmarco/document/msmarco-docdev-qrels.tsv \
    data/msmarco/document/msmarco-docdev-top100
```

Run our query and generate a TREC compatible result file. Make sure to choose the right template and a matching parameter configuration file.

```bash
time bin/bulk-search \
  --index msmarco-document \
  --name best_fields \
  --templates config/msmarco-document-templates.json \
  --template-id best_fields \
  --queries data/msmarco/document/msmarco-docdev-queries.tsv \
  --params data/params.best_fields.optimal.json \
  --size 100 \
  --output data/msmarco-docdev-best_fields-top100.tsv
```

And now evalute on the new results.

```bash
trec_eval-9.0.7/trec_eval -c -mmap -M 100 \
    data/msmarco/document/msmarco-docdev-qrels.tsv \
    data/msmarco-docdev-best_fields-top100.tsv
```

### Prepare an official MS MARCO submission

For making submissions to the MS MARCO Document ranking leaderboard, we need to follow the [submission guidelines](https://github.com/microsoft/MSMARCO-Document-Ranking-Submissions). The submission process is a pull-request based system, so read through the [README](https://github.com/microsoft/MSMARCO-Document-Ranking-Submissions) for all the details.

For all the commands below, make sure you symlink a local `data/submissions` to the `submissions` folder in the `MSMARCO-Document-Ranking-Submissions` fork on your local machine. Note that the commands from the [`microsoft/MSMARCO-Document-Ranking-Submissions`](https://github.com/microsoft/MSMARCO-Document-Ranking-Submissions) repository seem to not work on macOS, so please use a Linux OS for this process.

Here's an example that outlines how we made our first submission `20201125-elastic-optimal_best_fields`. For this submission, we've saved the best parameters from the `multi_match` `best_fields` query, as seen in the notbeook [2 - Query tuning - best_fields](notebooks/2%20-%20Query%20tuning%20-%20best_fields.ipynb).

```bash
export SUBMISSION_NAME=20201125-elastic-optimized_best_fields
mkdir data/submissions/$SUBMISSION_NAME
cp submissions/$SUBMISSION_NAME/metadata.json data/submissions/$SUBMISSION_NAME-metadata.json
```

Run our optimal query on the `dev` and `eval` queries.

```bash
time bin/bulk-search \
  --index msmarco-document \
  --name best_fields \
  --templates config/msmarco-document-templates.json \
  --template-id best_fields \
  --queries data/msmarco/document/msmarco-docdev-queries.tsv \
  --params submissions/$SUBMISSION_NAME/params.json \
  --size 100 \
  --output data/submissions/$SUBMISSION_NAME/results-dev.tsv

time bin/bulk-search \
  --index msmarco-document \
  --name best_fields \
  --templates config/msmarco-document-templates.json \
  --template-id best_fields \
  --queries data/msmarco/document/docleaderboard-queries.tsv \
  --params submissions/$SUBMISSION_NAME/params.json \
  --size 100 \
  --output data/submissions/$SUBMISSION_NAME/results-eval.tsv
```

Now switch to your fork's local clone of [`microsoft/MSMARCO-Document-Ranking-Submissions`](https://github.com/microsoft/MSMARCO-Document-Ranking-Submissions).

Prepare the submission files.

```bash
cut -f 1,3,4 submissions/$SUBMISSION_NAME/results-dev.tsv > submissions/$SUBMISSION_NAME/dev.txt
cut -f 1,3,4 submissions/$SUBMISSION_NAME/results-eval.tsv > submissions/$SUBMISSION_NAME/eval.txt
bzip2 -zfk submissions/$SUBMISSION_NAME/dev.txt
bzip2 -zfk submissions/$SUBMISSION_NAME/eval.txt
```

Run the official evaluation script and package the submission files.

```bash
python eval/run_eval.py --id $SUBMISSION_NAME
eval/pack.sh $SUBMISSION_NAME
```

Now you can commit and push the branch to your fork and open a pull request on the [upstream project](https://github.com/microsoft/MSMARCO-Document-Ranking-Submissions).
