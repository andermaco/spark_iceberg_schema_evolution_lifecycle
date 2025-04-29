{% test schema_evolution(model) %}

WITH raw_columns AS (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'customers_db'
      AND table_name = 'customers_table'
),
model_columns AS (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'customers_db'
      AND table_name = '{{ model.name }}'
),
missing_columns AS (
    SELECT column_name
    FROM raw_columns
    WHERE column_name NOT IN (SELECT column_name FROM model_columns)
)
SELECT column_name
FROM missing_columns

{% endtest %} 