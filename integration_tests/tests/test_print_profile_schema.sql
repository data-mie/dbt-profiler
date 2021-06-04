{% if execute %}

  {% set schema_dict = dbt_profiler.print_profile_schema(relation_name="test_data") %}

  {% set actual_model_count = schema_dict["models"] | length %}
  {% set actual_relation_name = schema_dict["models"][0]["name"] %}
  {% set actual_description = schema_dict["models"][0]["description"] %}
  {% set actual_column_count = schema_dict["models"][0]["columns"] | length %}
  
  {% set is_pass = 
    schema_dict["version"] == 2 
    and actual_model_count == 1 
    and actual_relation_name == "test_data" 
    and actual_description == ""
    and actual_column_count == 5
  %}
  {% if not is_pass %}
    select 'fail'
  {% else %}
    select 'ok' limit 0
  {% endif %}
  
{% endif %}