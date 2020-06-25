import eland as ed
import unittest

import metrics.resources as resources
import metrics.simulate as simulate

from tests.integration import ES_TEST_CLIENT, METRICS_INDEX


class TestIntegration(unittest.TestCase):

    def test_end_to_end(self):
        """Tests an end-to-end workflow with all components."""

        num_documents = 100
        num_users = 10
        max_queries = 5

        resources.prepare(ES_TEST_CLIENT)
        simulate.generate_events(
            num_documents,
            num_users,
            max_queries,
            lambda x: ES_TEST_CLIENT.index(index=resources.INDEX, pipeline=resources.INDEX, body=x),
            with_progress=True,
        )
        ES_TEST_CLIENT.indices.refresh(resources.INDEX)
        resources.start_transforms(ES_TEST_CLIENT, resources.TRANSFORM_NAMES)

        # if any of the mechanics above fail, we won't reach this point, which
        # is a good integration test in-and-of-itself
        index_size = ES_TEST_CLIENT.count(index=METRICS_INDEX)['count']
        self.assertGreaterEqual(index_size, num_users)
        self.assertLessEqual(index_size, num_users * max_queries)

        # make some invariant assertions based on aggregate statistics of the data
        # when things break, these statistics go to 0
        metrics_df = ed.DataFrame(es_client=ES_TEST_CLIENT, es_index_pattern=METRICS_INDEX)
        metrics_cols = [x for x in metrics_df.columns if x.startswith('metrics.clicks.')]
        non_zero_properties = metrics_df[metrics_cols].describe().loc[['count', 'mean', 'std', 'max']]
        self.assertFalse(non_zero_properties.eq(0.0).any().any())
