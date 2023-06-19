{# measure_row_count  -------------------------------------------------     #}

{%- macro measure_row_count(column_name, data_type) -%}
  {{ return(adapter.dispatch("measure_row_count", macro_namespace="dbt_profiler")(column_name, data_type)) }}
{%- endmacro -%}

{%- macro default__measure_row_count(column_name, data_type) -%}
cast(count(*) as {{ dbt.type_numeric() }})
{%- endmacro -%}


{# measure_not_null_proportion  -------------------------------------------------     #}

{%- macro measure_not_null_proportion(column_name, data_type) -%}
  {{ return(adapter.dispatch("measure_not_null_proportion", macro_namespace="dbt_profiler")(column_name, data_type)) }}
{%- endmacro -%}

{%- macro default__measure_not_null_proportion(column_name, data_type) -%}
sum(case when {{ adapter.quote(column_name) }} is null then 0 else 1 end) / cast(count(*) as {{ dbt.type_numeric() }})
{%- endmacro -%}


{# measure_distinct_proportion  -------------------------------------------------     #}

{%- macro measure_distinct_proportion(column_name, data_type) -%}
  {{ return(adapter.dispatch("measure_distinct_proportion", macro_namespace="dbt_profiler")(column_name, data_type)) }}
{%- endmacro -%}

{%- macro default__measure_distinct_proportion(column_name, data_type) -%}
{%- if not dbt_profiler.is_struct_dtype(data_type) -%}
    count(distinct {{ adapter.quote(column_name) }}) / cast(count(*) as {{ dbt.type_numeric() }})
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}
{%- endmacro -%}

{# measure_distinct_count  -------------------------------------------------     #}

{%- macro measure_distinct_count(column_name, data_type) -%}
  {{ return(adapter.dispatch("measure_distinct_count", macro_namespace="dbt_profiler")(column_name, data_type)) }}
{%- endmacro -%}

{%- macro default__measure_distinct_count(column_name, data_type) -%}
{%- if not dbt_profiler.is_struct_dtype(data_type) -%}
    count(distinct {{ adapter.quote(column_name) }})
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}
{%- endmacro -%}

{# measure_is_unique  -------------------------------------------------     #}

{%- macro measure_is_unique(column_name, data_type) -%}
  {{ return(adapter.dispatch("measure_is_unique", macro_namespace="dbt_profiler")(column_name, data_type)) }}
{%- endmacro -%}

{%- macro default__measure_is_unique(column_name, data_type) -%}
{%- if not dbt_profiler.is_struct_dtype(data_type) -%}
    count(distinct {{ adapter.quote(column_name) }}) = count(*)
{%- else -%}
    null
{%- endif -%}
{%- endmacro -%}

{%- macro sqlserver__measure_is_unique(column_name, data_type) -%}
case when count(distinct {{ adapter.quote(column_name) }}) = count(*) then 1 else 0 end
{%- endmacro -%}


{# measure_min  -------------------------------------------------     #}

{%- macro measure_min(column_name, data_type) -%}
  {{ return(adapter.dispatch("measure_min", macro_namespace="dbt_profiler")(column_name, data_type)) }}
{%- endmacro -%}

{%- macro default__measure_min(column_name, data_type) -%}
{%- if (dbt_profiler.is_numeric_dtype(data_type) or dbt_profiler.is_date_or_time_dtype(data_type)) and not dbt_profiler.is_struct_dtype(data_type) -%}
    cast(min({{ adapter.quote(column_name) }}) as {{ dbt_profiler.type_string() }})
{%- else -%}
    cast(null as {{ dbt_profiler.type_string() }})
{%- endif -%}
{%- endmacro -%}

{# measure_max  -------------------------------------------------     #}

{%- macro measure_max(column_name, data_type) -%}
  {{ return(adapter.dispatch("measure_max", macro_namespace="dbt_profiler")(column_name, data_type)) }}
{%- endmacro -%}

{%- macro default__measure_max(column_name, data_type) -%}
{%- if (dbt_profiler.is_numeric_dtype(data_type) or dbt_profiler.is_date_or_time_dtype(data_type)) and not dbt_profiler.is_struct_dtype(data_type) -%}
    cast(max({{ adapter.quote(column_name) }}) as {{ dbt_profiler.type_string() }})
{%- else -%}
    cast(null as {{ dbt_profiler.type_string() }})
{%- endif -%}
{%- endmacro -%}


{# measure_avg  -------------------------------------------------     #}

{%- macro measure_avg(column_name, data_type) -%}
  {{ return(adapter.dispatch("measure_avg", macro_namespace="dbt_profiler")(column_name, data_type)) }}
{%- endmacro -%}

{%- macro default__measure_avg(column_name, data_type) -%}

{%- if dbt_profiler.is_numeric_dtype(data_type) and not dbt_profiler.is_struct_dtype(data_type) -%}
    avg({{ adapter.quote(column_name) }})
{%- elif dbt_profiler.is_logical_dtype(data_type) -%}
    avg(case when {{ adapter.quote(column_name) }} then 1 else 0 end)
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}

{%- endmacro -%}


{# measure_median  -------------------------------------------------     #}

{%- macro measure_median(column_name, data_type) -%}
  {{ return(adapter.dispatch("measure_median", macro_namespace="dbt_profiler")(column_name, data_type)) }}
{%- endmacro -%}

{%- macro default__measure_median(column_name, data_type) -%}

{%- if dbt_profiler.is_numeric_dtype(data_type) and not dbt_profiler.is_struct_dtype(data_type) -%}
    median({{ adapter.quote(column_name) }})
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}

{%- endmacro -%}

{%- macro bigquery__measure_median(column_name, data_type) -%}

{%- if dbt_profiler.is_numeric_dtype(data_type) and not dbt_profiler.is_struct_dtype(data_type) -%}
    APPROX_QUANTILES({{ adapter.quote(column_name) }}, 100)[OFFSET(50)]
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}

{%- endmacro -%}

{%- macro postgres__measure_median(column_name, data_type) -%}

{%- if dbt_profiler.is_numeric_dtype(data_type) and not dbt_profiler.is_struct_dtype(data_type) -%}
    percentile_cont(0.5) within group (order by {{ adapter.quote(column_name) }})
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}

{%- endmacro -%}

{%- macro sql_server__measure_median(column_name, data_type) -%}

{%- if dbt_profiler.is_numeric_dtype(data_type) and not dbt_profiler.is_struct_dtype(data_type) -%}
    percentile_cont({{ adapter.quote(column_name) }}, 0.5) over ()
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}

{%- endmacro -%}

{# measure_std_dev_population  -------------------------------------------------     #}

{%- macro measure_std_dev_population(column_name, data_type) -%}
  {{ return(adapter.dispatch("measure_std_dev_population", macro_namespace="dbt_profiler")(column_name, data_type)) }}
{%- endmacro -%}

{%- macro default__measure_std_dev_population(column_name, data_type) -%}

{%- if dbt_profiler.is_numeric_dtype(data_type) and not dbt_profiler.is_struct_dtype(data_type) -%}
    stddev_pop({{ adapter.quote(column_name) }})
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}

{%- endmacro -%}


{%- macro sqlserver__measure_std_dev_population(column_name, data_type) -%}

{%- if dbt_profiler.is_numeric_dtype(data_type) -%}
    stdevp({{ adapter.quote(column_name) }})
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}

{%- endmacro -%}



{# measure_std_dev_sample  -------------------------------------------------     #}

{%- macro measure_std_dev_sample(column_name, data_type) -%}
  {{ return(adapter.dispatch("measure_std_dev_sample", macro_namespace="dbt_profiler")(column_name, data_type)) }}
{%- endmacro -%}

{%- macro default__measure_std_dev_sample(column_name, data_type) -%}

{%- if dbt_profiler.is_numeric_dtype(data_type) and not dbt_profiler.is_struct_dtype(data_type) -%}
    stddev_samp({{ adapter.quote(column_name) }})
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}

{%- endmacro -%}

{%- macro sqlserver__measure_std_dev_sample(column_name, data_type) -%}

{%- if dbt_profiler.is_numeric_dtype(data_type) -%}
    stdev({{ adapter.quote(column_name) }})
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}

{%- endmacro -%}
