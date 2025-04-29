-- models/silver/customers_silver.sql

{{config
(
    materialized='table',
    table_type='iceberg',    
    partitioned_by=["month(created_at)"]
) }}

/**
    materialized='table', -- 'incremental' if very large and you want to process incrementally
    -- schema='dbt', -- lets to add '_dbt' prefix to the database name
    table_type='iceberg'  -- Important for DBT to use the correct syntax for Iceberg in Athena
    -- If you use partitioning in Iceberg, configure it here:
    partitioned_by=["month(created_at)"] -- Example of partitioning by month
*/

WITH source_data AS (
    -- Select from source defined in sources.yml    
    SELECT * FROM {{ ref('customers_bronze') }}
),

renamed_casted AS (
    -- Rename, select desired columns and correct data types
    SELECT
        created_at,
        CAST(customer_id AS VARCHAR) AS customer_id,
        CAST(first_name AS VARCHAR) AS first_name,
        CAST(last_name AS VARCHAR) AS last_name,
        CAST(email AS VARCHAR) AS email, -- Consider masking/tokenizing here if necessary    
        CAST(phone AS VARCHAR) AS phone, -- Consider masking/tokenizing here
        CAST(date_of_birth AS DATE) AS date_of_birth,
        lower(CAST(gender AS VARCHAR)) AS gender, -- Standardize to lowercase
        lower(CAST(marital_status AS VARCHAR)) AS marital_status, -- Standardize to lowercase
        CAST(address AS VARCHAR) AS address, -- Could need more complex cleaning
        CAST(city AS VARCHAR) AS city,
        CAST(state AS VARCHAR) AS state,
        CAST(country AS VARCHAR) AS country,
        CAST(zip_code AS VARCHAR) AS zip_code, -- Corrected to VARCHAR
        CAST(latitude AS DOUBLE) AS latitude,
        CAST(longitude AS DOUBLE) AS longitude,
        CAST(customer_since AS DATE) AS customer_since,
        CAST(occupation AS VARCHAR) AS occupation,
        CAST(company AS VARCHAR) AS company,
        CAST(industry AS VARCHAR) AS industry,
        CAST(membership_level AS VARCHAR) AS membership_level,
        CAST(loyalty_points AS INT) AS loyalty_points, -- Corrected to INT
        CAST(average_order_value AS DECIMAL(18, 2)) AS average_order_value, -- Corrected to DECIMAL
        CAST(previous_purchases AS INT) AS previous_purchases, -- Corrected to INT
        CAST(last_login AS TIMESTAMP) AS last_login,
        CAST(purchase_date AS DATE) AS last_purchase_date, -- Renamed and casted
        CAST(customer_rating AS DECIMAL(3, 1)) AS customer_rating, -- Corrected to DECIMAL
        CAST(lead_source AS VARCHAR) AS lead_source,
        CAST(referral_source AS VARCHAR) AS referral_source,
        CAST(marketing_opt_in AS BOOLEAN) AS marketing_opt_in,
        CAST(newsletter_subscription AS BOOLEAN) AS newsletter_subscription,
        CAST(account_status AS VARCHAR) AS account_status,
        CAST(created_at_bronze AS TIMESTAMP) AS ingestion_timestamp -- Renamed

        -- Columns intentionally removed:
            -- PII Data: social_security_number, credit_card_number (sensitive)
            -- pressure, temperature, humidity, sensor_data, acceleration, altitude (sensors/technical)
            -- index, source_at, created_at (raw metadata/redundant)
            -- etc...

    FROM source_data
),

deduplicated AS (
    -- Optional but recommended: Eliminates duplicates by keeping the latest record by PK
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY ingestion_timestamp DESC) as rn
    FROM renamed_casted
)

-- Final selection of clean and deduplicated columns
SELECT
    -- Explicit list of all columns from the Silver table
    created_at,
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    date_of_birth,
    gender,
    marital_status,
    address,
    city,
    state,
    country,
    zip_code,
    latitude,
    longitude,
    customer_since,
    occupation,
    company,
    industry,
    membership_level,
    loyalty_points,
    average_order_value,
    previous_purchases,
    last_login,
    last_purchase_date,
    customer_rating,
    lead_source,
    referral_source,
    marketing_opt_in,
    newsletter_subscription,
    account_status,
    ingestion_timestamp
FROM deduplicated
WHERE rn = 1 -- Se queda solo con el registro más reciente por customer_id