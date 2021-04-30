{% macro print_profile(relation_name) %}

{%- set results = get_profile(relation_name) -%}

{% if execute %}
  {% do results.print_table(max_rows=None, max_columns=7, max_column_width=30) %}
{% endif %}

{% endmacro %}