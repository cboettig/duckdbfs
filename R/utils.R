
tmp_tbl_name <- function(n = 15) {
  paste0(sample(letters, n, replace = TRUE), collapse = "")
}

remote_src <- function(conn) {
  dbplyr::remote_src(conn)
}

strip_vsi <- function(path) {
  if(grepl("^/vsi\\w+/", path)) {
    path <- gsub("^/vsi\\w+/", "", path)
  }
  path
}
