{% macro profile_relation(relation_name) %}

{%- 
set relation = adapter.get_relation(
  database=target.database,
  schema=target.schema,
  identifier=relation_name
) 
-%}

{# Defaults #}
{%- set model_description = "" -%}
{%- set column_description = "" -%}

{%- set columns = adapter.get_columns_in_relation(relation) -%}
{%- set column_names = columns | map(attribute="name") -%}

{% if execute %}
  {% set column_dicts = [] %}
  
  {% set profile_sql %}
    with column_profiles as (
      {% for column_name in column_names %}
        select 
          '{{ column_name }}' as column_name,
          sum(case when {{ adapter.quote(column_name) }} is null then 0 else 1 end)::numeric / count(*) as not_null_proportion,
          count(distinct {{ adapter.quote(column_name) }})::numeric / count(*) as distinct_proportion,
          count(distinct {{ adapter.quote(column_name) }}) as distinct_count,
          count(distinct {{ adapter.quote(column_name) }}) = count(*) as is_unique,
          current_timestamp::varchar(255) as profiled_at
        from {{ relation }}

        {% if not loop.last %}union all{% endif %}
      {% endfor %}
    )
    select
      columns.data_type,
      column_profiles.*
    from column_profiles
    left join {{ relation.information_schema() }}.columns as columns on (
      columns.table_schema = '{{ target.schema }}' and
      columns.table_name = '{{ relation_name }}' and
      columns.column_name = column_profiles.column_name
    )
  {% endset %}

  {% set results = run_query(profile_sql) %}

  {% for row in results.rows %}
    {% set meta_dict = {} %}
    {% set column_name = row.get("column_name") %}
 
    {% for key, value in row.items() %}
      {%- if key != "column_name" %} 
        {% set column = results.columns.get(key) %}
        {% do meta_dict.update({key: column.data_type.jsonify(value) }) %}
      {%- endif %}
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
  {% do return(schema_yaml) %}
{% endif %}


{% endmacro %}