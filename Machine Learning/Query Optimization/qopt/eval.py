"""Evaluation support."""


def build_requests(index, template_id, queries, qrels, params={}):
    """
    Converts TREC queries and QRELs into requests for use with the ranking
    evaluation API.
    """

    def build_request(qid, query_string):
        # collect ratings for this qid
        ratings = []
        for doc_id, rating in qrels[qid].items():
            ratings.append({
                '_index': index,
                '_id': doc_id,
                'rating': rating
            })

        # setup search template params
        # add query string to params
        all_params = params.copy()
        all_params['query_string'] = query_string

        return {
            'id': qid,
            'template_id': template_id,
            'params': all_params,
            'ratings': ratings,
        }

    return [build_request(qid, query_string) for qid, query_string in queries]
