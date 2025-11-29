# as_view

Create a View of the current query. This can be an effective way to
allow a query chain to remain lazy

## Usage

``` r
as_view(x, tblname = tmp_tbl_name(), conn = cached_connection())
```

## Arguments

- x:

  a duckdb spatial dataset

- tblname:

  The name of the table to create in the database.

- conn:

  A connection to a database.

## Examples

``` r
if (FALSE) { # interactive()
path <- system.file("extdata/spatial-test.csv", package="duckdbfs")
df <- open_dataset(path)
library(dplyr)

df |> filter(latitude > 5) |> as_view()
}
```
