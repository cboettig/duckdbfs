# write_dataset

write_dataset

## Usage

``` r
write_dataset(
  dataset,
  path,
  conn = cached_connection(),
  format = c("parquet", "csv"),
  partitioning = dplyr::group_vars(dataset),
  overwrite = TRUE,
  options = list(),
  as_http = FALSE,
  ...
)
```

## Arguments

- dataset:

  a remote tbl object from `open_dataset`, or an in-memory data.frame.

- path:

  a local file path or S3 path with write credentials

- conn:

  duckdbfs database connection

- format:

  export format

- partitioning:

  names of columns to use as partition variables

- overwrite:

  allow overwriting of existing files?

- options:

  Additional arguments to COPY, see
  <https://duckdb.org/docs/stable/sql/statements/copy.html#copy--to-options>
  Note, uses duckdb native syntax, e.g. c("PER_THREAD_OUTPUT false"),
  for named arguments, see examples. (Recall SQL is case-insensitive).

- as_http:

  if path is an S3 location, will return corresponding HTTP address.

- ...:

  additional arguments to
  [`duckdb_s3_config()`](https://cboettig.github.io/duckdbfs/reference/duckdb_s3_config.md)

## Value

Returns the path, invisibly.

## See also

to_sf to_json to_geojson write_geo

## Examples

``` r
if (FALSE) { # interactive()
  write_dataset(mtcars, tempfile())
}
if (FALSE) { # interactive()
write_dataset(mtcars, tempdir())
write_dataset(mtcars, tempdir(), options = c("PER_THREAD_OUTPUT FALSE", "RETURN_STATS TRUE"))
}
```
