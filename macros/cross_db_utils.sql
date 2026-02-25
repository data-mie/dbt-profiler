{# type_string  -------------------------------------------------     #}

{%- macro type_string() -%}
  {{ return(adapter.dispatch("type_string", macro_namespace="dbt_profiler")()) }}
{%- endmacro -%}

{%- macro default__type_string() -%}
  varchar
{%- endmacro -%}


{# is_numeric_dtype  -------------------------------------------------     #}

{%- macro is_numeric_dtype(dtype) -%}
  {{ return(adapter.dispatch("is_numeric_dtype", macro_namespace="dbt_profiler")(dtype)) }}
{%- endmacro -%}

{%- macro default__is_numeric_dtype(dtype) -%}
  {% set is_numeric = dtype.startswith("int") or dtype.startswith("float") or "numeric" in dtype or "number" in dtype or "double" in dtype or "bigint" in dtype %}
  {% do return(is_numeric) %}
{%- endmacro -%}


{# is_logical_dtype  -------------------------------------------------     #}

{%- macro is_logical_dtype(dtype) -%}
  {{ return(adapter.dispatch("is_logical_dtype", macro_namespace="dbt_profiler")(dtype)) }}
{%- endmacro -%}

{%- macro default__is_logical_dtype(dtype) -%}
  {% set is_bool = dtype.startswith("bool") %}
  {% do return(is_bool) %}
{%- endmacro -%}


{# is_date_or_time_dtype  -------------------------------------------------     #}

{%- macro is_date_or_time_dtype(dtype) -%}
  {{ return(adapter.dispatch("is_date_or_time_dtype", macro_namespace="dbt_profiler")(dtype)) }}
{%- endmacro -%}

{%- macro default__is_date_or_time_dtype(dtype) -%}
  {% set is_date_or_time = dtype.startswith("timestamp") or dtype.startswith("date") %}
  {% do return(is_date_or_time) %}
{%- endmacro -%}


{# is_struct_dtype  -------------------------------------------------     #}

{%- macro is_struct_dtype(dtype) -%}
  {{ return(adapter.dispatch("is_struct_dtype", macro_namespace="dbt_profiler")(dtype)) }}
{%- endmacro -%}

{%- macro default__is_struct_dtype(dtype) -%}
  {% do return((dtype | lower).startswith('struct')) %}
{%- endmacro -%}


{# information_schema  -------------------------------------------------     #}

{%- macro information_schema(relation) -%}
  {{ return(adapter.dispatch("information_schema", macro_namespace="dbt_profiler")(relation)) }}
{%- endmacro -%}

{%- macro default__information_schema(relation) -%}
  {{ relation.information_schema() }}
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
