#' spatial_join
#'
#' @param x a duckdb table with a spatial geometry column called "geom"
#' @param y a duckdb table with a spatial geometry column called "geom"
#' @param by A spatial join function, see details.
#' @param join JOIN type (left, right, inner, full)
#' @param args additional arguments to join function (e.g. distance for st_dwithin)
#' @param tblname name for the temporary view
#' @param conn the duckdb connection (imputed by duckdbfs by default,
#' must be shared across both tables)
#' @return a (lazy) view of the resulting table. Users can continue to operate
#' on using dplyr operations and call to_st() to collect this as an sf object.
#' @details
#'
#' Possible [spatial joins](https://postgis.net/workshops/postgis-intro/spatial_relationships.html) include:
#'
#' Function            | Description
#' -------------------- | --------------------------------------------------------------------------------------------
#' st_intersects       | Geometry A intersects with geometry B
#' st_disjoint         | The complement of intersects
#' st_within           | Geometry A is within geometry B (complement of contains)
#' st_dwithin          | Geometries are within a specified distance, expressed in the same units as the coordinate reference system.
#' st_touches          | Two polygons touch if the that have at least one point in common, even if their interiors do not touch.
#' st_contains         | Geometry A entirely contains to geometry B. (complement of within)
#' st_containsproperly | stricter version of `st_contains` (boundary counts as external)
#' st_covers           | geometry B is inside or on boundary of A. (A polygon covers a point on its boundary but does not contain it.)
#' st_overlaps         | geometry A intersects but does not completely contain geometry B
#' st_equals           | geometry A is equal to geometry B
#' st_crosses          | Lines or points in geometry A cross geometry B.
#'
#' All though SQL is not case sensitive, this function expects only
#' lower case names for "by" functions.
#'
#' @examplesIf interactive()
#'
#' # note we can read in remote data in a variety of vector formats:
#' countries <-
#' paste0("/vsicurl/",
#'        "https://github.com/cboettig/duckdbfs/",
#'        "raw/spatial-read/inst/extdata/world.gpkg") |>
#' open_dataset(format = "sf")
#'
#' cities <-
#'  paste0("/vsicurl/https://github.com/cboettig/duckdbfs/raw/",
#'         "spatial-read/inst/extdata/metro.fgb") |>
#'  open_dataset(format = "sf")
#'
#' countries |>
#'   dplyr::filter(iso_a3 == "AUS") |>
#'   spatial_join(cities)
#'
#' @export
spatial_join <- function(x,
                         y,
                         by=c("st_intersects", "st_within",
                              "st_dwithin", "st_touches",
                              "st_contains", "st_containsproperly",
                              "st_covers", "st_overlaps",
                              "st_crosses", "st_equals",
                              "st_disjoint"),
                         args = "",
                         join="left",
                         tblname =  tmp_tbl_name(),
                         conn = cached_connection()) {

  by <- match.arg(by)
  ## x,y may be promised queries
  x <- as_view(x)
  y <- as_view(y)

  # buil spatial join query
  x.name <- remote_name(x, conn)
  y.name <- remote_name(y, conn)
  x.geom <- paste0(x.name, ".geom")
  y.geom <- paste0(y.name, ".geom")

  if(args != ""){
    args <- paste(",", args)
  }

  # be more careful than SELECT *

  # x.geom becomes the "geom" column, y.geom becomes geom:1
  query <- paste(
    "SELECT *",
    "FROM", x.name,
    join, "JOIN", y.name,
    "ON", paste0(by, "(", x.geom, ", ", y.geom, args, ")")
  )
  query_to_view(query, tblname, conn)

}


#' as_view
#'
#' Create a View of the current query.  This can be an effective way to allow
#' a query chain to remain lazy
#' @param x a duckdb spatial dataset
#' @inheritParams open_dataset
#' @examplesIf interactive()
#' path <- system.file("extdata/spatial-test.csv", package="duckdbfs")
#' df <- open_dataset(path)
#' library(dplyr)
#'
#' df |> filter(latitude > 5) |> as_view()
#'
#' @export
as_view <- function(x, tblname =  tmp_tbl_name(), conn = cached_connection()) {

  # assert x is a tbl_lazy, a tbl_sql, and a tbl_duckdb_connection

  ## lazy_base_query objects are good to go.
  if(inherits(x$lazy_query, "lazy_base_query")) {
    return(x)
  }
  ## lazy_select_query objects are unnamed,
  ## convert to named views so we can re-use them in queries
  q <- dbplyr::sql_render(x)
  query_to_view(q, tblname, conn)
}

query_to_view <- function(query,
                          tblname =  tmp_tbl_name(),
                          conn = cached_connection()) {
  q <- paste("CREATE OR REPLACE TEMPORARY VIEW", tblname, "AS", query)
  DBI::dbSendQuery(conn, q)
  dplyr::tbl(conn, tblname)
}
