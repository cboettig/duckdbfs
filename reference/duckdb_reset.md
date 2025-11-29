# duckdb reset configuration to default

duckdb reset configuration to default

## Usage

``` r
duckdb_reset(x, conn = cached_connection())
```

## Arguments

- x:

  parameter name

- conn:

  A connection to a database.

## See also

duckdb_config, duckdb_get_config

## Examples

``` r
if (FALSE) { # interactive()
duckdb_config(threads = 10)
duckdb_get_config("threads")
duckdb_reset("threads")
}
```
