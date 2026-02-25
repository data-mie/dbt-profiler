-- depends_on: {{ ref("test_data_large_int") }}
{% if execute %}
  {{ dbt_profiler.get_profile(relation=ref("test_data_large_int")) }}
{% endif %}
