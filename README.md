[![CircleCI](https://circleci.com/gh/data-mie/dbt-profiler/tree/main.svg?style=svg)](https://circleci.com/gh/data-mie/dbt-profiler/tree/main)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![dbt Hub](https://img.shields.io/badge/dbt%20Hub-dbt__profiler-FF694B)](https://hub.getdbt.com/data-mie/dbt_profiler/latest/)

# dbt-profiler

> dbt macros for profiling database relations and embedding the results in dbt docs and schema files.

## Contents

- [Installation](#installation)
- [Supported adapters](#supported-adapters)
- [Quick start](#quick-start)
- [Profile measures](#profile-measures)
- [Macros](#macros)
  - [get_profile](#get_profile-source)
  - [get_profile_table](#get_profile_table-source)
  - [print_profile](#print_profile-source)
  - [print_profile_schema](#print_profile_schema-source)
  - [print_profile_docs](#print_profile_docs-source)
- [Using profiles in dbt docs](#using-profiles-in-dbt-docs)
- [Automating profile updates with CI](#automating-profile-updates-with-ci)
- [Contributing](#contributing)
- [License](#license)

## Installation

`dbt-profiler` requires dbt `>=1.1.0`. Check [dbt Hub](https://hub.getdbt.com/data-mie/dbt_profiler/latest/) for the latest installation instructions.

## Supported adapters

| Adapter | Supported |
|---|---|
| AWS Athena | ✅ |
| BigQuery | ✅ |
| Databricks | ✅ |
| PostgreSQL | ✅ |
| Redshift | ✅ |
| Snowflake | ✅ |
| Oracle | ✅ |
| SQL Server | ✅ |
| Apache Spark | ❌ |
| Presto | ❌ |

`dbt-profiler` may work with unsupported adapters but they haven't been tested. If you've used `dbt-profiler` with an unsupported adapter, feedback is very welcome: open an issue, a PR, or reach out in the [#tools-dbt-profiler](https://getdbt.slack.com/archives/C094X0V0Y4V) channel on dbt Slack.

## Quick start

Profile a relation and print the result to stdout:

```bash
dbt run-operation print_profile --args '{"relation_name": "customers"}'
```

Use a relation profile as a dbt model:

```sql
-- models/customers_profile.sql
{{ dbt_profiler.get_profile(relation=ref("customers")) }}
```

Generate a `schema.yml` skeleton with profile data embedded in column `meta` properties:

```bash
dbt run-operation print_profile_schema --args '{"relation_name": "customers"}'
```

## Profile measures

A calculated profile contains the following measures for each column:

| Measure | Description | Columns |
|---|---|---|
| `column_name` | Name of the column | all |
| `data_type` | Data type of the column | all |
| `not_null_proportion` † | Proportion of non-`NULL` values (e.g. `0.62` = 62% populated) | all |
| `distinct_proportion` † | Proportion of unique values | all |
| `distinct_count` † | Count of unique values | all |
| `is_unique` † | `true` if all values are unique | all |
| `min` *† | Minimum value | numeric, date, time |
| `max` *† | Maximum value | numeric, date, time |
| `avg` **† | Average value | numeric |
| `median` **† | Median value | numeric |
| `std_dev_population` **† | Population standard deviation | numeric |
| `std_dev_sample` **† | Sample standard deviation | numeric |
| `profiled_at` | Timestamp when the profile was calculated | all |

\* numeric, date and time columns only
\*\* numeric columns only
† can be excluded using the `exclude_measures` argument

## Macros

### get_profile ([source](macros/get_profile.sql))

Returns a relation profile as a SQL query that can be used in a dbt model. Handy for previewing profiles in dbt Cloud.

#### Arguments

| Argument | Required | Default | Description |
|---|---|---|---|
| `relation` | yes | | [Relation](https://docs.getdbt.com/reference/dbt-classes#relation) object |
| `exclude_measures` | no | `[]` | List of measures to exclude from the profile |
| `include_columns` | no | `[]` (all) | Columns to include. Cannot be used together with `exclude_columns`. |
| `exclude_columns` | no | `[]` | Columns to exclude. Cannot be used together with `include_columns`. |
| `where_clause` | no | | SQL `WHERE` clause to filter records before profiling |
| `group_by` | no | `[]` | SQL `GROUP BY` columns to aggregate data before profiling |

#### Usage

Use with [ref()](https://docs.getdbt.com/reference/dbt-jinja-functions/ref):

```sql
{{ dbt_profiler.get_profile(relation=ref("customers"), where_clause="is_active = true") }}
```

Use with [source()](https://docs.getdbt.com/reference/dbt-jinja-functions/source):

```sql
{{ dbt_profiler.get_profile(relation=source("jaffle_shop","customers"), exclude_measures=["std_dev_population", "std_dev_sample"]) }}
```

To run only in [execute](https://docs.getdbt.com/reference/dbt-jinja-functions/execute) mode:

```sql
-- depends_on: {{ ref("customers") }}
{% if execute %}
    {{ dbt_profiler.get_profile(relation=ref("customers")) }}
{% endif %}
```

---

### get_profile_table ([source](macros/get_profile_table.sql))

Returns a relation profile as an [agate.Table](https://agate.readthedocs.io/en/1.6.1/api/table.html#module-agate.table). Does not print anything to stdout; intended to be called from another macro or model, not as a standalone operation.

#### Arguments

| Argument | Required | Default | Description |
|---|---|---|---|
| `relation` | either `relation` or `relation_name` | | Relation object |
| `relation_name` | either `relation` or `relation_name` | | Relation name |
| `schema` | no | target schema | Schema where `relation_name` exists |
| `database` | no | target database | Database where `relation_name` exists |
| `exclude_measures` | no | `[]` | List of measures to exclude from the profile |
| `include_columns` | no | `[]` (all) | Columns to include. Cannot be used together with `exclude_columns`. |
| `exclude_columns` | no | `[]` | Columns to exclude. Cannot be used together with `include_columns`. |
| `where_clause` | no | | SQL `WHERE` clause to filter records before profiling |

#### Usage

```sql
{% set table = dbt_profiler.get_profile_table(relation_name="customers") %}
```

---

### print_profile ([source](macros/print_profile.sql))

> ❗ **Does not work in dbt Cloud.** The profile doesn't display in the cloud console log because the underlying [print_table()](https://agate.readthedocs.io/en/1.6.1/api/table.html#agate.Table.print_table) method is disabled.

Prints a relation profile as a Markdown table to stdout.

#### Arguments

| Argument | Required | Default | Description |
|---|---|---|---|
| `relation` | either `relation` or `relation_name` | | Relation object |
| `relation_name` | either `relation` or `relation_name` | | Relation name |
| `schema` | no | target schema | Schema where `relation_name` exists |
| `database` | no | target database | Database where `relation_name` exists |
| `exclude_measures` | no | `[]` | List of measures to exclude from the profile |
| `include_columns` | no | `[]` (all) | Columns to include. Cannot be used together with `exclude_columns`. |
| `exclude_columns` | no | `[]` | Columns to exclude. Cannot be used together with `include_columns`. |
| `max_rows` | no | none (not truncated) | Maximum number of rows to display |
| `max_columns` | no | `7` | Maximum number of columns to display |
| `max_column_width` | no | `30` | Truncate all columns to at most this width |
| `max_precision` | no | none (not limited) | Maximum precision for number types |
| `where_clause` | no | | SQL `WHERE` clause to filter records before profiling |

#### Usage

```bash
dbt run-operation print_profile --args '{"relation_name": "customers"}'
```

For dbt Cloud, an alternative that logs to the console (without Markdown formatting):

```sql
{% set profile = dbt_profiler.get_profile(relation=ref("customers")) %}
{% for row in profile.rows %}
  {% do log(row.values(), info=True) %}
{% endfor %}
```

#### Example output

| column_name | data_type | not_null_proportion | distinct_proportion | distinct_count | is_unique | min | max | avg | std_dev_population | std_dev_sample | profiled_at |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| customer_id | int64 | 1.00 | 1.00 | 100 | 1 | 1 | 100 | 50.50 | 28.87 | 29.01 | 2022-01-13 10:14:48+00 |
| first_order | date | 0.62 | 0.46 | 46 | 0 | 2018-01-01 | 2018-04-07 | | | | 2022-01-13 10:14:48+00 |
| most_recent_order | date | 0.62 | 0.52 | 52 | 0 | 2018-01-09 | 2018-04-09 | | | | 2022-01-13 10:14:48+00 |
| number_of_orders | int64 | 0.62 | 0.04 | 4 | 0 | 1 | 5 | 1.60 | 0.77 | 0.78 | 2022-01-13 10:14:48+00 |
| customer_lifetime_value | float64 | 0.62 | 0.35 | 35 | 0 | 1 | 99 | 26.97 | 18.66 | 18.81 | 2022-01-13 10:14:48+00 |

---

### print_profile_schema ([source](macros/print_profile_schema.sql))

Prints a `schema.yml` to stdout with all columns and their profile data embedded as `meta` properties.

#### Arguments

| Argument | Required | Default | Description |
|---|---|---|---|
| `relation` | either `relation` or `relation_name` | | Relation object |
| `relation_name` | either `relation` or `relation_name` | | Relation name |
| `schema` | no | target schema | Schema where `relation_name` exists |
| `database` | no | target database | Database where `relation_name` exists |
| `exclude_measures` | no | `[]` | List of measures to exclude from the profile |
| `include_columns` | no | `[]` (all) | Columns to include. Cannot be used together with `exclude_columns`. |
| `exclude_columns` | no | `[]` | Columns to exclude. Cannot be used together with `include_columns`. |
| `model_description` | no | `""` | Model description to include in the schema |
| `column_description` | no | `""` | Column description to include for each column |
| `where_clause` | no | | SQL `WHERE` clause to filter records before profiling |

#### Usage

```bash
dbt run-operation print_profile_schema --args '{"relation_name": "customers"}'
```

#### Example output

```yaml
version: 2
models:
- name: customers
  description: ''
  columns:
  - name: customer_id
    description: ''
    meta:
      data_type: int64
      row_count: 100.0
      not_null_proportion: 1.0
      distinct_proportion: 1.0
      distinct_count: 100.0
      is_unique: 1.0
      min: '1'
      max: '100'
      avg: 50.5
      std_dev_population: 28.86607004772212
      std_dev_sample: 29.01149197588202
      profiled_at: '2022-01-13 10:08:18.446822+00'
  - name: first_order
    description: ''
    meta:
      data_type: date
      row_count: 100.0
      not_null_proportion: 0.62
      distinct_proportion: 0.46
      distinct_count: 46.0
      is_unique: 0.0
      min: '2018-01-01'
      max: '2018-04-07'
      avg: null
      std_dev_population: null
      std_dev_sample: null
      profiled_at: '2022-01-13 10:08:18.446822+00'
  # ... remaining columns
```

This is what the profile looks like in the dbt docs UI:

<p align="center">
  <img src=".github/dbt_docs_example.png" alt="dbt docs example"/>
</p>

---

### print_profile_docs ([source](macros/print_profile_docs.sql))

> ❗ **Does not work in dbt Cloud.** The profile doesn't display in the cloud console log because the underlying [print_table()](https://agate.readthedocs.io/en/1.6.1/api/table.html#agate.Table.print_table) method is disabled.

Prints a relation profile as a Markdown table wrapped in a Jinja `docs` block to stdout. Intended to be used as part of the [dbt docs workflow](#using-profiles-in-dbt-docs).

#### Arguments

| Argument | Required | Default | Description |
|---|---|---|---|
| `relation` | either `relation` or `relation_name` | | Relation object |
| `relation_name` | either `relation` or `relation_name` | | Relation name |
| `schema` | no | target schema | Schema where `relation_name` exists |
| `database` | no | target database | Database where `relation_name` exists |
| `exclude_measures` | no | `[]` | List of measures to exclude from the profile |
| `include_columns` | no | `[]` (all) | Columns to include. Cannot be used together with `exclude_columns`. |
| `exclude_columns` | no | `[]` | Columns to exclude. Cannot be used together with `include_columns`. |
| `docs_name` | no | `dbt_profiler__{{ relation_name }}` | Name of the generated `docs` block |
| `max_rows` | no | none (not truncated) | Maximum number of rows to display |
| `max_columns` | no | `7` | Maximum number of columns to display |
| `max_column_width` | no | `30` | Truncate all columns to at most this width |
| `max_precision` | no | none (not limited) | Maximum precision for number types |
| `where_clause` | no | | SQL `WHERE` clause to filter records before profiling |

#### Usage

```bash
dbt run-operation print_profile_docs --args '{"relation_name": "customers"}'
```

#### Example output

```
{% docs dbt_profiler__customers %}
| column_name             | data_type | not_null_proportion | distinct_proportion | distinct_count | is_unique | min        | max        |
| ----------------------- | --------- | ------------------- | ------------------- | -------------- | --------- | ---------- | ---------- |
| customer_id             | int64     |                1.00 |                1.00 |            100 |         1 | 1          | 100        |
| first_order             | date      |                0.62 |                0.46 |             46 |         0 | 2018-01-01 | 2018-04-07 |
| most_recent_order       | date      |                0.62 |                0.52 |             52 |         0 | 2018-01-09 | 2018-04-09 |
| number_of_orders        | int64     |                0.62 |                0.04 |              4 |         0 | 1          | 5          |
| customer_lifetime_value | float64   |                0.62 |                0.35 |             35 |         0 | 1          | 99         |
{% enddocs %}
```

## Using profiles in dbt docs

There are two ways to embed profiles in dbt docs: via `meta` properties (see [print_profile_schema](#print_profile_schema-source)) or via `doc` blocks. The `doc` block approach is recommended because it keeps profile data out of `schema.yml` and lets profiles be updated independently.

### Setup

**1.** Add a `docs` folder to `dbt_project.yml`:

```yaml
model-paths: ["models", "docs"]
```

**2.** Run `print_profile_docs` and save the output to a file:

```bash
# docs/dbt_profiler/customers.md
dbt run-operation print_profile_docs --args '{"relation_name": "customers"}'
```

> Note: store the output in a variable before redirecting to a file. Piping directly (e.g. `dbt run-operation ... > customers.md`) will empty the file before dbt compiles the project, causing an error if the `doc` block is already referenced. See the example [update-relation-profile.sh](update-relation-profile.sh) script.

**3.** Reference the `doc` block in your model description:

```yaml
version: 2

models:
  - name: customers
    description: |
      Represents a customer.

      `dbt-profiler` results:

      {{ doc("dbt_profiler__customers") }}
    columns:
      - name: customer_id
        tests:
          - not_null
          - unique
```

## Automating profile updates with CI

The `doc` block approach makes it straightforward to keep profiles up to date via a scheduled CI job:

1. List the models to profile (e.g. `dbt list --output name -m ${node_selection}`)
2. For each model, run `print_profile_docs` and write the output to `docs/dbt_profiler/${relation_name}.md`
3. Open a pull request for the updated profiles (e.g. using the [create-pull-request](https://github.com/peter-evans/create-pull-request) GitHub Action)

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. For significant changes, open an issue first to discuss the approach.

You can also reach the maintainers in the [#tools-dbt-profiler](https://getdbt.slack.com/archives/C094X0V0Y4V) channel on dbt Slack.

## License

[Apache License 2.0](LICENSE)
