#' to_json
#' write data out as a JSON object
#'
#' @inheritParams write_dataset
#' @param options additional options as a char string, see
# https://duckdb.org/docs/sql/statements/copy.html#json-options
to_json <- function(x, dest, con = cached_connection(), array = TRUE, options) {
  sql <- dbplyr::sql_render(x)
  if (array)
    options <- c("ARRAY true", options)

  options <- paste("FORMAT JSON", options, sep = ", ", collapse = ", ")

  q <- glue::glue("COPY ({sql}) TO '{dest}' ({options});")
  #DBI::dbExecute(con, q)
  q
}

