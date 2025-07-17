
#' duckdb configuration
#'
#' @inheritParams open_dataset
#' @param ... named argument of the parameters to set, see examples
#' see all possible configuration options at <https://duckdb.org/docs/sql/configuration.html>
#' @return the active duckdb connection, invisibly
#' @details Note: in I/O bound tasks such as streaming data, it can be helpful to set
#' thread parallelism signifantly higher than avialable CPU cores.
#' @seealso duckdb_reset, duckdb_get_config
#' @export
#' @examplesIf interactive()
#' duckdb_config(threads = 1, memory_limit = '10GB')
#' duckdb_get_config("threads")
#' duckdb_reset("threads")
duckdb_config <- function(..., conn = cached_connection()) {
    parameters <- list(...)
    for(p in names(parameters)) {
      cmd <- paste0("SET ", p, "='", parameters[p], "';")
      DBI::dbExecute(conn, cmd)
    }
    invisible(conn)
}


#' duckdb reset configuration to default
#'
#' @inheritParams open_dataset
#' @param x parameter name
#' @seealso duckdb_config, duckdb_get_config
#' @export
#' @examplesIf interactive()
#' duckdb_config(threads = 10)
#' duckdb_get_config("threads")
#' duckdb_reset("threads")
duckdb_reset <- function(x, conn = cached_connection()) {
    cmd <- paste0("RESET ", x, ";")
    DBI::dbExecute(conn, cmd)
    invisible(conn)
}


#' duckdb reset configuration to default
#'
#' @inheritParams open_dataset
#' @param x parameter name. Omit to see a table of all settings.
#' @seealso duckdb_config, duckdb_get_config
#' @export
#' @examplesIf interactive()
#' # Full config table
#' duckdb_get_config()
#'
#' # look up single config value
#' duckdb_get_config("threads")
#'
#' # set a different value, test, reset.
#' duckdb_config(threads = 10)
#' duckdb_get_config("threads")
#' duckdb_reset("threads")
#'
duckdb_get_config <- function(x = NULL, conn = cached_connection()) {
  cmd <- paste0("SELECT * FROM duckdb_settings()")
  settings <- DBI::dbGetQuery(conn, cmd)
  settings <- dplyr::as_tibble(settings)

  if(is.null(x)) return(settings)

  settings$value[settings$name == tolower(x)]
}




# internal
duckdb_set <- function(x, conn = cached_connection()) {
  if(!is.null(x)) {
    name <- deparse(substitute(x))
    cmd <- paste0("SET ", name, "='", x, "';")
    DBI::dbExecute(conn, cmd)
  }
}



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
#' @param anonymous request anonymous access (sets `s3_access_key_id` and
#'   `s3_secret_access_key` to `""`, allowing anonymous access to public buckets).
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
#'            s3_use_ssl = TRUE,
#'            anonymous = TRUE)
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
                             s3_use_ssl = NULL,
                             anonymous = NULL) {

  if (!is.null(s3_endpoint) && is.null(s3_url_style)) {
    s3_url_style <- "path"
  }

  if(!is.null(s3_endpoint))
    s3_endpoint <- gsub("^http[s]://", "", s3_endpoint)

  if(!is.null(anonymous)){
    if(!is.null(s3_access_key_id) || !is.null(s3_secret_access_key))
      warning(paste("access keys provided when anonymous access requested.\n",
                    "keys will be ignored"))
    s3_access_key_id <- ""
    s3_secret_access_key <- ""
  }

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




load_extension <-
  function(extension = "httpfs",
           conn = cached_connection(),
           nightly = getOption("duckdbfs_use_nightly", FALSE),
           force = FALSE) {
  exts <- duckdb_extensions()
  source <- ""
  if (nightly) {
    source <- " FROM 'http://nightly-extensions.duckdb.org'"
  }
  status <- exts[exts$extension_name == extension,]
  status_code <- 0
  if (force) {
    FORCE <- "FORCE "
  } else {
    FORCE <- ""
  }

  if(!status$installed) {

    if (!nightly) {
    DBI::dbExecute(conn, paste0(FORCE,
      glue::glue("INSTALL '{extension}'"), source, ";"))
    } else {
      source <- " FROM 'http://nightly-extensions.duckdb.org'"
      status_code <- DBI::dbExecute(conn, paste0(FORCE,
        glue::glue("INSTALL '{extension}'"), source, ";"))
    }

  }
  if(!status$loaded) {
    status_code <- DBI::dbExecute(conn, glue::glue("LOAD '{extension}';"))
  }

  invisible(status_code)
}


load_httpfs <- function(conn = cached_connection(),
                        nightly = getOption("duckdbfs_use_nightly", FALSE),
                        force = FALSE){
  load_extension("httpfs", conn = conn, nightly=nightly, force = force)
}



enable_parallel <- function(conn = cached_connection(),
                            duckdb_cores = parallel::detectCores()){
  status <- DBI::dbExecute(conn, paste0("PRAGMA threads=", duckdb_cores))
  invisible(status)
}


#' load the duckdb geospatial data plugin
#'
#' @inheritParams duckdb_s3_config
#' @param nightly should we use the nightly version or not?
#'   default FALSE, configurable as `duckdbfs_use_nightly` option.
#' @param force force re-install?
#' @return loads the extension and returns status invisibly.
#' @references <https://duckdb.org/docs/extensions/spatial.html>
#' @export
load_spatial <- function(conn = cached_connection(),
                         nightly=getOption("duckdbfs_use_nightly", FALSE),
                         force = FALSE) {

  load_extension("spatial", conn = conn, nightly = nightly, force = force)
}


#' show duckdb extensions
#'
#' @inheritParams open_dataset
#' @return a data frame listing all available extensions, with boolean columns
#' indicating which extensions are installed or loaded, and a description of each
#' extension.
#' @export
#' @examplesIf interactive()
#' duckdb_extensions()
duckdb_extensions <- function(conn = cached_connection()) {
  query <- "SELECT * FROM duckdb_extensions();"
  DBI::dbGetQuery(conn, query)
}
