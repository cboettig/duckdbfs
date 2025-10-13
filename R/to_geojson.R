#' Write geojson using duckdb's native JSON writer
#'
#' @inheritParams write_dataset
#' @param id_col (deprecated). to_geojson() will preserve all atomic columns
#' as properties.
#' @return path, invisibly
#' @export
to_geojson <- function(
    dataset,
    path,
    conn = cached_connection(),
    id_col = NULL,
    as_http = FALSE
) {
    # In geojson it must be called "geometry"
    dataset <- safe_geometry_name(dataset)
    # Forget about nested list columns/properties
    dataset <- drop_nested_cols(dataset)

    who <- colnames(dataset)
    properties <- who[who != "geometry"]

    collection <- glue::glue_sql("'FeatureCollection'", .con = conn)
    sql <- dbplyr::sql_render(dataset)

    # Build the properties object dynamically
    prop_pairs <- paste0("'", properties, "': t1.", properties, collapse = ", ")

    q <- glue::glue(
        "
   COPY (
     WITH t1 AS (<sql>)
     SELECT json_group_array(
                {'type': 'Feature',
                 'properties': {<prop_pairs>},
                 'geometry': ST_AsGeoJSON(t1.geometry)
                }) as features,
                <collection> as type
         FROM t1
  ) TO '<path>' (FORMAT json);
  ",
        .open = "<",
        .close = ">"
    )

    DBI::dbExecute(conn, q)

    if (as_http) {
        path <- s3_as_http(path)
    }

    invisible(path)
}

# Make geometry column always called "geometry" (GeoJSON standard name)
safe_geometry_name <- function(dataset) {
    # FIXME identify geometry-type column in duckdb.
    # error if there are multiple such.
    if ("geom" %in% colnames(dataset)) {
        dataset <- dplyr::rename(dataset, geometry = geom)
    }
    if ("Shape" %in% colnames(dataset)) {
        dataset <- dplyr::rename(dataset, geometry = Shape)
    }
    if ("SHAPE" %in% colnames(dataset)) {
        dataset <- dplyr::rename(dataset, geometry = SHAPE)
    }
    dataset
}

drop_nested_cols <- function(gdf) {
    # Use native R types from parsing first row.
    if (inherits(gdf, "tbl_lazy")) {
        x <- dplyr::collect(utils::head(gdf, 1))
    }
    keep <- lapply(x, function(x) is.atomic(x) || inherits(x, "sfc"))
    cols <- c(names(keep[unlist(keep)]), "geometry")
    dplyr::select(gdf, dplyr::any_of(cols))
}

utils::globalVariables(
    c("geom", "geometry", "Shape", "SHAPE"),
    package = "duckdbfs"
)

# smoketest
#local_file <- system.file("extdata/world.fgb", package = "duckdbfs")
#dataset <- open_dataset(local_file, format = 'sf') |> head(3)
#dataset |> to_geojson("testme.json")
#terra::vect("testme.json")
