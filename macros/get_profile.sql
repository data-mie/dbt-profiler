{% macro get_profile(relation_name, schema=none) %}

{% if schema is none %}
  {% set schema = target.schema %}
{% endif %}

{%- 
set relation = adapter.get_relation(
  database=target.database,
  schema=schema,
  identifier=relation_name
) 
-%}

{%- set columns = adapter.get_columns_in_relation(relation) -%}
{%- set column_names = columns | map(attribute="name") -%}

{% set profile_sql %}
  with column_profiles as (
    {% for column_name in column_names %}
      select 
        lower('{{ column_name }}') as column_name,
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
    column_profiles.column_name,
    columns.data_type,
    column_profiles.not_null_proportion,
    column_profiles.distinct_proportion,
    column_profiles.distinct_count,
    column_profiles.is_unique,
    column_profiles.profiled_at
  from column_profiles
  left join {{ relation.information_schema() }}.columns as columns on (
    lower(columns.table_schema) = lower('{{ schema }}') and
    lower(columns.table_name) = lower('{{ relation_name }}') and
    lower(columns.column_name) = lower(column_profiles.column_name)
  )
{% endset %}

{% set results = run_query(profile_sql) %}
{% set results = results.rename(results.column_names | map('lower')) %}
{% do return(results) %}

{% endmacro %}