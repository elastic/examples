import unittest

from metrics.simulate import *


class TestSimulate(unittest.TestCase):

    def test_time_to_timestamp(self):
        self.assertEqual(time_to_timestamp(datetime.datetime(2019, 11, 15)), '2019-11-15T00:00:00.000Z')
        self.assertEqual(time_to_timestamp(datetime.datetime(2019, 11, 10, 19, 24, 45)), '2019-11-10T19:24:45.000Z')

    def test_timestamp_to_time(self):
        self.assertEqual(timestamp_to_time('2019-11-15T00:00:00.000Z'), datetime.datetime(2019, 11, 15))
        self.assertEqual(timestamp_to_time('2019-11-10T19:24:45.000Z'), datetime.datetime(2019, 11, 10, 19, 24, 45))

    def random_range(self):
        return

    def test_random_time(self):
        date = datetime.date(2019, 11, 18)
        for _ in range(0, 10):
            # datetimes should be on the same date still
            self.assertEqual(random_time(date).date(), date)

    def test_random_geo(self):
        user_id = str(random.randint(0, 10000))
        (country1, city1, location1) = random_geo(user_id)
        (country2, city2, location2) = random_geo(user_id)

        # countries are always equal, everything else *could* be different/random
        self.assertEqual(country1, country2)

    def test_random_ab_test(self):
        user_id = str(random.randint(0, 10000))
        ab1 = random_ab_test(user_id)
        ab2 = random_ab_test(user_id)

        self.assertEqual(ab1, ab2)

    def test_random_query(self):
        for _ in range(0, 10):
            q = random_query()
            terms = q.split()
            num_terms = len(terms)

            # queries should have no punctuation/only letters and spaces
            self.assertTrue(r'''[\w ]+''')

    def test_random_uuid(self):
        uuids = [random_uuid() for _ in range(0, 10)]

        # they kind of look like UUIDs - hexadecimal, hyphen, 26 characters long
        for uuid in uuids:
            self.assertTrue(r'''[\w\d-]{36}''')

        # they are random/not equal
        uuids_deduplicated = list(set(uuids))
        self.assertEqual(len(uuids_deduplicated), len(uuids))
        self.assertEqual(sorted(uuids_deduplicated), sorted(uuids))

    def test_random_results(self):
        doc_ids = string_ids(set(range(0, 100)))

        results = random_results(doc_ids, maximize_num_results=True)
        result_set = set(results)

        self.assertEqual(len(results), MAX_NUM_RESULTS)
        self.assertTrue(len(result_set), len(results))
        self.assertTrue(result_set.issubset(doc_ids))

    def test_generate_static_queries(self):
        doc_ids = set(string_ids(range(0, 100)))

        static_queries = generate_static_queries(doc_ids, maximize_num_results=True)

        (q_with_results, r_with_results) = list(map(list, zip(*static_queries['with_results'])))
        (q_without_results, r_without_results) = list(map(list, zip(*static_queries['without_results'])))

        self.assertNotEqual(set(q_with_results), set(q_without_results))

        for r in r_with_results:
            self.assertTrue(r)
        for r in r_without_results:
            self.assertFalse(r)

    def test_query(self):
        doc_ids = set(string_ids(range(0, 100)))
        user_id = 3

        static_queries = generate_static_queries(doc_ids, maximize_num_results=True)
        (time, event, _) = query(doc_ids, user_id, static_queries, maximize_num_results=True)

        # date is under test already
        self.assertTrue(time)

        self.assertEqual(event['event']['action'], 'SearchMetrics.query')
        self.assertEqual(event['source']['user']['id'], user_id)
        self.assertEqual(len(event['SearchMetrics']['results']['ids']), event['SearchMetrics']['results']['size'])
        self.assertTrue(set(event['SearchMetrics']['results']['ids']).issubset(doc_ids))

    def test_result_clicks(self):
        doc_ids = set(string_ids(range(0, 1000)))
        user_id = 1

        static_queries = generate_static_queries(doc_ids, maximize_num_results=True)
        (query_time, query_event, _) = query(doc_ids, user_id, static_queries, maximize_num_results=True)

        clicks = sorted(
            result_clicks(query_time, query_event, maximize_num_clicks=True),
            key=lambda x: x['@timestamp'],
        )

        self.assertTrue(clicks, "error in test, there are no clicks")

        for click in clicks:
            self.assertEqual(click['event']['action'], 'SearchMetrics.click')
            self.assertEqual(click['SearchMetrics']['query']['id'], query_event['SearchMetrics']['query']['id'])
            self.assertTrue(click['SearchMetrics']['click']['result']['id'] in doc_ids)

        click_times = [timestamp_to_time(click['@timestamp']) for click in clicks]

        # first click is after query
        self.assertGreater(click_times[0], query_time)

        # times are increasing
        last_click_time = click_times[0]
        for click_time in click_times:
            self.assertLessEqual(last_click_time, click_time)


if __name__ == '__main__':
    unittest.main()
