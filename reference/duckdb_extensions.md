# show duckdb extensions

show duckdb extensions

## Usage

``` r
duckdb_extensions(conn = cached_connection())
```

## Arguments

- conn:

  A connection to a database.

## Value

a data frame listing all available extensions, with boolean columns
indicating which extensions are installed or loaded, and a description
of each extension.

## Examples

``` r
if (FALSE) { # interactive()
duckdb_extensions()
}
```
