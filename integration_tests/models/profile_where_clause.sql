-- depends_on: {{ ref("test_data") }}
{% if execute %}
  {%- set where_clause = "string_not_nullable = 'one'" -%}
  {{ dbt_profiler.get_profile(relation=ref("test_data"), where_clause=where_clause) }}
{% endif %}