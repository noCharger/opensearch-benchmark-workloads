#!/bin/bash

# Script to run a single operation and restart cluster
# Usage: ./run_single_operation.sh <workload> <operation_name> [target_host] [warmup_iter] [test_iter] [throughput] [clients]

WORKLOAD=${1:-"big5"}
OPERATION=${2:-"all"}
TARGET_HOST=${3:-"localhost:9200"}
WARMUP_ITER=${4:-100}
TEST_ITER=${5:-200}
THROUGHPUT=${6:-0}
CLIENTS=${7:-1}

# Define all PPL operations
PPL_OPERATIONS=(
    "ppl-sort-ingested-input" "ppl-eval-length-stats" "ppl-regex-replace-stats"
    "ppl-multiple-sums" "ppl-stats-by-datastream-host" "ppl-stats-by-event-host"
    "ppl-stats-by-event-host-all" "ppl-count-by-log-path" "ppl-count-by-constant"
    "ppl-size-conversions" "ppl-timespan-pageviews" "ppl-pageviews-by-datastream"
    "ppl-pageviews-by-log-path" "ppl-complex-dataflow-analysis" "ppl-pageviews-by-date-log-path"
    "ppl-pageviews-by-namespace-type" "ppl-pageviews-with-time-format" "ppl-lookup-event-delay"
    "ppl-join-event-delay"
)


echo "Running operations from workload: $WORKLOAD"

# Determine operations to run
if [ "$OPERATION" = "all" ]; then
    OPERATIONS_TO_RUN=("${PPL_OPERATIONS[@]}")
else
    OPERATIONS_TO_RUN=("$OPERATION")
fi

# Set additional variables
WORKLOAD_PATH="/home/ubuntu/calcite-benchmark/opensearch-benchmark-workloads/$WORKLOAD"
EXCLUDE_TASKS="index-append,create-index,delete-index"
OPENSEARCH_PATH="/home/ubuntu/calcite-benchmark/opensearch-3.2.0-SNAPSHOT"

# Run benchmark for each operation
for OP in "${OPERATIONS_TO_RUN[@]}"; do
    echo "Running operation: $OP"
    
    # Kill existing OpenSearch processes
    echo "Killing OpenSearch processes..."
    sudo pkill -f opensearch || echo "No OpenSearch processes found"
    sudo killall -9 java 2>/dev/null || echo "No Java processes found"
    
    # Wait for processes to terminate
    sleep 5
    
    # Start OpenSearch
    echo "Starting OpenSearch..."
    $OPENSEARCH_PATH/bin/opensearch -d
    
    # Wait for cluster to be ready
    echo "Waiting for cluster to be ready..."
    sleep 30
    RESULTS_FILE=~/results_${OP}_$(date +%Y%m%d_%H%M%S).json
    
    # Create single operation test procedure
    cat > /tmp/single_op_test.json << EOF
{
  "name": "single-operation-test",
  "default": false,
  "description": "Test procedure for single operation",
  "schedule": [
    {
      "operation": "$OP",
      "warmup-iterations": $WARMUP_ITER,
      "iterations": $TEST_ITER,
      "target-throughput": $THROUGHPUT,
      "clients": $CLIENTS
    }
  ]
}
EOF

    # Copy to workload directory
    cp /tmp/single_op_test.json "$WORKLOAD_PATH/test_procedures/"
    
    # Run the benchmark
    ~/benchmark-venv/bin/opensearch-benchmark execute-test \
      --pipeline=benchmark-only \
      --workload-path="$WORKLOAD_PATH" \
      --test-procedure=single-operation-test \
      --target-host="$TARGET_HOST" \
      --exclude-tasks="$EXCLUDE_TASKS" \
      --results-file="$RESULTS_FILE" \
      --workload-params="warmup_iterations:$WARMUP_ITER,test_iterations:$TEST_ITER,target_throughput:$THROUGHPUT,search_clients:$CLIENTS"
    
    echo "Operation $OP completed. Results saved to: $RESULTS_FILE"
done

echo "All operations completed."