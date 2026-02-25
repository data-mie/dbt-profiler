{% macro print_profile_docs(relation=none, relation_name=none, docs_name=none, schema=none, database=none, exclude_measures=[], include_columns=[], exclude_columns=[], max_rows=none, max_columns=13, max_column_width=30, max_precision=none, where_clause=none) %}

{% if execute %}

    {%- set results = dbt_profiler.get_profile_table(relation=relation, relation_name=relation_name, schema=schema, database=database, exclude_measures=exclude_measures, include_columns=include_columns, exclude_columns=exclude_columns, where_clause=where_clause) -%}

    {% if docs_name is none %}
        {% set docs_name = 'dbt_profiler__' + relation_name %}
    {% endif %}

    {%- set startdocs = '{% docs ' ~ docs_name ~ '  %}' -%}
    {%- set enddocs = '{% enddocs %}' -%}

    {# Check if macro is called in dbt Cloud #}
    {%- if env_var('DBT_CLOUD_ENVIRONMENT_TYPE', '') != '' -%}
        {%- set is_dbt_cloud = true -%}
    {%- else -%}
        {%- set is_dbt_cloud = false -%}
    {%- endif -%}

    {% if not is_dbt_cloud %}

        {{ print(startdocs) }}
        {% do results.print_table(max_rows=max_rows, max_columns=max_columns, max_column_width=max_column_width, max_precision=max_precision) %}
        {{ print(enddocs) }}

    {% else %}

        {%- set profile_docs=[] -%}
        {% do profile_docs.append(startdocs) -%}
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
        {% do profile_docs.append(enddocs) %}

        {# Join profile docs #}
        {%- set joined = profile_docs | join ('\n') -%}
        {{ log(joined, info=True) }}
        {% do return(joined) %}

    {% endif %}

{% endif %}

{% endmacro %}