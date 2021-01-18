"""Support for Jupyter Lab notebooks."""

import datetime
import os

from copy import deepcopy
from .eval import build_requests
from .optimize import optimize_query, optimize_bm25, set_bm25_parameters
from .trec import load_queries_as_tuple_list, load_qrels
from .util import load_json

ROOT_DIR = os.path.abspath('..')
TEMPLATES_FILE = os.path.join(ROOT_DIR, 'config', 'msmarco-document-templates.json')


def set_bm25_params(es, index, best):
    """Sets the BM25 parameters for given field names and params."""

    def similarity_name(field):
        return f"bm25-{field.replace('.', '-')}"

    print("Setting BM25 params fields:")
    for field, params in best:
        print(f" - {field}: {params}")
        set_bm25_parameters(es, index, name=similarity_name(field), **params)


def mrr(k):
    return deepcopy({
        'mean_reciprocal_rank': {
            'k': k,
            'relevant_rating_threshold': 1,
        }
    })


def evaluate_mrr100_dev(es, max_concurrent_searches, index, template_id, params):
    templates = load_json(TEMPLATES_FILE)
    return evaluate_mrr100_dev_templated(es, max_concurrent_searches, index, templates, template_id, params)


def evaluate_mrr100_dev_templated(es, max_concurrent_searches, index, templates, template_id, params):
    k = 100
    queries = load_queries_as_tuple_list(os.path.join(ROOT_DIR, 'data', 'msmarco', 'document', 'msmarco-docdev-queries.tsv'))
    qrels = load_qrels(os.path.join(ROOT_DIR, 'data', 'msmarco', 'document', 'msmarco-docdev-qrels.tsv'))

    body = {
        'metric': mrr(k),
        'templates': templates,
        'requests': build_requests(index, template_id, queries, qrels, params),
        'max_concurrent_searches': max_concurrent_searches,
    }

    print(f"Evaluation with: MRR@{k}")

    results = es.rank_eval(body=body, index=index, request_timeout=1200,
                           allow_no_indices=False, ignore_unavailable=False,
                           search_type='dfs_query_then_fetch')
    print(f"Score: {results['metric_score']:.04f}")
    return results


def verbose_logger(iteration, total_iterations, score, curr_min_score, duration, params):
    def seconds_to_str(seconds):
        delta = datetime.timedelta(seconds=seconds)
        return str(delta - datetime.timedelta(microseconds=delta.microseconds))

    remaining_duration = duration * (total_iterations - iteration)
    duration_s = seconds_to_str(duration)
    remaining_s = seconds_to_str(remaining_duration)
    print(f" > iteration {iteration}/{total_iterations}, took {duration_s} (remains: {remaining_s})")
    print(f"   | {score:.04f} (best: {curr_min_score:.04f}) - {params}")


def optimize_query_mrr100(es, max_concurrent_searches, index, template_id, config_space, verbose=True):
    templates = load_json(TEMPLATES_FILE)
    return optimize_query_mrr100_templated(es, max_concurrent_searches, index,
                                           templates, template_id, config_space,
                                           verbose)


def optimize_query_mrr100_templated(es, max_concurrent_searches, index, templates, template_id, config_space, verbose=True):
    k = 100
    queries_fname = os.path.join('data', 'msmarco-document-sampled-queries.1000.tsv')
    qrels_fname = os.path.join('data', 'msmarco', 'document', 'msmarco-doctrain-qrels.tsv')

    queries = load_queries_as_tuple_list(os.path.join(ROOT_DIR, queries_fname))
    qrels = load_qrels(os.path.join(ROOT_DIR, qrels_fname))

    print("Optimizing parameters")
    print(f" - metric: MRR@{k}")
    print(f" - queries: {queries_fname}")
    print(f" - queries: {qrels_fname}")

    if verbose:
        logger = verbose_logger
    else:
        logger = None

    best_score, best_params, final_params, metadata = optimize_query(
        es, max_concurrent_searches, index, config_space, mrr(100), templates,
        template_id, queries, qrels, logger)

    print(f"Best score: {best_score:.04f}")
    print(f"Best params: {best_params}")
    print(f"Final params: {final_params}")
    print()

    return best_score, best_params, final_params, metadata


def optimize_bm25_mrr100(es, max_concurrent_searches, index, template_id, query_params, config_space, name=None, verbose=True):
    templates = load_json(TEMPLATES_FILE)
    return optimize_bm25_mrr100_templated(es, max_concurrent_searches, index,
                                          templates, template_id, query_params,
                                          config_space, name, verbose)


def optimize_bm25_mrr100_templated(es, max_concurrent_searches, index, templates, template_id, query_params, config_space, name=None, verbose=True):
    k = 100
    queries_fname = os.path.join('data', 'msmarco-document-sampled-queries.1000.tsv')
    qrels_fname = os.path.join('data', 'msmarco', 'document', 'msmarco-doctrain-qrels.tsv')

    queries = load_queries_as_tuple_list(os.path.join(ROOT_DIR, queries_fname))
    qrels = load_qrels(os.path.join(ROOT_DIR, qrels_fname))

    print("Optimizing parameters")
    print(f" - metric: MRR@{k}")
    print(f" - queries: {queries_fname}")
    print(f" - queries: {qrels_fname}")

    if verbose:
        logger = verbose_logger
    else:
        logger = None

    best_score, best_params, final_params, metadata = optimize_bm25(
        es, max_concurrent_searches, index, config_space, mrr(100), templates,
        template_id, queries, qrels, query_params, name, logger)

    print(f"Best score: {best_score:.04f}")
    print(f"Best params: {best_params}")
    print(f"Final params: {final_params}")
    print()

    return best_score, best_params, final_params, metadata
