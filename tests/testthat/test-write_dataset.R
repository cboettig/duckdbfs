
#' Note that it is not possible to open from one S3 source and write to another
#'
test_that("write_dataset", {

  skip_on_cran()
  ## write an in-memory dataset
  path <- file.path(tempdir(), "mtcars.parquet")
  write_dataset(mtcars, path)

  expect_true(file.exists(path))
  df <- open_dataset(path)
  expect_s3_class(df, "tbl")

  ## write from an on-disk dataset
  local_file <-  system.file("extdata/spatial-test.csv", package="duckdbfs")
  tbl <- open_dataset(local_file, format='csv')
  path <- file.path(tempdir(), "spatial.parquet")
  write_dataset(tbl, path)

  expect_true(file.exists(path))
  df <- open_dataset(path)
  expect_s3_class(df, "tbl")

  ## Write from a query string
  path2 <- file.path(tempdir(), "spatial2.parquet")

  tbl |>
    dplyr::mutate(new = "test") |>
    write_dataset(path2)

})

test_that("write_dataset partitions", {

  skip_on_cran()
  ## write an in-memory dataset
  path <- file.path(tempdir(), "mtcars")
  library(dplyr)

  mtcars |>
    group_by(cyl, gear) |>
    write_dataset(path)

  expect_true(file.exists(path))
  df <- open_dataset(path)
  expect_s3_class(df, "tbl")
  parts <- list.files(path)
  expect_true(any(grepl("cyl=4", parts)))

})


test_that("write_dataset, remote input", {
  skip_on_cran()
  skip_on_os("windows")
  skip_if_offline()

  tbl <- open_dataset(
    paste0("https://raw.githubusercontent.com/cboettig/duckdbfs/",
           "main/inst/extdata/spatial-test.csv"),
    format = "csv")

  path <- file.path(tempdir(), "spatial.parquet")
  write_dataset(tbl, path)

  expect_true(file.exists(path))
  df <- open_dataset(path)
  expect_s3_class(df, "tbl")

})

test_that("write_dataset to s3:", {

#  skip("S3 write not enabled")
  skip_on_os("windows")
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("minioclient")
  minioclient::install_mc(force = TRUE)
  p <- minioclient::mc_alias_ls("play --json")
  config <- jsonlite::fromJSON(p$stdout)

  minioclient::mc_mb("play/duckdbfs")

  mtcars |> group_by(cyl, gear) |>
  write_dataset(
                "s3://duckdbfs/mtcars.parquet",
                s3_access_key_id = config$accessKey,
                s3_secret_access_key = config$secretKey,
                s3_endpoint = config$URL,
                s3_use_ssl=TRUE,
                s3_url_style="path"
                )

  expect_true(TRUE)
  minioclient::mc("rb --force play/duckdbfs")

})
