

#' Convert output to sf object
#'
#' @param x a remote duckdb `tbl` (from `open_dataset`) or dplyr-pipeline thereof.
#' @param crs The coordinate reference system, any format understood by `sf::st_crs`.
#' If `NA` (the default), `to_sf()` will pick up the CRS from the column's
#' `GEOMETRY('...')` type annotation when one is present (e.g. when reading
#' a georeferenced file via `open_dataset(format = "sf")`).
#' @param conn the connection object from the tbl.
#' Takes a duckdb table (from `open_dataset`) or a dataset or dplyr
#' pipline and returns an sf object. **Important**: the table must have
#' a `geometry` column, which you will almost always have to create
#' first.
#'
#' Note: `to_sf()` triggers collection into R.  This function is suitable
#' to use at the end of a dplyr pipeline that will subset the data.
#' Using this function on a large dataset without filtering first may
#' exceed available memory.
#' @return an `sf` class object (in memory).
#'
#' @examplesIf interactive()
#'
#' library(dplyr)
#' csv_file <- system.file("extdata/spatial-test.csv", package="duckdbfs")
#'
#' # Note that we almost always must first create a `geometry` column, e.g.
#' # from lat/long columns using the `st_point` method.
#' sf <-
#'   open_dataset(csv_file, format = "csv") |>
#'   mutate(geom = ST_Point(longitude, latitude)) |>
#'   to_sf()
#'
#' # We can use the full space of spatial operations, including spatial
#' # and normal dplyr filters.  All operations are translated into a
#' # spatial SQL query by `to_sf`:
#' open_dataset(csv_file, format = "csv") |>
#'   mutate(geom = ST_Point(longitude, latitude)) |>
#'   mutate(dist = ST_Distance(geom, ST_Point(0,0))) |>
#'   filter(site %in% c("a", "b", "e")) |>
#'   to_sf()
#'
#'
#' @export
to_sf <- function(x,
                  crs = NA,
                  conn = cached_connection()) {

  load_spatial(conn)

  if("geometry" %in% colnames(x)) {
    x <- x |> dplyr::rename(geom=geometry)
  }

  # Inspect the query's geom column type. Native GEOMETRY columns can be
  # read directly by sf; only BLOB / unknown columns need an explicit cast
  # to WKB. GEOMETRY types also carry their CRS annotation, which we use
  # as the default when the caller hasn't supplied `crs`.
  geom_info <- geom_column_info(x, conn, "geom")

  if (geom_info$is_geometry) {
    sql <- dbplyr::sql_render(x)
  } else {
    sql <- x |>
      dplyr::mutate(geom = ST_AsWKB(geom)) |>
      dbplyr::sql_render()
  }

  requireNamespace("sf", quietly = TRUE)
  out <- sf::st_read(conn, query=sql, geometry_column = "geom")

  if (is.na(crs) && !is.na(geom_info$crs)) {
    crs <- geom_info$crs
  }
  if (!is.na(crs)) {
    sf::st_crs(out) <- crs
  }
  out
}

# Internal: inspect a geom column in a lazy query. Returns a list with
#   is_geometry: TRUE when the column type starts with "GEOMETRY"
#   crs: character (e.g. "EPSG:4326") parsed from the type annotation, or NA
geom_column_info <- function(x, conn, col = "geom") {
  default <- list(is_geometry = FALSE, crs = NA_character_)

  sql <- tryCatch(dbplyr::sql_render(x), error = function(e) NULL)
  if (is.null(sql)) return(default)

  schema <- tryCatch(
    DBI::dbGetQuery(conn, paste0("DESCRIBE ", sql)),
    error = function(e) NULL
  )
  if (is.null(schema) || !(col %in% schema$column_name)) return(default)

  col_type <- schema$column_type[schema$column_name == col][[1]]
  if (!grepl("^GEOMETRY", col_type)) return(default)

  crs <- NA_character_
  m <- regmatches(col_type, regexec("GEOMETRY\\('([^']+)'\\)", col_type))[[1]]
  if (length(m) >= 2) crs <- m[[2]]

  list(is_geometry = TRUE, crs = crs)
}

utils::globalVariables(c("ST_AsWKB", "geom", "geometry"), package = "duckdbfs")
