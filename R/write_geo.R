#' Write a spatial file with gdal
#'
#' @inheritParams write_dataset
#' @param driver driver, see <https://duckdb.org/docs/stable/extensions/spatial/gdal>
#' @param layer_creation_options to GDAL, see <https://duckdb.org/docs/stable/extensions/spatial/gdal>
#' @param srs Set a spatial reference system as metadata to use for the export.
#'  This can be a WKT string, an EPSG code or a proj-string, basically anything
#'  you would normally be able to pass to GDAL. Note that this will not perform
#'  any reprojection of the input geometry, it just sets the metadata if the
#'  target driver supports it.
#' @details NOTE: at this time, duckdb's pre-packaged GDAL does not support s3 writes,
#' and will produce a "Error: Not implemented Error: GDAL Error (6): Seek not supported on writable /vsis3/ files".
#' Use to_geojson() to export using duckdb's native JSON serializer instead.
#' @examplesIf interactive()
#' local_file <-  system.file("extdata/spatial-test.csv", package="duckdbfs")
#' load_spatial()
#' tbl <- open_dataset(local_file, format='csv')
#' write_geo(tbl, "spatial.geojson")
#'
#' @export
write_geo <- function(
    dataset,
    path,
    conn = cached_connection(),
    driver = 'GeoJSON',
    layer_creation_options = 'WRITE_BBOX=YES',
    srs = 'ESPG:4326'
) {
    cols <- paste(colnames(dataset), collapse = ", ")
    sql <- dbplyr::sql_render(dataset)
    q <- glue::glue(
        "
    COPY ({sql}) TO '{path}'
    WITH (FORMAT gdal, DRIVER '{driver}',
          LAYER_CREATION_OPTIONS '{layer_creation_options}',
          SRS '{srs}'
          );
  "
    )
    DBI::dbExecute(conn, q)
}
