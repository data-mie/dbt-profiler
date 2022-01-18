{#
#37 Profiling a table whose column are integer, date, string in this order raised the following error :
ERROR:  UNION types text and numeric cannot be matched
LINE 60:           avg("int_after_date_after_string") as avg,
Appropriately casting the null default value solves it.
#}

-- depends_on: {{ ref("test_data_int_date_str") }}
{% if execute %}
  {{ dbt_profiler.get_profile(relation=ref("test_data_int_date_str")) }}
{% endif %}