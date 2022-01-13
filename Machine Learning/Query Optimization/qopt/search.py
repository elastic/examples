import multiprocessing
import random
import string

from contextlib import contextmanager
from elasticsearch import Elasticsearch
from elasticsearch.exceptions import RequestError
from functools import partial
from .util import load_json


@contextmanager
def temporary_search_template(es, template_file, template_id_in_file, size=None, with_source=False):
    """A context manager that manages a temporary search template."""

    def random_string(length=10):
        """Generate a simple random string to use as a temporary template ID"""
        return ''.join(random.choice(string.ascii_letters) for _ in range(length))

    # check es argument
    if type(es) is str:
        es = Elasticsearch(es)
    elif type(es) is not Elasticsearch:
        raise ValueError(f"Requires an Elasticsearch client or connection string URL: {type(es)}")

    # load search template from file
    template = load_json(template_file)

    # load a single template if multiple are in the file
    if type(template) is list:
        assert template_id_in_file, "A template ID is required when multiple templates are present"
        template = next((x for x in template if x["id"] == template_id_in_file), None)
        assert template, f"No template found for template ID: {template_id_in_file}"
        del template['id']

    # set some optional parameters
    if size: template['template']['source']['size'] = size
    template['template']['source']['_source'] = with_source

    # generate a random, temporary template ID
    template_id = random_string()

    # cleanup to save as script
    template['script'] = template['template']
    del template['template']

    try:
        es.put_script(id=template_id, body=template)
        yield template_id
    finally:
        es.delete_script(template_id)


def search_template(local_es, index, template_id, query):
    def format_hit(hit):
        return {
            'id': hit['_id'],
            'score': hit['_score'],
        }

    body = {
        'id': template_id,
        'params': query['params'],
    }

    try:
        res = local_es.search_template(index=index, body=body, allow_no_indices=False)
    except RequestError as e:
        print(f"Error: id={query['id']}, query={query['params']['query_string']}")
        print(e)
        return {'id': query['id'], 'hits': []}

    hits = [format_hit(hit) for hit in res['hits']['hits']]
    return {'id': query['id'], 'hits': hits}


def _search_template(index, template_id, query):
    return search_template(es, index, template_id, query)


def init_search_process(url):
    global es
    es = Elasticsearch(url)


def bulk_search(url, num_procs, index, name, template_file, template_id_in_file,
                queries, output_file, size=None):
    """
    Search in bulk using a template and query actions.

    NOTE: This does not use msearch since we want to keep a relationship between
    query ID's and the results.
    """

    with temporary_search_template(url, template_file, template_id_in_file, size) as template_id:
        with open(output_file, 'wt') as outfile:
            pool = multiprocessing.Pool(num_procs, initializer=init_search_process, initargs=[url])
            processor = partial(_search_template, index, template_id)

            for result in pool.imap(processor, queries):
                query_id = result['id']
                for i, hit in enumerate(result['hits']):
                    doc_id = hit['id']
                    rank = i+1
                    score = hit['score']
                    outfile.write(f'{query_id}\tQ0\t{doc_id}\t{rank}\t{score}\t{name}\n')
