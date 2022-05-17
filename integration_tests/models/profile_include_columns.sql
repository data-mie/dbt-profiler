-- depends_on: {{ ref("test_data") }}
{% if execute %}
  {%- set include_columns = ["numeric_not_nullable"] -%}
  {%- if target.type == "snowflake" -%}
    {%- set include_columns = include_columns | map("upper") | list -%}
  {%- endif -%}
  {{ dbt_profiler.get_profile(relation=ref("test_data"), include_columns=include_columns) }}
{% endif %}