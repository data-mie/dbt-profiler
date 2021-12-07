{{
  config(
    materialized="incremental"
  )
}}

select
  *
from {{ ref("profile") }}