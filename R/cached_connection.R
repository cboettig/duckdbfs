
duckdbfs_env <- new.env()


#' create a cachable duckdb connection
#'
#' This function is primarily intended for internal use by other
#' `duckdbfs` functions.  However, it can be called directly by
#' the user whenever it is desirable to have direct access to the
#' connection object.
#'
#' When first called (by a user or internal function),
#' this function both creates a duckdb connection and places
#' that connection into a cache (`duckdbfs_conn` option).
#' On subsequent calls, this function returns the cached connection,
#' rather than recreating a fresh connection.
#'
#' This frees the user from the responsibility of managing a
#' connection object, because functions needing access to the
#' connection can use this to create or access the existing connection.
#' At the close of the global environment, this function's finalizer
#' should gracefully shutdown the connection before removing the cache.
#'
#'
#' By default, this function creates an in-memory connection. When reading
#' from on-disk or remote files (parquet or csv), this option can still
#' effectively support most operations on much-larger-than-RAM data.
#' However, some operations require additional working space, so by default
#' we set a temporary storage location in configuration as well.
#' @inheritParams duckdb::duckdb
#' @param autoload_exts should we auto-load extensions?  TRUE by default,
#' can be configured with `options(duckdbfs_autoload_extensions = FALSE)`
#' @param with_spatial install (if missing) and load spatial extension, default TRUE.
#'  Opt out by closing any active cached connection first (with
#'  `close_connection()`) and re-instantiating the with
#'  `connect(with_spatial = FALSE)`.
#' @param with_h3 install (if missing) and load  the h3 spatial index extension.
#' @returns a [duckdb::duckdb()] connection object
#' @aliases cached_connection duckdb_connect
#' @examplesIf interactive()
#'
#' con <- cached_connection()
#' close_connection(con)
#'
#' @export
#'
cached_connection <- function(dbdir = ":memory:",
                              read_only = FALSE,
                              bigint = "numeric",
                              config = list(temp_directory = tempfile()),
                              autoload_exts =
                                getOption("duckdbfs_autoload_extensions",
                                          TRUE),
                              with_spatial = getOption("duckdbfs_autoload_extensions",
                                                       TRUE),
                              with_h3 = not_windows() && getOption("duckdbfs_autoload_extensions",
                                                                   TRUE)
                              ) {

  #conn <- mget("duckdbfs_conn", envir = duckdbfs_env,
  #             ifnotfound = list(NULL))$duckdbfs_conn

  conn <- getOption("duckdbfs_conn", NULL)

  ## destroy invalid (closed) connections first
  if(inherits(conn, "duckdb_connection")) {
    if(!DBI::dbIsValid(conn)) {
      close_connection(conn)
      conn <- NULL
    }
  }

  if(!inherits(conn, "duckdb_connection")) {
    if(getOption("duckdbfs_debug", FALSE)) {
      message("Making a duckdb connection!")
    }

    conn <- DBI::dbConnect(duckdb::duckdb(),
                           dbdir = dbdir,
                           read_only = read_only,
                           bigint = bigint,
                           config = config)

    if (with_spatial) {
      # can't use load_spatial here, creates infinite recursion
      DBI::dbExecute(conn, "INSTALL spatial;")
      DBI::dbExecute(conn, "LOAD spatial;")
    }

    if (with_h3) {
      DBI::dbExecute(conn, "INSTALL h3 from community;")
      DBI::dbExecute(conn, "LOAD h3;")
    }

    if (autoload_exts) {
      DBI::dbExecute(conn, "SET autoinstall_known_extensions=1;")
      DBI::dbExecute(conn, "SET autoload_known_extensions=1;")
    }

    options(duckdbfs_conn = conn)
    # assign("duckdbfs_conn", conn, envir = duckdbfs_env)

  }

  ## create finalizer to avoid duckdb complaining that connection
  ## was not shut down before gc
  e <- globalenv()
  reg.finalizer(e, function(e) close_connection(),TRUE)

  conn
}



#' close connection
#'
#' @param conn a duckdb connection (leave blank)
#' Closes the invisible cached connection to duckdb
#' @details
#' Shuts down connection before gc removes it.
#' Then clear cached reference to avoid using a stale connection
#' This avoids complaint about connection being garbage collected.
#' @returns returns nothing.
#' @examplesIf interactive()
#'
#' close_connection()
#'
#' @export
close_connection <- function(conn = cached_connection()) {

  if(DBI::dbIsValid(conn)) {
    DBI::dbDisconnect(conn, shutdown=TRUE)
  }

  ## clear cached reference to the now-closed connection
  # name <- ls("duckdbfs_conn", envir = duckdbfs_env)
  #if(length(name) > 0) rm("duckdbfs_conn", envir = duckdbfs_env)
  .Options$duckdbfs_conn <- NULL

  rm(conn)
}



#' @export
duckdb_connect <- cached_connection



not_windows <- function() {
  tolower(Sys.info()[["sysname"]]) != "windows"
}
