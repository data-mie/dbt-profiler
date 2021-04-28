# dbt-profiler (alpha)

**NOTE: This is a Work in Progress, please do not integrate any of the implemented macros with production workflows.**


Macros that profile dbt relations and create model schema YAML definitions containing said profiles.

# Macros
## profile_relation ([source](macros/profile_relation.sql))

This macro generates YAML for a [Relation](https://docs.getdbt.com/reference/dbt-classes#relation) which you can then paste into a schema file.

### Arguments
* `relation_name` (required): Relation name

### Usage:
Call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):
```bash
dbt run-operation profile_relation --args '{"relation_name": "customers"}'
```

### Example output:

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
 <img src=".github/dbt_docs_example.png" alt="dbt docs example" width=600/>
</p>
