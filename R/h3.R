


#' load the duckdb geospatial data plugin
#'
#' @param force force re-install?
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
load_h3 <- function(conn = cached_connection(),
                         force = FALSE) {

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
to_h3j <- function(x, dest, con = cached_connection()) {
  cols <- paste(colnames(x), collapse = ", ")
  sql <- dbplyr::sql_render(x)
  q <- glue::glue("
    COPY (
      WITH t1 AS ({sql})
      SELECT json_group_array(struct_pack({cols}))
      AS cells
      FROM t1
    ) TO '{dest}' (FORMAT JSON)
  ")
  DBI::dbExecute(con, q)
}
