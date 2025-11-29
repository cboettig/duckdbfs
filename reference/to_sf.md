# Convert output to sf object

Convert output to sf object

## Usage

``` r
to_sf(x, crs = NA, conn = cached_connection())
```

## Arguments

- x:

  a remote duckdb `tbl` (from `open_dataset`) or dplyr-pipeline thereof.

- crs:

  The coordinate reference system, any format understood by
  [`sf::st_crs`](https://r-spatial.github.io/sf/reference/st_crs.html).

- conn:

  the connection object from the tbl. Takes a duckdb table (from
  `open_dataset`) or a dataset or dplyr pipline and returns an sf
  object. **Important**: the table must have a `geometry` column, which
  you will almost always have to create first.

  Note: `to_sf()` triggers collection into R. This function is suitable
  to use at the end of a dplyr pipeline that will subset the data. Using
  this function on a large dataset without filtering first may exceed
  available memory.

## Value

an `sf` class object (in memory).

## Examples

``` r
if (FALSE) { # interactive()

library(dplyr)
csv_file <- system.file("extdata/spatial-test.csv", package="duckdbfs")

# Note that we almost always must first create a `geometry` column, e.g.
# from lat/long columns using the `st_point` method.
sf <-
  open_dataset(csv_file, format = "csv") |>
  mutate(geom = ST_Point(longitude, latitude)) |>
  to_sf()

# We can use the full space of spatial operations, including spatial
# and normal dplyr filters.  All operations are translated into a
# spatial SQL query by `to_sf`:
open_dataset(csv_file, format = "csv") |>
  mutate(geom = ST_Point(longitude, latitude)) |>
  mutate(dist = ST_Distance(geom, ST_Point(0,0))) |>
  filter(site %in% c("a", "b", "e")) |>
  to_sf()

}
```
