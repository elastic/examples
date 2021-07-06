"""General utilities."""

import csv
import datetime
import json
import sys

from timeit import default_timer


class Timer:
    """A context manager that times execution."""

    def __enter__(self):
        self.start = default_timer()
        return self

    def __exit__(self, *args):
        self.end = default_timer()
        self.interval = self.end - self.start

    def interval_str(self):
        return str(datetime.timedelta(seconds=self.interval))


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


def maximize_csv_field_size_limit():
    """
    For very large CSV files, we need to set the {{csv.field_size_limit}}. This
    dynamically finds the maximum supported value and sets it to that.

    See: https://stackoverflow.com/a/15063941
    """

    maxInt = sys.maxsize
    while True:
        # decrease the maxInt value by factor 10
        # as long as the OverflowError occurs.
        try:
            csv.field_size_limit(maxInt)
            break
        except OverflowError:
            maxInt = int(maxInt / 10)

    csv.field_size_limit(maxInt)
