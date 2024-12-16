
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
#> # Source:   table<f1> [3 x 4]
#> # Database: DuckDB v0.10.1 [unknown@Linux 6.6.10-76060610-generic:R 4.3.2/:memory:]
#>       i     j     x     k
#>   <int> <int> <dbl> <int>
#> 1    42    84     1    NA
#> 2    42    84     1    NA
#> 3    NA   128     2    33
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
package. See [the list of supported
functions](https://github.com/duckdb/duckdb-spatial#supported-functions)
for details. Most spatial query operations require an geometry column
that expresses the simple feature geometry in `duckdb`’s internal
geometry format (nearly but not exactly WKB).

### Generating spatial data from tabular

A common pattern will first generate the geometry column from raw
columns, such as `latitude` and `lognitude` columns, using the `duckdb`
implementation of the a method familiar to postgis, `st_point`:

``` r
spatial_ex <- paste0("https://raw.githubusercontent.com/cboettig/duckdbfs/",
                     "main/inst/extdata/spatial-test.csv") |>
  open_dataset(format = "csv") 

spatial_ex |>
  mutate(geometry = st_point(longitude, latitude)) |>
  mutate(dist = st_distance(geometry, st_point(0,0))) |> 
  to_sf(crs = 4326)
#> Simple feature collection with 10 features and 4 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 1 ymin: 1 xmax: 10 ymax: 10
#> Geodetic CRS:  WGS 84
#>    site latitude longitude      dist          geom
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

Note that when coercing generic tabular such as CSV into spatial data,
the user is responsible for specifying the coordinate reference system
(crs) used by the columns. For instance, in this case our data is
latitude-longitude, so we specify the corresponding EPSG code. This is
optional (sf allows objects to have unknown CRS), but advisable.

Recall that when used against any sort of external database like
`duckdb`, most `dplyr` functions like `dplyr::mutate()` are being
transcribed into SQL by `dbplyr`, and not actually ever run in R. This
allows us to seamlessly pass along spatial functions like `st_point`,
despite this not being an available R function. (Also note that SQL is
not case-sensitive, so this function is also written as `ST_Point`).
Optionally, we can do additional operations on this geometry column,
such as computing distances (`st_distance` shown here), spatial filters,
and so forth. The `to_sf()` coercion will parse its input into a SQL
query that gets passed to `duckdb`, and the return object will be
collected through `sf::st_read`, returning an (in-memory) `sf` object.

For more details including a complete list of the dozens of spatial
operations currently supported and notes on performance and current
limitations, see the [duckdb spatial
docs](https://github.com/duckdb/duckdb-spatial)

### Reading spatial vector files

The `duckdb` spatial package can also use GDAL to read large spatial
vector files. This includes support for remote files. This means that we
can easily subset columns from a wide array of potentially remote file
types and filter on rows and columns, and perform many spatial
operations without ever reading the entire objects into memory in R.

``` r
url <- "https://github.com/cboettig/duckdbfs/raw/main/inst/extdata/world.fgb"
countries <- open_dataset(url, format = "sf")
```

Note that `open_dataset()` always returns a lazy remote table – we have
not yet downloaded the data, let alone read it into R. We simply have a
connection allowing us to stream the data.

We can examine the spatial metadata associated with this remote dataset
using the duckdbfs spatial helper function, `st_read_meta`,

``` r
countries_meta <- st_read_meta(url)
countries_meta
#> # A tibble: 1 × 7
#>   feature_count geom_column_name geom_type     name  code  wkt             proj4
#>           <dbl> <chr>            <chr>         <chr> <chr> <chr>           <chr>
#> 1           177 geom             Multi Polygon EPSG  4326  "GEOGCS[\"WGS … +pro…
```

Because this is a small dataset, we can bring the entire data into R (in
memory) using `to_sf()`, specifying the CRS indicated in this metadata:

``` r
in_mem <- countries |> to_sf(crs = countries_meta$wkt)
```

However, we can also do a wide range of spatial observations without
importing the data. This can be particularly helpful when working with
very large datasets. For example: which country polygon contains
Melbourne?  
Note the result is still a lazy read, we haven’t downloaded or read in
the full spatial data object.

``` r
library(sf)
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is TRUE
melbourne <- st_point(c(144.9633, -37.814)) |> st_as_text()

countries |> 
  filter(st_contains(geom, ST_GeomFromText({melbourne})))
#> # Source:   SQL [1 x 16]
#> # Database: DuckDB v0.10.1 [unknown@Linux 6.6.10-76060610-generic:R 4.3.2/:memory:]
#>   iso_a3 name      sovereignt continent    area  pop_est pop_est_dens economy   
#>   <chr>  <chr>     <chr>      <chr>       <dbl>    <dbl>        <dbl> <chr>     
#> 1 AUS    Australia Australia  Oceania   7682300 21262641         2.77 2. Develo…
#> # ℹ 8 more variables: income_grp <chr>, gdp_cap_est <dbl>, life_exp <dbl>,
#> #   well_being <dbl>, footprint <dbl>, inequality <dbl>, HPI <dbl>, geom <list>
```

As before, we use `to_sf()` to read in the query results as a native
(in-memory) `sf` object:

``` r
sf_obj <- countries |> filter(continent == "Africa") |> to_sf() 
plot(sf_obj["name"])
```

<img src="man/figures/README-unnamed-chunk-10-1.png" width="100%" />

## Spatial joins

One very common operation are spatial joins, which can be a very
powerful way to subset large data. Lets consider a set of point
geometries representing the coordinates of major cities around the
world:

``` r
url_cities <- "https://github.com/cboettig/duckdbfs/raw/spatial-read/inst/extdata/metro.fgb"
cities <- open_dataset(url_cities, format="sf")
```

Note that metadata must be read directly from the source file, it is not
embedded into the duckdb table view. Before combining this data with the
countries data, we confirm that the CRS is the same for both datasets:

``` r
countries_meta$proj4
#> [1] "+proj=longlat +datum=WGS84 +no_defs"
st_read_meta(url_cities)$proj4
#> [1] "+proj=longlat +datum=WGS84 +no_defs"
```

For instance, we can return all points (cities) within a collection of
polygons (all country boundaries in Oceania continent):

``` r
countries |>
   dplyr::filter(continent == "Oceania") |>
   spatial_join(cities, by = "st_intersects", join="inner") |>
   select(name_long, sovereignt, pop2020) 
#> # Source:   SQL [6 x 3]
#> # Database: DuckDB v0.10.1 [unknown@Linux 6.6.10-76060610-generic:R 4.3.2/:memory:]
#>   name_long sovereignt  pop2020
#>   <chr>     <chr>         <dbl>
#> 1 Brisbane  Australia   2388517
#> 2 Perth     Australia   2036118
#> 3 Sydney    Australia   4729406
#> 4 Adelaide  Australia   1320783
#> 5 Auckland  New Zealand 1426070
#> 6 Melbourne Australia   4500501
```

Possible [spatial
joins](https://postgis.net/workshops/postgis-intro/spatial_relationships.html)
include:

| Function            | Description                                                                                                   |
|---------------------|---------------------------------------------------------------------------------------------------------------|
| st_intersects       | Geometry A intersects with geometry B                                                                         |
| st_disjoint         | The complement of intersects                                                                                  |
| st_within           | Geometry A is within geometry B (complement of contains)                                                      |
| st_dwithin          | Geometries are within a specified distance, expressed in the same units as the coordinate reference system.   |
| st_touches          | Two polygons touch if the that have at least one point in common, even if their interiors do not touch.       |
| st_contains         | Geometry A entirely contains to geometry B. (complement of within)                                            |
| st_containsproperly | stricter version of `st_contains` (boundary counts as external)                                               |
| st_covers           | geometry B is inside or on boundary of A. (A polygon covers a point on its boundary but does not contain it.) |
| st_overlaps         | geometry A intersects but does not completely contain geometry B                                              |
| st_equals           | geometry A is equal to geometry B                                                                             |
| st_crosses          | Lines or points in geometry A cross geometry B.                                                               |

Note that while SQL functions are not case-sensitive, `spatial_join`
expects lower-case names.

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
