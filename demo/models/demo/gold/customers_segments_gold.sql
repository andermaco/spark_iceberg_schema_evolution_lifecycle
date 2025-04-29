-- models/gold/dm_customer_segments.sql
/**
Goal: Segment customers based on their approximate historical value (proxy LTV), activity recency and membership level, \
using only customers_silver data. This creates a business view focused on marketing or customer value analysis.
*/


{{ config(
    materialized='table',
    table_type='iceberg'
) }}

WITH customers_silver_data AS (
    -- Select the necessary fields from the Silver model
    SELECT
        customer_id,
        country,
        membership_level,
        loyalty_points,
        -- Use COALESCE to handle possible nulls in calculations
        COALESCE(average_order_value, 0) AS average_order_value,
        COALESCE(previous_purchases, 0) AS previous_purchases,
        last_purchase_date,
        last_login,
        customer_rating,
        account_status
    FROM {{ ref('customers_silver') }} -- Reference to the Silver model
),

calculated_metrics AS (
    -- Calculate derived metrics and recency
    SELECT
        *,
        -- Proxy LTV: Average order value x number of purchases. Careful if AOV is 0 or N_Purchases is 0.
        (average_order_value * previous_purchases) AS ltv_proxy,

        -- Days since last purchase (if exists)
        CASE
            WHEN last_purchase_date IS NOT NULL
            THEN date_diff('day', last_purchase_date, current_date)
            ELSE NULL -- Or a very high value if you prefer, e.g., 9999
        END AS days_since_last_purchase,

        -- Days since last login (if exists)
        CASE
            WHEN last_login IS NOT NULL
            -- Ensure casting timestamp to date if date_diff requires it
            THEN date_diff('day', CAST(last_login AS DATE), current_date)
            ELSE NULL -- Or a very high value
        END AS days_since_last_login

    FROM customers_silver_data
),

customer_segmentation AS (
    -- Create segments based on calculated metrics and existing dimensions
    SELECT
        *,
        -- Segment based on LTV Proxy (simple example)
        CASE
            WHEN ltv_proxy >= 1000 THEN 'High Value' -- Adjust thresholds according to your business
            WHEN ltv_proxy >= 200  THEN 'Medium Value'
            ELSE 'Low Value'
        END AS value_segment,

        -- Segment based on Recency (taking the most recent activity between purchase and login)
        CASE
            -- If we have a last purchase date or last login date:
            WHEN COALESCE(days_since_last_purchase, 99999) <= 30 OR COALESCE(days_since_last_login, 99999) <= 30
                THEN 'Active (Last 30d)'
            WHEN COALESCE(days_since_last_purchase, 99999) <= 90 OR COALESCE(days_since_last_login, 99999) <= 90
                THEN 'Active (Last 90d)'
            WHEN COALESCE(days_since_last_purchase, 99999) <= 365 OR COALESCE(days_since_last_login, 99999) <= 365
                THEN 'Inactive (3-12 Months)'
            -- Si no hay fechas o son muy antiguas
            ELSE 'Churned/Very Inactive'
        END AS recency_segment,

        -- Combined segment (example)
        CASE
            WHEN account_status <> 'active' THEN 'Inactive Account' -- Prioritize account status if not active
            WHEN membership_level IN ('Gold', 'Platinum') AND ltv_proxy >= 1000 THEN 'High Value VIP'
            WHEN membership_level IN ('Gold', 'Platinum') THEN 'VIP'
            WHEN (COALESCE(days_since_last_purchase, 99999) > 180 AND COALESCE(days_since_last_login, 99999) > 180) AND ltv_proxy < 200 THEN 'Low Value Inactive Risk'
            ELSE 'Standard' -- Categoría por defecto
        END AS combined_segment

    FROM calculated_metrics
)

-- Selection final for the Gold table
SELECT
    customer_id,
    country,
    membership_level,
    account_status,
    ltv_proxy,
    days_since_last_purchase,
    days_since_last_login,
    value_segment,
    recency_segment,
    combined_segment,
    loyalty_points, -- Include some direct metrics also
    customer_rating
FROM customer_segmentation