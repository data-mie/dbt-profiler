{% if execute %}

  {% set schema_dict = dbt_profiler.print_profile_schema(relation_name="test_data") %}
  
  -- Test passes if no exceptions are raised from the macro call (the actual output is not tested)
  {% set is_pass = True %}
  {% if not is_pass %}
    select 'fail'
  {% else %}
    select 'ok' limit 0
  {% endif %}
  
{% endif %}