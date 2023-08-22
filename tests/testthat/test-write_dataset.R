
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

  skip("S3 write not enabled")
  skip_on_os("windows")
  skip_if_offline()
  skip_on_cran()

  minioclient::install_mc()
  p <- minioclient::mc_alias_ls("play --json")
  config <- jsonlite::fromJSON(p$stdout)

  minioclient::mc_mb("play/duckdbfs")

  write_dataset(mtcars,
                "s3://duckdbfs/test",
                s3_access_key_id = config$accessKey,
                s3_secret_access_key = config$secretKey,
                s3_endpoint = config$URL
                )

  minioclient::mc("rb play/duckdbfs")

})
