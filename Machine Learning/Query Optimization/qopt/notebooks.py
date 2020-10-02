"""Support for Jupyter Lab notebooks."""

import os

from copy import deepcopy
from .eval import build_requests
from .optimize import optimize_query, optimize_bm25
from .trec import load_queries_as_tuple_list, load_qrels
from .util import load_json

ROOT_DIR = os.path.abspath('..')
TEMPLATES_FILE = os.path.join(ROOT_DIR, 'config', 'msmarco-document-templates.json')


def mrr(k):
    return deepcopy({
        'mean_reciprocal_rank': {
            'k': k,
            'relevant_rating_threshold': 1,
        }
    })


def evaluate_mrr100_dev(es, max_concurrent_searches, index, template_id, params):
    k = 100
    templates = load_json(TEMPLATES_FILE)
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


def verbose_logger(iteration, score, params):
    print(f" - iteration {iteration} scored {score:.04f} with: {params}")


def optimize_query_mrr100(es, max_concurrent_searches, index, template_id, config_space, verbose=True):
    k = 100
    queries_fname = os.path.join('data', 'msmarco-document-sampled-queries.1000.tsv')
    qrels_fname = os.path.join('data', 'msmarco', 'document', 'msmarco-doctrain-qrels.tsv')

    templates = load_json(TEMPLATES_FILE)
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


def optimize_bm25_mrr100(es, max_concurrent_searches, index, template_id, query_params, config_space, verbose=True):
    k = 100
    queries_fname = os.path.join('data', 'msmarco-document-sampled-queries.1000.tsv')
    qrels_fname = os.path.join('data', 'msmarco', 'document', 'msmarco-doctrain-qrels.tsv')

    templates = load_json(TEMPLATES_FILE)
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
        template_id, queries, qrels, query_params, logger)

    print(f"Best score: {best_score:.04f}")
    print(f"Best params: {best_params}")
    print(f"Final params: {final_params}")
    print()

    return best_score, best_params, final_params, metadata
