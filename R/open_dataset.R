
open_dataset <- function() {

}


load_httpfs <- function(conn = cached_connection()) {
  status <- DBI::dbExecute(conn, "INSTALL 'httpfs';")
  status <- DBI::dbExecute(conn, "LOAD 'httpfs';")
  invisible(status)
}
