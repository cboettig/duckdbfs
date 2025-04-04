
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

  dataset <- tbl |>
    dplyr::mutate(new = "test")
  dataset |>
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

  expect_true(dir.exists(path))
  df <- open_dataset(path)
  expect_s3_class(df, "tbl")
  parts <- list.files(path)
  expect_true(any(grepl("cyl=4", parts)))

  path <- file.path(tempdir(), "mtcars2")
  mtcars |> write_dataset(path, partitioning = "cyl", overwrite=TRUE)
  expect_true(file.exists(path))
  df <- open_dataset(path)
  expect_s3_class(df, "tbl")

})


test_that("write_dataset, remote input", {
  skip_on_cran()
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

  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("minioclient")
  minioclient::install_mc(force = TRUE)

  skip_on_os("windows")
  p <- minioclient::mc_alias_ls("play --json")
  config <- jsonlite::fromJSON(p$stdout)

  minioclient::mc_mb("play/duckdbfs")

  duckdb_secrets(config$accessKey, config$secretKey, gsub("https://", "", config$URL))

  mtcars |> dplyr::group_by(cyl, gear) |>
  write_dataset("s3://duckdbfs/mtcars.parquet")

  expect_true(TRUE)
  minioclient::mc("rb --force play/duckdbfs")

  close_connection()
})

mc_config_get <- function(alias="play"){

  # this can fail tp parse on windows, stdout is not pure json
  # p <- minioclient::mc_alias_ls(paste(alias, "--json"))
  # config <- jsonlite::fromJSON(p$stdout)

  ## fails to find config on remote
  path <- getOption("minioclient.dir", tools::R_user_dir("minioclient", "data"))
  json <- jsonlite::read_json(file.path(path, "config.json"))
  config <- json$aliases[[alias]]
  config$alias <- alias
  config$URL <- config$url
  config
}






test_that("write_geo", {

  skip_on_cran()
  skip_if_not_installed("sf")

  ## write from an on-disk dataset
  local_file <-  system.file("extdata/spatial-test.csv", package="duckdbfs")
  load_spatial()
  tbl <- open_dataset(local_file, format='csv')
  path <- file.path(tempdir(), "spatial.geojson")
  write_geo(tbl, path)

  expect_true(file.exists(path))
  df <- sf::st_read(path)
  expect_s3_class(df, "sf")

})



