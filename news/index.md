# Changelog

## duckdbfs 0.1.2.99

- All methods that write to a file / path now return that path
  (invisibly). Previously the return was just inherited from dbExecute()
  call, except for write_dataset() which always followed this
  convention. An additional optional argument has been added which can
  format the returned path as an HTTP address.

## duckdbfs 0.1.2

CRAN release: 2025-10-12

- [`write_geo()`](https://cboettig.github.io/duckdbfs/reference/write_geo.md)
  now takes argument, `srs` for projection information
- [`to_geojson()`](https://cboettig.github.io/duckdbfs/reference/to_geojson.md)
  now writes all atomic columns, not just an id column.

## duckdbfs 0.1.1

CRAN release: 2025-07-17

- new function
  [`duckdb_config()`](https://cboettig.github.io/duckdbfs/reference/duckdb_config.md)
  streamlines common configurations, like
  `duckdb_config(threads = 1, memory_limit = '10GB')`
- related helpers
  [`duckdb_get_config()`](https://cboettig.github.io/duckdbfs/reference/duckdb_get_config.md)
  shows any or all configuration settings,
  [`duckdb_reset()`](https://cboettig.github.io/duckdbfs/reference/duckdb_reset.md)
  restores defaults.
- new function
  [`duckdb_extensions()`](https://cboettig.github.io/duckdbfs/reference/duckdb_extensions.md)
  lists all available, installed, or loaded extensions and descriptions.
- [`cached_connection()`](https://cboettig.github.io/duckdbfs/reference/cached_connection.md)
  is aliased as
  [`duckdb_connect()`](https://cboettig.github.io/duckdbfs/reference/cached_connection.md),
  reflecting its use as more than an under-the-hood utility.
- [`load_h3()`](https://cboettig.github.io/duckdbfs/reference/load_h3.md)
  and
  [`load_spatial()`](https://cboettig.github.io/duckdbfs/reference/load_spatial.md)
  are called by default. Opt out by closing any active cached connection
  first (with
  [`close_connection()`](https://cboettig.github.io/duckdbfs/reference/close_connection.md))
  and re-instantiating the with `connect(with_h3 = FALSE)` etc.  
- [`open_dataset()`](https://cboettig.github.io/duckdbfs/reference/open_dataset.md)
  gains the argument `parser_options` to pass arbitrary options to
  parsers such as duckdb’s read_csv(), see
  <https://duckdb.org/docs/stable/data/csv/overview.html#parameters>.  
- [`write_dataset()`](https://cboettig.github.io/duckdbfs/reference/write_dataset.md)
  gains the argument `options` to support custom options controlling the
  COPY behavior writing to file, such as thread parallelism, file naming
  conventions, and more. see
  <https://duckdb.org/docs/stable/sql/statements/copy.html#copy--to-options>
- S3-based access will no longer automatically try recursion if path
  ends in a recognized extension, `.parquet`, `.csv`, or `.csv.gz`

## duckdbfs 0.1.0

CRAN release: 2025-04-04

- Adds
  [`to_h3j()`](https://cboettig.github.io/duckdbfs/reference/to_h3j.md)
  method for streaming data to H3J format
- Adds
  [`duckdb_secrets()`](https://cboettig.github.io/duckdbfs/reference/duckdb_secrets.md)
  as more modern [credential
  manager](https://duckdb.org/docs/stable/configuration/secrets_manager.html)
- Adds
  [`write_geo()`](https://cboettig.github.io/duckdbfs/reference/write_geo.md)
  method, currently writes geojson
  [\#37](https://github.com/cboettig/duckdbfs/issues/37)
- [`cached_connection()`](https://cboettig.github.io/duckdbfs/reference/cached_connection.md)
  / `connect()` now supports `config` argument and sets a temporary
  directory to the R tempdir by default, allowing disk-backed storage
  when duckdb detects memory limits.

## duckdbfs 0.0.9

CRAN release: 2024-12-16

- Restore default to non-nightly.

## duckdbfs 0.0.8

CRAN release: 2024-12-09

- work-around for error
  `The file was built for DuckDB version 'v1.1.3', but we can only load extensions built for DuckDB version '19864453f7'.`
  by using nightly repo for extensions by default.

## duckdbfs 0.0.7

CRAN release: 2024-08-29

- The default
  [`cached_connection()`](https://cboettig.github.io/duckdbfs/reference/cached_connection.md)
  helper will configure a temporary storage location by default. It also
  now supports all options supported by
  [`duckdb::duckdb()`](https://r.duckdb.org/reference/duckdb.html) for
  connection creation.
- New
  [`as_dataset()`](https://cboettig.github.io/duckdbfs/reference/as_dataset.md)
  utility copies a local in-memory data.frame into the connection.

## duckdbfs 0.0.6

- bugfix: reading from local disk recursively no longer requires manual
  `**`. Also, trying to read from an existing *local* file won’t try and
  append recursive search even when given the default recursive=TRUE
  option.
- bugfix:
  [`open_dataset()`](https://cboettig.github.io/duckdbfs/reference/open_dataset.md)
  uses random table name by default, avoid naming collisions.

## duckdbfs 0.0.5

CRAN release: 2024-08-17

- bugfix
  [`write_dataset()`](https://cboettig.github.io/duckdbfs/reference/write_dataset.md)
  no longer adds `**` into paths when writing some partitions.
- Protect from unsupported table names generated from file names that
  start with a digit, fixes
  [\#21](https://github.com/cboettig/duckdbfs/issues/21).

## duckdbfs 0.0.4

CRAN release: 2024-02-28

- [`open_dataset()`](https://cboettig.github.io/duckdbfs/reference/open_dataset.md)
  gains the ability to read spatial vector data formats (objects read by
  `sf`) using `format="sf"`

- default geometry column in
  [`to_sf()`](https://cboettig.github.io/duckdbfs/reference/to_sf.md) is
  now termed `geom`, to match the default used in `duckdb`’s
  [`st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)
  function.

- [`open_dataset()`](https://cboettig.github.io/duckdbfs/reference/open_dataset.md)
  now tries to guess the data format instead of defaulting to parquet
  when no format is explicitly provided.

- a new function,
  [`spatial_join()`](https://cboettig.github.io/duckdbfs/reference/spatial_join.md),
  allows a variety of spatial joins.  

- a new function,
  [`st_read_meta()`](https://cboettig.github.io/duckdbfs/reference/st_read_meta.md),
  exposes the spatial metadata of remote spatial objects.

- new helper function,
  [`as_view()`](https://cboettig.github.io/duckdbfs/reference/as_view.md),
  creates a temporary view of a query.

## duckdbfs 0.0.3

CRAN release: 2023-10-19

- [`write_dataset()`](https://cboettig.github.io/duckdbfs/reference/write_dataset.md)
  now understands lazy queries, not just lazy tables.

## duckdbfs 0.0.2

CRAN release: 2023-09-06

- duckdbfs now has spatial data query support! Users can leverage
  spatial data operations like
  [`st_distance()`](https://r-spatial.github.io/sf/reference/geos_measures.html)
  and
  [`st_area()`](https://r-spatial.github.io/sf/reference/geos_measures.html)
  and request return values as `sf` objects. Supports network-based
  access too. See README.md

- Added
  [`write_dataset()`](https://cboettig.github.io/duckdbfs/reference/write_dataset.md)
  which can write to (potentially partitioned) parquet to local
  directories or remote (S3) buckets.

- The S3 interface supports `arrow`-compatible URI notation:

  - Alternate endpoints can now be passed like so
    `s3://userid:secret_token@bucket-name?endpoint_override=data.ecoforecast.org`
  - Users can omit the use of `*` (match any file) or `**` (recursive
    search) and just supply a path. Recursive search is then assumed
    automatically. Note: unlike `arrow`, this still supports the use of
    globs (`*`) elsewhere in the path, e.g. `s3://bucket/*/path`

- `duckdb_s3_config` gains argument `anonymous` allowing users to ignore
  existing AWS keys that may be set in environmental variables or AWS
  configuration files. This can also be passed as the username position
  in URI notation, e.g. `s3://anonymous@bucket_name`.

- `open_dataset` drops use of `endpoint` as an argument. Instead,
  alternative S3 endpoints can be set either by using the URI query
  notation or calling
  [`duckdb_s3_config()`](https://cboettig.github.io/duckdbfs/reference/duckdb_s3_config.md)
  first. Additionally, any arguments to
  [`duckdb_s3_config()`](https://cboettig.github.io/duckdbfs/reference/duckdb_s3_config.md),
  including `s3_endpoint`, can now be passed to `open_dataset` through
  the `...`. Note these settings will override any set by the URI
  notation.

## duckdbfs 0.0.1

CRAN release: 2023-08-09

- Initial release to CRAN
