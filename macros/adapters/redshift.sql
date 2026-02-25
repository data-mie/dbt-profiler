{# Redshift adapter overrides  -------------------------------------------------     #}


{%- macro redshift__select_from_information_schema_columns(relation) -%}
  select
    attr.attname::varchar as column_name,
    type.typname::varchar as data_type,
    class.relname::varchar as table_name,
    namespace.nspname::varchar as table_schema
  from pg_catalog.pg_attribute as attr
  join pg_catalog.pg_type as type on (attr.atttypid = type.oid)
  join pg_catalog.pg_class as class on (attr.attrelid = class.oid)
  join pg_catalog.pg_namespace as namespace on (class.relnamespace = namespace.oid)
  where lower(table_schema) = lower('{{ relation.schema }}')
    and lower(table_name) = lower('{{ relation.identifier }}')
    and attr.attnum > 0
{%- endmacro -%}


{%- macro redshift__measure_avg(column_name, data_type) -%}

{%- if dbt_profiler.is_numeric_dtype(data_type) and not dbt_profiler.is_struct_dtype(data_type) -%}
    avg({{ adapter.quote(column_name) }}::float)
{%- elif dbt_profiler.is_logical_dtype(data_type) -%}
    avg(case when {{ adapter.quote(column_name) }} then 1.0 else 0.0 end)
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}

{%- endmacro -%}


{%- macro redshift__measure_median(column_name, data_type, cte_name) -%}

{%- if dbt_profiler.is_numeric_dtype(data_type) and not dbt_profiler.is_struct_dtype(data_type) -%}
    select percentile_cont(0.5) within group (order by {{ adapter.quote(column_name) }}) from {{ cte_name }}
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}

{%- endmacro -%}
