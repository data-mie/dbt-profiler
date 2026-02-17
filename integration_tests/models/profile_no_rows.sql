-- depends_on: {{ ref("test_data_no_rows") }}
{% if execute %}
  {{ dbt_profiler.get_profile(relation=ref("test_data_no_rows")) }}
{% endif %}