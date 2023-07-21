
test_that("local csv files", {
  cars <- tempfile()
  write.csv(mtcars, cars)
  df <- open_dataset(cars, format = "csv", threads=1)
  expect_true(inherits(df, "tbl_duckdb_connection"))
  unlink(cars)

})

test_that("duckdb_s3_config", {

  skip_on_os("windows")
  skip_if_offline()
  skip_on_cran()
  duckdb_s3_config(
             s3_access_key_id = "YOUR_ACCESS_KEY_ID",
             s3_secret_access_key = "YOUR_SECRET_ACCESS_KEY",
             s3_endpoint = "YOUR_S3_ENDPOINT",
             s3_region = "YOUR_S3_REGION",
             s3_uploader_max_filesize = "800GB",
             s3_uploader_max_parts_per_file = 1000,
             s3_url_compatibility_mode = FALSE,
             s3_url_style = "vhost",
             s3_use_ssl = TRUE)



})


test_that("https", {

  skip_on_os("windows")
  skip_if_offline()
  skip_on_cran()

  base <- paste0("https://github.com/duckdb/duckdb/raw/master/",
                 "data/parquet-testing/hive-partitioning/union_by_name/")
  f1 <- paste0(base, "x=1/f1.parquet")
  f2 <- paste0(base, "x=1/f2.parquet")
  f3 <- paste0(base, "x=2/f2.parquet")

  conn <- cached_connection()
  ds <- open_dataset( c(f1,f2,f3),
                      conn = conn,
                      unify_schemas = TRUE,
                      threads=1)
  expect_s3_class(ds, "tbl")

  df <- dplyr::collect(ds)
  expect_s3_class(df, "data.frame")
  close_connection(conn)
})


test_that("close_connection", {
  close_connection()
  close_connection()
  expect_true(TRUE)
})



test_that("s3", {

  skip_on_os("windows")
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("minioclient")

  # Hmm... this is quite an involved setup but...
  # Put some parquet the MINIO test server:
  base <- paste0("https://github.com/duckdb/duckdb/raw/master/",
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
  df <- open_dataset("s3://duckdbfs/*.parquet", threads=1)

  expect_s3_class(df, "tbl")
  expect_s3_class(df, "tbl_duckdb_connection")


})
