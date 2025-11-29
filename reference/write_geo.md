# Write a spatial file with gdal

Write out to any spatial data format supported by GDAL.

## Usage

``` r
write_geo(
  dataset,
  path,
  conn = cached_connection(),
  driver = "GeoJSON",
  layer_creation_options = "WRITE_BBOX=YES",
  srs = "ESPG:4326",
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

- driver:

  driver, see <https://duckdb.org/docs/stable/extensions/spatial/gdal>

- layer_creation_options:

  to GDAL, see <https://duckdb.org/docs/stable/extensions/spatial/gdal>

- srs:

  Set a spatial reference system as metadata to use for the export. This
  can be a WKT string, an EPSG code or a proj-string, basically anything
  you would normally be able to pass to GDAL. Note that this will not
  perform any reprojection of the input geometry, it just sets the
  metadata if the target driver supports it.

- as_http:

  if path is an S3 location, will return corresponding HTTP address.

## Value

path, invisibly

## Details

NOTE: This uses the version of GDAL packaged inside of duckdb, and not
the system GDAL. At this time, duckdb's pre-packaged GDAL does not
support s3 writes, and will produce a "Error: Not implemented Error:
GDAL Error (6): Seek not supported on writable /vsis3/ files". Use
to_geojson() to export using duckdb's native JSON serializer instead.

## Examples

``` r
if (FALSE) { # interactive()
local_file <-  system.file("extdata/spatial-test.csv", package="duckdbfs")
load_spatial()
tbl <- open_dataset(local_file, format='csv')
write_geo(tbl, "spatial.geojson")
}
```
