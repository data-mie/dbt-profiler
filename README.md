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