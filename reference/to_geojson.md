# Write geojson using duckdb's native JSON writer

Write geojson using duckdb's native JSON writer

## Usage

``` r
to_geojson(
  dataset,
  path,
  conn = cached_connection(),
  id_col = NULL,
  as_http = FALSE,
  server = Sys.getenv("AWS_S3_ENDPOINT", "s3.amanzonaws.com"),
  use_ssl = Sys.getenv("AWS_HTTPS", "TRUE")
)
```

## Arguments

- dataset:

  a remote tbl object from `open_dataset`, or an in-memory data.frame.

- path:

  a local file path or S3 path with write credentials

- conn:

  duckdbfs database connection

- id_col:

  (deprecated). to_geojson() will preserve all atomic columns as
  properties.

- as_http:

  convert returned S3 path to URL (e.g. for public buckets)

- server:

  aws endpoint if converting s3 path to URL

- should:

  url use https

## Value

path, invisibly
