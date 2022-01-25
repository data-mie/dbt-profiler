{% macro get_profile_table(relation=none, relation_name=none, schema=none, database=none, exclude_columns=none) %}

{%- set relation = dbt_profiler.get_relation(
  relation=relation,
  relation_name=relation_name,
  schema=schema,
  database=database
) -%}

{%- set profile_sql = dbt_profiler.get_profile(relation, exclude_columns=exclude_columns) -%}

{% set results = run_query(profile_sql) %}
{% set results = results.rename(results.column_names | map('lower')) %}

{% do return(results) %}

{% endmacro %}