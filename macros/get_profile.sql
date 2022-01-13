{% macro get_profile(relation=none) %}

{{ log("Get columns in relation %s" | format(relation.include()), info=False) }}
{%- set columns = adapter.get_columns_in_relation(relation) -%}
{%- set column_names = columns | map(attribute="name") | list -%}
{{ log("Columns: " ~ column_names | join(', '), info=False) }}

{% set information_schema_columns = run_query(dbt_profiler.select_from_information_schema_columns(relation)) %}
{% set information_schema_columns = information_schema_columns.rename(information_schema_columns.column_names | map('lower')) %}
{% set information_schema_data_types = information_schema_columns.columns['data_type'].values() | map('lower') | list %}
{% set information_schema_column_names = information_schema_columns.columns['column_name'].values() | map('lower') | list %}
{% set data_type_map = {} %}
{% for column_name in information_schema_column_names %}
  {% do data_type_map.update({column_name: information_schema_data_types[loop.index-1]}) %}
{% endfor %}
{{ log("Column data types: " ~ data_type_map, info=False) }}

{% set profile_sql %}
  with column_profiles as (
    {% for column_name in column_names %}
      {% set data_type = data_type_map.get(column_name, "") %}
      select 
        lower('{{ column_name }}') as column_name,
        nullif(lower('{{ data_type }}'), '') as data_type,
        cast(count(*) as numeric) as row_count,
        sum(case when {{ adapter.quote(column_name) }} is null then 0 else 1 end) / cast(count(*) as numeric) as not_null_proportion,
        count(distinct {{ adapter.quote(column_name) }}) / cast(count(*) as numeric) as distinct_proportion,
        count(distinct {{ adapter.quote(column_name) }}) as distinct_count,
        count(distinct {{ adapter.quote(column_name) }}) = count(*) as is_unique,
        {% if "int" in data_type %}avg({{ adapter.quote(column_name) }}){% else %}null{% endif %} as average,
        cast(current_timestamp as {{ dbt_profiler.type_string() }}) as profiled_at
      from {{ relation }}

      {% if not loop.last %}union all{% endif %}
    {% endfor %}
  )

  select
    *
  from column_profiles
{% endset %}

{% do return(profile_sql) %}

{% endmacro %}