
<!-- README.md is generated from README.Rmd. Please edit that file -->

# duckdbfs

<!-- badges: start -->

[![R-CMD-check](https://github.com/cboettig/duckdbfs/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/cboettig/duckdbfs/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

duckdbfs is a simple wrapper around the `duckdb` package to facilitate
working with the construction of a single lazy table (SQL connection)
from a set of file paths, URLs, or S3 URIs.

## Installation

You can install the development version of duckdbfs from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("cboettig/duckdbfs")
```

## Example

Imagine we have a collection of URLs to files we want to combine into a
single tibble in R. The files could be parquet or csv, and some files
may have additional columns not present in other files. The combined
data may be very large, potentially bigger than available RAM or slow to
download completely, but we may only want a subset using methods like
`dplyr::filter()` or `dplyr::summarise()`.

``` r
base <- paste0("https://github.com/duckdb/duckdb/raw/master/",
               "data/parquet-testing/hive-partitioning/union_by_name/")
f1 <- paste0(base, "x=1/f1.parquet")
f2 <- paste0(base, "x=1/f2.parquet")
f3 <- paste0(base, "x=2/f2.parquet")
urls <- c(f1,f2,f3)
```

We can easily read this data into duckdb by passing a vector of URLs

``` r
library(duckdbfs)

ds <- open_dataset(urls)
#> [1] "Making a duckdb connection!"
ds
#> # Source:   table<tkebhpypqcxzwaa> [3 x 4]
#> # Database: DuckDB 0.7.1 [unknown@Linux 5.17.15-76051715-generic:R 4.2.3/:memory:]
#>       i     j x         k
#>   <int> <int> <chr> <int>
#> 1    42    84 1        NA
#> 2    42    84 1        NA
#> 3    NA   128 2        33
```

Use `filter()`, `select()`, etc from dplyr to subset and process data –
[any method supported by
dbpylr](https://dbplyr.tidyverse.org/reference/index.html). Then use
`dplyr::collect()` to trigger evaluation and ingest results of the query
into R.

## Mechanism / motivation

This package simply creates a duckdb connection, ensures the httpfs
extension is installed if necessary, and constructs a `VIEW` using
duckdb’s `parquet_scan()` or `read_csv_auto()` methods and associated
options. It then returns a `dplyr::tbl()` for the resulting view. Though
straightforward, this process is substantially more verbose than the
analogous single function call provided by `arrow::open_dataset()` due
mostly to the necessary string manipulation to construct the VIEW as a
SQL statement. I’ve used this pattern a lot, especially when arrow is
not an option (http data) or has substantially worse performance (many
S3 URIs).

## Advanced notes

This is very similar to the behaviour of `arrow::open_dataset()`, with a
few exceptions:

- at this time, `arrow` does not support access over HTTP – remote
  sources must be in an S3 or GC-based object store.
- With local filesystem or S3 paths, `duckdb` can support “globbing” and
  recursive globbing, e.g. `open_dataset(data/**/*.parquet)`. In
  contrast, http(s) URLs will always require the full vector since an
  `ls()` method is not possible. However, note that even with URLs,
  `duckdb` can automatically populate columns given only by hive
  structure. Also note that passing a vector of paths can be
  significantly faster than globbing with S3 sources where the `ls()`
  operation is relatively expensive.
- at this time, the duckdb httpfs filesystem extension in R does not
  support Windows.

## Performance notes

On slow network connections or when accessing a remote table repeatedly,
it may improve performance to create a local copy of the table rather
than perform all operations over the network. The simplest way to do
this is by setting the `mode = "TABLE"` instead of “VIEW” on open
dataset. It is probably desirable to pass a duckdb connection backed by
persistent disk location in this case instead of the default
`cached_connection()` unless available RAM is not limiting.
