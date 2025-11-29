# Open a dataset from a variety of sources

This function opens a dataset from a variety of sources, including
Parquet, CSV, etc, using either local file system paths, URLs, or S3
bucket URI notation.

## Usage

``` r
open_dataset(
  sources,
  schema = NULL,
  hive_style = TRUE,
  unify_schemas = FALSE,
  format = c("parquet", "csv", "tsv", "sf"),
  conn = cached_connection(),
  tblname = tmp_tbl_name(),
  mode = "VIEW",
  filename = FALSE,
  recursive = TRUE,
  parser_options = list(),
  ...
)
```

## Arguments

- sources:

  A character vector of paths to the dataset files.

- schema:

  The schema for the dataset. If NULL, the schema will be inferred from
  the dataset files.

- hive_style:

  A logical value indicating whether to the dataset uses Hive-style
  partitioning.

- unify_schemas:

  A logical value indicating whether to unify the schemas of the dataset
  files (union_by_name). If TRUE, will execute a UNION by column name
  across all files (NOTE: this can add considerably to the initial
  execution time)

- format:

  The format of the dataset files. One of `"parquet"`, `"csv"`, or
  `"sf"` (spatial vector files supported by the sf package / GDAL). if
  no argument is provided, the function will try to guess the type based
  on minimal heuristics.

- conn:

  A connection to a database.

- tblname:

  The name of the table to create in the database.

- mode:

  The mode to create the table in. One of `"VIEW"` or `"TABLE"`.
  Creating a `VIEW`, the default, will execute more quickly because it
  does not create a local copy of the dataset. `TABLE` will create a
  local copy in duckdb's native format, downloading the full dataset if
  necessary. When using `TABLE` mode with large data, please be sure to
  use a `conn` connections with disk-based storage, e.g. by calling
  [`cached_connection()`](https://cboettig.github.io/duckdbfs/reference/cached_connection.md),
  e.g. `cached_connection("storage_path")`, otherwise the full data must
  fit into RAM. Using `TABLE` assumes familiarity with R's DBI-based
  interface.

- filename:

  A logical value indicating whether to include the filename in the
  table name.

- recursive:

  should we assume recursive path? default TRUE. Set to FALSE if trying
  to open a single, un-partitioned file.

- parser_options:

  additional options passed to the parser, e.g. to read_csv(), see
  <https://duckdb.org/docs/stable/data/csv/overview.html#parameters>

- ...:

  optional additional arguments passed to
  [`duckdb_s3_config()`](https://cboettig.github.io/duckdbfs/reference/duckdb_s3_config.md).
  Note these apply after those set by the URI notation and thus may be
  used to override or provide settings not supported in that format.

## Value

A lazy [`dplyr::tbl`](https://dplyr.tidyverse.org/reference/tbl.html)
object representing the opened dataset backed by a duckdb SQL
connection. Most `dplyr` (and some `tidyr`) verbs can be used directly
on this object, as they can be translated into SQL commands
automatically via `dbplyr`. Generic R commands require using
[`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html)
on the table, which forces evaluation and reading the resulting data
into memory.

## Examples

``` r
if (FALSE) { # interactive()
# A remote, hive-partitioned Parquet dataset
base <- paste0("https://github.com/duckdb/duckdb/raw/main/",
             "data/parquet-testing/hive-partitioning/union_by_name/")
f1 <- paste0(base, "x=1/f1.parquet")
f2 <- paste0(base, "x=1/f2.parquet")
f3 <- paste0(base, "x=2/f2.parquet")

open_dataset(c(f1,f2,f3), unify_schemas = TRUE)

# Access an S3 database specifying an independently-hosted (MINIO) endpoint
efi <- open_dataset("s3://neon4cast-scores/parquet/aquatics",
                    s3_access_key_id="",
                    s3_endpoint="data.ecoforecast.org")

# Use parser-options for non-standard csv:
 cars <- tempfile() # dummy data
 write.table(mtcars, cars, row.names = FALSE)

# Note nested quotes on parser option for delimiter:
 df <- open_dataset(cars, format = "csv",
                    parser_options = c(delim = "' '", header = TRUE))
}
```
