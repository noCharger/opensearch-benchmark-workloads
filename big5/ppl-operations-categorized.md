# PPL Operations Categorized by Big 5 Essential Areas

## 1. Text Querying
- `ppl-default` - Basic source query with head limit
- `ppl-term` - Where clause filtering on log.file.path field
- `ppl-keyword-in-range` - Match query combined with timestamp range
- `ppl-query-string-on-message` - Query string search on message field
- `ppl-query-string-on-message-filtered` - Query string with timestamp filter
- `ppl-query-string-on-message-filtered-sorted-num` - Query string with filter and numeric sort
- `ppl-scroll` - Basic scroll-like query with head limit

## 2. Sorting
- `ppl-desc-sort-timestamp` - Descending timestamp sort
- `ppl-desc-sort-with-after-timestamp` - Descending sort with head limit
- `ppl-asc-sort-timestamp` - Ascending timestamp sort
- `ppl-asc-sort-with-after-timestamp` - Ascending sort with head limit
- `ppl-desc-sort-timestamp-can-match-shortcut` - Descending sort with match filter
- `ppl-desc-sort-timestamp-no-can-match-shortcut` - Descending sort with match filter
- `ppl-asc-sort-timestamp-can-match-shortcut` - Ascending sort with match filter
- `ppl-asc-sort-timestamp-no-can-match-shortcut` - Ascending sort with match filter
- `ppl-sort-keyword-can-match-shortcut` - Keyword field sort with match
- `ppl-sort-keyword-no-can-match-shortcut` - Keyword field sort with match
- `ppl-sort-numeric-desc` - Descending numeric sort on metrics.size
- `ppl-sort-numeric-asc` - Ascending numeric sort on metrics.size
- `ppl-sort-numeric-desc-with-match` - Descending numeric sort with match
- `ppl-sort-numeric-asc-with-match` - Ascending numeric sort with match
- `ppl-range-with-asc-sort` - Range query with ascending sort
- `ppl-range-with-desc-sort` - Range query with descending sort

## 3. Date Histogram
- `ppl-date-histogram-hourly-agg` - Hourly date histogram with stats
- `ppl-date-histogram-minute-agg` - Minute-level date histogram with stats
- `ppl-composite-date-histogram-daily` - Daily composite date histogram with stats
- `ppl-range-auto-date-histo` - Range buckets with auto date histogram
- `ppl-range-auto-date-histo-with-metrics` - Range buckets with date histogram and metrics

## 4. Range Queries
- `ppl-range` - Basic timestamp range query
- `ppl-range-numeric` - Numeric range query on metrics.size
- `ppl-range-field-conjunction-big-range-big-term-query` - Where clause with term and range
- `ppl-range-field-disjunction-big-range-small-term-query` - Where clause with OR condition
- `ppl-range-field-conjunction-small-range-small-term-query` - Where clause with OR and small range
- `ppl-range-field-conjunction-small-range-big-term-query` - Where clause with small range

## 5. Terms Aggregation
- `ppl-terms-significant-1` - Stats aggregation by aws.cloudwatch.log_stream
- `ppl-terms-significant-2` - Stats aggregation by process.name
- `ppl-multi-terms-keyword` - Multi-field stats aggregation with sort
- `ppl-composite-terms` - Composite stats aggregation with multiple fields
- `ppl-composite-terms-keyword` - Composite stats with three keyword fields
- `ppl-keyword-terms` - Basic stats aggregation on keyword field
- `ppl-keyword-terms-low-cardinality` - Low cardinality stats aggregation

## Other Operations
