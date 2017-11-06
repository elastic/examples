#!/usr/bin/env bash
set -o pipefail -o errexit

if [ -z "$1" ]; then
  echo "Specify watch name e.g. run_test.sh <foldername>"
fi

run_test_args=()
if [ -n "${2:-}" ]; then
  run_test_args+=(--username "$2")
fi
if [ -n "${3:-}" ]; then
  run_test_args+=(--password "$3")
fi
if [ -n "${4:-}" ]; then
  run_test_args+=(--protocol "$4")
fi

num_tests=0
pass=0
fails=0
echo "--------------------------------------------------"
for test in ./$1/tests/*.*; do
  echo "Running test $test"
  if python3 run_test.py --test_file "$test" "${run_test_args[@]}"; then
    let pass=pass+1
  else
    let fails=fails+1
  fi
  let num_tests=num_tests+1
  echo "--------------------------------------------------"
done

echo "$num_tests tests run: $pass passed. $fails failed."
if [ $fails -eq 0 ]; then
  exit 0
else
  exit 1
fi
