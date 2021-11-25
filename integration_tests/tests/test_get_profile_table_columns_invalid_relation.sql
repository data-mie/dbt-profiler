{% if execute %}
  {% 
    set actual_profile = dbt_profiler.get_profile_table(
      relation_name="no_exist"
    )
  %}

  {% set actual_columns = actual_profile.column_names | list %}

  {% 
    set expected_columns = [
      "column_name", 
      "data_type", 
      "not_null_proportion", 
      "distinct_proportion", 
      "distinct_count", 
      "is_unique", 
      "profiled_at"
    ]
  %}

  {% if actual_columns != expected_columns %}
    {% set msg %}
      Expected did not match actual

      Actual:
      {{ actual_columns }}

      Expected:
      {{ expected_columns }}

    {% endset %}

    {{ log(msg, info=True) }}
    select 'fail'
  {% else %}
    select 'ok' limit 0
  {% endif %}


{% endif %}




