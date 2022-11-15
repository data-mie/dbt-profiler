{%- set incremental_strategy=none -%}
{%- if target.type == "bigquery" -%}
  {%- set incremental_strategy = "merge" -%}
{%- elif target.type == "snowflake" -%}
  {%- set incremental_strategy = "merge" -%}
{%- endif -%}

{{
  config(
    materialized="incremental",
    incremental_strategy=incremental_strategy
  )
}}

select
  *
from {{ ref("profile") }}