# Write H3 hexagon data out as an h3j-compliant JSON file NOTE: the column containing H3 hashes must be named `hexid`

Write H3 hexagon data out as an h3j-compliant JSON file NOTE: the column
containing H3 hashes must be named `hexid`

## Usage

``` r
to_h3j(dataset, path, conn = cached_connection(), as_http = FALSE)
```

## Arguments

- dataset:

  a remote tbl object from `open_dataset`, or an in-memory data.frame.

- path:

  a local file path or S3 path with write credentials

- conn:

  duckdbfs database connection

- as_http:

  if path is an S3 location, will return corresponding HTTP address.

## Examples

``` r
if (FALSE) { # interactive()
# example code
}
```
