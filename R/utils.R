
tbl_name <- function(path) {
  if (length(path) > 1) {
    path <- path[[1]]
  }
  # sql-safe names based on path
  name <- basename(tools::file_path_sans_ext(path))
  name <- gsub("[^a-zA-Z0-9]", "_", name)
  ## what if it starts with a digit
  if (grepl("^[0-9]", name)) name <- paste0("file_", name)
  name
}

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
