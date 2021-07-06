"""Utilities for loading TREC files."""

import csv

from collections import defaultdict


def load_qrels(filename):
    """
    Loads a TREC QRELs TSV file keyed on ``qId`` and result ``docId``:
    ``{qId: {docId: label}}``. Labels are parsed as {{int}}s.

    This loads all QRELs into a {{dict}} in memory. It cannot be used for
    streaming very large QREL files.
    """
    with open(filename, 'r') as f:
        reader = csv.reader(f, delimiter='\t')
        by_qid = defaultdict(dict)
        for q_id, _, doc_id, label in reader:
            by_qid[q_id][doc_id] = int(label)

        return by_qid


def load_queries_as_tuple(filename):
    """
    Loads a TREC Topics TSV file as a tuple of `(qId, query)`.

    This is a generator and can be read streaming.
    """
    with open(filename, 'r') as f:
        reader = csv.reader(f, delimiter='\t')
        for qId, query in reader:
            yield qId, query


def load_queries_as_tuple_list(filename):
    return list(load_queries_as_tuple(filename))
