#!/bin/bash

# Set your OpenSearch host
HOST="localhost:9200"

# Run the check test procedure
echo "Running PPL check..."
opensearch-benchmark execute-test --pipeline=benchmark-only --workload=big5 --test-procedure=ppl-check --target-host=$HOST

# Check if the command was successful
if [ $? -eq 0 ]; then
  echo "PPL check passed. Running full PPL test procedure..."
  opensearch-benchmark execute-test --pipeline=benchmark-only --workload=big5 --test-procedure=ppl --target-host=$HOST
else
  echo "PPL check failed. Skipping full PPL test procedure."
  exit 1
fi