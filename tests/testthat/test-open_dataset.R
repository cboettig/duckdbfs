
test_that("local csv files", {
  cars <- tempfile()
  write.csv(mtcars, cars)
  df <- open_dataset(cars, format = "csv")
  expect_true(inherits(df, "tbl_duckdb_connection"))
  unlink(cars)

  close_connection()


})

test_that("duckdb_s3_config", {

  skip_if_offline()
  skip_on_os("windows")
  skip_on_cran()
  status <- duckdb_s3_config(
             s3_access_key_id = "YOUR_ACCESS_KEY_ID",
             s3_secret_access_key = "YOUR_SECRET_ACCESS_KEY",
             s3_endpoint = "YOUR_S3_ENDPOINT",
             s3_region = "YOUR_S3_REGION",
             s3_uploader_max_filesize = "800GB",
             s3_uploader_max_parts_per_file = 1000,
             s3_url_compatibility_mode = FALSE,
             s3_url_style = "vhost",
             s3_use_ssl = TRUE)

  expect_identical(status, 0)


})


test_that("https", {

  skip_on_os("windows")
  skip_if_offline()
  skip_on_cran()

  base <- paste0("https://github.com/duckdb/duckdb/raw/main/",
                 "data/parquet-testing/hive-partitioning/union_by_name/")
  f1 <- paste0(base, "x=1/f1.parquet")
  f2 <- paste0(base, "x=1/f2.parquet")
  f3 <- paste0(base, "x=2/f2.parquet")

  conn <- cached_connection()
  ds <- open_dataset( c(f1,f2,f3),
                      conn = conn,
                      unify_schemas = TRUE)
  expect_s3_class(ds, "tbl")

  df <- dplyr::collect(ds)
  expect_s3_class(df, "data.frame")
  close_connection(conn)
})


test_that("close_connection", {

  skip_on_cran()

  close_connection()
  close_connection()
  expect_true(TRUE)
})



test_that("s3", {

  skip_on_os("windows")
  skip_if_offline()
  skip_on_cran()
  close_connection()
  parquet <- "s3://gbif-open-data-us-east-1/occurrence/2023-06-01/occurrence.parquet"
  gbif <- open_dataset(parquet,
                       anonymous = TRUE,
                       s3_region="us-east-1")
  expect_s3_class(gbif, "tbl_dbi")
  expect_s3_class(gbif, "tbl")

})
