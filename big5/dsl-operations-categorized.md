# DSL Operations Categorized by Big 5 Essential Areas

## 1. Text Querying
- `match-all` - Basic match all query
- `term` - Term query on log.file.path field
- `keyword-in-range` - Boolean query combining match and range
- `query-string-on-message` - Query string search on message field
- `query-string-on-message-filtered` - Query string with timestamp filter
- `query-string-on-message-filtered-sorted-num` - Query string with filter and sort
- `scroll` - Scroll search for pagination
- 
## 2. Sorting
- `desc_sort_timestamp` - Descending timestamp sort
- `desc_sort_with_after_timestamp` - Descending sort with search_after
- `asc_sort_timestamp` - Ascending timestamp sort
- `asc_sort_with_after_timestamp` - Ascending sort with search_after
- `desc_sort_timestamp_can_match_shortcut` - Descending sort with match shortcut
- `desc_sort_timestamp_no_can_match_shortcut` - Descending sort without shortcut
- `asc_sort_timestamp_can_match_shortcut` - Ascending sort with match shortcut
- `asc_sort_timestamp_no_can_match_shortcut` - Ascending sort without shortcut
- `sort_keyword_can_match_shortcut` - Keyword field sort with shortcut
- `sort_keyword_no_can_match_shortcut` - Keyword field sort without shortcut
- `sort_numeric_desc` - Descending numeric sort
- `sort_numeric_asc` - Ascending numeric sort
- `sort_numeric_desc_with_match` - Descending numeric sort with match
- `sort_numeric_asc_with_match` - Ascending numeric sort with match
- `range_with_asc_sort` - Range query with ascending sort
- `range_with_desc_sort` - Range query with descending sort

## 3. Date Histogram
- `date_histogram_hourly_agg` - Hourly date histogram aggregation
- `date_histogram_minute_agg` - Minute-level date histogram aggregation
- `composite-date_histogram-daily` - Daily composite date histogram
- `range-auto-date-histo` - Range aggregation with auto date histogram
- `range-auto-date-histo-with-metrics` - Range with auto date histogram and metrics

## 4. Range Queries
- `range` - Basic timestamp range query
- `range-numeric` - Numeric range query on metrics.size
- `range_field_conjunction_big_range_big_term_query` - Boolean must with term and range
- `range_field_disjunction_big_range_small_term_query` - Boolean should with term and range
- `range_field_conjunction_small_range_small_term_query` - Boolean should with small range
- `range_field_conjunction_small_range_big_term_query` - Boolean must with small range
- `range-agg-1` - Range aggregation with multiple buckets
- `range-agg-2` - Range aggregation with fewer buckets

## 5. Terms Aggregation
- `terms-significant-1` - Terms aggregation with significant terms sub-agg
- `terms-significant-2` - Terms aggregation with different field combination
- `multi_terms-keyword` - Multi-terms aggregation on multiple fields
- `composite-terms` - Composite aggregation with terms sources
- `composite_terms-keyword` - Composite terms with multiple keyword fields
- `keyword-terms` - Basic terms aggregation on keyword field
- `keyword-terms-low-cardinality` - Low cardinality terms aggregation
- `cardinality-agg-low` - Low cardinality estimation
- `cardinality-agg-high` - High cardinality estimation
- `cardinality-agg-high-2` - High cardinality with execution hint
