
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

## Quickstart

``` r
library(duckdbfs)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

Imagine we have a collection of URLs to files we want to combine into a
single tibble in R. The files could be parquet or csv, and some files
may have additional columns not present in other files. The combined
data may be very large, potentially bigger than available RAM or slow to
download completely, but we may only want a subset using methods like
`dplyr::filter()` or `dplyr::summarise()`.

``` r
base <- paste0("https://github.com/duckdb/duckdb/raw/main/",
               "data/parquet-testing/hive-partitioning/union_by_name/")
f1 <- paste0(base, "x=1/f1.parquet")
f2 <- paste0(base, "x=1/f2.parquet")
f3 <- paste0(base, "x=2/f2.parquet")
urls <- c(f1,f2,f3)
```

We can easily access this data without downloading by passing a vector
of URLs. Note that if schemas (column names) do not match, we must
explicitly request `duckdb` join the two schemas. Leave this as default,
`FALSE` when not required to achieve much better performance.

``` r
ds <- open_dataset(urls, unify_schemas = TRUE)
ds
#> # Source:   table<kkkmtknecathhep> [3 x 4]
#> # Database: DuckDB 0.8.1 [unknown@Linux 6.4.6-76060406-generic:R 4.3.1/:memory:]
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

## S3-based access

We can also access remote data over the S3 protocol. An advantage of S3
is that unlike https, it can discover all files in a given folder, so we
don’t have to list them individually. This is particularly convenient
for accessing large, partitioned datasets, like GBIF: (nearly 200 GB of
data split across more than 2000 parquet files)

``` r
parquet <- "s3://gbif-open-data-us-east-1/occurrence/2023-06-01/occurrence.parquet"
duckdb_s3_config()
gbif <- open_dataset(parquet, anonymous = TRUE, s3_region="us-east-1")
```

