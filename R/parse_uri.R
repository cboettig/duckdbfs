parse_uri <- function(sources, conn) {

  if(all(grepl("^[http|s3:]", sources))) {
    load_httpfs(conn)
  }

  ## for now only parse sources of length-1
  if(length(sources) > 1) return(sources)

  if (grepl("^s3://", sources)) {
    # first strip any * for compatibility
    sources <- gsub("/\\*+$", "", sources)


    url <- httr2::url_parse(sources)

    scheme <- url$query[["scheme"]]
    use_ssl <- identical(scheme, "http")

    duckdb_s3_config(conn = conn,
                     s3_access_key_id = url$username,
                     s3_secret_access_key = url$password,
                     s3_endpoint = url$query[["endpoint_override"]],
                     s3_use_ssl = use_ssl)

    # append ** for recursive search
    sources <- paste0(sources, "**")
  }
  sources
}

