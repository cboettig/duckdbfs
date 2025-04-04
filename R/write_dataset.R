
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
    tblname <- as.character(remote_name(dataset, conn))
  }

  ## local writes use different notation to allow overwrites:
  allow_overwrite <- character(0)
  if(overwrite){
    allow_overwrite <- "OVERWRITE_OR_IGNORE"
  }

  path <- parse_uri(path, conn = conn, recursive = FALSE)
  if(grepl("^s3://", path)) {
    duckdb_s3_config(conn = conn, ...)
  }

  partition_by <- character(0)
  if(length(partitioning) > 0) {
    partition_by <- paste0("PARTITION_BY (",
                           paste(partitioning, collapse=", "),
                           ") ")
  }

  format <- toupper(format)
  format_by <- glue::glue("FORMAT {format}")
  options_vec <- c(format_by, partition_by, allow_overwrite)
  options <- glue::glue_collapse(options_vec, sep = ", ")

  copy <- glue::glue("COPY {tblname} TO '{path}' ")
  query <- glue::glue(copy, "({options})", ";")
  status <- DBI::dbSendQuery(conn, query)
  invisible(path)
}

is_not_remote <- function(x) {
  is.null(suppressWarnings(dbplyr::remote_src(x)))
}


remote_name <- function (x, con)
{
  out <- dbplyr::remote_name(x)
  if(is.null(out))
    out <- paste0("(", dbplyr::sql_render(x$lazy_query, con = con), ")")
  out
}

#' as_dataset
#'
#' Push a local (in-memory) dataset into a the duckdb database as a table.
#' This enables it to share the connection source with other data.
#' This is equivalent to the behavior of copy=TRUE on many (but not all) of the two-table verbs in dplyr.
#' @param df a local data frame.  Otherwise will be passed back without side effects
#' @return a remote `dplyr::tbl` connection to the table.
#' @inheritParams open_dataset
#' @export
as_dataset <- function(df, conn = cached_connection()) {
  if(is_not_remote(df)) {
    tblname = tmp_tbl_name()
    DBI::dbWriteTable(conn, name = tblname, value = df)
    df = dplyr::tbl(conn, tblname)
  }
  return(df)
}






#' Write H3 hexagon data out as an h3j-compliant JSON file
#' NOTE: the column containing H3 hashes must be named `hexid`
#'
#' @inheritParams write_dataset
#' @examplesIf interactive()
#' # example code
#'
#' @export
write_geo <- function(dataset, path, conn = cached_connection()) {
  cols <- paste(colnames(dataset), collapse = ", ")
  sql <- dbplyr::sql_render(dataset)
  q <- glue::glue("
    COPY ({sql}) TO '{path}'
    WITH (FORMAT gdal, DRIVER 'GeoJSON',
          LAYER_CREATION_OPTIONS 'WRITE_BBOX=YES');
  ")
  DBI::dbExecute(conn, q)
}
