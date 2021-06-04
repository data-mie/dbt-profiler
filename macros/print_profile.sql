{% macro print_profile(relation_name, schema=none, max_rows=none, max_columns=7, max_column_width=30, max_precision=none) %}

{%- set results = dbt_profiler.get_profile(relation_name, schema=schema) -%}

{% if execute %}
  {% do results.print_table(max_rows=max_rows, max_columns=max_columns, max_column_width=max_column_width, max_precision=max_precision) %}
{% endif %}

{% endmacro %}