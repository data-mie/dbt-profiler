{{ config(depends_on=["ref('test_data_default')"]) }}
{% if execute %}

  {% do dbt_profiler.print_profile(relation_name="test_data_default") %}
  
  -- Test passes if no exceptions are raised from the macro call (the actual output is not tested)
  {% set is_pass = True %}
  {% if not is_pass %}
    select 'fail' as result
  {% else %}
    select 'ok' as result where 1=0
  {% endif %}
  
{% endif %}