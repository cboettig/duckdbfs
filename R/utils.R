tbl_name <- function(path) {
  if (length(path) > 1) {
    path <- path[[1]]
  }
  # sql-safe names based on path
  name <- basename(tools::file_path_sans_ext(path))
  name <- gsub("[^a-zA-Z0-9]", "_", name)
  ## what if it starts with a digit
  if (grepl("^[0-9]", name)) {
    name <- paste0("file_", name)
  }
  name
}

tmp_tbl_name <- function(n = 15) {
  paste0(sample(letters, n, replace = TRUE), collapse = "")
}

remote_src <- function(conn) {
  dbplyr::remote_src(conn)
}

strip_vsi <- function(path) {
  if (grepl("^/vsi\\w+/", path)) {
    path <- gsub("^/vsi\\w+/", "", path)
  }
  path
}


# Convert S3 addresses to http addresses, suitable for sharing publicly.
# no change on paths that are local or already http
s3_as_http <- function(
  path,
  endpoint = Sys.getenv("AWS_S3_ENDPOINT", "s3.amazonaws.com"),
  use_ssl = Sys.getenv("AWS_HTTPS", "TRUE")
) {
  if (use_ssl) {
    http <- "https"
  } else {
    http <- "http"
  }

  # handle GDAL-type paths too
  if (grepl("^/vsis3/", path)) {
    path <- gsub("^/vsis3/", glue::glue("{http}://{endpoint}/"), path)
  }

  if (grepl("^s3://", path)) {
    path <- gsub("^s3://", glue::glue("{http}://{endpoint}/"), path)
  }
  path
}
