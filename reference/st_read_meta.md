# read spatial metadata

At this time, reads a subset of spatial metadata. This is similar to
what is reported by `ogrinfo -json`

## Usage

``` r
st_read_meta(
  path,
  layer = 1L,
  tblname = tbl_name(path),
  conn = cached_connection(),
  ...
)
```

## Arguments

- path:

  URL or path to spatial data file

- layer:

  layer number to read metadata for, defaults to first layer.

- tblname:

  metadata will be stored as a view with this name, by default this is
  based on the name of the file.

- conn:

  A connection to a database.

- ...:

  optional additional arguments passed to
  [`duckdb_s3_config()`](https://cboettig.github.io/duckdbfs/reference/duckdb_s3_config.md).
  Note these apply after those set by the URI notation and thus may be
  used to override or provide settings not supported in that format.

## Value

A lazy [`dplyr::tbl`](https://dplyr.tidyverse.org/reference/tbl.html)
object containing core spatial metadata such as projection information.

## Examples

``` r
if (FALSE) { # interactive()
st_read_meta("https://github.com/duckdb/duckdb_spatial/raw/main/test/data/amsterdam_roads.fgb")
}
```
