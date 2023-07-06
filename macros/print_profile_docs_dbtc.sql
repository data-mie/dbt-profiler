{% macro print_profile_docs__dbtc(relation=none, relation_name=none, docs_name=none, schema=none, database=none, exclude_measures=[], include_columns=[], exclude_columns=[], max_rows=none, max_columns=13, max_column_width=30, max_precision=none, where_clause=none) %}

    {%- if execute %}

        {%- set results = dbt_profiler.get_profile_table(relation=relation, relation_name=relation_name, schema=schema, database=database, exclude_measures=exclude_measures, include_columns=include_columns, exclude_columns=exclude_columns, where_clause=where_clause) -%}
        {%- set profile_docs=[] -%}
        {% if docs_name is none %}
            {% set docs_name = "dbt_profiler__" + relation_name %}
        {% endif %}
        {% do profile_docs.append('{% docs ' ~ docs_name ~ '  %}') -%}
        {% do profile_docs.append('') %}

        {# Get header from column names #}
        {%- set headers = results.column_names -%}
        {%- set header = [] -%}
        {%- set horizontal_line = [] -%}

        {% for i in range(0,headers|length) %}
            {% do header.append(headers[i]) %}
            {% do horizontal_line.append('---') %}
        {% endfor %}
        {% do profile_docs.append('| ' ~ header|join(' | ') ~ ' |') %}
        {% do profile_docs.append('| ' ~ horizontal_line|join(' | ') ~ ' |') %}

        {# Get row values #}
        {% for row in results.rows %}
            {%- set list_row = [''] -%}
            {% for val in row.values() %}
                {% do list_row.append(val) %}
            {% endfor %}
            {% do profile_docs.append(list_row|join(' | ') ~ ' |') %}
        {% endfor %}
        {% do profile_docs.append('') %}
        {% do profile_docs.append('{% enddocs %}') %}

        {# Join profile docs #}
        {%- set joined = profile_docs | join ('\n') -%}
        {{ log(joined, info=True) }}
        {% do return(joined) %}

    {% endif -%}

{% endmacro %}