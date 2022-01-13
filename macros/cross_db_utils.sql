{# type_string  -------------------------------------------------     #}

{%- macro type_string() -%}
  {{ return(adapter.dispatch("type_string", macro_namespace="dbt_profiler")()) }}
{%- endmacro -%}

{%- macro default__type_string() -%}
  varchar
{%- endmacro -%}

{%- macro bigquery__type_string() -%}
  string
{%- endmacro -%}


{# is_numeric_dtype  -------------------------------------------------     #}

{%- macro is_numeric_dtype(dtype) -%}
  {{ return(adapter.dispatch("is_numeric_dtype", macro_namespace="dbt_profiler")(dtype)) }}
{%- endmacro -%}

{%- macro default__is_numeric_dtype(dtype) -%}
  {% set is_numeric = dtype.startswith("int") or dtype.startswith("float") or "numeric" in dtype or "number" in dtype or "double" in dtype %}
  {% do return(is_numeric) %}
{%- endmacro -%}


{# is_date_or_time_dtype  -------------------------------------------------     #}

{%- macro is_date_or_time_dtype(dtype) -%}
  {{ return(adapter.dispatch("is_date_or_time_dtype", macro_namespace="dbt_profiler")(dtype)) }}
{%- endmacro -%}

{%- macro default__is_date_or_time_dtype(dtype) -%}
  {% set is_date_or_time = dtype.startswith("timestamp") or dtype.startswith("date") %}
  {% do return(is_date_or_time) %}
{%- endmacro -%}

{# information_schema  -------------------------------------------------     #}

{%- macro information_schema(relation) -%}
  {{ return(adapter.dispatch("information_schema", macro_namespace="dbt_profiler")(relation)) }}
{%- endmacro -%}

{%- macro default__information_schema(relation) -%}
  {{ relation.information_schema() }}
{%- endmacro -%}

{%- macro bigquery__information_schema(relation) -%}
  {{ adapter.quote(relation.schema) }}.INFORMATION_SCHEMA
{%- endmacro -%}


{# select_from_information_schema_columns  -------------------------------------------------     #}

{%- macro select_from_information_schema_columns(relation) -%}
  {{ return(adapter.dispatch("select_from_information_schema_columns", macro_namespace="dbt_profiler")(relation)) }}
{%- endmacro -%}

{%- macro default__select_from_information_schema_columns(relation) -%}
  select
    *
  from {{ dbt_profiler.information_schema(relation) }}.COLUMNS
  where lower(table_schema) = lower('{{ relation.schema }}') 
    and lower(table_name) = lower('{{ relation.identifier }}')
  order by ordinal_position asc
{%- endmacro -%}

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