The additional configuration arguments are passed to the helper function
`duckdb_s3_config()` to set access credentials and configure other
settings, like alternative endpoints (for use with S3-compliant systems
like [minio](https://min.io)). Of course it also possible to set these
ahead of time by calling `duckdb_s3_config()` directly. Many of these
settings can also be passed along more compactly using the URI query
notation found in the `arrow` package. For instance, we can request
anonymous access to a bucket on an alternative endpoint as:

``` r
efi <- open_dataset("s3://anonymous@neon4cast-scores/parquet/aquatics?endpoint_override=data.ecoforecast.org")
```

## Spatial data

`duckdb` can also understand a wide array of spatial data queries for
spatial vector data, similar to operations found in the popular `sf`
package. Most spatial query operations require an geometry column that
expresses the simple feature geometry in `duckdb`’s internal geometry
format (nearly but not exactly WKB). A common pattern will first
generate the geometry column from raw columns, such as `latitude` and
`lognitude` columns, using the `duckdb` implementation of the a method
familiar to postgis, `ST_Point`:

``` r
spatial_ex <- paste0("https://raw.githubusercontent.com/cboettig/duckdbfs/",
                     "main/inst/extdata/spatial-test.csv") |>
  open_dataset(format = "csv") 

spatial_ex |>
  mutate(geometry = ST_Point(longitude, latitude)) |>
  to_sf()
#> Simple feature collection with 10 features and 3 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 1 ymin: 1 xmax: 10 ymax: 10
#> CRS:           NA
#>    site latitude longitude      geometry
#> 1     a        1         1   POINT (1 1)
#> 2     b        2         2   POINT (2 2)
#> 3     c        3         3   POINT (3 3)
#> 4     d        4         4   POINT (4 4)
#> 5     e        5         5   POINT (5 5)
#> 6     f        6         6   POINT (6 6)
#> 7     g        7         7   POINT (7 7)
#> 8     h        8         8   POINT (8 8)
#> 9     i        9         9   POINT (9 9)
#> 10    j       10        10 POINT (10 10)
```

Recall that when used against any sort of external database like
`duckdb`, most `dplyr` functions like `dplyr::mutate()` are being
transcribed into SQL by `dbplyr`, and not actually ever run in R. This
allows us to seamlessly pass along spatial functions like `ST_Point`,
despite this not being an available R function. The `to_sf()` coercion
will parse its input into a SQL query that gets passed to `duckdb`, and
the return object will be collected through `sf::st_read`, returning an
(in-memory) `sf` object.

Note that we can add arbitrary spatial functions that operate on this
geometry, provided we do so prior to our call to `to_sf`. For instance,
here we first create our geometry column from lat/lon columns, and then
compute the distance from each element to a spatial point:

``` r
spatial_ex |> 
  mutate(geometry = ST_Point(longitude, latitude)) |>
  mutate(dist = ST_Distance(geometry, ST_Point(0,0))) |> 
  to_sf()
#> Simple feature collection with 10 features and 4 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 1 ymin: 1 xmax: 10 ymax: 10
#> CRS:           NA
#>    site latitude longitude      dist      geometry
#> 1     a        1         1  1.414214   POINT (1 1)
#> 2     b        2         2  2.828427   POINT (2 2)
#> 3     c        3         3  4.242641   POINT (3 3)
#> 4     d        4         4  5.656854   POINT (4 4)
#> 5     e        5         5  7.071068   POINT (5 5)
#> 6     f        6         6  8.485281   POINT (6 6)
#> 7     g        7         7  9.899495   POINT (7 7)
#> 8     h        8         8 11.313708   POINT (8 8)
#> 9     i        9         9 12.727922   POINT (9 9)
#> 10    j       10        10 14.142136 POINT (10 10)
```

For more details including a complete list of the dozens of spatial
operations currently supported and notes on performance and current
limitations, see the [duckdb spatial
docs](https://github.com/duckdblabs/duckdb_spatial)

## Writing datasets

Like `arrow::write_dataset()`, `duckdbfs::write_dataset()` can write
partitioned parquet files to local disks and also directly to an S3
bucket. Partitioned writes should take advantage of threading. Partition
variables can be specified explicitly, or any `dplyr` grouping variables
will be used by default:

``` r
mtcars |> group_by(cyl, gear) |> write_dataset(tempfile())
```

## Local files

Of course, `open_dataset()` and `write_dataset()` also be used with
local files. Remember that parquet format is not required, we can read
csv files (including multiple and hive-partitioned csv files).

``` r
write.csv(mtcars, "mtcars.csv", row.names=FALSE)
lazy_cars <- open_dataset("mtcars.csv", format = "csv")
```

## Limitations

- ***NOTE***: at this time, the duckdb httpfs file system extension in R
  does not support Windows.

## Mechanism / motivation

This package simply creates a duckdb connection, ensures the `httpfs`
and `spatial` extensions are installed if necessary, sets the S3
configuration, and then constructs a `VIEW` using duckdb’s
`parquet_scan()` or `read_csv_auto()` methods and associated options. It
then returns a `dplyr::tbl()` for the resulting view. Though
straightforward, this process is substantially more verbose than the
analogous single function call provided by `arrow::open_dataset()` due
mostly to the necessary string manipulation to construct the VIEW as a
SQL statement. I’ve used this pattern a lot, especially when arrow is
not an option (http data) or has substantially worse performance (many
S3 URIs).

## Advanced notes

This is very similar to the behavior of `arrow::open_dataset()`, with a
few exceptions:

- at this time, `arrow` does not support access over HTTP – remote
  sources must be in an S3 or GC-based object store.
- With local file system or S3 paths, `duckdb` can support “globbing” at
  any point in the path, e.g. `open_dataset(data/*/subdir)`. (Like
  arrow, `duckdbfs::open_dataset` will assume recursive path discovery
  on directories). Note that http(s) URLs will always require the full
  vector since a `ls()` method is not possible. Even with URLs or
  vector-based paths, `duckdb` can automatically populate column names
  given only by hive structure when `hive_style=TRUE` (default). Note
  that passing a vector of paths can be significantly faster than
  globbing with S3 sources where the `ls()` operation is relatively
  expensive when there are many partitions.

## Performance notes

- In some settings, `duckdbfs::open_dataset` can give substantially
  better performance (orders of magnitude) than `arrow::open_dataset()`,
  while in other settings it may be comparable or even slower. Package
  versions, system libraries, network architecture, remote storage
  performance, network traffic, and other factors can all influence
  performance, making precise benchmark comparisons in real-world
  contexts difficult.
- On slow network connections or when accessing a remote table
  repeatedly, it may improve performance to create a local copy of the
  table rather than perform all operations over the network. The
  simplest way to do this is by setting the `mode = "TABLE"` instead of
  “VIEW” on open dataset. It is probably desirable to pass a duckdb
  connection backed by persistent disk location in this case instead of
  the default `cached_connection()` unless available RAM is not
  limiting.
- `unify_schema` is very computationally expensive. Ensuring all
  files/partitions match schema in advance or processing different files
  separately can greatly improve performance.
