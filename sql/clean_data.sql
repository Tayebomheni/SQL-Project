/*=====================================================
   6. CLEANING → SILVER
===================================================== */

USE SCHEMA SILVER;

-- CUSTOMER
CREATE OR REPLACE TABLE customer_demographics_clean AS
SELECT DISTINCT
    customer_id,
    name,
    date_of_birth,
    UPPER(gender) AS gender,
    region,
    country,
    city,
    marital_status,
    TRY_TO_NUMBER(REPLACE(annual_income,' ','')) AS annual_income
FROM ANYCOMPANY_LAB.BRONZE.customer_demographics
WHERE customer_id IS NOT NULL;

-- TRANSACTIONS
CREATE OR REPLACE TABLE financial_transactions_clean AS
SELECT
    transaction_id,
    transaction_date,
    transaction_type,
    TRY_TO_NUMBER(REPLACE(amount,' ','')) AS amount,
    payment_method,
    entity,
    region,
    account_code
FROM ANYCOMPANY_LAB.BRONZE.financial_transactions
WHERE TRY_TO_NUMBER(REPLACE(amount,' ','')) > 0;

-- PROMOTIONS
CREATE OR REPLACE TABLE promotions_clean AS
SELECT
    promotion_id,
    product_category,
    promotion_type,
    discount_percentage,
    start_date,
    end_date,
    region
FROM ANYCOMPANY_LAB.BRONZE.promotions_data
WHERE discount_percentage BETWEEN 0 AND 1;

-- MARKETING
CREATE OR REPLACE TABLE marketing_campaigns_clean AS
SELECT
    campaign_id,
    campaign_name,
    campaign_type,
    product_category,
    target_audience,
    start_date,
    end_date,
    region,
    TRY_TO_NUMBER(REPLACE(budget,' ','')) AS budget,
    reach,
    conversion_rate
FROM ANYCOMPANY_LAB.BRONZE.marketing_campaigns;

-- SHIPPING
CREATE OR REPLACE TABLE logistics_clean AS
SELECT
    shipment_id,
    order_id,
    ship_date,
    estimated_delivery,
    shipping_method,
    status,
    TRY_TO_NUMBER(REPLACE(shipping_cost,' ','')) AS shipping_cost,
    destination_region,
    destination_country,
    carrier
FROM ANYCOMPANY_LAB.BRONZE.logistics_and_shipping;

-- SUPPLIERS
CREATE OR REPLACE TABLE supplier_clean AS
SELECT *
FROM ANYCOMPANY_LAB.BRONZE.supplier_information;

-- EMPLOYEES
CREATE OR REPLACE TABLE employee_clean AS
SELECT
    employee_id,
    name,
    date_of_birth,
    hire_date,
    department,
    job_title,
    TRY_TO_NUMBER(REPLACE(salary,' ','')) AS salary,
    region,
    country,
    email
FROM ANYCOMPANY_LAB.BRONZE.employee_records;

-- REVIEWS
CREATE OR REPLACE TABLE product_reviews_clean AS
SELECT *
FROM ANYCOMPANY_LAB.BRONZE.product_reviews;

-- CUSTOMER SERVICE
CREATE OR REPLACE TABLE customer_service_clean AS
SELECT *
FROM ANYCOMPANY_LAB.BRONZE.customer_service_interactions;

CREATE OR REPLACE TABLE inventory_clean AS
SELECT
    $1:product_id::STRING AS product_id,
    $1:product_category::STRING AS product_category,
    $1:region::STRING AS region,
    $1:country::STRING AS country,
    $1:warehouse::STRING AS warehouse,
    $1:current_stock::INT AS current_stock,
    $1:reorder_point::INT AS reorder_point,
    $1:lead_time::INT AS lead_time,
    TO_DATE($1:last_restock_date::STRING) AS last_restock_date
FROM ANYCOMPANY_LAB.BRONZE.inventory_raw;


-- JSON → STORES
CREATE OR REPLACE TABLE store_locations_clean AS
SELECT
    $1:store_id::STRING AS store_id,
    $1:store_name::STRING AS store_name,
    $1:store_type::STRING AS store_type,
    $1:region::STRING AS region,
    $1:country::STRING AS country,
    $1:city::STRING AS city,
    $1:address::STRING AS address,
    $1:postal_code::INT AS postal_code,
    $1:square_footage::FLOAT AS square_footage,
    $1:employee_count::INT AS employee_count
FROM ANYCOMPANY_LAB.BRONZE.store_locations_raw;

select * from store_locations_clean;
/* =====================================================
   7. FINAL CHECK
===================================================== */

SELECT COUNT(*) FROM customer_demographics_clean;
SELECT COUNT(*) FROM financial_transactions_clean;

SELECT * FROM inventory_clean LIMIT 10;


-- Vérification du chargement des données

SELECT * 
FROM PRODUCT_REVIEWS_CLEAN
LIMIT 10;

SELECT COUNT(*) AS TOTAL_ROWS 
FROM PRODUCT_REVIEWS_CLEAN;

DESC TABLE PRODUCT_REVIEWS_CLEAN;

SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME => 'PRODUCT_REVIEWS_CLEAN',
    START_TIME => DATEADD('hour', -1, CURRENT_TIMESTAMP())
));

