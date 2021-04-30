# dbt-profiler (alpha)

**NOTE: This is a Work in Progress, please do not integrate any of the implemented macros with production workflows.**


Macros that profile dbt relations and create model schema YAML definitions containing said profiles.

# Macros

## print_profile ([source](macros/print_profile.sql))

This macro prints a relation profile to `stdout`.

### Arguments
* `relation_name` (required): Relation name

### Usage
Call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):
```bash
dbt run-operation print_profile --args '{"relation_name": "customers"}'
```

### Example output

| column_name             | data_type | not_null_proportion | distinct_proportion | distinct_count | is_unique | profiled_at                   |
| ----------------------- | --------- | ------------------- | ------------------- | -------------- | --------- | ----------------------------- |
| customer_id             | integer   |                1.00 |                1.00 |            100 |      True | 2021-04-28 11:36:59.431462+00 |
| first_order             | date      |                0.62 |                0.46 |             46 |     False | 2021-04-28 11:36:59.431462+00 |
| most_recent_order       | date      |                0.62 |                0.52 |             52 |     False | 2021-04-28 11:36:59.431462+00 |
| number_of_orders        | bigint    |                0.62 |                0.04 |              4 |     False | 2021-04-28 11:36:59.431462+00 |
| customer_lifetime_value | bigint    |                0.62 |                0.35 |             35 |     False | 2021-04-28 11:36:59.431462+00 |


## print_profile_schema ([source](macros/print_profile_schema.sql))

This macro prints a relation schema YAML to `stdout` containing all columns and their profiles.

### Arguments
* `relation_name` (required): Relation name
* `model_description` (optional): Model description included in the schema
* `column_description` (optional): Column descriptions included in the schema

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
  - name: customer_id
    description: ''
    meta:
      data_type: integer
      not_null_proportion: 1.0
      distinct_proportion: 1.0
      distinct_count: 100.0
      is_unique: true
      profiled_at: '2021-04-28 11:36:59.431462+00'
  - name: first_order
    description: ''
    meta:
      data_type: date
      not_null_proportion: 0.62
      distinct_proportion: 0.46
      distinct_count: 46.0
      is_unique: false
      profiled_at: '2021-04-28 11:36:59.431462+00'
  - name: most_recent_order
    description: ''
    meta:
      data_type: date
      not_null_proportion: 0.62
      distinct_proportion: 0.52
      distinct_count: 52.0
      is_unique: false
      profiled_at: '2021-04-28 11:36:59.431462+00'
  - name: number_of_orders
    description: ''
    meta:
      data_type: bigint
      not_null_proportion: 0.62
      distinct_proportion: 0.04
      distinct_count: 4.0
      is_unique: false
      profiled_at: '2021-04-28 11:36:59.431462+00'
  - name: customer_lifetime_value
    description: ''
    meta:
      data_type: bigint
      not_null_proportion: 0.62
      distinct_proportion: 0.35
      distinct_count: 35.0
      is_unique: false
      profiled_at: '2021-04-28 11:36:59.431462+00'
```

This what the profile looks like on the dbt docs site:

<p align="center">
 <img src=".github/dbt_docs_example.png" alt="dbt docs example"/>
</p>


## get_profile ([source](macros/get_profile.sql))

This macro returns a relation profile as an [agate.Table](https://agate.readthedocs.io/en/1.6.1/api/table.html#module-agate.table). The macro does not print anything to `stdout` and therefore is not meant to be used as a standalone [operation](https://docs.getdbt.com/docs/using-operations).

### Arguments
* `relation_name` (required): Relation name

### Usage

Call this macro from another macro or dbt model:

```bash
{{ get_profile(relation_name="customers") }}
```