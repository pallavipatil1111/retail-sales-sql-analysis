-- =====================================================================
-- Retail Sales SQL Analysis — star schema (MySQL 8)
-- One fact table (fact_sales, one row per order line) surrounded by
-- four dimension tables: date, store, product and customer.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS retail_sales;
USE retail_sales;

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_store;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_customer;

CREATE TABLE dim_date (
    date_key          INT          PRIMARY KEY,          -- YYYYMMDD, e.g. 20251024
    full_date         DATE         NOT NULL UNIQUE,
    year              SMALLINT     NOT NULL,
    quarter           TINYINT      NOT NULL CHECK (quarter BETWEEN 1 AND 4),
    month             TINYINT      NOT NULL CHECK (month BETWEEN 1 AND 12),
    month_name        VARCHAR(10)  NOT NULL,
    day_of_week       VARCHAR(10)  NOT NULL,
    is_weekend        TINYINT      NOT NULL,
    is_festive_season TINYINT      NOT NULL               -- October–November
);

CREATE TABLE dim_store (
    store_key   INT          PRIMARY KEY,
    store_name  VARCHAR(60)  NOT NULL,
    city        VARCHAR(40)  NOT NULL,
    region      VARCHAR(10)  NOT NULL,
    store_type  VARCHAR(20)  NOT NULL,                    -- Mall / High Street / Express
    opened_date DATE         NOT NULL
);

CREATE TABLE dim_product (
    product_key  INT            PRIMARY KEY,
    product_name VARCHAR(80)    NOT NULL,
    category     VARCHAR(30)    NOT NULL,
    subcategory  VARCHAR(30)    NOT NULL,
    brand        VARCHAR(30)    NOT NULL,
    unit_price   DECIMAL(10,2)  NOT NULL CHECK (unit_price > 0),
    unit_cost    DECIMAL(10,2)  NOT NULL CHECK (unit_cost > 0),
    launch_date  DATE           NOT NULL
);

CREATE TABLE dim_customer (
    customer_key  INT          PRIMARY KEY,
    customer_code VARCHAR(12)  NOT NULL UNIQUE,
    city          VARCHAR(40)  NOT NULL,
    age_band      VARCHAR(8)   NOT NULL,
    loyalty_tier  VARCHAR(10)  NOT NULL,                  -- Bronze / Silver / Gold
    signup_date   DATE         NOT NULL
);

CREATE TABLE fact_sales (
    sales_id       INT            PRIMARY KEY,
    order_id       INT            NOT NULL,
    date_key       INT            NOT NULL,
    store_key      INT            NOT NULL,
    product_key    INT            NOT NULL,
    customer_key   INT            NOT NULL,
    quantity       INT            NOT NULL CHECK (quantity > 0),
    unit_price     DECIMAL(10,2)  NOT NULL,
    discount_pct   TINYINT        NOT NULL CHECK (discount_pct BETWEEN 0 AND 100),
    net_amount     DECIMAL(12,2)  NOT NULL,              -- revenue after discount
    cost_amount    DECIMAL(12,2)  NOT NULL,
    payment_method VARCHAR(10)    NOT NULL,
    CONSTRAINT fk_sales_date     FOREIGN KEY (date_key)     REFERENCES dim_date(date_key),
    CONSTRAINT fk_sales_store    FOREIGN KEY (store_key)    REFERENCES dim_store(store_key),
    CONSTRAINT fk_sales_product  FOREIGN KEY (product_key)  REFERENCES dim_product(product_key),
    CONSTRAINT fk_sales_customer FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key)
);
