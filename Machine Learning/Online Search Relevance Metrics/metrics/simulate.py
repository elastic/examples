import datetime
import faker
import random
import uuid

from tqdm import tqdm

AB_EXPERIMENTS = ['alpha', 'beta', None]
AB_VARIANTS = ['control', 'a', 'b']
COUNTRIES_ALL = sorted(list(set(
    [country for (lat, lon, city, country, tz) in faker.providers.geo.Provider.land_coords]
)))
COUNTRIES = random.sample(COUNTRIES_ALL, 5)
DATE = datetime.date(2019, 11, 15)
ECS_VERSION = '1.6.0-dev'
FAKE = faker.Faker()
MAX_CLICKS_PER_QUERY = 5
MAX_NUM_RESULTS = 100
MAX_SECONDS_FIRST_CLICK = 10
MAX_SECONDS_LAST_CLICK = 60
MAX_TOOK_MS = 300
MIN_SECONDS_FIRST_CLICK = 1
MIN_TOOK_MS = 1
MS_TO_NANOS = 1000000
NUM_STATIC_QUERIES = 10
PAGE_NAMES = ['home_page_onebox', 'user_search_page', 'product_search_page']
PAGE_SIZE = 10
SECOND_PAGE_PROBABILITY = 0.5
STATIC_QUERY_PROBABILITY = 0.3


def string_ids(ids):
    return [str(x) for x in ids]


def time_to_timestamp(time):
    """Converts from a datetime to a string timestamp in a standard ISO 8601 format, with Z timezone for UTC."""
    return time.isoformat(sep='T', timespec='milliseconds') + "Z"


def timestamp_to_time(timestamp):
    """Converts from a string timestamp in a standard ISO 8601 format to a datetime."""
    return datetime.datetime.strptime(timestamp, '%Y-%m-%dT%H:%M:%S.%fZ')


def random_range(max):
    """
    A range from 0 to a randomly chosen end between 1 and `max`. The smallest range would thus be `range(0, 1)` while
    the largest would be `range(0, max)`.
    """
    assert max >= 1, f"max {max} must be greater than or equal to 1"

    return range(0, random.randint(1, max))


def random_time(date=DATE):
    """Generates a random datetime that occurs during the given date."""

    start = datetime.datetime.combine(date, datetime.time.min)
    end = start + datetime.timedelta(days=1) - datetime.timedelta(seconds=1)

    return FAKE.date_time_between(start_date=start, end_date=end)


def random_geo(user_id):
    """
    Generate a consistent random ISO country code based on the user ID. Then generate a random location within that
    country.
    """
    idx = hash(user_id) % len(COUNTRIES)
    (lat, lon, city, country_code, tz) = FAKE.local_latlng(country_code=COUNTRIES[idx])
    return country_code, city, f'{lat},{lon}'


def random_ab_test(user_id):
    """Generate a random A/B experiment name and assignment bucket."""
    exp_idx = hash(user_id) % len(AB_EXPERIMENTS)
    var_idx = hash(user_id) % len(AB_VARIANTS)

    if AB_EXPERIMENTS[exp_idx]:
        return AB_EXPERIMENTS[exp_idx], AB_VARIANTS[var_idx]
    else:
        return 'none', 'none'


def random_query():
    """Generate a random query string of varying length. Query terms are cased and without final punctuation."""
    tokens = FAKE.sentence(variable_nb_words=True)[:-1].split()

    # capitalize a random token - used later to show influence of query normalization
    idx = random.randint(0, len(tokens) - 1)
    tokens[idx] = tokens[idx].capitalize()

    return " ".join(tokens)


def random_uuid():
    """Generate a random UUID as string."""
    return str(uuid.uuid4())


def random_results(doc_ids, maximize_num_results=False):
    """Generate a random result set."""

    # used at testing time to always return results
    if maximize_num_results:
        num_results = MAX_NUM_RESULTS
    else:
        num_results = random.randint(0, MAX_NUM_RESULTS)

    # random sample corpus to get results
    return random.sample(doc_ids, num_results)


def generate_static_queries(doc_ids, maximize_num_results=False):
    """Generates static queries to be able to show top queries metrics."""

    # fixed number of static queries (or should this be random?)
    r = range(0, NUM_STATIC_QUERIES)

    # generate queries
    with_results = [random_query() for _ in r]
    without_results = [random_query() for q in r if q not in with_results]

    # add results
    with_results = [(q, random_results(doc_ids, maximize_num_results)) for q in with_results]
    without_results = [(q, []) for q in without_results]

    return {
        'with_results': with_results,
        'without_results': without_results,
    }


def query(doc_ids, user_id, static_queries, maximize_num_results=False):
    """Generates a random query and returns a complete event as a dictionary (for ECS)."""

    time = random_time()
    timestamp = time_to_timestamp(time)
    query_id = random_uuid()
    ab_experiment, ab_variant = random_ab_test(user_id)
    country_code, city, location = random_geo(user_id)

    # pick results
    if random.random() >= STATIC_QUERY_PROBABILITY:
        # generate random query and results
        query_value = random_query()
        results = random_results(doc_ids, maximize_num_results)
    else:
        # static query, 50/50 probability with or without results
        if not maximize_num_results and random.random() < 0.5:
            # without results (or we are maximizing num results, in which case we can't show these)
            key = 'without_results'
        else:
            # with results
            key = 'with_results'
        (query_value, results) = random.choice(static_queries[key])

    results_end = min(len(results), PAGE_SIZE)
    results_page = results[:results_end]

    event = {
        '@timestamp': timestamp,
        'ecs': {
            'version': ECS_VERSION,
        },
        'event': {
            'action': 'SearchMetrics.query',
            'dataset': 'SearchMetrics.query',
            'id': query_id,
            'duration': random.randint(MIN_TOOK_MS, MAX_TOOK_MS) * MS_TO_NANOS,
        },
        'SearchMetrics': {
            'query': {
                'id': query_id,
                'value': query_value,
                'page': 1,
            },
            'results': {
                'size': len(results_page),
                'total': len(results),
                'ids': results_page,
            },
        },
        'SearchMetricsSimulation': {
            'ab': {
                'experiment': ab_experiment,
                'variant': ab_variant,
            },
            'page_name': random.choice(PAGE_NAMES),
        },
        'source': {
            'user': {
                'id': user_id,
            },
            'geo': {
                'country_iso_code': country_code,
                'city_name': city,
                'location': location,
            },
        },
    }

    return time, event, results


