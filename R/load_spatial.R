has_spatial <- function() {
    duckdbfs::duckdb_extensions() |>
        dplyr::filter(extension_name == "spatial") |>
        dplyr::pull(installed)
}

#' load the duckdb geospatial data plugin
#'
#' @inheritParams duckdb_s3_config
#' @param nightly should we use the nightly version or not?
#'   default FALSE, configurable as `duckdbfs_use_nightly` option.
#' @param force force re-install?
#' @return loads the extension and returns status invisibly.
#' @references <https://duckdb.org/docs/extensions/spatial.html>
#' @export
load_spatial <- function(
    conn = cached_connection(),
    nightly = getOption("duckdbfs_use_nightly", FALSE),
    force = FALSE
) {
    load_extension("spatial", conn = conn, nightly = nightly, force = force)
}
