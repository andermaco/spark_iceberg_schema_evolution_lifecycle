{{ config(severity='warn') }}

{% macro schema_evolution_test(model) %}

{% set raw_columns_query %}
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'raw_schema'
      AND table_name = 'raw_table'
{% endset %}

{% set bronze_columns_query %}
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'bronze_schema'
      AND table_name = '{{ model }}'
{% endset %}

{% set raw_columns = run_query(raw_columns_query).columns[0].values() %}
{% set bronze_columns = run_query(bronze_columns_query).columns[0].values() %}

{% set missing_columns = [] %}

{% for col in raw_columns %}
    {% if col not in bronze_columns %}
        {% do missing_columns.append(col) %}
    {% endif %}
{% endfor %}

{% if missing_columns | length > 0 %}
    {{ exceptions.raise_compiler_error(
        "⚠️ Esquema desincronizado: Las siguientes columnas existen en RAW pero faltan en BRONZE (" ~ model ~ "): " ~ missing_columns | join(', ')
    ) }}
{% endif %}

{% endmacro %}



-- Just a simple macro to check if the schema of the raw table has changed.
-- It's very clear to see in your CI/CD or in your local build.