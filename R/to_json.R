#' to_json
#' write data out as a JSON object
#'
#' @inheritParams write_dataset
#' @param array generate a JSON array?
#' @param options additional options
#' @param options additional options as a char string, see
# https://duckdb.org/docs/sql/statements/copy.html#json-options
to_json <- function(dataset,
                    path,
                    conn = cached_connection(),
                    array = TRUE,
                    options = NULL) {
  sql <- dbplyr::sql_render(dataset)
  if (array)
    options <- c("ARRAY true", options)

  options <- paste("FORMAT JSON", options, sep = ", ", collapse = ", ")

  q <- glue::glue("COPY ({sql}) TO '{path}' ({options});")
  DBI::dbExecute(conn, q)

}

