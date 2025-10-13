#' load the duckdb geospatial data plugin
#' @inheritParams load_spatial
#' @param repo repository path for community extensions
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
load_h3 <- function(
  conn = cached_connection(),
  repo = "http://community-extensions.duckdb.org"
) {
  DBI::dbExecute(conn, glue::glue("INSTALL h3 from '{repo}'"))
  status <- DBI::dbExecute(conn, "LOAD h3")

  invisible(status)
}
