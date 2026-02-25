{# BigQuery adapter overrides  -------------------------------------------------     #}


{%- macro bigquery__type_string() -%}
  string
{%- endmacro -%}


{%- macro bigquery__information_schema(relation) -%}
  {{ adapter.quote(relation.database) }}.{{ adapter.quote(relation.schema) }}.INFORMATION_SCHEMA
{%- endmacro -%}


{%- macro bigquery__measure_median(column_name, data_type, cte_name) -%}

{%- if dbt_profiler.is_numeric_dtype(data_type) and not dbt_profiler.is_struct_dtype(data_type) -%}
    APPROX_QUANTILES({{ adapter.quote(column_name) }}, 100)[OFFSET(50)]
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}

{%- endmacro -%}
