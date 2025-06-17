#!/bin/bash

# Configuration variables
HOST="localhost:9200"
WORKLOAD_PATH="/home/ec2-user/workload/opensearch-benchmark-workloads/big5"
TEST_PROCEDURES_DIR="$WORKLOAD_PATH/test_procedures"
RESULTS_FILE=~/results.json
EXCLUDE_TASKS="index-append,create-index,delete-index"

# Allow overriding configuration via environment variables
HOST=${OPENSEARCH_HOST:-$HOST}
WORKLOAD_PATH=${WORKLOAD_PATH:-$WORKLOAD_PATH}
TEST_PROCEDURES_DIR=${TEST_PROCEDURES_DIR:-$TEST_PROCEDURES_DIR}
RESULTS_FILE=${RESULTS_FILE:-$RESULTS_FILE}

# Define all PPL operations
PPL_OPERATIONS=(
  "ppl-term"
  "ppl-query-string-on-message"
  "ppl-query-string-on-message-filtered"
  "ppl-query-string-on-message-filtered-sorted-num"
  "ppl-date_histogram_hourly_agg"
  "ppl-date_histogram_minute_agg"
  "ppl-composite-date_histogram-daily"
  "ppl-range"
  "ppl-range-numeric"
  "ppl-keyword-in-range"
  "ppl-range_field_conjunction_big_range_big_term_query"
  "ppl-keyword-terms"
  "ppl-keyword-terms-low-cardinality"
  "ppl-composite-terms"
  "ppl-composite_terms-keyword"
  "ppl-subquery_where"
  "ppl-left_join_timestamp"
  "ppl-semi_join_process"
)

# Create a temporary directory for individual test procedures
TEMP_DIR=$(mktemp -d)
echo "Created temporary directory: $TEMP_DIR"

# Function to clean up temporary files
cleanup() {
  echo "Cleaning up temporary files..."
  rm -rf "$TEMP_DIR"
}

# Register cleanup function to run on script exit
trap cleanup EXIT

# Create individual test procedures for each PPL operation
for operation in "${PPL_OPERATIONS[@]}"; do
  # Create a safe filename by replacing special characters
  safe_name=$(echo "$operation" | tr -d '-')
  
  cat > "$TEMP_DIR/${safe_name}_check.json" << EOF
{
  "name": "${safe_name}_check",
  "default": false,
  "description": "Test procedure to check if $operation works",
  "schedule": [
    {
      "operation": "$operation",
      "warmup-iterations": 1,
      "iterations": 1,
      "target-throughput": 1,
      "clients": 1,
      "request-timeout": 30
    }
  ]
}
EOF

  # Copy the test procedure to the workload directory
  cp "$TEMP_DIR/${safe_name}_check.json" "$TEST_PROCEDURES_DIR/"
done

# Test each PPL operation individually
FAILED_OPERATIONS=()
SUCCESSFUL_OPERATIONS=()
FAILURE_REASONS=()

echo "Testing each PPL operation individually..."
for operation in "${PPL_OPERATIONS[@]}"; do
  # Create a safe filename by replacing special characters
  safe_name=$(echo "$operation" | tr -d '-')
  
  echo "Testing $operation..."
  
  # Run the test and capture output
  OUTPUT_FILE="$TEMP_DIR/${safe_name}_output.txt"
  opensearch-benchmark execute-test \
    --pipeline=benchmark-only \
    --workload-path="$WORKLOAD_PATH" \
    --test-procedure="${safe_name}_check" \
    --target-host=$HOST \
    --exclude-tasks="$EXCLUDE_TASKS" \
    --results-file="$RESULTS_FILE" 2>&1 | tee "$OUTPUT_FILE"
  
  # Check exit status, warnings, and error rate
  EXIT_STATUS=${PIPESTATUS[0]}
  HAS_WARNINGS=$(grep -q -i "warn\|error\|exception\|fail" "$OUTPUT_FILE" && echo "true" || echo "false")
  ERROR_RATE=$(grep -o "error rate: [0-9.]*%" "$OUTPUT_FILE" | sed 's/error rate: //' | sed 's/%//')
  
  # If error rate is not found, set it to 0
  if [ -z "$ERROR_RATE" ]; then
    ERROR_RATE="0"
  fi
  
  # Extract failure reason if any
  FAILURE_REASON=""
  if [ $EXIT_STATUS -ne 0 ] || [ "$HAS_WARNINGS" = "true" ] || [ $(echo "$ERROR_RATE > 0" | bc -l) -eq 1 ]; then
    FAILURE_REASON=$(grep -i "warn\|error\|exception\|fail" "$OUTPUT_FILE" | head -1)
    if [ -z "$FAILURE_REASON" ]; then
      FAILURE_REASON="Unknown error"
    fi
  fi
  
  if [ $EXIT_STATUS -eq 0 ] && [ "$HAS_WARNINGS" = "false" ] && [ $(echo "$ERROR_RATE == 0" | bc -l) -eq 1 ]; then
    echo "✅ $operation passed"
    SUCCESSFUL_OPERATIONS+=("$operation")
  else
    echo "❌ $operation failed (Error rate: $ERROR_RATE%)"
    FAILED_OPERATIONS+=("$operation")
    FAILURE_REASONS+=("$operation: $FAILURE_REASON")
  fi
done

# Clean up the test procedures
for operation in "${PPL_OPERATIONS[@]}"; do
  safe_name=$(echo "$operation" | tr -d '-')
  rm -f "$TEST_PROCEDURES_DIR/${safe_name}_check.json"
done

# Print summary
echo "=== Test Summary ==="
echo "Total operations tested: ${#PPL_OPERATIONS[@]}"
echo "Successful operations: ${#SUCCESSFUL_OPERATIONS[@]}"
echo "Failed operations: ${#FAILED_OPERATIONS[@]}"

if [ ${#FAILED_OPERATIONS[@]} -gt 0 ]; then
  echo "Failed operations and reasons:"
  for reason in "${FAILURE_REASONS[@]}"; do
    echo "  - $reason"
  done
  
  # Build exclude tasks list for the full run
  ADDITIONAL_EXCLUDES=""
  for operation in "${FAILED_OPERATIONS[@]}"; do
    if [ -z "$ADDITIONAL_EXCLUDES" ]; then
      ADDITIONAL_EXCLUDES="$operation"
    else
      ADDITIONAL_EXCLUDES="$ADDITIONAL_EXCLUDES,$operation"
    fi
  done
  
  # Add failed operations to exclude tasks
  if [ -n "$ADDITIONAL_EXCLUDES" ]; then
    if [ -n "$EXCLUDE_TASKS" ]; then
      EXCLUDE_TASKS="$EXCLUDE_TASKS,$ADDITIONAL_EXCLUDES"
    else
      EXCLUDE_TASKS="$ADDITIONAL_EXCLUDES"
    fi
  fi
  
  echo "Running full PPL test procedure with failed operations excluded..."
  echo "Excluded tasks: $EXCLUDE_TASKS"
else
  echo "All PPL operations passed. Running full PPL test procedure..."
fi

# Run the full test with excluded tasks
opensearch-benchmark execute-test \
  --pipeline=benchmark-only \
  --workload-path="$WORKLOAD_PATH" \
  --test-procedure=ppl \
  --target-host=$HOST \
  --exclude-tasks="$EXCLUDE_TASKS" \
  --results-file="$RESULTS_FILE"