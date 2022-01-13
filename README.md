# dbt-profiler

`dbt-profiler` implements dbt macros for profiling database relations and creating  `doc` blocks and table schemas (`schema.yml`) containing said profiles. A calculated profile contains the following measures for each column in a relation:

* `column_name`: Name of the column
* `data_type`: Data type of the column
* `not_null_proportion`: Proportion of column values that are not `NULL` (e.g., `0.62` means that 62% of the values are populated while 38% are `NULL`)
* `distinct_proportion`: Proportion of unique column values (e.g., `1` means that 100% of the values are unique)
* `distinct_count`: Count of unique column values
* `is_unique`: True if all column values are unique
* `min`*: Minimum column value
* `max`*: Maximum column value
* `avg`**: Average column value
* `std_dev_population`**: Population standard deviation
* `std_dev_sample`**: Sample standard deviation
* `profiled_at`: Profile calculation date and time

`*` numeric, date and time columns only
`**` numeric columns only

## Purpose 

`dbt-profiler` aims to provide the following:

1. [get_profile](#get_profile-source) macro for generating profiling SQL queries that can be used as dbt models or ad-hoc queries
2. [print_profile](#print_profile-source) macro for ad-hoc model profiling to support data exploration 
3. Describe a mechanism to include model profiles in [dbt docs](https://docs.getdbt.com/docs/building-a-dbt-project/documentation)

For the third point there are at least two options: 

1. `meta` properties, and 
2. `doc` blocks. 

An example of the first is implemented in the [print_profile_schema](#print_profile_schema-source) macro. The second can be achieved with the following pattern:

1. Use [print_profile_docs](#print_profile_docs-source) macro to generate the profile as a Markdown table wrapped in a Jinja `docs` macro
2. Copy the output to a `docs/dbt_profiler/<model>.md` file
```
# docs/dbt_profiler/customer.md
{% docs dbt_profiler__customer %}

| column_name             | data_type | not_null_proportion | distinct_proportion | distinct_count | is_unique | min        | max        |                 avg |  std_dev_population |      std_dev_sample | profiled_at                   |
| ----------------------- | --------- | ------------------- | ------------------- | -------------- | --------- | ---------- | ---------- | ------------------- | ------------------- | ------------------- | ----------------------------- |
| customer_id             | int64     |                1.00 |                1.00 |            100 |         1 | 1          | 100        | 50.5000000000000000 | 28.8660700477221200 | 29.0114919758820200 | 2022-01-13 10:14:48.300040+00 |
| first_order             | date      |                0.62 |                0.46 |             46 |         0 | 2018-01-01 | 2018-04-07 |                     |                     |                     | 2022-01-13 10:14:48.300040+00 |
| most_recent_order       | date      |                0.62 |                0.52 |             52 |         0 | 2018-01-09 | 2018-04-09 |                     |                     |                     | 2022-01-13 10:14:48.300040+00 |
| number_of_orders        | int64     |                0.62 |                0.04 |              4 |         0 | 1          | 5          |  1.5967741935483863 |  0.7716692718648833 |  0.7779687173818426 | 2022-01-13 10:14:48.300040+00 |
| customer_lifetime_value | float64   |                0.62 |                0.35 |             35 |         0 | 1          | 99         | 26.9677419354838830 | 18.6599171435558730 | 18.8122455252636630 | 2022-01-13 10:14:48.300040+00 |

{% enddocs %}
```
3. Include the profile in a model description using the `doc` macro
```yml
version: 2

models:
  - name: customer
    description: |
      Represents a customer.
      
      `dbt-profiler` results:

      {{ doc("dbt_profiler__customer") }}
    columns:
      - name: customer_id
        tests:
          - not_null
          - unique
```

### Continuous integration (CI)

One of the advantages of the `doc` approach over the `meta` approach is that it doesn't require changes to the schema.yml except for the `doc` macro call. Once the macro call has been embedded in the schema the actual profiles can be maintained in a dedicated `dbt_profiler/` directory as Markdown files. The profile files can then be automatically updated by a CI process that runs once a week or month as follows:

1. List the models you want to profile (e.g., using `dbt list --output name -m ${node_selection}`)
2. For each model run `dbt run-operation print_profile_docs --args '{"relation_name": "'${relation_name}'", "schema": "'${schema}'"}'` and store the result in `dbt_profiler/${relation_name}.md`
  * Note that you need to store the `dbt run-operation print_profile_docs` output in e.g. a variable before piping it to the target file. Piping the output directly to a file (e.g., `dbt run-operation print_profile_docs > ${relation_name}.md`) will result in a situation where the target file is emptied before `dbt run-operation` compiles the dbt project which will throw an error if you're already referring to the `doc` block that the operation has not yet generated. See example [update-relation-profile.sh](update-relation-profile.sh) script.

3. Create a Pull Request for the updated profiles (e.g., using [create-pull-request GitHub Action](https://github.com/peter-evans/create-pull-request))

## Installation

`dbt-profiler` requires dbt version `>=0.19.2`. Check [dbt Hub](https://hub.getdbt.com/data-mie/dbt_profiler/latest/) for the latest installation instructions. 

## Supported adapters

`dbt-profiler` may work with unsupported adapters but they haven't been tested yet. If you've used `dbt-profiler` with any of the unsupported adapters I'd love to hear your feedback (e.g., create an issue, PR or hit me with with a DM on [dbt Slack](https://community.getdbt.com/)) 😊

✅ PostgreSQL

✅ BigQuery

✅ Snowflake

✅ Redshift

❌ Apache Spark

❌ Databricks

❌ Presto

# Contents
* [get_profile](#get_profile-source)
* [get_profile_table](#get_profile_table-source)
* [print_profile](#print_profile-source)
* [print_profile_schema](#print_profile_schema-source)
* [print_profile_docs](#print_profile_docs-source)


# Macros

## get_profile ([source](macros/get_profile.sql))

This macro returns a relation profile as a SQL query that can be used in a dbt model. This is handy for previewing relation profiles in dbt Cloud.

### Arguments
* `relation` (required): [Relation](https://docs.getdbt.com/reference/dbt-classes#relation) object

### Usage

Use this macro in a dbt model, using a [ref()](https://docs.getdbt.com/reference/dbt-jinja-functions/ref):

```sql
{{ dbt_profiler.get_profile(relation=ref("customers")) }}
```

Use this macro in a dbt model, using a [source()](https://docs.getdbt.com/reference/dbt-jinja-functions/source):

```sql
{{ dbt_profiler.get_profile(relation=source("jaffle_shop","customers")) }}
```

To configure the macro to be called only when dbt is in [execute](https://docs.getdbt.com/reference/dbt-jinja-functions/execute) mode:

```sql
-- depends_on: {{ ref("customers") }}
{% if execute %}
    {{ dbt_profiler.get_profile(relation=ref("customers")) }}
{% endif %}
```

## get_profile_table ([source](macros/get_profile_table.sql))

This macro returns a relation profile as an [agate.Table](https://agate.readthedocs.io/en/1.6.1/api/table.html#module-agate.table). The macro does not print anything to `stdout` and therefore is not meant to be used as a standalone [operation](https://docs.getdbt.com/docs/using-operations).

### Arguments
* `relation` (either `relation` or `relation_name` is required): Relation object
* `relation_name` (either `relation` or `relation_name` is required): Relation name
* `schema` (optional): Schema where `relation_name` exists (default: `none` i.e., target schema)
* `database` (optional): Database where `relation_name` exists (default: `none` i.e., target database)

### Usage

Call this macro from another macro or dbt model:

```sql
{% set table = dbt_profiler.get_profile_table(relation_name="customers") %}
```

## print_profile ([source](macros/print_profile.sql))

This macro prints a relation profile as a Markdown table to `stdout`.

### Arguments
* `relation` (either `relation` or `relation_name` is required): Relation object
* `relation_name` (either `relation` or `relation_name` is required): Relation name
* `schema` (optional): Schema where `relation_name` exists (default: `none` i.e., target schema)
* `database` (optional): Database where `relation_name` exists (default: `none` i.e., target database)
* `max_rows` (optional): The maximum number of rows to display before truncating the data (default: `none` i.e., not truncated)
* `max_columns` (optional): The maximum number of columns to display before truncating the data (default: `7`)
* `max_column_width` (optional): Truncate all columns to at most this width (default: `30`)
* `max_precision` (optional): Puts a limit on the maximum precision displayed for number types (default: `none` i.e., not limited)

### Usage
Call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):
```bash
dbt run-operation print_profile --args '{"relation_name": "customers"}'
```

### Example output

| column_name             | data_type | not_null_proportion | distinct_proportion | distinct_count | is_unique | min        | max        |                 avg |  std_dev_population |      std_dev_sample | profiled_at                   |
| ----------------------- | --------- | ------------------- | ------------------- | -------------- | --------- | ---------- | ---------- | ------------------- | ------------------- | ------------------- | ----------------------------- |
| customer_id             | int64     |                1.00 |                1.00 |            100 |         1 | 1          | 100        | 50.5000000000000000 | 28.8660700477221200 | 29.0114919758820200 | 2022-01-13 10:14:48.300040+00 |
| first_order             | date      |                0.62 |                0.46 |             46 |         0 | 2018-01-01 | 2018-04-07 |                     |                     |                     | 2022-01-13 10:14:48.300040+00 |
| most_recent_order       | date      |                0.62 |                0.52 |             52 |         0 | 2018-01-09 | 2018-04-09 |                     |                     |                     | 2022-01-13 10:14:48.300040+00 |
| number_of_orders        | int64     |                0.62 |                0.04 |              4 |         0 | 1          | 5          |  1.5967741935483863 |  0.7716692718648833 |  0.7779687173818426 | 2022-01-13 10:14:48.300040+00 |
| customer_lifetime_value | float64   |                0.62 |                0.35 |             35 |         0 | 1          | 99         | 26.9677419354838830 | 18.6599171435558730 | 18.8122455252636630 | 2022-01-13 10:14:48.300040+00 |


## print_profile_schema ([source](macros/print_profile_schema.sql))

This macro prints a relation schema YAML to `stdout` containing all columns and their profiles.

### Arguments
* `relation` (either `relation` or `relation_name` is required): Relation object
* `relation_name` (either `relation` or `relation_name` is required): Relation name
* `schema` (optional): Schema where `relation_name` exists (default: `none` i.e., target schema)
* `database` (optional): Database where `relation_name` exists (default: `none` i.e., target database)
* `model_description` (optional): Model description included in the schema (default: `""`)
* `column_description` (optional): Column descriptions included in the schema (default: `""`)

### Usage
Call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):
```bash
dbt run-operation print_profile_schema --args '{"relation_name": "customers"}'
```

### Example output

```yaml
version: 2
models:
- name: customers
  description: ''
  columns:
  - name: number_of_orders
    description: ''
    meta:
      data_type: int64
      row_count: 100.0
      not_null_proportion: 0.62
      distinct_proportion: 0.04
      distinct_count: 4.0
      is_unique: 0.0
      min: '1'
      max: '5'
      avg: 1.5967741935483863
      std_dev_population: 0.7716692718648833
      std_dev_sample: 0.7779687173818426
      profiled_at: '2022-01-13 10:08:18.446822+00'
  - name: customer_lifetime_value
    description: ''
    meta:
      data_type: float64
      row_count: 100.0
      not_null_proportion: 0.62
      distinct_proportion: 0.35
      distinct_count: 35.0
      is_unique: 0.0
      min: '1'
      max: '99'
      avg: 26.967741935483883
      std_dev_population: 18.659917143555873
      std_dev_sample: 18.812245525263663
      profiled_at: '2022-01-13 10:08:18.446822+00'
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
  - name: most_recent_order
    description: ''
    meta:
      data_type: date
      row_count: 100.0
      not_null_proportion: 0.62
      distinct_proportion: 0.52
      distinct_count: 52.0
      is_unique: 0.0
      min: '2018-01-09'
      max: '2018-04-09'
      avg: null
      std_dev_population: null
      std_dev_sample: null
      profiled_at: '2022-01-13 10:08:18.446822+00'
```

This what the profile looks like on the dbt docs site:

<p align="center">
 <img src=".github/dbt_docs_example.png" alt="dbt docs example"/>
</p>

## print_profile_docs ([source](macros/print_profile_docs.sql))

This macro prints a relation profile as a Markdown table wrapped in a Jinja `docs` macro to `stdout`.

### Arguments
* `relation` (either `relation` or `relation_name` is required): Relation object
* `relation_name` (either `relation` or `relation_name` is required): Relation name
* `schema` (optional): Schema where `relation_name` exists (default: `none` i.e., target schema)
* `database` (optional): Database where `relation_name` exists (default: `none` i.e., target database)
* `docs_name` (optional): `docs` macro name (default: `dbt_profiler__{{ relation_name }}`)
* `max_rows` (optional): The maximum number of rows to display before truncating the data (default: `none` i.e., not truncated)
* `max_columns` (optional): The maximum number of columns to display before truncating the data (default: `7`)
* `max_column_width` (optional): Truncate all columns to at most this width (default: `30`)
* `max_precision` (optional): Puts a limit on the maximum precision displayed for number types (default: `none` i.e., not limited)


### Usage
Call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):
```bash
dbt run-operation print_profile_docs --args '{"relation_name": "customers"}'
```

### Example output

```
{% docs dbt_profiler__customers  %}
| column_name             | data_type | not_null_proportion | distinct_proportion | distinct_count | is_unique | min        | max        |                 avg |  std_dev_population |      std_dev_sample | profiled_at                   |
| ----------------------- | --------- | ------------------- | ------------------- | -------------- | --------- | ---------- | ---------- | ------------------- | ------------------- | ------------------- | ----------------------------- |
| customer_id             | int64     |                1.00 |                1.00 |            100 |         1 | 1          | 100        | 50.5000000000000000 | 28.8660700477221200 | 29.0114919758820200 | 2022-01-13 10:14:48.300040+00 |
| first_order             | date      |                0.62 |                0.46 |             46 |         0 | 2018-01-01 | 2018-04-07 |                     |                     |                     | 2022-01-13 10:14:48.300040+00 |
| most_recent_order       | date      |                0.62 |                0.52 |             52 |         0 | 2018-01-09 | 2018-04-09 |                     |                     |                     | 2022-01-13 10:14:48.300040+00 |
| number_of_orders        | int64     |                0.62 |                0.04 |              4 |         0 | 1          | 5          |  1.5967741935483863 |  0.7716692718648833 |  0.7779687173818426 | 2022-01-13 10:14:48.300040+00 |
| customer_lifetime_value | float64   |                0.62 |                0.35 |             35 |         0 | 1          | 99         | 26.9677419354838830 | 18.6599171435558730 | 18.8122455252636630 | 2022-01-13 10:14:48.300040+00 |
{% enddocs %}
```
