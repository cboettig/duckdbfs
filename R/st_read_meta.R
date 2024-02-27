
#url <- "https://github.com/duckdb/duckdb_spatial/raw/main/test/data/amsterdam_roads.fgb"
#path <- paste0("/vsicurl/", url)

#' read spatial metadata
#'
#' At this time, reads a subset of spatial metadata.
#' This is similar to what is reported by `ogrinfo -json`
#' @param path URL or path to spatial data file
#' @param layer layer number to read metadata for, defaults to first layer.
#' @param tblname metadata will be stored as a view with this name,
#' by default this is based on the name of the file.
#' @inheritParams open_dataset
#' @return  A lazy `dplyr::tbl` object containing core spatial metadata such
#' as projection information.
#' @export
#' @examplesIf interactive()
#' st_read_meta("https://github.com/duckdb/duckdb_spatial/raw/main/test/data/amsterdam_roads.fgb")
#'
st_read_meta <- function(path,
                         layer = 1L,
                         tblname = basename(tools::file_path_sans_ext(path)),
                         conn = cached_connection(),
                         ...){


  duckdbfs::duckdb_s3_config(conn, ...)
  load_httpfs(conn)
  load_spatial(conn)

  ##strip VSI, not supported
  path <- strip_vsi(path)
  query <- glue::glue(
  "CREATE OR REPLACE VIEW {tblname}_meta AS SELECT
    layers[{i}].feature_count as feature_count,
    layers[{i}].geometry_fields[1].name as geom_column_name,
    layers[{i}].geometry_fields[1].type as geom_type,
    layers[{i}].geometry_fields[1].crs.auth_name as name,
    layers[{i}].geometry_fields[1].crs.auth_code as code,
    layers[{i}].geometry_fields[1].crs.wkt as wkt,
    layers[{i}].geometry_fields[1].crs.proj4 as proj4
    FROM st_read_meta('{path}');
    ", i = layer)

  DBI::dbSendQuery(conn, query)
  out <- dplyr::tbl(conn, glue::glue("{tblname}_meta"))
  dplyr::collect(out) # small table, no point in being lazy
}

