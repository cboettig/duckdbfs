
duckdbfs_env <- new.env()


# consider making persistent storage when mode=TABLE
# to avoid reading entirely into RAM
cached_connection <- function() {
  #conn <- mget("duckdbfs_conn", envir = duckdbfs_env,
  #             ifnotfound = list(NULL))$duckdbfs_conn
  conn <- getOption("duckdbfs_conn", NULL)
  if(!inherits(conn, "duckdb_connection")) {
    if(getOption("duckdbfs_debug", FALSE)) print("Making a duckdb connection!")
    conn <- DBI::dbConnect(duckdb::duckdb(), ":memory:")
    options(duckdbfs_conn = conn)
    # assign("duckdbfs_conn", conn, envir = duckdbfs_env)
  }

  # prevent gc from removing connection (envir / options copy doesn't help)
  # .duckdbfs_conn <<- conn

  ## create finalizer to avoid duckdb complaining that connection
  ## was not shut down before gc
  #e <- environment()
  #reg.finalizer(e, function(e) close_connection(conn),TRUE)
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
#' @export
#' @examples
#'
#' close_connection()
#'
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

