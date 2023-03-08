
{{ config(enabled=target.type == "bigquery") }}

-- depends_on: {{ ref("test_data_default") }}
select
    *,
    struct(numeric_not_nullable as numeric_not_nullable, numeric_nullable as numeric_nullable) as struct_nullable
from {{ ref("test_data_default") }}
