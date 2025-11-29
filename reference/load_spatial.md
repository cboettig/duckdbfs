# load the duckdb geospatial data plugin

load the duckdb geospatial data plugin

## Usage

``` r
load_spatial(
  conn = cached_connection(),
  nightly = getOption("duckdbfs_use_nightly", FALSE),
  force = FALSE
)
```

## Arguments

- conn:

  A database connection object created using the `cache_connection`
  function (default: `cache_connection()`).

- nightly:

  should we use the nightly version or not? default FALSE, configurable
  as `duckdbfs_use_nightly` option.

- force:

  force re-install?

## Value

loads the extension and returns status invisibly.

## References

<https://duckdb.org/docs/extensions/spatial.html>
