-- depends_on: {{ ref("test_data_default") }}
{% if execute %}
  {%- set where_clause = "string_not_nullable = 'one'" -%}
  {{ dbt_profiler.get_profile(relation=ref("test_data_default"), where_clause=where_clause) }}
{% endif %}