import json
import os
import time

from timeit import default_timer as timer

IGNORES = [400, 404]
INDEX = 'ecs-search-metrics'
TRANSFORM_NAMES = [f'{INDEX}_transform_queryid', f'{INDEX}_transform_completion']
INDEX_NAMES = [INDEX] + TRANSFORM_NAMES
PIPELINE_NAMES = INDEX_NAMES


class Timer:
    def __enter__(self):
        self.start = timer()
        return self

    def __exit__(self, *args):
        self.end = timer()
        self.interval = self.end - self.start


def list_filenames(directory):
    """Lists all files in a directory without traversal."""
    listings = [os.path.join(directory, x) for x in os.listdir(directory)]
    return [x for x in listings if os.path.isfile(x)]


def file_length(filename):
    """
    Count the number of lines in a file.
    See: https://gist.github.com/zed/0ac760859e614cd03652#file-gistfile1-py-L48-L49
    """
    return sum(1 for _ in open(filename, 'r'))


def load_json(filename):
    """Loads a JSON file."""
    with open(filename, 'r') as f:
        return json.load(f)


def load_config(kind, name):
    f = os.path.join('config', kind, f'{name}.json')
    return load_json(f)


def delete_index(es, name):
    """Deletes an index, if it exists."""
    print(f"Deleting index: {name}")
    es.indices.delete(name, ignore=IGNORES)


def recreate_index(es, name):
    """Creates a new index, deleting any existing index."""
    delete_index(es, name)
    print(f"Creating new index: {name}")
    es.indices.create(name, body=load_config('indices', name))


def recreate_indices(es, names):
    for name in names:
        recreate_index(es, name)


def delete_transform(es, name):
    print(f"Deleting transform: {name}")
    es.transform.delete_transform(name, ignore=IGNORES)


def create_transform(es, name):
    print(f"Creating new transform: {name}")
    with open(os.path.join('config', 'transforms', f'{name}.json'), 'r') as f:
        transform = json.load(f)
    es.transform.put_transform(name, transform)


def recreate_transform(es, name):
    """Creates transform, deleting any existing transform."""
    delete_transform(es, name)
    create_transform(es, name)


def recreate_transforms(es, names):
    for name in names:
        recreate_transform(es, name)


def get_transform_state(es, name):
    response = es.transform.get_transform_stats(name)
    assert response['count'] == 1
    return response['transforms'][0]['state']


def start_transform(es, name):
    print(f"Starting batch transform: {name}")
    es.transform.start_transform(name)

    time.sleep(1)
    state = get_transform_state(es, name)

    if state != 'stopped':
        print(f"Waiting for batch transform: {name} ", end='')
        while state != 'stopped':
            print(".", end='')
            time.sleep(5)
            state = get_transform_state(es, name)
        print()

    es.indices.refresh(name)


def start_transforms(es, names):
    for name in names:
        start_transform(es, name)


def create_pipeline(es, name):
    print(f"Creating pipeline: {name}")
    es.ingest.put_pipeline(name, body=load_config('pipelines', name))


def recreate_pipelines(es, names):
    for name in names:
        create_pipeline(es, name)


def prepare(es, index_names=INDEX_NAMES, pipeline_names=PIPELINE_NAMES, transform_names=TRANSFORM_NAMES):
    """Prepares resources: indices, pipelines, transforms"""

    recreate_indices(es, index_names)
    recreate_pipelines(es, pipeline_names)
    recreate_transforms(es, transform_names)
    for x in transform_names:
        delete_index(es, f'{x}_failed')
