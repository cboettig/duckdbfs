
#' duckdb secrets
#'
#' Configure the duckdb secrets for remote access.
#' @inheritParams open_dataset
#' @param key key
#' @param secret secret
#' @param endpoint endpoint address
#' @param bucket restricts the "SCOPE" of this key to only objects in this
#' bucket-name.  note that the bucket name is currently insensitive to endpoint
#' @param url_style path or vhost, for S3
#' @param type Key type, e.g. S3.  See duckdb docs for details.
#' references <https://duckdb.org/docs/configuration/secrets_manager.html>
duckdb_secrets <- function(key = Sys.getenv("AWS_ACCESS_KEY_ID", ""),
                           secret = Sys.getenv("AWS_SECRET_ACCESS_KEY", ""),
                           endpoint = Sys.getenv("AWS_S3_ENDPOINT",
                                                 "s3.amazonaws.com"),
                           bucket = NULL,
                           url_style = NULL,
                           type = "S3",
                           conn = cached_connection()) {

  g <- glue::glue
  if (grepl('amazonaws.com', endpoint)) {
    url_style <- "URL_STYLE 'vhost'"
  } else if (type == "S3") {
    url_style <- "URL_STYLE 'path'"
  } else if (!is.null(url_style)){
    url_style <- g("URL_STYLE '{url_style}'")
  }

  if (is.null(bucket)) {
    bucket = g("SCOPE 's3://{bucket}'")
  }

  query <- paste0(
            g("CREATE OR REPLACE SECRET s3_{key} ("),
            paste(c(
              g("TYPE {type}"),
              g("KEY_ID '{key}'"),
              g("SECRET '{secret}'"),
              g("ENDPOINT '{endpoint}'"),
              url_style,
              bucket),
              collapse = ", "
            ),
            ");"
           )

  DBI::dbExecute(conn, query)
}
