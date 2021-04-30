{% macro print_profile(relation_name, max_rows=none, max_columns=7, max_column_width=30) %}

{%- set results = get_profile(relation_name) -%}

{% if execute %}
  {% do results.print_table(max_rows=max_rows, max_columns=max_columns, max_column_width=max_column_width) %}
{% endif %}

{% endmacro %}