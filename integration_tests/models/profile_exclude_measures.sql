-- depends_on: {{ ref("test_data") }}
{% if execute %}
  {{ dbt_profiler.get_profile(relation=ref("test_data"), exclude_measures=["avg", "std_dev_population", "std_dev_sample"]) }}
{% endif %}