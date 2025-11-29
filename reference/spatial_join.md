# spatial_join

spatial_join

## Usage

``` r
spatial_join(
  x,
  y,
  by = c("st_intersects", "st_within", "st_dwithin", "st_touches", "st_contains",
    "st_containsproperly", "st_covers", "st_overlaps", "st_crosses", "st_equals",
    "st_disjoint"),
  args = "",
  join = "left",
  tblname = tmp_tbl_name(),
  conn = cached_connection()
)
```

## Arguments

- x:

  a duckdb table with a spatial geometry column called "geom"

- y:

  a duckdb table with a spatial geometry column called "geom"

- by:

  A spatial join function, see details.

- args:

  additional arguments to join function (e.g. distance for st_dwithin)

- join:

  JOIN type (left, right, inner, full)

- tblname:

  name for the temporary view

- conn:

  the duckdb connection (imputed by duckdbfs by default, must be shared
  across both tables)

## Value

a (lazy) view of the resulting table. Users can continue to operate on
using dplyr operations and call to_st() to collect this as an sf object.

## Details

Possible [spatial
joins](https://postgis.net/workshops/postgis-intro/spatial_relationships.html)
include:

|                     |                                                                                                               |
|---------------------|---------------------------------------------------------------------------------------------------------------|
| Function            | Description                                                                                                   |
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

All though SQL is not case sensitive, this function expects only lower
case names for "by" functions.

## Examples

``` r
if (FALSE) { # interactive()

# note we can read in remote data in a variety of vector formats:
countries <-
paste0("/vsicurl/",
       "https://github.com/cboettig/duckdbfs/",
       "raw/spatial-read/inst/extdata/world.gpkg") |>
open_dataset(format = "sf")

cities <-
 paste0("/vsicurl/https://github.com/cboettig/duckdbfs/raw/",
        "spatial-read/inst/extdata/metro.fgb") |>
 open_dataset(format = "sf")

countries |>
  dplyr::filter(iso_a3 == "AUS") |>
  spatial_join(cities)
}
```
