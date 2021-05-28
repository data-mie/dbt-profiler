{# type_string  -------------------------------------------------     #}

{%- macro type_string() -%}
  {{ return(adapter.dispatch("type_string", packages = ["dbt_profiler"])()) }}
{%- endmacro -%}

{%- macro default__type_string() -%}
  varchar
{%- endmacro -%}

{%- macro bigquery__type_string() -%}
  string
{%- endmacro -%}


{# information_schema  -------------------------------------------------     #}

{%- macro information_schema(relation) -%}
  {{ return(adapter.dispatch("information_schema", packages = ["dbt_profiler"])(relation)) }}
{%- endmacro -%}

{%- macro default__information_schema(relation) -%}
  {{ relation.information_schema() }}
{%- endmacro -%}

{%- macro bigquery__information_schema(relation) -%}
  {{ adapter.quote(relation.schema) }}.INFORMATION_SCHEMA
{%- endmacro -%}