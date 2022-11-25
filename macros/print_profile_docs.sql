{% macro print_profile_docs(relation=none, relation_name=none, docs_name=none, schema=none, database=none, exclude_measures=[], include_columns=[], exclude_columns=[], max_rows=none, max_columns=13, max_column_width=30, max_precision=none, where_clause=none) %}

{%- set results = dbt_profiler.get_profile_table(relation=relation, relation_name=relation_name, schema=schema, database=database, exclude_measures=exclude_measures, include_columns=include_columns, exclude_columns=exclude_columns, where_clause=where_clause) -%}

{% if docs_name is none %}
  {% set docs_name = 'dbt_profiler__' + relation_name %}
{% endif %}

{% if execute %}
  {{ print('{% docs ' + docs_name + '  %}') }}
  {% do results.print_table(max_rows=max_rows, max_columns=max_columns, max_column_width=max_column_width, max_precision=max_precision) %}
  {{ print('{% enddocs %}') }}
{% endif %}

{% endmacro %}