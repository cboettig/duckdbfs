


#' Open a dataset from a variety of sources
#'
#' This function opens a dataset from a variety of sources, including Parquet,
#' CSV, etc, using either local filesystem paths, URLs, or S3 bucket URI
#'  notation.
#'
#' @param sources A character vector of paths to the dataset files.
#' @param schema The schema for the dataset. If NULL, the schema will be
#'  inferred from the dataset files.
#' @param hive_style A logical value indicating whether to the dataset uses
#' Hive-style partitioning.
#' @param unify_schemas A logical value indicating whether to unify the schemas
#'  of the dataset files. If TRUE, will execute a UNION by column name across
#'  all files (NOTE: this can add considerably to the initial execution time)
#' @param format The format of the dataset files. One of `"parquet"`, `"csv"`,
#' `"tsv"`, or `"text"`.
#' @param conn A connection to a database.
#' @param tblname The name of the table to create in the database.
#' @param mode The mode to create the table in. One of `"VIEW"` or `"TABLE"`.
#' @param filename A logical value indicating whether to include the filename in
#' the table name.
#' @param endpoint optionally, an alternative endpoint for the S3 object store.
#'
#' @return A lazy `dplyr::tbl` object representing the opened dataset backed
#' by a duckdb SQL connection.  Most `dplyr` (and some `tidyr`) verbs can be
#' used directly on this object, as they can be translated into SQL commands
#' automatically via `dbplyr`.  Generic R commands require using
#' `dplyr::collect()` on the table, which forces evaluation and reading the
#' resulting data into memory.
#'
#' @examplesIf duckdbfs:::example_safe()
#' # Open a remote, hive-partitioned Parquet dataset
#' base <- paste0("https://github.com/duckdb/duckdb/raw/master/",
#'              "data/parquet-testing/hive-partitioning/union_by_name/")
#' f1 <- paste0(base, "x=1/f1.parquet")
#' f2 <- paste0(base, "x=1/f2.parquet")
#' f3 <- paste0(base, "x=2/f2.parquet")
#'
#' open_dataset(c(f1,f2,f3))
#'
#' @export
open_dataset <- function(sources,
                         schema = NULL,
                         hive_style = TRUE,
                         unify_schemas = FALSE,
                         format = c("parquet", "csv", "tsv", "text"),
                         conn = cached_connection(),
                         tblname = tmp_tbl_name(),
                         mode = "VIEW",
                         filename = FALSE,
                         endpoint = NULL) {

  load_httpfs(conn)
  enable_parallel(conn)

  format <- match.arg(format)
  view_query <- query_string(tblname,
                             sources,
                             format = format,
                             mode = mode,
                             hive_partitioning = hive_style,
                             union_by_name = unify_schemas,
                             filename = filename
                             )
  DBI::dbSendQuery(conn, view_query)
  dplyr::tbl(conn, tblname)
}


vec_as_str <- function(x) {
  paste0("[", paste0(paste0("'", x, "'"), collapse = ","),"]")
}

query_string <- function(tblname,
                         sources,
                         format = "parquet",
                         mode = c("VIEW", "TABLE"),
                         hive_partitioning = TRUE,
                         union_by_name = TRUE,
                         filename = FALSE) {

  source_uris <- vec_as_str(sources)
  scanner <- switch(format,
                    "parquet" = "parquet_scan(",
                    "read_csv_auto(")
  paste0(
    paste("CREATE", mode, tblname, "AS SELECT * FROM "),
    paste0(scanner, source_uris,
           ", HIVE_PARTITIONING=",hive_partitioning,
           ", UNION_BY_NAME=",union_by_name,
           ", FILENAME=",filename,
           ");")
  )
}
#union_by_name=True, filename=True

tmp_tbl_name <- function(n = 15) {
  paste0(sample(letters, n, replace = TRUE), collapse = "")
}

load_httpfs <- function(conn = cached_connection()) {
  # NOTE: remote access (http or S3 paths) are not supported on Windows.
  # If OS is Windows, this call should be skipped with non-zero return status
  # Then, we should attempt to download http addresses to tempfile
  # S3:// URIs on Windows should throw a "not supported on Windows" error.

  status <- DBI::dbExecute(conn, "INSTALL 'httpfs';")
  status <- DBI::dbExecute(conn, "LOAD 'httpfs';")
  invisible(status)
}

set_endpoint <- function(endpoint, conn = cached_connection()) {
  DBI::dbExecute(conn, paste0("SET s3_endpoint='", endpoint, "';"))
  DBI::dbExecute(conn, "SET s3_url_style='path';")
}

enable_parallel <- function(conn = cached_connection(),
                            duckdb_cores = parallel::detectCores()){
  DBI::dbExecute(conn, paste0("PRAGMA threads=", duckdb_cores))
}

example_safe <- function() {
  # not Windows, not CRAN

  interactive() # dummy
}

remote_src <- function(conn) {
  dbplyr::remote_src(conn)
}