def query_second_page(first_query_event, results, last_timestamp):

    time = timestamp_to_time(last_timestamp)
    timestamp = last_timestamp

    results_start = PAGE_SIZE
    results_end = min(results_start + len(results), results_start + PAGE_SIZE)
    results_page = results[results_start:results_end]

    event = {
        '@timestamp': timestamp,
        'ecs': first_query_event['ecs'],
        'event': {
            'action': 'SearchMetrics.page',
            'dataset': 'SearchMetrics.page',
            'id': random_uuid(),
            'duration': random.randint(MIN_TOOK_MS, MAX_TOOK_MS),
        },
        'SearchMetrics': {
            'query': {
                'id': first_query_event['SearchMetrics']['query']['id'],
                'page': 2,
            },
            'results': {
                'size': len(results_page),
                'ids': results_page,
            },
        }
    }

    return time, event


def result_clicks(query_time, query_event, maximize_num_clicks=False):
    """For a given query event, generate resulting clicks and return click events as dictionaries (for ECS)."""

    def click(result):
        (click_time, result) = result
        timestamp = time_to_timestamp(click_time)
        query_id = query_event['SearchMetrics']['query']['id']

        return {
            '@timestamp': timestamp,
            'ecs': {
                'version': ECS_VERSION,
            },
            'event': {
                'action': 'SearchMetrics.click',
                'dataset': 'SearchMetrics.click',
                'id': random_uuid(),
            },
            'SearchMetrics': {
                'query': {
                    'id': query_id,
                    'page': page,
                },
                'click': {
                    'result': {
                        'id': result['id'],
                        'rank': result['rank'],
                    },
                },
            },
        }

    results = query_event['SearchMetrics']['results']['ids']
    page = query_event['SearchMetrics']['query']['page']
    num_results = len(results)

    # add rank to results before selecting for clicks
    results = [{'rank': ((page - 1) * PAGE_SIZE) + idx + 1, 'id': id} for (idx, id) in enumerate(results)]

    # random sample results to produce clicks for
    # sampling is done with replacement so that some results could get multiple clicks
    # TODO: This should really be weighted sampling to get the position-bias effect
    max_clicks = min(num_results, MAX_CLICKS_PER_QUERY)

    # used at testing time to always click all results
    if maximize_num_clicks:
        num_clicked_results = max_clicks
    else:
        num_clicked_results = random.randint(0, max_clicks)

    clicked_results = random.choices(results, k=num_clicked_results)

    # calculate click times
    seconds_first_click = random.randint(MIN_SECONDS_FIRST_CLICK, MAX_SECONDS_FIRST_CLICK)
    click_seconds = random.sample(range(seconds_first_click, MAX_SECONDS_LAST_CLICK), num_clicked_results)
    click_times = [query_time + datetime.timedelta(seconds=x) for x in click_seconds]

    # zip in click times with result docs
    # generate click per result
    return [click(result) for result in zip(click_times, clicked_results)]


def user_behaviour(doc_ids, user_id, max_queries, static_queries):
    """Generates a number of queries and clicks for a user. Returns all events flattened in a single list."""

    events = []

    def generate():
        time, query_event, results = query(doc_ids, user_id, static_queries)
        click_events = result_clicks(time, query_event)

        events.append(query_event)
        events.extend(click_events)

        if not click_events:
            last_timestamp = query_event['@timestamp']
        else:
            last_timestamp = click_events[-1]['@timestamp']

        return query_event, results, last_timestamp

    def generate_second_page(first_query_event, results, timestamp):
        time, query_event = query_second_page(first_query_event, results, timestamp)
        click_events = result_clicks(time, query_event)

        events.append(query_event)
        events.extend(click_events)

    for _ in random_range(max_queries):
        query_event, results, last_timestamp = generate()

        # decide if we should add a second page query and maybe clicks sometimes
        is_pageable = query_event['SearchMetrics']['results']['total'] > PAGE_SIZE
        if is_pageable and random.random() >= SECOND_PAGE_PROBABILITY:
            generate_second_page(query_event, results, last_timestamp)

    return events


def generate_events(num_documents, num_users, max_queries, event_output_fn, with_progress=False):
    doc_ids = string_ids(range(0, num_documents))
    user_ids = string_ids(range(0, num_users))

    # generate the static queries: with results, without results
    static_queries = generate_static_queries(doc_ids)

    def generate(user_id):
        events = user_behaviour(
            doc_ids,
            user_id,
            max_queries,
            static_queries,
        )

        for event in events:
            event_output_fn(event)

    if with_progress:
        for user_id in tqdm(user_ids):
            generate(user_id)
    else:
        for user_id in user_ids:
            generate(user_id)
