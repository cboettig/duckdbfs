% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/duckdb_config.R
\name{duckdb_extensions}
\alias{duckdb_extensions}
\title{show duckdb extensions}
\usage{
duckdb_extensions(conn = cached_connection())
}
\arguments{
\item{conn}{A connection to a database.}
}
\value{
a data frame listing all available extensions, with boolean columns
indicating which extensions are installed or loaded, and a description of each
extension.
}
\description{
show duckdb extensions
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
duckdb_extensions()
\dontshow{\}) # examplesIf}
}
