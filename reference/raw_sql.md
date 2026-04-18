# Run a raw SQL query and return a lazy table

An escape hatch for SQL that can't easily be expressed through the
`dplyr`/`dbplyr` translation layer, analogous to `ibis`'s `con.sql()`.
Useful for DuckDB-specific syntax such as `UNION ALL BY NAME`, which
aligns columns by name across queries with differing schemas and fills
missing columns with NULL.

## Usage

``` r
raw_sql(query, tblname = NULL, conn = cached_connection())
```

## Arguments

- query:

  A character string of SQL to execute against `conn`.

- tblname:

  Optional name for a temporary view. If `NULL` (default), the query is
  used as an inline subquery and nothing is persisted. If supplied, a
  `CREATE OR REPLACE TEMPORARY VIEW <tblname>` is created, which can
  then be referenced by name in subsequent queries.

- conn:

  A duckdb connection, by default
  [`cached_connection()`](https://cboettig.github.io/duckdbfs/reference/cached_connection.md).

## Value

A lazy [`dplyr::tbl`](https://dplyr.tidyverse.org/reference/tbl.html)
object that can be further refined with `dplyr` verbs or collected into
memory with
[`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html).

## Examples

``` r
if (FALSE) { # interactive()
# Combine two datasets with differing schemas using UNION ALL BY NAME
base <- paste0("https://github.com/duckdb/duckdb/raw/main/",
              "data/parquet-testing/hive-partitioning/union_by_name/")
a <- open_dataset(paste0(base, "x=1/f1.parquet"), tblname = "a")
b <- open_dataset(paste0(base, "x=2/f2.parquet"), tblname = "b")

raw_sql("SELECT * FROM a UNION ALL BY NAME SELECT * FROM b")
}
```
