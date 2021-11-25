{% if execute %}
  {% 
    set actual_profile = dbt_profiler.get_profile_table(
      relation_name="test_data"
    ).exclude(["profiled_at", "data_type"])
  %}

  {% set actual_rows = [] %}
  
  {% for row in actual_profile.rows %}
    {% set row_values = row.values() %}
    {% do actual_rows.append(
      (
        row_values[0], 
        row_values[1] | float, 
        row_values[2] | float, 
        row_values[3] | float, 
        row_values[4]
      )
    ) %}
  {% endfor %}

  {% 
    set expected_rows = [
      ("id", 1.0, 1.0, 5, True),
      ("numeric_not_nullable", 1.0, 0.6, 3, False),
      ("numeric_nullable", 0.6, 0.4, 2, False),
      ("string_not_nullable", 1.0, 0.6, 3, False),
      ("string_nullable", 0.6, 0.4, 2, False)
    ]
  %}

  {% if actual_rows | sort != expected_rows | sort %}
    {% set msg %}
      Expected did not match actual

      Actual:
      {{ actual_rows }}

      Expected:
      {{ expected_rows }}

    {% endset %}

    {{ log(msg, info=True) }}
    select 'fail'
  {% else %}
    select 'ok' limit 0
  {% endif %}

{% endif %}




