{% macro get_profile(relation) %}

{% if execute %}
  {% do dbt_profiler.assert_relation_exists(relation) %}

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
        {% set data_type = data_type_map.get(column_name.lower(), "") %}
        select 
          lower('{{ column_name }}') as column_name,
          nullif(lower('{{ data_type }}'), '') as data_type,
          cast(count(*) as numeric) as row_count,
          sum(case when {{ adapter.quote(column_name) }} is null then 0 else 1 end) / cast(count(*) as numeric) as not_null_proportion,
          count(distinct {{ adapter.quote(column_name) }}) / cast(count(*) as numeric) as distinct_proportion,
          count(distinct {{ adapter.quote(column_name) }}) as distinct_count,
          count(distinct {{ adapter.quote(column_name) }}) = count(*) as is_unique,
          {% if dbt_profiler.is_numeric_dtype(data_type) or dbt_profiler.is_date_or_time_dtype(data_type) %}cast(min({{ adapter.quote(column_name) }}) as {{ dbt_profiler.type_string() }}){% else %}null{% endif %} as min,
          {% if dbt_profiler.is_numeric_dtype(data_type) or dbt_profiler.is_date_or_time_dtype(data_type) %}cast(max({{ adapter.quote(column_name) }}) as {{ dbt_profiler.type_string() }}){% else %}null{% endif %} as max,
          {% if dbt_profiler.is_numeric_dtype(data_type) %}avg({{ adapter.quote(column_name) }}){% else %}null{% endif %} as avg,
          {% if dbt_profiler.is_numeric_dtype(data_type) %}stddev_pop({{ adapter.quote(column_name) }}){% else %}null{% endif %} as std_dev_population,
          {% if dbt_profiler.is_numeric_dtype(data_type) %}stddev_samp({{ adapter.quote(column_name) }}){% else %}null{% endif %} as std_dev_sample,
          cast(current_timestamp as {{ dbt_profiler.type_string() }}) as profiled_at,
          {{ loop.index }} as _column_position
        from {{ relation }}

        {% if not loop.last %}union all{% endif %}
      {% endfor %}
    )

    select
      column_name,
      data_type,
      row_count,
      not_null_proportion,
      distinct_proportion,
      distinct_count,
      is_unique,
      min,
      max,
      avg,
      std_dev_population,
      std_dev_sample,
      profiled_at
    from column_profiles
    order by _column_position asc
  {% endset %}

  {% do return(profile_sql) %}
{% endif %}

{% endmacro %}