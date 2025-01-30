


#' load the duckdb geospatial data plugin
#' @inheritParams load_spatial
#' @return loads the extension and returns status invisibly.
#' @references <https://github.com/isaacbrodsky/h3-duckdb>
#'
#' @examplesIf interactive()
#'
#' library(dplyr)
#' load_h3()
#' ex <- system.file("extdata/spatial-test.csv", package="duckdbfs")
#'
#' zoom <- 9L # Zoom must be explicit integer, L
#' query <- ex |>
#'   open_dataset(format = "csv") |>
#'   mutate(h3id = h3_latlng_to_cell_string(latitude, longitude, zoom))
#'
#'  # as data.frame
#'  collect(query)
#'
#'  # write to a file
#'  path <- tempfile(fileext = ".h3j")
#'  query |> to_h3j(path)
#'
#' @export
load_h3 <- function(conn = cached_connection()) {

  DBI::dbExecute(conn, "INSTALL h3 from community")
  status <- DBI::dbExecute(conn, "LOAD h3")

  invisible(status)
}


#' Write H3 hexagon data out as an h3j-compliant JSON file
#' NOTE: the column containing H3 hashes must be named `hexid`
#'
#' @inheritParams write_dataset
#' @examplesIf interactive()
#' # example code
#'
#' @export
to_h3j <- function(dataset, path, conn = cached_connection()) {
  cols <- paste(colnames(dataset), collapse = ", ")
  sql <- dbplyr::sql_render(dataset)
  q <- glue::glue("
    COPY (
      WITH t1 AS ({sql})
      SELECT json_group_array(struct_pack({cols}))
      AS cells
      FROM t1
    ) TO '{path}' (FORMAT JSON)
  ")
  DBI::dbExecute(conn, q)
}
