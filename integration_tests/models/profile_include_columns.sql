-- depends_on: {{ ref("test_data") }}
{% if execute %}
  {{ dbt_profiler.get_profile(relation=ref("test_data"), include_columns=["numeric_not_nullable"]) }}
{% endif %}