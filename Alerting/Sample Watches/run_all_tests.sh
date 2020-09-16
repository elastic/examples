#!/usr/bin/env bash
set -o nounset -o pipefail -o errexit

./run_test.sh '**' "${1:-}" "${2:-}" "${3:-}" "${4:-}" "${5:-}"
