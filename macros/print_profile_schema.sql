{% macro print_profile_schema(relation=none, relation_name=none, schema=none, database=none, model_description="", column_description="") %}

{%- set column_dicts = [] -%}
{%- set results = dbt_profiler.get_profile_table(relation=relation, relation_name=relation_name, schema=schema, database=database) -%}

{% if execute %}
  {% for row in results.rows %}

    {% set row_dict = row.dict() %}
    {% set column_name = row_dict.pop("column_name") %}

    {% set meta_dict = {} %}
    {% for key, value in row_dict.items() %}
      {% set column = results.columns.get(key) %}
      {% do meta_dict.update({key: column.data_type.jsonify(value)}) %}
    {% endfor %}

    {% set column_dict = {"name": column_name, "description": column_description, "meta": meta_dict} %}
    {% do column_dicts.append(column_dict) %}
  {% endfor %}

  {% set schema_dict = {
    "version": 2,
    "models": [
      {
        "name": relation_name,
        "description": model_description,
        "columns": column_dicts
      }
    ]
  } %}
  {% set schema_yaml = toyaml(schema_dict) %}

  {{ log(schema_yaml, info=True) }}
  {% do return(schema_dict) %}
{% endif %}

{% endmacro %}