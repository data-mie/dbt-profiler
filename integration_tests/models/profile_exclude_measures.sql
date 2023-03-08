-- depends_on: {{ ref("test_data_default") }}
{% if execute %}
  {{ dbt_profiler.get_profile(relation=ref("test_data_default"), exclude_measures=["avg", "std_dev_population", "std_dev_sample"]) }}
{% endif %}