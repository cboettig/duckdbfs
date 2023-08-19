

to_sf <- function(x, geometry_column = "geom", conn = cached_connection()) {
  load_spatial(conn)
  requireNamespace("sf", quietly = TRUE)
  sql <- x |>
    dplyr::mutate(geometry = ST_AsWKB({geometry_column})) |>
    dbplyr::sql_render()
  sf::st_read(conn, query=sql, geometry_column = geometry)
}

utils::globalVariables(c("ST_AsWKB", "geometry"), package = "duckdbfs")
