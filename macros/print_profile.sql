{% macro print_profile(relation=none, relation_name=none, schema=none, database=none, max_rows=none, max_columns=13, max_column_width=30, max_precision=none) %}

{%- set results = dbt_profiler.get_profile_table(relation=relation, relation_name=relation_name, schema=schema, database=database) -%}

{% if execute %}
  {% do results.print_table(max_rows=max_rows, max_columns=max_columns, max_column_width=max_column_width, max_precision=max_precision) %}
{% endif %}

{% endmacro %}