"""Optimization support."""

import numpy as np

from functools import reduce
from skopt import gp_minimize
from skopt.callbacks import DeltaXStopper
from skopt.space import Categorical, Integer, Real
from sklearn.model_selection import ParameterGrid
from .eval import build_requests


class Config:
    DEFAULT_METHOD = 'auto'
    DEFAULT_NUM_ITERATIONS = 30
    DEFAULT_NUM_INITIAL_POINTS = 5

    __DEFAULT_BASE = 10
    __DEFAULT_DISTRIBUTION = 'uniform'
    __METHODS = {'auto', 'grid', 'random', 'bayesian', None}
    __RANGE_FIELDS = {'low', 'high', 'distribution', 'base'}

    def __init__(self, space, method=DEFAULT_METHOD, num_iterations=DEFAULT_NUM_ITERATIONS,
                 num_initial_points=DEFAULT_NUM_INITIAL_POINTS, default={}):
        assert space, "Space is required"
        assert method in Config.__METHODS, f"Unsupported method: {method}, must be one of {Config.__METHODS}"

        self.space = space
        self.method = method
        self.num_iterations = num_iterations
        self.num_initial_points = num_initial_points
        self.default = default or {}

        self.selected_method = self.__select_method()

    def dimension_names(self):
        return [dim.name for dim in self.space]

    def param_dict_from_values(self, v):
        return {k: v for k, v in zip(self.dimension_names(), v)}

    def __select_method(self):
        """Select method if it's auto, otherwise use the provided method."""

        def all_dimensions_are_categorical():
            return all([isinstance(dim, Categorical) for dim in self.space])

        def dimensionality():
            sizes = [len(dim.categories) for dim in self.space]
            return reduce(lambda x, y: x * y, sizes)

        if self.method != 'auto':
            # if a specific method was already chosen, use it
            return self.method
        elif not all_dimensions_are_categorical():
            # we can only do a grid search if all the dimensions are categorical
            return 'bayesian'
        elif dimensionality() <= self.num_iterations:
            # do a grid search only when the dimensionality is <= num iterations
            return 'grid'
        else:
            # default to bayesian as it's the most flexible option
            return 'bayesian'

    @staticmethod
    def __parse_space(space):
        """Parse a set of dimensions (space)."""
        assert isinstance(space, dict), "Space should be a dict of simple key-value pairs"

        def parse_dimension(name, values):
            """Parse a single dimension from JSON into an {{skopt.Dimension}}"""

            def convert_to_categorical_dimension():
                # discrete, but what kind?
                if isinstance(values[0], int) or isinstance(values[0], float):
                    return Categorical(values, transform='identity', name=name)
                elif isinstance(values[0], str):
                    return Categorical(values, transform='onehot', name=name)
                else:
                    raise ValueError("Discrete values can only be numerical (int, float) or string.")

            def convert_to_numerical_dimension():
                if 'distribution' in values:
                    prior = values['distribution']
                else:
                    prior = Config.__DEFAULT_DISTRIBUTION

                if 'base' in values:
                    base = values['base']
                else:
                    base = Config.__DEFAULT_BASE

                # range, but what kind?
                if isinstance(values['low'], int):
                    return Integer(values['low'], values['high'], prior=prior, base=base, name=name)
                elif isinstance(values['low'], float):
                    return Real(values['low'], values['high'], prior=prior, base=base, name=name)
                else:
                    raise ValueError("Range values can only be int or float.")

            if isinstance(values, list):
                return convert_to_categorical_dimension()
            elif isinstance(values, dict) and set(values.keys()).issubset(Config.__RANGE_FIELDS):
                return convert_to_numerical_dimension()
            else:
                raise ValueError(
                    "Parameter config must be either a list of discrete values or a dictionary with field " +
                    f"{Config.__RANGE_FIELDS}: {values}")

        return [parse_dimension(name, values) for name, values in space.items()]

    @staticmethod
    def parse(config):
        """Parse a space config from JSON into a concrete {{ConfigSpace}}."""
        assert 'space' in config, "Space is required in a space configuration"
        assert not ('method' in config and 'num_iterations' in config and config['method'] == 'grid'), \
            f"Number of iterations is not supported for grid search"
        assert not ('method' in config and 'num_initial_points' in config and config['method'] == 'grid'), \
            f"Number of initial points is not supported for grid search"
        assert not ('method' in config and 'num_initial_points' in config and config['method'] == 'random'), \
            f"Number of initial points is not supported for random search"

        return Config(
            space=Config.__parse_space(config['space']),
            method=config.get('method') or Config.DEFAULT_METHOD,
            num_iterations=config.get('num_iterations') or Config.DEFAULT_NUM_ITERATIONS,
            num_initial_points=config.get('num_initial_points') or Config.DEFAULT_NUM_INITIAL_POINTS,
            default=config.get('default'))


