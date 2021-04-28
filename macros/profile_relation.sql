{% macro profile_relation(relation_name) %}

{%- 
set relation = adapter.get_relation(
  database=target.database,
  schema=target.schema,
  identifier=relation_name
) 
-%}

{%- set columns = adapter.get_columns_in_relation(relation) -%}
{%- set column_names = columns | map(attribute="name") -%}


{% if execute %}
  {% set column_dicts = [] %}
  {% for column_name in column_names %}
    {% set profile_sql %}

      with profile as (
        select 
          sum(case when {{ adapter.quote(column_name) }} is null then 0 else 1 end)::numeric / count(*) as not_null_proportion,
          count(distinct {{ adapter.quote(column_name) }})::numeric / count(*) as distinct_proportion,
          count(distinct {{ adapter.quote(column_name) }}) as distinct_count,
          count(distinct {{ adapter.quote(column_name) }}) = count(*) as is_unique,
          current_timestamp::varchar(255) as profiled_at
        from {{ relation }}
      )
      select
        columns.data_type,
        profile.*
      from profile
      left join {{ relation.information_schema() }}.columns as columns on (
        columns.table_schema = '{{ target.schema }}' and
        columns.table_name = '{{ relation_name }}' and
        columns.column_name = '{{ column_name }}'
      )

    {% endset %}

    {% set results = run_query(profile_sql) %}
    
    {% set meta_dict = {} %}
    {% for column in results.columns %}
      {% do meta_dict.update({column.name: column.data_type.jsonify(column.values()[0]) }) %}
    {% endfor %}

    {% set column_dict = {"name": column_name, "description": "", "meta": meta_dict} %}
    {% do column_dicts.append(column_dict) %}

  {% endfor %}

  {% set schema_dict = {
    "version": 2,
    "models": [
      {
        "name": relation_name,
        "description": "",
        "columns": column_dicts
      }
    ]
  } %}
  {% set schema_yaml = toyaml(schema_dict) %}
  {{ log(schema_yaml, info=True) }}

  {% do return(schema_yaml) %}
{% endif %}


{% endmacro %}