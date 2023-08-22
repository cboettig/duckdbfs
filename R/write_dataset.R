
#' write_dataset
#'
#' @param dataset a remote tbl object from `open_dataset`,
#' or an in-memory data.frame.
#' @param path a local file path or S3 path with write credentials
#' @param conn duckdbfs database connection
#' @param ... additional arguments to [duckdb_s3_config()]
#' @examplesIf interactive()
#'   write_dataset(mtcars, tempfile())
#'
#' @export
write_dataset <- function(dataset,
                          path,
                          conn = cached_connection(),
                          ...) {
  if(is.null(dbplyr::remote_src(dataset))) {
    tblname = tmp_tbl_name()
    DBI::dbWriteTable(conn, name = tblname, value = dataset)
  } else {
    tblname <- as.character(dbplyr::remote_name(dataset))
  }

  path <- parse_uri(path, conn = conn, recursive = FALSE)

  if(grepl("^s3://", path)) {
    load_httpfs(conn)
    duckdb_s3_config(conn = conn, ...)

    query <- paste("COPY", tblname, "TO", paste0("'", path, "'"))
  } else {

    query <- paste("COPY", tblname, "TO",
                   paste0("'", path, "'"),
                   "(FORMAT PARQUET);")
  }

  DBI::dbSendQuery(conn, query)
}
