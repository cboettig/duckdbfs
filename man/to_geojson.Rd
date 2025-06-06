% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/write_dataset.R
\name{to_geojson}
\alias{to_geojson}
\title{Write geojson using duckdb's native JSON writer}
\usage{
to_geojson(dataset, path, conn = cached_connection(), id_col = "iso_a3")
}
\arguments{
\item{dataset}{a remote tbl object from \code{open_dataset},
or an in-memory data.frame.}

\item{path}{a local file path or S3 path with write credentials}

\item{conn}{duckdbfs database connection}

\item{id_col}{pick a column as the id column}
}
\description{
Write geojson using duckdb's native JSON writer
}
