{% macro print_profile_docs(relation=none, relation_name=none, docs_name=none, schema=none, database=none, max_rows=none, max_columns=13, max_column_width=30, max_precision=none) %}

{%- set results = dbt_profiler.get_profile_table(relation=relation, relation_name=relation_name, schema=schema, database=database) -%}

{% if docs_name is none %}
  {% set docs_name = 'dbt_profiler__' + relation_name %}
{% endif %}

{% if execute %}
  {{ log('{% docs ' + docs_name + '  %}', info=True) }}
  {% do results.print_table(max_rows=max_rows, max_columns=max_columns, max_column_width=max_column_width, max_precision=max_precision) %}
  {{ log('{% enddocs %}', info=True) }}
{% endif %}

{% endmacro %}