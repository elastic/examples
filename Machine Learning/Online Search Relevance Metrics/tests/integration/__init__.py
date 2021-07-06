import os
import metrics.resources as resources

from elasticsearch import Elasticsearch

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))

# Define test files and indices
ELASTICSEARCH_HOST = os.environ.get("ELASTICSEARCH_HOST") or "localhost"

# Define client to use in tests
TEST_SUITE = os.environ.get("TEST_SUITE", "xpack")
if TEST_SUITE == "xpack":
    ES_TEST_CLIENT = Elasticsearch(
        ELASTICSEARCH_HOST, http_auth=("elastic", "changeme"),
    )
else:
    ES_TEST_CLIENT = Elasticsearch(ELASTICSEARCH_HOST)

METRICS_INDEX = f'{resources.INDEX}_transform_queryid'