def _convert_param_types(params):
    def _convert(x):
        if isinstance(x, np.int64):
            return int(x)
        else:
            return x

    return {k: _convert(v) for k, v in params.items()}


def merge_params(params):
    """
    Build a complete parameter set by merging all parameters in the provided
    list from left to right.
    """

    assert isinstance(params, list), f"params needs to be a list of dicts, got {type(params)}={params}"
    for p in params:
        assert isinstance(p, dict), f"params needs to be a list of dicts, got an element {type(p)}={p}"
    assert len(params) >= 1, f"params must contain at least one dict"

    # merge copies of all the dicts from left to right
    merged = {}
    for p in params:
        merged.update(p)
    return merged


def optimize_bm25(es, max_concurrent_searches, index, config, metric, templates,
                  template_id, queries, qrels, query_params, logger_fn=None):

    # initial points, assumes parameter order k1,b
    initial_points = [
        [1.2, 0.75],  # Elasticsearch defaults
        [0.9, 0.4],  # Anserini defaults
    ]

    def objective_fn(trial_params):
        set_bm25_parameters(es, index, **trial_params)
        return -1 * search_and_evaluate(
            es, max_concurrent_searches, index, metric, templates, template_id,
            queries, qrels, params=query_params)

    return optimize(config, objective_fn, initial_points, logger_fn)


def optimize_query(es, max_concurrent_searches, index, config, metric,
                   templates, template_id, queries, qrels, logger_fn=None):

    def objective_fn(trial_params):
        return -1 * search_and_evaluate(
            es, max_concurrent_searches, index, metric, templates, template_id,
            queries, qrels, params=merge_params([config.default, trial_params]))

    return optimize(config, objective_fn, initial_points=None, logger_fn=logger_fn)


def optimize(config, objective_fn, initial_points=None, logger_fn=None):
    best_params = {}
    best_score = 0.0
    metadata = None

    def skopt_logger(result):
        x0 = result.x_iters  # list of input points
        y0 = result.func_vals  # evaluation of input points

        num_iters = len(x0)
        params = config.param_dict_from_values(x0[-1])
        params = _convert_param_types(params)
        score = -1 * y0[-1]

        if logger_fn:
            logger_fn(num_iters, score, params)

    if config.selected_method == 'grid':
        grid_space = config.param_dict_from_values([list(dim.categories) for dim in config.space])
        for i, params in enumerate(list(ParameterGrid(grid_space))):
            # keep the same order as in the configuration to make reading logs easier
            ordered_params = {k: params[k] for k in config.dimension_names()}
            score = -1 * objective_fn(ordered_params)

            if logger_fn:
                logger_fn(i + 1, score, ordered_params)

            if score > best_score:
                best_score = score
                best_params = ordered_params.copy()

    elif config.selected_method == 'bayesian' or config.selected_method == 'random':

        if config.selected_method == 'random':
            config.num_initial_points = config.num_iterations

        def list_based_objective_fn(param_values):
            """Convert params to a dict first."""
            return objective_fn(config.param_dict_from_values(param_values))

        res = gp_minimize(func=list_based_objective_fn, dimensions=config.space,
                          n_calls=config.num_iterations,  # total calls to func, includes initial points
                          n_initial_points=config.num_initial_points,  # random points to seed process
                          verbose=False,
                          callback=[DeltaXStopper(0.001), skopt_logger],
                          x0=initial_points)
        best_params = config.param_dict_from_values(res.x)
        best_score = -1 * res.fun
        metadata = res
    else:
        raise ValueError(f"Unsupported method: {config.selected_method}")

    final_params = merge_params([config.default, best_params])
    return best_score, _convert_param_types(best_params), _convert_param_types(final_params), metadata


def search_and_evaluate(es, max_concurrent_searches, index, metric, templates, template_id, queries, qrels, params):
    """Run the rank evaluation API which will search all requests and evaluate based on the provided resources."""

    # build the rank eval API request body from components
    requests = build_requests(index, template_id, queries, qrels, params)
    body = {
        'metric': metric,
        'templates': templates,
        'requests': requests,
        'max_concurrent_searches': max_concurrent_searches,
    }

    assert metric, "metric was empty"
    assert templates, "templates was empty"
    assert requests, "requests was empty"

    results = es.rank_eval(index=index, body=body, request_timeout=1200,
                           allow_no_indices=False, ignore_unavailable=False,
                           search_type='dfs_query_then_fetch')
    return results['metric_score']


def set_bm25_parameters(es, index, k1, b):
    es.indices.close(index=index, ignore_unavailable=False)
    es.indices.put_settings(index=index, body={
        'index': {
            'similarity': {
                'default': {
                    'type': 'BM25',
                    'k1': k1,
                    'b': b,
                }
            }
        }
    })
    es.indices.open(index=index)
