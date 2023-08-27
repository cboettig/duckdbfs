
test_that("s3 minio", {

  skip_on_os("windows")
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("minioclient")

  # Hmm... this is quite an involved setup but...
  # Put some parquet the MINIO test server:
  base <- paste0("https://github.com/duckdb/duckdb/raw/main/",
                 "data/parquet-testing/hive-partitioning/union_by_name/")
  f1 <- paste0(base, "x=1/f1.parquet")
  tmp <- tempfile(fileext = ".parquet")
  download.file(f1, tmp, quiet = TRUE)
  minioclient::mc("mb -p play/duckdbfs", verbose = FALSE)
  minioclient::mc_cp(tmp, "play/duckdbfs")

  # allow password-less access
  minioclient::mc("anonymous set download play/duckdbfs", verbose=FALSE)

  # Could set passwords here if necessary
  duckdb_s3_config(s3_endpoint = "play.min.io",
                   s3_url_style="path")
  df <- open_dataset("s3://duckdbfs/")

  expect_s3_class(df, "tbl")
  expect_s3_class(df, "tbl_duckdb_connection")

  minioclient::mc("rb --force play/duckdbfs", verbose = FALSE)

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

  library(dplyr)

  mtcars |> group_by(cyl, gear) |>
  write_dataset("s3://duckdbfs/mtcars",
                s3_access_key_id = config$accessKey,
                s3_secret_access_key = config$secretKey,
                s3_endpoint = config$URL,
                s3_use_ssl=TRUE,
                s3_url_style="path"
  )

  expect_true(TRUE)
  minioclient::mc("rb --force play/duckdbfs")

})
