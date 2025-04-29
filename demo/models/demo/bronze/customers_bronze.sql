{{ config
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

SELECT
    from_unixtime(to_unixtime(created_at)) as created_at,

    -- Enriching with current timestamp at bronze layer and source to test schema evolution
    date_trunc('millisecond', cast(current_timestamp as timestamp)) as created_at_bronze,
    'customers_db' as source_at,
    
    loyalty_points,
    ethnicity,
    from_unixtime(to_unixtime(next_scheduled_contact)) as next_scheduled_contact,
    marital_status,
    pressure,
    hobbies,
    page_views,
    website,
    temperature,
    billing_address,
    ip_address,
    support_tickets,
    latitude,
    index,
    average_order_value,
    keyword,
    from_unixtime(to_unixtime(last_contacted)) as last_contacted,
    click_id,
    browser,
    previous_purchases,
    lead_status,
    campaign_name,
    customer_rating,
    first_name,
    purchase_date,
    address,
    zip_code,
    sensor_data,
    ad_group,
    customer_id,
    customer_since,
    occupation,
    longitude,
    language,
    product_category,
    from_unixtime(to_unixtime(last_login)) as last_login,
    location_coordinates,
    email,
    gender,
    city,
    credit_card_number,
    altitude,
    company,
    newsletter_subscription,
    marketing_opt_in,
    time_zone,
    screen_resolution,
    state,
    membership_level,
    industry,
    campaign_id,
    department,
    account_status,
    country,
    last_name,
    job_title,
    referral_source,
    device_type,
    comments,
    preferred_contact_method,
    session_duration,
    shipping_address,
    lead_source,
    subscription_date,
    operating_system,
    social_security_number,
    education_level,
    interests,
    acceleration,
    phone,
    humidity,
    user_agent,
    date_of_birth,
    order_id,
    notes,
    revenue
FROM customers_table



-- The Bronze table could be, or not, the first layer in a Lakehouse model (raw → bronze → silver → gold), and its primary purpose is to:
-- Goal: To store the data as close as possible to its original format, with the least possible transformation. That means:
    -- Standardize formats.
    -- Minimun type verification. e.g.: just convert some timestamp fields from microseconds to seconds using from_unixtime(to_unixtime(col)) for compatibility with AWS Athena Query Engine.
    -- Add technical metadata if necessary.
    -- NOT perform business-level cleaning yet. Only minimally structure the data."

-- example:
    -- timestamp(now()) as created_at. That column stores the current timestamp when the row was created. Used to track the creation time of the row.
    -- "sales_dpmt" as source_at. That column stores the source of the data. Used to track the source of the data. Also used to identify if the data is coming from a staging or a production environment.
    -- from_unixtime(to_unixtime(created_at)) as created_at.                            Changed for compatibility with AWS Athena Query Engine.
    -- from_unixtime(to_unixtime(next_scheduled_contact)) as next_scheduled_contact.    Changed for compatibility with AWS Athena Query Engine.
    -- from_unixtime(to_unixtime(last_contacted)) as last_contacted.                    Changed for compatibility with AWS Athena Query Engine.
    -- from_unixtime(to_unixtime(last_login)) as last_login.                            Changed for compatibility with AWS Athena Query Engine.



-- Test regading schema evolution over raw tables. Bronze layer should be able to check whether the raw table has changed. 


-- WITH base AS (
--     SELECT 
--         -- date_trunc('millisecond', last_contacted) as last_contacted,
--         -- date_trunc('millisecond', created_at) as created_at,
--         -- date_trunc('millisecond', updated_at) as updated_at,
--         * EXCEPT (last_contacted, created_at, updated_at)
--     FROM customers_table
-- )
-- SELECT * FROM base