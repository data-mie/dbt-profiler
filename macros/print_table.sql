{% macro print_table(table, max_rows=none, max_columns=13, max_column_width=30, max_precision=none) %}

{# Check if macro is called in dbt Cloud #}
{%- set is_dbt_cloud = flags.WHICH == 'rpc' -%}

{%- if not is_dbt_cloud -%}
    {% do results.print_table(max_rows=max_rows, max_columns=max_columns, max_column_width=max_column_width, max_precision=max_precision) %}
{% else %}
    {%- set table_printout_lines = [] -%}

    {# Get header from column names #}
    {%- set headers = results.column_names | list -%}
    {%- set horizontal_lines = ['---'] * headers | length -%}
    {% do table_printout_lines.append('| ' ~ headers | join(' | ') ~ ' |') %}
    {% do table_printout_lines.append('| ' ~ horizontal_lines | join(' | ') ~ ' |') %}

    {# Get row values #}
    {% for row in results.rows %}
        {%- set list_row = [''] -%}
        {% for val in row.values() %}
            {% do list_row.append(val) %}
        {% endfor %}
        {% do table_printout_lines.append(list_row | join(' | ') ~ ' |') %}
    {% endfor %}

    {%- set table_printout = table_printout_lines | join ('\n') -%}
    {{ print(table_printout) }}
{% endif %}


{% endmacro %}