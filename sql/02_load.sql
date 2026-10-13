-- =====================================================================
-- Load the generated CSVs (run from the repository root).
-- Needs local_infile enabled on the server and client:
--   mysql --local-infile=1 -u root -p < sql/02_load.sql
-- Dimensions load first so the foreign keys on fact_sales are satisfied.
-- =====================================================================
USE retail_sales;

LOAD DATA LOCAL INFILE 'data/dim_date.csv'
INTO TABLE dim_date
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'data/dim_store.csv'
INTO TABLE dim_store
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'data/dim_product.csv'
INTO TABLE dim_product
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'data/dim_customer.csv'
INTO TABLE dim_customer
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'data/fact_sales.csv'
INTO TABLE fact_sales
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Quick sanity check: row counts per table
SELECT 'dim_date' AS table_name, COUNT(*) AS row_count FROM dim_date
UNION ALL SELECT 'dim_store', COUNT(*) FROM dim_store
UNION ALL SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL SELECT 'fact_sales', COUNT(*) FROM fact_sales;
