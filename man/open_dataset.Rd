% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/open_dataset.R
\name{open_dataset}
\alias{open_dataset}
\title{Open a dataset from a variety of sources}
\usage{
open_dataset(
  sources,
  schema = NULL,
  hive_style = TRUE,
  unify_schemas = FALSE,
  format = c("parquet", "csv", "tsv", "text"),
  conn = cached_connection(),
  tblname = tmp_tbl_name(),
  mode = "VIEW",
  filename = FALSE,
  endpoint = NULL
)
}
\arguments{
\item{sources}{A character vector of paths to the dataset files.}

\item{schema}{The schema for the dataset. If NULL, the schema will be inferred from
the dataset files.}

\item{hive_style}{A logical value indicating whether to the dataset uses
Hive-style partitioning.}

\item{unify_schemas}{A logical value indicating whether to unify the schemas of
the dataset files. If TRUE, will execute a UNION by column name across all files
(NOTE: this can add considerably to the initial execution time)}

\item{format}{The format of the dataset files. One of \code{"parquet"}, \code{"csv"},
\code{"tsv"}, or \code{"text"}.}

\item{conn}{A connection to a database.}

\item{tblname}{The name of the table to create in the database.}

\item{mode}{The mode to create the table in. One of \code{"VIEW"} or \code{"TABLE"}.}

\item{filename}{A logical value indicating whether to include the filename in
the table name.}

\item{endpoint}{optionally, an alternative endpoint for the S3 object store.}
}
\value{
A lazy \code{dplyr::tbl} object representing the opened dataset backed
by a duckdb SQL connection.  Most \code{dplyr} (and some \code{tidyr}) verbs can be
used directly on this object, as they can be translated into SQL commands
automatically via \code{dbplyr}.  Generic R commands require using
\code{dplyr::collect()} on the table, which forces evaluation and reading the
resulting data into memory.
}
\description{
This function opens a dataset from a variety of sources, including Parquet,
CSV, etc, using either local filesystem paths, URLs, or S3 bucket URI notation.
}
\examples{
\dontshow{if (duckdbfs:::example_safe()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
# Open a remote, hive-partitioned Parquet dataset
base <- paste0("https://github.com/duckdb/duckdb/raw/master/",
             "data/parquet-testing/hive-partitioning/union_by_name/")
f1 <- paste0(base, "x=1/f1.parquet")
f2 <- paste0(base, "x=1/f2.parquet")
f3 <- paste0(base, "x=2/f2.parquet")

open_dataset(c(f1,f2,f3))
\dontshow{\}) # examplesIf}
}
