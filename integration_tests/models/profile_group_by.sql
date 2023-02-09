-- depends_on: {{ ref("test_data_group_by") }}
{% if execute %}
<<<<<<< HEAD
  {{ dbt_profiler.get_profile(relation=ref("test_data_group_by"), group_by=["group_by"]) }}
=======
  {%- set group_by = "group_by" -%}
  {{ dbt_profiler.get_profile(relation=ref("test_data_group_by"), group_by=group_by) }}
>>>>>>> main
{% endif %}