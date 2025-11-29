# duckdb reset configuration to default

duckdb reset configuration to default

## Usage

``` r
duckdb_get_config(x = NULL, conn = cached_connection())
```

## Arguments

- x:

  parameter name. Omit to see a table of all settings.

- conn:

  A connection to a database.

## See also

duckdb_config, duckdb_get_config

## Examples

``` r
if (FALSE) { # interactive()
# Full config table
duckdb_get_config()

# look up single config value
duckdb_get_config("threads")

# set a different value, test, reset.
duckdb_config(threads = 10)
duckdb_get_config("threads")
duckdb_reset("threads")
}
```
