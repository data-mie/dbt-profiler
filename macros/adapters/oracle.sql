{# Oracle adapter overrides  -------------------------------------------------     #}


{%- macro oracle__type_string() -%}
  varchar(1000)
{%- endmacro -%}


{%- macro oracle__information_schema(relation) -%}
  ALL_TAB_COLUMNS
{%- endmacro -%}


{%- macro oracle__select_from_information_schema_columns(relation) -%}
  select
    *
  from {{ dbt_profiler.information_schema(relation) }}
  where lower(owner) = lower('{{ relation.schema }}')
    and lower(table_name) = lower('{{ relation.identifier }}')
  order by column_id asc
{%- endmacro -%}


{%- macro oracle__measure_row_count(column_name, data_type) -%}
cast(count(*) as {{ dbt.type_numeric() }})
{%- endmacro -%}


{%- macro oracle__measure_not_null_proportion(column_name, data_type) -%}
case when cast(count(*) as {{ dbt.type_numeric() }}) != 0 THEN
sum(case when {{ adapter.quote(column_name) }} is null then 0 else 1 end) / cast(count(*) as {{ dbt.type_numeric() }})
ELSE 0 END
{%- endmacro -%}


{%- macro oracle__measure_distinct_proportion(column_name, data_type) -%}
{%- if not dbt_profiler.is_struct_dtype(data_type) -%}
	CASE WHEN cast(count(*) as {{ dbt.type_numeric() }}) != 0 THEN
    count(distinct {{ adapter.quote(column_name) }}) / cast(count(*) as {{ dbt.type_numeric() }})
	ELSE 0 END
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}
{%- endmacro -%}


{%- macro oracle__measure_is_unique(column_name, data_type) -%}
{%- if not dbt_profiler.is_struct_dtype(data_type) -%}
    CASE WHEN count(distinct {{ adapter.quote(column_name) }}) = count(*) THEN 'Y' ELSE 'N' END
{%- else -%}
    null
{%- endif -%}
{%- endmacro -%}


{% macro oracle__assert_relation_exists(relation) %}

{% do run_query("select * from " ~ relation ~ " where rownum < 0") %}

{% endmacro %}
