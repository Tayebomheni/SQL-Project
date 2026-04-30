/* =====================================================
   1. SETUP ENVIRONNEMENT
===================================================== */

CREATE OR REPLACE DATABASE ANYCOMPANY_LAB;
USE DATABASE ANYCOMPANY_LAB;

CREATE OR REPLACE SCHEMA BRONZE;
CREATE OR REPLACE SCHEMA SILVER;

USE SCHEMA BRONZE;

/* =====================================================
   2. FILE FORMATS + STAGE
===================================================== */

-- CSV format
CREATE OR REPLACE FILE FORMAT csv_format
TYPE = 'CSV'
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
SKIP_HEADER = 1
NULL_IF = ('NULL', 'null', '');

-- JSON format
CREATE OR REPLACE FILE FORMAT json_format
TYPE = 'JSON';

-- Stage S3
CREATE OR REPLACE STAGE food_stage
URL='s3://logbrain-datalake/datasets/food-beverage/'
FILE_FORMAT = csv_format;

/* =====================================================
   3. CREATION TABLES BRONZE
===================================================== */

CREATE OR REPLACE TABLE customer_demographics (
    customer_id STRING,
    name STRING,
    date_of_birth DATE,
    gender STRING,
    region STRING,
    country STRING,
    city STRING,
    marital_status STRING,
    annual_income STRING
);

CREATE OR REPLACE TABLE customer_service_interactions (
    interaction_id STRING,
    interaction_date DATE,
    interaction_type STRING,
    issue_category STRING,
    description STRING,
    duration_minutes INT,
    resolution_status STRING,
    follow_up_required STRING,
    customer_satisfaction INT
);

CREATE OR REPLACE TABLE financial_transactions (
    transaction_id STRING,
    transaction_date DATE,
    transaction_type STRING,
    amount STRING,
    payment_method STRING,
    entity STRING,
    region STRING,
    account_code STRING
);

CREATE OR REPLACE TABLE promotions_data (
    promotion_id STRING,
    product_category STRING,
    promotion_type STRING,
    discount_percentage FLOAT,
    start_date DATE,
    end_date DATE,
    region STRING
);

CREATE OR REPLACE TABLE marketing_campaigns (
    campaign_id STRING,
    campaign_name STRING,
    campaign_type STRING,
    product_category STRING,
    target_audience STRING,
    start_date DATE,
    end_date DATE,
    region STRING,
    budget STRING,
    reach INT,
    conversion_rate FLOAT
);

CREATE OR REPLACE TABLE product_reviews (
    review_id INT,
    product_id STRING,
    reviewer_id STRING,
    reviewer_name STRING,
    rating INT,
    review_date DATE,
    review_title STRING,
    review_text STRING,
    product_category STRING
);

CREATE OR REPLACE TABLE logistics_and_shipping (
    shipment_id STRING,
    order_id STRING,
    ship_date DATE,
    estimated_delivery DATE,
    shipping_method STRING,
    status STRING,
    shipping_cost STRING,
    destination_region STRING,
    destination_country STRING,
    carrier STRING
);

CREATE OR REPLACE TABLE supplier_information (
    supplier_id STRING,
    supplier_name STRING,
    product_category STRING,
    region STRING,
    country STRING,
    city STRING,
    lead_time INT,
    reliability_score FLOAT,
    quality_rating STRING
);

CREATE OR REPLACE TABLE employee_records (
    employee_id STRING,
    name STRING,
    date_of_birth DATE,
    hire_date DATE,
    department STRING,
    job_title STRING,
    salary STRING,
    region STRING,
    country STRING,
    email STRING
);

-- JSON raw tables
CREATE OR REPLACE TABLE inventory_raw (data VARIANT);
CREATE OR REPLACE TABLE store_locations_raw (data VARIANT);


-- =====================================================
-- FILE FORMAT (product_reviews - TSV / TAB separated)
-- =====================================================

CREATE OR REPLACE FILE FORMAT tab_csv_format
TYPE = 'CSV'
FIELD_DELIMITER = '\t'
RECORD_DELIMITER = '\n'
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
TRIM_SPACE = TRUE
NULL_IF = ('NULL', 'null', '')
EMPTY_FIELD_AS_NULL = TRUE
ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;


-- =====================================================
-- COPY INTO BRONZE (product_reviews)
-- =====================================================




/* =====================================================
   4. LOAD DATA (COPY INTO)
===================================================== */

COPY INTO BRONZE.product_reviews
FROM (
    SELECT
        $1 AS review_id,
        $2 AS product_id,
        $3 AS reviewer_id,
        $4 AS reviewer_name,
        $5 AS rating,
        $6 AS review_date,
        $7 AS review_title,
        $8 AS review_text,
        $9 AS product_category
    FROM @food_stage/product_reviews.csv
)
FILE_FORMAT = (FORMAT_NAME = 'tab_csv_format')
ON_ERROR = 'CONTINUE';



COPY INTO customer_demographics FROM @food_stage/customer_demographics.csv;
COPY INTO customer_service_interactions FROM @food_stage/customer_service_interactions.csv;
COPY INTO financial_transactions FROM @food_stage/financial_transactions.csv;
COPY INTO promotions_data FROM @food_stage/promotions-data.csv;
COPY INTO marketing_campaigns FROM @food_stage/marketing_campaigns.csv;
COPY INTO logistics_and_shipping FROM @food_stage/logistics_and_shipping.csv;
COPY INTO supplier_information FROM @food_stage/supplier_information.csv;
COPY INTO employee_records FROM @food_stage/employee_records.csv;
CREATE OR REPLACE FILE FORMAT json_format
TYPE = JSON;

-- JSON
COPY INTO inventory_raw
FROM @food_stage/inventory.json
FILE_FORMAT = (
    TYPE = 'JSON',
    STRIP_OUTER_ARRAY = TRUE
)
ON_ERROR = 'CONTINUE';
COPY INTO store_locations_raw
FROM @food_stage/store_locations.json
FILE_FORMAT = (
    TYPE = 'JSON',
    STRIP_OUTER_ARRAY = TRUE
)
ON_ERROR = 'CONTINUE';




/* =====================================================
   5. VERIFICATIONS
===================================================== */

SELECT COUNT(*) FROM customer_demographics;
SELECT COUNT(*) FROM financial_transactions;
SELECT * FROM product_reviews;

SELECT * FROM financial_transactions LIMIT 10;
SELECT * FROM inventory_raw LIMIT 10;