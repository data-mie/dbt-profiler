{% if execute %}

  {% set schema_dict = dbt_profiler.print_profile_schema(relation_name="test_data") %}
  
  {% set is_pass = schema_dict["version"] == 2 and schema_dict["models"] | length == 1 %}
  {% if not is_pass %}
    select 'fail'
  {% else %}
    select 'ok' limit 0
  {% endif %}
  
{% endif %}