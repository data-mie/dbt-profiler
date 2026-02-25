-- Generates rows with large integer values typical of hash-based surrogate keys
-- (e.g. CONVERT(BIGINT, HASHBYTES('SHA2_256', ...)) in SQL Server).
-- All values exceed INT range so each adapter types the column as bigint/INT64.
select 1 as id, 3037000499 as hash_key
union all select 2, -3037000499
union all select 3, 4000000001
union all select 4, -4000000001
union all select 5, 2500000000
