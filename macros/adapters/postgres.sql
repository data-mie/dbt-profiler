{# PostgreSQL adapter overrides  -------------------------------------------------     #}


{%- macro postgres__measure_median(column_name, data_type, cte_name) -%}

{%- if dbt_profiler.is_numeric_dtype(data_type) and not dbt_profiler.is_struct_dtype(data_type) -%}
    percentile_cont(0.5) within group (order by {{ adapter.quote(column_name) }})
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}

{%- endmacro -%}
