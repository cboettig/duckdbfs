#' Configure S3 settings for database connection
#'
#' This function is used to configure S3 settings for a database connection.
#' It allows you to set various S3-related parameters such as access key,
#' secret access key, endpoint, region, session token, uploader settings,
#' URL compatibility mode, URL style, and SSL usage.
#'
#' @param conn A database connection object created using the
#'  \code{cache_connection} function (default: \code{cache_connection()}).
#' @param s3_access_key_id The S3 access key ID (default: \code{NULL}).
#' @param s3_secret_access_key The S3 secret access key (default: \code{NULL}).
#' @param s3_endpoint The S3 endpoint (default: \code{NULL}).
#' @param s3_region The S3 region (default: \code{NULL}).
#' @param s3_session_token The S3 session token (default: \code{NULL}).
#' @param s3_uploader_max_filesize The maximum filesize for S3 uploader
#'  (between 50GB and 5TB, default 800GB).
#' @param s3_uploader_max_parts_per_file The maximum number of parts per file
#'  for S3 uploader (between 1 and 10000, default 10000).
#' @param s3_uploader_thread_limit The thread limit for S3 uploader
#'  (default: 50).
#' @param s3_url_compatibility_mode Disable Globs and Query Parameters on
#'  S3 URLs (default: 0, allows globs/queries).
#' @param s3_url_style The style of S3 URLs to use. Default is
#' "vhost" unless s3_endpoint is set, which makes default "path"
#'  (i.e. MINIO systems).
#' @param s3_use_ssl Enable or disable SSL for S3 connections
#'  (default: 1 (TRUE)).
#' @details see <https://duckdb.org/docs/sql/configuration.html>
#' @return Returns silently (NULL) if successful.
#'
#' @examplesIf interactive()
#' # Configure S3 settings
#' duckdb_s3_config(
#'            s3_access_key_id = "YOUR_ACCESS_KEY_ID",
#'            s3_secret_access_key = "YOUR_SECRET_ACCESS_KEY",
#'            s3_endpoint = "YOUR_S3_ENDPOINT",
#'            s3_region = "YOUR_S3_REGION",
#'            s3_uploader_max_filesize = "800GB",
#'            s3_uploader_max_parts_per_file = 100,
#'            s3_uploader_thread_limit = 8,
#'            s3_url_compatibility_mode = FALSE,
#'            s3_url_style = "vhost",
#'            s3_use_ssl = TRUE)
#'
#' @export
duckdb_s3_config <- function(conn = cached_connection(),
                             s3_access_key_id = NULL,
                             s3_secret_access_key = NULL,
                             s3_endpoint = NULL,
                             s3_region = NULL,
                             s3_session_token = NULL,
                             s3_uploader_max_filesize = NULL,
                             s3_uploader_max_parts_per_file = NULL,
                             s3_uploader_thread_limit = NULL,
                             s3_url_compatibility_mode = NULL,
                             s3_url_style = NULL,
                             s3_use_ssl = NULL) {
  if (!is.null(s3_endpoint) && is.null(s3_url_style)) {
    s3_url_style <- "path"
  }
  s3_endpoint <- gsub("^http[s]://", "", s3_endpoint)
  load_httpfs(conn)

  duckdb_set(s3_access_key_id, conn = conn)
  duckdb_set(s3_secret_access_key, conn = conn)
  duckdb_set(s3_endpoint, conn = conn)
  duckdb_set(s3_region, conn = conn)
  duckdb_set(s3_secret_access_key, conn = conn)
  duckdb_set(s3_session_token, conn = conn)
  duckdb_set(s3_uploader_max_filesize, conn = conn)
  duckdb_set(s3_uploader_max_parts_per_file, conn = conn)
  duckdb_set(s3_uploader_thread_limit, conn = conn)
  duckdb_set(s3_url_compatibility_mode, conn = conn)
  duckdb_set(s3_url_style, conn = conn)
  duckdb_set(s3_use_ssl, conn = conn)
}

duckdb_set <- function(x, conn = cached_connection()) {
  if(!is.null(x)) {
    name <- deparse(substitute(x))
    cmd <- paste0("SET ", name, "='", x, "';")
    DBI::dbExecute(conn, cmd)
  }
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

enable_parallel <- function(conn = cached_connection(),
                            duckdb_cores = parallel::detectCores()){
  DBI::dbExecute(conn, paste0("PRAGMA threads=", duckdb_cores))
}

