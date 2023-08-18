parse_uri <- function(sources, conn) {

  if(all(grepl("^[http|s3:]", sources))) {
    load_httpfs(conn)
  }

  ## for now only parse sources of length-1
  if(length(sources) > 1) return(sources)

  if (grepl("^s3://", sources)) {
    # first strip any * for compatibility
    sources <- gsub("/\\*+$", "", sources)


    url <- url_parse(sources)
    scheme <- url$query[["scheme"]]
    use_ssl <- identical(scheme, "http")

    if(identical(url$username, "anonymous")) {
      url$username <- ""
      url$password <- ""
    }



    duckdb_s3_config(conn = conn,
                     s3_access_key_id = url$username,
                     s3_secret_access_key = url$password,
                     s3_session_token = url$token,
                     s3_endpoint = url$query[["endpoint_override"]],
                     s3_use_ssl = use_ssl)

    # append ** for recursive search
    sources <- paste0(sources, "/**")
  }
  sources
}




## Adapted from httr2 0.2.3, MIT License, RStudio
parse_match <- function(x,pattern) {
  m <- regexec(pattern, x, perl = TRUE)
  pieces <- regmatches(x, m)[[1]][-1]
  lapply(pieces, empty_to_null)
}

empty_to_null <- function(x) {
  if (x == "")
    NULL
  else x
}
null_to_empty <- function(x) {
  if (is.null(x))
    ""
  else x
}

parse_delim <- function(x, delim, quote = "\"", ...) {
  scan(text = x, what = character(), sep = delim, quote = quote,
       quiet = TRUE, strip.white = TRUE, ...)
}

parse_name_equals_value <- function (x) {
  loc <- regexpr("=", x, fixed = TRUE)
  pieces <- regmatches(x, loc, invert = TRUE)
  expand <- function(x) if (length(x) == 1)
    c(x, "")
  else x
  pieces <- lapply(pieces, expand)
  val <- trimws(vapply(pieces, "[[", "", 2))
  name <- trimws(vapply(pieces, "[[", "", 1))
  stats::setNames(as.list(val), name)
}

query_parse <- function(x) {
  x <- gsub("^\\?", "", x)
  params <- parse_name_equals_value(parse_delim(x, "&"))
  if (length(params) == 0) {
    return(NULL)
  }
  #out <- as.list(curl::curl_unescape(params))
  #names(out) <- curl::curl_unescape(names(params))
  #out
  params
}


url_parse <- function(url) {

  pieces <- parse_match(url, "^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?")
  scheme <- pieces[[2]]
  authority <- null_to_empty(pieces[[4]])
  path <- pieces[[5]]
  query <- pieces[[7]]
  if (!is.null(query)) {
    query <- query_parse(query)
  }
  fragment <- pieces[[9]]
  pieces <- parse_match(authority, "^(([^@]+)@)?([^:]+)?(:([^#]+))?")


  token <- NULL
  username <- NULL
  password <- NULL

  userinfo <- pieces[[2]]
  if (!is.null(userinfo)) {

    if (grepl(":", userinfo)) {
      keys <- strsplit(userinfo, ":")[[1]]
      if(length(keys) > 0) {
        username <- keys[1]
      }
      if(length(keys) > 0) {
        password <- keys[2]
      }
      if(length(keys) > 1) {
        token <- keys[3]
      }
    }
    else {
      userinfo <- list(userinfo, NULL)
    }
  }
  hostname <- pieces[[3]]
  port <- pieces[[5]]
  structure(list(scheme = scheme, hostname = hostname, username = username,
                 password = password, token = token, port = port, path = path,
                 query = query, fragment = fragment))
}


