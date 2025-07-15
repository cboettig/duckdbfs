
#' write_dataset
#'
#' @param dataset a remote tbl object from `open_dataset`,
#' or an in-memory data.frame.
#' @param path a local file path or S3 path with write credentials
#' @param conn duckdbfs database connection
#' @param format export format
#' @param partitioning names of columns to use as partition variables
#' @param overwrite allow overwriting of existing files?
#' @param options Additional arguments to COPY, see <https://duckdb.org/docs/stable/sql/statements/copy.html#copy--to-options>
#' Note, uses duckdb native syntax, e.g. c("PER_THREAD_OUTPUT false"), for named arguments, see examples. 
#' (Recall SQL is case-insensitive).
#' @param ... additional arguments to [duckdb_s3_config()]
#' @examplesIf interactive()
#'   write_dataset(mtcars, tempfile())
#' @return Returns the path, invisibly.
#' @export
#' @examplesIf interactive()
#' write_dataset(mtcars, tempdir())
#' write_dataset(mtcars, tempdir(), options = c("PER_THREAD_OUTPUT FALSE", "RETURN_STATS TRUE"))
#'
write_dataset <- function(dataset,
                          path,
                          conn = cached_connection(),
                          format = c("parquet", "csv"),
                          partitioning = dplyr::group_vars(dataset),
                          overwrite = TRUE,
                          options = list(),
                          ...) {

  format <- match.arg(format)
  version <- DBI::dbExecute(conn, "PRAGMA version;")

  if(is_not_remote(dataset)) {
    tblname = tmp_tbl_name()
    DBI::dbWriteTable(conn, name = tblname, value = dataset)

  } else {
    tblname <- as.character(remote_name(dataset, conn))
  }

  ## local writes use different notation to allow overwrites:
  allow_overwrite <- character(0)
  if(overwrite){
    allow_overwrite <- "OVERWRITE_OR_IGNORE"
  }

  path <- parse_uri(path, conn = conn, recursive = FALSE)
  if(grepl("^s3://", path)) {
    duckdb_s3_config(conn = conn, ...)
  }

  partition_by <- character(0)
  if(length(partitioning) > 0) {
    partition_by <- paste0("PARTITION_BY (",
                           paste(partitioning, collapse=", "),
                           ") ")
  }

  format <- toupper(format)
  format_by <- glue::glue("FORMAT {format}")
  options_vec <- c(format_by, partition_by, allow_overwrite, options)
  copy_options <- glue::glue_collapse(options_vec, sep = ", ")

  copy <- glue::glue("COPY {tblname} TO '{path}' ")
  query <- glue::glue(copy, "({copy_options})", ";")
  status <- DBI::dbSendQuery(conn, query)
  invisible(path)
}

is_not_remote <- function(x) {
  is.null(suppressWarnings(dbplyr::remote_src(x)))
}


remote_name <- function (x, con)
{
  out <- dbplyr::remote_name(x)
  if(is.null(out))
    out <- paste0("(", dbplyr::sql_render(x$lazy_query, con = con), ")")
  out
}

#' as_dataset
#'
#' Push a local (in-memory) dataset into a the duckdb database as a table.
#' This enables it to share the connection source with other data.
#' This is equivalent to the behavior of copy=TRUE on many (but not all) of the two-table verbs in dplyr.
#' @param df a local data frame.  Otherwise will be passed back without side effects
#' @return a remote `dplyr::tbl` connection to the table.
#' @inheritParams open_dataset
#' @export
as_dataset <- function(df, conn = cached_connection()) {
  if(is_not_remote(df)) {
    tblname = tmp_tbl_name()
    DBI::dbWriteTable(conn, name = tblname, value = df)
    df = dplyr::tbl(conn, tblname)
  }
  return(df)
}






#' Write a spatial file with gdal
#'
#' @inheritParams write_dataset
#' @param driver driver, see <https://duckdb.org/docs/stable/extensions/spatial/gdal>
#' @param layer_creation_options to GDAL, see <https://duckdb.org/docs/stable/extensions/spatial/gdal>
#'
#' @details NOTE: at this time, duckdb's pre-packaged GDAL does not support s3 writes,
#' and will produce a "Error: Not implemented Error: GDAL Error (6): Seek not supported on writable /vsis3/ files".
#' Use to_geojson() instead.
#' @examplesIf interactive()
#' local_file <-  system.file("extdata/spatial-test.csv", package="duckdbfs")
#' load_spatial()
#' tbl <- open_dataset(local_file, format='csv')
#' write_geo(tbl, "spatial.geojson")
#'
#' @export
write_geo <- function(dataset,
                      path,
                      conn = cached_connection(),
                      driver = 'GeoJSON',
                      layer_creation_options = 'WRITE_BBOX=YES') {
  cols <- paste(colnames(dataset), collapse = ", ")
  sql <- dbplyr::sql_render(dataset)
  q <- glue::glue("
    COPY ({sql}) TO '{path}'
    WITH (FORMAT gdal, DRIVER '{driver}',
          LAYER_CREATION_OPTIONS '{layer_creation_options}');
  ")
  DBI::dbExecute(conn, q)
}



#' Write geojson using duckdb's native JSON writer
#'
#' @inheritParams write_dataset
#' @param id_col pick a column as the id column
#'
#' @export
to_geojson <- function(dataset, path, conn = cached_connection(),
                       id_col = "iso_a3") {

  if ("geom" %in% colnames(dataset)) {
    dataset <- dplyr::rename(dataset,geometry = geom)
  }




  # remove geometry column
  collection <- glue::glue_sql("'FeatureCollection'", .con = conn)
  sql <- dbplyr::sql_render(dataset)


  q <- glue::glue("
   COPY (
     WITH t1 AS (<sql>)
     SELECT json_group_array(
                {'type': 'Feature',
                 'properties': {'<id_col>': t1.<id_col>},
                 'geometry': ST_AsGeoJSON(t1.geometry)
                }) as features,
                <collection> as type
         FROM t1
  ) TO '<path>' (FORMAT json);
  ", .open="<", .close=">")

  DBI::dbExecute(conn, q)
}


#local_file <-  system.file("extdata/world.fgb", package="duckdbfs")
#dataset <- open_dataset(local_file, format='sf') |> head(3)
#dataset |> to_geojson("testme.json")
#terra::vect("testme.json")


utils::globalVariables(c("geom", "geometry"), package="duckdbfs")

