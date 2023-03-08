{{ config(enabled=target.type == "bigquery") }}

-- depends_on: {{ ref("test_data_struct") }}
{% if execute %}
  {{ dbt_profiler.get_profile(relation=ref("test_data_struct")) }}
{% endif %}