# Query Optimization

In the following example code and notebooks we present a principled, data-driven approach to tuning queries based on a search relevance metric. We use the [Rank Evaluation API](https://www.elastic.co/guide/en/elasticsearch/reference/7.10/search-rank-eval.html) and [search templates](https://www.elastic.co/guide/en/elasticsearch/reference/7.10/search-template.html) to build a black-box optimization function and parameter space over which to optimize. This relies on the [skopt](https://scikit-optimize.github.io/) library for Bayesian optimization, which is one of the techniques used. All examples use the [MS MARCO](https://msmarco.org/) Document ranking datasets and metric, however all scripts and notebooks can easily be run with your own data and metric of choice. See the [Rank Evaluation API](https://www.elastic.co/guide/en/elasticsearch/reference/7.10/search-rank-eval.html) for a description of [supported metrics](https://www.elastic.co/guide/en/elasticsearch/reference/7.10/search-rank-eval.html#_available_evaluation_metrics).

In the context of the MS MARCO Document ranking task, we believe this provides a stronger baseline for comparison with neural ranking approaches. It can also be tuned for recall to provide a strong "retriever" component of a Q&A pipeline. What is often not talked about on leaderboards is also the latency of queries. You may achieve a higher relevance score (MRR@100) with neural ranking approaches but at what cost to real performance? This technique allows us to get the most relevance out of a query while maintaining high scalability and low latency search queries.   

For a high-level overview of the motivation, prerequisite knowledge and summary, please see the accompanying [blog post](https://www.elastic.co/blog/improving-search-relevance-with-data-driven-query-optimization).

## Results

Based on a series of evaluations with various analyzers, query types, and optimization, we’ve achieved the following results on the MS MARCO Document "Full Ranking" task as measured by MRR@100 on the "development" dataset. All experiments with full details and explanations can be found in the referenced Jupyter notebook. The best scores from each notebook are highlighted.

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

At this point, you can choose to either carry on running things from the command line or you can jump to the notebooks and walk through a more detailed set of examples. We recommend the notebooks first, then come back and use the command line scripts when you have larger scale experimentation or evaluation that you'd like to perform.

## Notebooks

The notebooks are structued as teaching walkthroughs and contain a lot of detail on the process. We recommend going through the notebooks in the following order:

- [0 - Analyzers](notebooks/0%20-%20Analyzers.ipynb)
- [1 - Query tuning](notebooks/1%20-%20Query%20tuning.ipynb)
- [2 - Query tuning - best_fields](notebooks/2%20-%20Query%20tuning%20-%20best_fields.ipynb)
- [Appendix A - BM25 tuning](notebooks/Appendix%20A%20-%20BM25%20tuning.ipynb)
- [Appendix B - Combining queries](notebooks/Appendix%20B%20-%20Combining%20queries.ipynb)

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
