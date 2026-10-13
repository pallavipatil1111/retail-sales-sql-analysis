-- =====================================================================
-- Extra indexes for the analysis workload.
-- InnoDB already indexes the foreign-key columns. These add:
--   * order_id                 -> grouping lines into orders, basket self-join
--   * (customer_key, date_key) -> cohort and repeat-purchase queries
--   * (date_key, store_key)    -> time-series per store
--   * dim_product(category)    -> category filters and rollups
-- scripts/benchmark_indexes.sh times key queries before and after these.
-- =====================================================================
USE retail_sales;

CREATE INDEX idx_sales_order          ON fact_sales (order_id);
CREATE INDEX idx_sales_customer_date  ON fact_sales (customer_key, date_key);
CREATE INDEX idx_sales_date_store     ON fact_sales (date_key, store_key);
CREATE INDEX idx_product_category     ON dim_product (category);
