#' Write H3 hexagon data out as an h3j-compliant JSON file
#' NOTE: the column containing H3 hashes must be named `hexid`
#'
#' @inheritParams write_dataset
#' @examplesIf interactive()
#' # example code
#'
#' @export
to_h3j <- function(dataset, path, conn = cached_connection(), as_http = FALSE) {
    cols <- paste(colnames(dataset), collapse = ", ")
    sql <- dbplyr::sql_render(dataset)
    q <- glue::glue(
        "
    COPY (
      WITH t1 AS ({sql})
      SELECT json_group_array(struct_pack({cols}))
      AS cells
      FROM t1
    ) TO '{path}' (FORMAT JSON)
  "
    )
    DBI::dbExecute(conn, q)
    if (as_http) {
        path <- s3_as_http(path)
    }
    invisible(path)
}
