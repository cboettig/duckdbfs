
duckdbfs_env <- new.env()

cached_connection <- function() {
  conn <- mget("duckdbfs_conn", envir = duckdbfs_env,
               ifnotfound = list(NULL))$duckdbfs_conn
  if(!inherits(conn, "duckdb_connection")) {
    print("Making a duckdb connection!")
    conn <- DBI::dbConnect(duckdb::duckdb(), ":memory:")
    assign("duckdbfs_conn", conn, envir = duckdbfs_env)
  }

  e <- environment()
  reg.finalizer(e,
                function(e) close_connection(conn),
                TRUE)
  conn
}


# only needed by finalizer
close_connection <- function(conn = cached_connection()) {
  name <- ls("duckdbfs_conn", envir = duckdbfs_env)
  if(length(name) > 0) rm("duckdbfs_conn", envir = duckdbfs_env)
  if(DBI::dbIsValid(conn)) {
    DBI::dbDisconnect(conn, shutdown=TRUE)
  }
  rm(conn)
}

