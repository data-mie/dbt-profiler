{% macro get_relation(relation=none, relation_name=none, schema=none, database=none) %}

{% if relation is none and relation_name is none %}
  {{ exceptions.raise_compiler_error("Either relation or relation_name must be specified.") }}
{% endif %}

{% if relation is none %}
  {% if schema is none %}
    {% set schema = target.schema %}
  {% endif %}

  {% if database is none %}
    {% set database = target.database %}
  {% endif %}

  {{ log("Get relation %s (database=%s, schema=%s)" | format(adapter.quote(relation_name), adapter.quote(database), adapter.quote(schema)), info=False) }}

  {%- 
  set relation = adapter.get_relation(
    database=database,
    schema=schema,
    identifier=relation_name
  ) 
  -%}
  {% if relation is none %}
    {{ exceptions.raise_compiler_error("Relation " ~ adapter.quote(relation_name) ~ " does not exist or not authorized.") }}
  {% endif %}
{% endif %}

{% do return(relation) %}

{% endmacro %}

{% macro assert_relation_exists(relation) %}

{% do run_query("select * from " ~ relation ~ " limit 0") %}

{% endmacro %}
