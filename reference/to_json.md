# to_json write data out as a JSON object

to_json write data out as a JSON object

## Usage

``` r
to_json(
  dataset,
  path,
  conn = cached_connection(),
  array = TRUE,
  options = NULL,
  as_http = FALSE
)
```

## Arguments

- dataset:

  a remote tbl object from `open_dataset`, or an in-memory data.frame.

- path:

  a local file path or S3 path with write credentials

- conn:

  duckdbfs database connection

- array:

  generate a JSON array?

- options:

  additional options as a char string, see

- as_http:

  if path is an S3 location, will return corresponding HTTP address.

## Value

path, invisibly
