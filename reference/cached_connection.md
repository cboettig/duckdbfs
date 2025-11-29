# create a cachable duckdb connection

This function is primarily intended for internal use by other `duckdbfs`
functions. However, it can be called directly by the user whenever it is
desirable to have direct access to the connection object.

## Usage

``` r
cached_connection(
  dbdir = ":memory:",
  read_only = FALSE,
  bigint = "numeric",
  config = list(temp_directory = tempfile()),
  autoload_exts = getOption("duckdbfs_autoload_extensions", TRUE),
  with_spatial = not_windows() && getOption("duckdbfs_autoload_extensions", TRUE),
  with_h3 = not_windows() && getOption("duckdbfs_autoload_extensions", TRUE)
)
```

## Arguments

- dbdir:

  Location for database files. Should be a path to an existing directory
  in the file system. With the default (or `""`), all data is kept in
  RAM.

- read_only:

  Set to `TRUE` for read-only operation. For file-based databases, this
  is only applied when the database file is opened for the first time.
  Subsequent connections (via the same `drv` object or a `drv` object
  pointing to the same path) will silently ignore this flag.

- bigint:

  How 64-bit integers should be returned. There are two options:
  `"numeric"` and `"integer64"`. If `"numeric"` is selected, bigint
  integers will be treated as double/numeric. If `"integer64"` is
  selected, bigint integers will be set to bit64 encoding.

- config:

  Named list with DuckDB configuration flags, see
  <https://duckdb.org/docs/configuration/overview#configuration-reference>
  for the possible options. These flags are only applied when the
  database object is instantiated. Subsequent connections will silently
  ignore these flags.

- autoload_exts:

  should we auto-load extensions? TRUE by default, can be configured
  with `options(duckdbfs_autoload_extensions = FALSE)`

- with_spatial:

  install (if missing) and load spatial extension, default TRUE Opt out
  by closing any active cached connection first (with
  [`close_connection()`](https://cboettig.github.io/duckdbfs/reference/close_connection.md))
  and re-instantiating the with `connect(with_spatial = FALSE)`.

- with_h3:

  install (if missing) and load the h3 spatial index extension. Default
  TRUE

## Value

a [`duckdb::duckdb()`](https://r.duckdb.org/reference/duckdb.html)
connection object

## Details

When first called (by a user or internal function), this function both
creates a duckdb connection and places that connection into a cache
(`duckdbfs_conn` option). On subsequent calls, this function returns the
cached connection, rather than recreating a fresh connection.

This frees the user from the responsibility of managing a connection
object, because functions needing access to the connection can use this
to create or access the existing connection. At the close of the global
environment, this function's finalizer should gracefully shutdown the
connection before removing the cache.

By default, this function creates an in-memory connection. When reading
from on-disk or remote files (parquet or csv), this option can still
effectively support most operations on much-larger-than-RAM data.
However, some operations require additional working space, so by default
we set a temporary storage location in configuration as well.

## Examples

``` r
if (FALSE) { # interactive()

con <- cached_connection()
close_connection(con)
}
```
