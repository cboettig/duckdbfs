
#' duckdb secrets
#'
#' Configure the duckdb secrets for remote access.
#' @inheritParams open_dataset
#' @param key key
#' @param secret secret
#' @param endpoint endpoint address
#' @param region AWS region (ignored by some other S3 providers)
#' @param bucket restricts the "SCOPE" of this key to only objects in this
#' bucket-name.  note that the bucket name is currently insensitive to endpoint
#' @param url_style path or vhost, for S3
#' @param use_ssl Use SSL address (https instead of http), default TRUE
#' @param url_compatibility_mode optional mode for increased compatibility with some endpoints
#' @param session_token AWS session token, used in some AWS authentication with short-lived tokens
#' @param type Key type, e.g. S3.  See duckdb docs for details.
#' references <https://duckdb.org/docs/configuration/secrets_manager.html>
#' @export
duckdb_secrets <- function(key = Sys.getenv("AWS_ACCESS_KEY_ID", ""),
                           secret = Sys.getenv("AWS_SECRET_ACCESS_KEY", ""),
                           endpoint = Sys.getenv("AWS_S3_ENDPOINT",
                                                 "s3.amazonaws.com"),
                           region = Sys.getenv("AWS_REGION",  "us-east-1"),
                           bucket = NULL,
                           url_style = NULL,
                           use_ssl = Sys.getenv("AWS_HTTPS", "TRUE"),
                           url_compatibility_mode = TRUE,
                           session_token = Sys.getenv("AWS_SESSION_TOKEN", ""),
                           type = "S3",
                           conn = cached_connection()) {

  g <- glue::glue

  if (!is.null(url_style)){
    url_style <- g("URL_STYLE '{url_style}'")
  } else { 
    if (grepl('amazonaws.com', endpoint)) {
      url_style <- "URL_STYLE 'vhost'"
    } else if (type == "S3") {
      url_style <- "URL_STYLE 'path'"
    }
  }


  if (!is.null(bucket)) {
    bucket <- g("SCOPE 's3://{bucket}'")
  }

  if(!is.null(session_token) || session_token != "") {
    session_token <- g("SESSION_TOKEN '{session_token}'")
  }

  query <- paste0(
            g("CREATE OR REPLACE SECRET s3_{key} ("),
            paste(c(
              g("TYPE {type}"),
              g("KEY_ID '{key}'"),
              g("SECRET '{secret}'"),
              g("ENDPOINT '{endpoint}'"),
              g("REGION '{region}'"),
              g("URL_COMPATIBILITY_MODE {url_compatibility_mode}"),
              g("USE_SSL {use_ssl}"),
              url_style,
              bucket,
              session_token),
              collapse = ", "
            ),
            ");"
           )

  DBI::dbExecute(conn, query)
}

