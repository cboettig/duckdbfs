# duckdb configuration

duckdb configuration

## Usage

``` r
duckdb_config(..., conn = cached_connection())
```

## Arguments

- ...:

  named argument of the parameters to set, see examples see all possible
  configuration options at
  <https://duckdb.org/docs/sql/configuration.html>

- conn:

  A connection to a database.

## Value

the active duckdb connection, invisibly

## Details

Accepts any duckdb setting as a named argument. Commonly useful:

- `threads`, `memory_limit`, `temp_directory`, `max_temp_directory_size`
  — resource tuning for large local jobs (see second example).

- `http_retries`, `http_retry_wait_ms` — back off and retry when a
  remote server returns HTTP 429 (rate-limited) or other transient
  errors while streaming parquet / CSV over HTTP(S).

Note: in I/O bound tasks such as streaming data, it can be helpful to
set thread parallelism significantly higher than available CPU cores.

## See also

duckdb_reset, duckdb_get_config

## Examples

``` r
if (FALSE) { # interactive()
duckdb_config(threads = 1, memory_limit = '10GB')
duckdb_get_config("threads")
duckdb_reset("threads")

# Common settings for larger local jobs
duckdb_config(
  threads = 64,
  memory_limit = "30GB",
  temp_directory = "/tmp/duckdb_swap",
  max_temp_directory_size = "100GB"
)

# Retry HTTP requests (e.g. a server returning HTTP 429 on parquet reads)
duckdb_config(http_retries = 5, http_retry_wait_ms = 2000)
}
```
