% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/h3.R
\name{load_h3}
\alias{load_h3}
\title{load the duckdb geospatial data plugin}
\usage{
load_h3(conn = cached_connection())
}
\arguments{
\item{conn}{A database connection object created using the
\code{cache_connection} function (default: \code{cache_connection()}).}
}
\value{
loads the extension and returns status invisibly.
}
\description{
load the duckdb geospatial data plugin
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}

library(dplyr)
load_h3()
ex <- system.file("extdata/spatial-test.csv", package="duckdbfs")

zoom <- 9L # Zoom must be explicit integer, L
query <- ex |>
  open_dataset(format = "csv") |>
  mutate(h3id = h3_latlng_to_cell_string(latitude, longitude, zoom))

 # as data.frame
 collect(query)

 # write to a file
 path <- tempfile(fileext = ".h3j")
 query |> to_h3j(path)
\dontshow{\}) # examplesIf}
}
\references{
\url{https://github.com/isaacbrodsky/h3-duckdb}
}
