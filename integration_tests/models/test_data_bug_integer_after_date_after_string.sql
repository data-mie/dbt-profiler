select
    string_nullable,
    to_date(cast(date_nullable as text), 'YYYY-MM-DD') as parsed_date_nullable,
    id as integer_after_date_after_string
    from {{ ref('test_data') }}