# close connection

close connection

## Usage

``` r
close_connection(conn = cached_connection())
```

## Arguments

- conn:

  a duckdb connection (leave blank) Closes the invisible cached
  connection to duckdb

## Value

returns nothing.

## Details

Shuts down connection before gc removes it. Then clear cached reference
to avoid using a stale connection This avoids complaint about connection
being garbage collected.

## Examples

``` r
if (FALSE) { # interactive()

close_connection()
}
```
