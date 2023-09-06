
#' write_dataset
#'
#' @param dataset a remote tbl object from `open_dataset`,
#' or an in-memory data.frame.
#' @param path a local file path or S3 path with write credentials
#' @param conn duckdbfs database connection
#' @param format export format
#' @param partitioning names of columns to use as partition variables
#' @param overwrite allow overwriting of existing files?
#' @param ... additional arguments to [duckdb_s3_config()]
#' @examplesIf interactive()
#'   write_dataset(mtcars, tempfile())
#' @return Returns the path, invisibly.
#' @export
#' @examplesIf interactive()
#' write_dataset(mtcars, tempdir())
#'
write_dataset <- function(dataset,
                          path,
                          conn = cached_connection(),
                          format = c("parquet", "csv"),
                          partitioning = dplyr::group_vars(dataset),
                          overwrite = TRUE,
                          ...) {

  format <- match.arg(format)
  version <- DBI::dbExecute(conn, "PRAGMA version;")

  if(is_not_remote(dataset)) {
    tblname = tmp_tbl_name()
    DBI::dbWriteTable(conn, name = tblname, value = dataset)

  } else {

    tblname <- as.character(dbplyr::remote_name(dataset))

  }

  path <- parse_uri(path, conn = conn, recursive = FALSE)

  ## local writes use different notation to allow overwrites:
  allow_overwrite <- character(0)
  if(overwrite){
    allow_overwrite <- paste("OVERWRITE_OR_IGNORE")
  }

  if(grepl("^s3://", path)) {
    duckdb_s3_config(conn = conn, ...)
    if(overwrite){
     # allow_overwrite <- paste("ALLOW_OVERWRITE", overwrite)
    }
  }


  format <- toupper(format)
  partition_by <- character(0)
  if(length(partitioning) > 0) {
    partition_by <- paste0("PARTITION_BY (",
                           paste(partitioning, collapse=", "),
                           "), ")
  }
  comma <- character(0)
  if (length(c(partition_by, allow_overwrite) > 0)){
    comma <- ", "
  }
  options <-  paste0(
                    paste("FORMAT", "'parquet'"), comma,
                    partition_by,
                    allow_overwrite
                   )

  query <- paste("COPY", tblname, "TO",
                 paste0("'", path, "'"),
                 paste0("(",  options, ")"), ";")


  status <- DBI::dbSendQuery(conn, query)
  invisible(path)
}

is_not_remote <- function(x) {
  is.null(suppressWarnings(dbplyr::remote_src(x)))
}
