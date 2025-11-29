# duckdb configuration

duckdb configuration

## Usage

``` r
duckdb_config(..., conn = cached_connection())
```

## Arguments

- ...:

  named argument of the parameters to set, see examples see all possible
  configuration options at
  <https://duckdb.org/docs/sql/configuration.html>

- conn:

  A connection to a database.

## Value

the active duckdb connection, invisibly

## Details

Note: in I/O bound tasks such as streaming data, it can be helpful to
set thread parallelism significantly higher than available CPU cores.

## See also

duckdb_reset, duckdb_get_config

## Examples

``` r
if (FALSE) { # interactive()
duckdb_config(threads = 1, memory_limit = '10GB')
duckdb_get_config("threads")
duckdb_reset("threads")
}
```
