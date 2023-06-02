



open_dataset <- function(sources,
                         schema = NULL,
                         hive_syle = TRUE,
                         unify_schemas = TRUE,
                         format = c("parquet", "csv", "tsv", "text"),
                         conn = cached_connection(),
                         tblname = temp_tbl_name(),
                         mode = "VIEW",
                         filename = TRUE,
                         endpoint = NULL) {

  load_httpfs(conn)

  tblname <- temp_tbl_name()
  view_query <- query_string(tblname,
                             sources,
                             mode = mode,
                             hive_partitioning = hive_syle,
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
  scanner <- "parquet_scan("
  paste0(
    paste("CREATE", mode, tblname, "AS SELECT * FROM"),
    paste0(scanner, source_uris,
           ", HIVE_PARTITIONING=",hive_partitioning,
           ", UNION_BY_NAME=",union_by_name,
           ", FILENAME=",filename,
           ");")
  )
}
#union_by_name=True, filename=True

tmp_table_name <- function(n = 20) {
  paste0("duckdbfs_", sample(letters, n, replace = TRUE), collapse = "")
}

load_httpfs <- function(conn = cached_connection()) {
  status <- DBI::dbExecute(conn, "INSTALL 'httpfs';")
  status <- DBI::dbExecute(conn, "LOAD 'httpfs';")
  invisible(status)
}

set_endpoint <- function(endpoint) {
  DBI::dbExecute(conn, glue("SET s3_endpoint='{endpoint}';"))
  DBI::dbExecute(conn, glue("SET s3_url_style='path';"))
}
