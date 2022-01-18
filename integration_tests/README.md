# Running tests locally (postgres)

1. Configure a `postgres` connection profile in your `profiles.yml` file (see [Configuring your profile](https://docs.getdbt.com/dbt-cli/configure-your-profile))
2. Start a local PostgreSQL instance using docker-compose: `docker-compose up -d`
3. Run tests against the local PostgreSQL instance:

```bash
dbt seed -t postgres
dbt run -t postgres
dbt test -t postgres
```
