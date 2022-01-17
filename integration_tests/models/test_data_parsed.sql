select
    id,
    numeric_not_nullable,
    numeric_nullable,
    string_not_nullable,
    string_nullable,
    to_date(cast(date_nullable as text), 'YYYY-MM-DD') as parsed_date_nullable
    from {{ ref('test_data') }}