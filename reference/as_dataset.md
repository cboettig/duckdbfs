# as_dataset

Push a local (in-memory) dataset into a the duckdb database as a table.
This enables it to share the connection source with other data. This is
equivalent to the behavior of copy=TRUE on many (but not all) of the
two-table verbs in dplyr.

## Usage

``` r
as_dataset(df, conn = cached_connection())
```

## Arguments

- df:

  a local data frame. Otherwise will be passed back without side effects

- conn:

  A connection to a database.

## Value

a remote [`dplyr::tbl`](https://dplyr.tidyverse.org/reference/tbl.html)
connection to the table.
