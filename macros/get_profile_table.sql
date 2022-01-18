{% macro get_profile_table(relation=none, relation_name=none, schema=none, database=none, exclude_metrics=none) %}

{%- set relation = dbt_profiler.get_relation(
  relation=relation,
  relation_name=relation_name,
  schema=schema,
  database=database,
  exclude_metrics=exclude_metrics
) -%}
{%- set profile_sql = dbt_profiler.get_profile(relation=relation.relation, exclude_metrics=relation.exclude_metrics) -%}
{{ log(profile_sql, info=False) }}
{% set results = run_query(profile_sql) %}
{% set results = results.rename(results.column_names | map('lower')) %}

{% set results_res = {'results':results, 'exclude_metrics':exclude_metrics} %}
{% do return(results_res) %}
{% endmacro %}
