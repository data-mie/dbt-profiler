-- depends_on: {{ ref("test_data_default") }}
{% if execute %}
  {%- set include_columns = ["numeric_not_nullable"] -%}
  {%- if target.type == "snowflake" -%}
    {%- set include_columns = include_columns | map("upper") | list -%}
  {%- endif -%}
  {{ dbt_profiler.get_profile(relation=ref("test_data_default"), include_columns=include_columns) }}
{% endif %}