{# Athena adapter overrides  -------------------------------------------------     #}


{%- macro athena__is_numeric_dtype(dtype) -%}
  {% set is_numeric = "int" in dtype or "float" in dtype or "decimal" in dtype or "double" in dtype %}
  {% do return(is_numeric) %}
{%- endmacro -%}


{%- macro athena__measure_median(column_name, data_type, cte_name) -%}

{%- if dbt_profiler.is_numeric_dtype(data_type) and not dbt_profiler.is_struct_dtype(data_type) -%}
    approx_percentile( {{ adapter.quote(column_name) }}, 0.5)
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}

{%- endmacro -%}
