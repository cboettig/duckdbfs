# load the duckdb geospatial data plugin

load the duckdb geospatial data plugin

## Usage

``` r
load_h3(
  conn = cached_connection(),
  repo = "http://community-extensions.duckdb.org"
)
```

## Arguments

- conn:

  A database connection object created using the `cache_connection`
  function (default: `cache_connection()`).

- repo:

  repository path for community extensions

## Value

loads the extension and returns status invisibly.

## References

<https://github.com/isaacbrodsky/h3-duckdb>

## Examples

``` r
if (FALSE) { # interactive()

library(dplyr)
load_h3()
ex <- system.file("extdata/spatial-test.csv", package="duckdbfs")

zoom <- 9L # Zoom must be explicit integer, L
query <- ex |>
  open_dataset(format = "csv") |>
  mutate(h3id = h3_latlng_to_cell_string(latitude, longitude, zoom))

 # as data.frame
 collect(query)

 # write to a file
 path <- tempfile(fileext = ".h3j")
 query |> to_h3j(path)
}
```
