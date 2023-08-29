
s3_bucket <- function(bucket, anonymous = NULL, access_key = NULL,
                      secret_key = NULL, session_token = NULL,
                      region = NULL, endpoint_override = NULL, scheme = NULL,
                      conn = cached_connection()) {

  if (!grepl("^s3://", bucket)) {
    bucket <- paste0("s3://", bucket)
  }

  duckdb_s3_config(conn = conn,
                   anonymous = anonymous,
                   s3_access_key_id = access_key,
                   s3_secret_access_key = secret_key,
                   s3_session_token = session_token,
                   s3_endpoint = endpoint_override,
                   s3_use_ssl = !identical(scheme, "http"),
                   )
  return(bucket)

}
