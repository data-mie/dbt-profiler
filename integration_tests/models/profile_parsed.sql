-- depends_on: {{ ref("test_data_parsed") }}
{% if execute %}
  {{ dbt_profiler.get_profile(relation=ref("test_data_parsed")) }}
{% endif %}