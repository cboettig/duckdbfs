# duckdbfs 0.1.1

* new function `duckdb_config()` streamlines common configurations, like `duckdb_config(threads = 1, memory_limit = '10GB')`
* related helpers `duckdb_get_config()` shows any or all configuration settings, `duckdb_reset()` restores defaults.
* new function `duckdb_extensions()` lists all available, installed, or loaded extensions and descriptions. 
* `cached_connection()` is aliased as `duckdb_connect()`, reflecting its use as more than an under-the-hood utility. 
* `load_h3()` and `load_spatial()` are called by default.  Opt out by closing any active cached connection first (with `close_connection()`) and re-instantiating the with `connect(with_h3 = FALSE)` etc.  
* `open_dataset()` gains the argument `parser_options` to pass arbitrary options to parsers such as duckdb's read_csv(), see <https://duckdb.org/docs/stable/data/csv/overview.html#parameters>.  
* `write_dataset()` gains the argument `options` to support custom options controlling the COPY behavior writing to file, such as thread parallelism, file naming conventions, and more.  see <https://duckdb.org/docs/stable/sql/statements/copy.html#copy--to-options>
* S3-based access will no longer automatically try recursion if path ends in a recognized extension, `.parquet`, `.csv`, or `.csv.gz`

# duckdbfs 0.1.0

* Adds `to_h3j()` method for streaming data to H3J format 
* Adds `duckdb_secrets()` as more modern [credential manager](https://duckdb.org/docs/stable/configuration/secrets_manager.html)
* Adds `write_geo()` method, currently writes geojson [#37](https://github.com/cboettig/duckdbfs/issues/37)
* `cached_connection()` / `connect()` now supports `config` argument and sets a temporary directory to the R tempdir by default, allowing disk-backed storage when duckdb detects memory limits.  

# duckdbfs 0.0.9

* Restore default to non-nightly. 

# duckdbfs 0.0.8

* work-around for error `The file was built for DuckDB version 'v1.1.3', but we can only load extensions built for DuckDB version '19864453f7'.`
  by using nightly repo for extensions by default. 


# duckdbfs 0.0.7

* The default `cached_connection()` helper will configure a temporary storage location by default.
  It also now supports all options supported by `duckdb::duckdb()` for connection creation. 
* New `as_dataset()` utility copies a local in-memory data.frame into the connection.
  
# duckdbfs 0.0.6

* bugfix: reading from local disk recursively no longer requires manual `**`.
  Also, trying to read from an existing _local_ file won't try and append recursive search
  even when given the default recursive=TRUE option.
* bugfix: `open_dataset()` uses random table name by default, avoid naming collisions.

# duckdbfs 0.0.5

* bugfix `write_dataset()` no longer adds `**` into paths when writing some partitions.
* Protect from unsupported table names generated from file names that start with a digit, fixes #21. 

# duckdbfs 0.0.4

* `open_dataset()` gains the ability to read spatial vector data formats
  (objects read by `sf`) using `format="sf"`
* default geometry column in `to_sf()` is now termed `geom`, to match the default
  used in `duckdb`'s `st_read()` function.
* `open_dataset()` now tries to guess the data format instead of defaulting to
  parquet when no format is explicitly provided. 

* a new function, `spatial_join()`, allows a variety of spatial joins.  
* a new function, `st_read_meta()`, exposes the spatial metadata of remote spatial objects.
* new helper function, `as_view()`, creates a temporary view of a query.

# duckdbfs 0.0.3

* `write_dataset()` now understands lazy queries, not just lazy tables.

# duckdbfs 0.0.2

* duckdbfs now has spatial data query support! Users can leverage spatial
  data operations like `st_distance()` and `st_area()` and request return
  values as `sf` objects.  Supports network-based access too.  See README.md

* Added `write_dataset()` which can write to (potentially partitioned) parquet
  to local directories or remote (S3) buckets.

* The S3 interface supports `arrow`-compatible URI notation:
  - Alternate endpoints can now be passed like so 
    `s3://userid:secret_token@bucket-name?endpoint_override=data.ecoforecast.org`
  - Users can omit the use of `*` (match any file) or `**` 
    (recursive search) and just supply a path.  Recursive search is then
    assumed automatically.  Note: unlike `arrow`, this still supports the
    use of globs (`*`) elsewhere in the path, e.g. `s3://bucket/*/path`

* `duckdb_s3_config` gains argument `anonymous` allowing users to ignore existing
  AWS keys that may be set in environmental variables or AWS configuration files.
  This can also be passed as the username position in URI notation, e.g.
  `s3://anonymous@bucket_name`.  

* `open_dataset` drops use of `endpoint` as an argument.  Instead, alternative
  S3 endpoints can be set either by using the URI query notation or calling
  `duckdb_s3_config()` first.  Additionally, any arguments to `duckdb_s3_config()`,
  including `s3_endpoint`, can now be passed to `open_dataset` through the `...`.
  Note these settings will override any set by the URI notation.

# duckdbfs 0.0.1

* Initial release to CRAN
