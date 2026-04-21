has_spatial <- function() {
  duckdbfs::duckdb_extensions() |>
    dplyr::filter(extension_name == "spatial") |>
    dplyr::pull(installed)
}
