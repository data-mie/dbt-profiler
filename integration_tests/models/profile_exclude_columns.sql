-- depends_on: {{ ref("test_data") }}
{% if execute %}
  {%- set exclude_columns = ["numeric_not_nullable"] -%}
  {%- if target.type == "snowflake" -%}
    {%- set exclude_columns = exclude_columns | map("upper") | list -%}
  {%- endif -%}
  {{ dbt_profiler.get_profile(relation=ref("test_data"), exclude_columns=exclude_columns) }}
{% endif %}