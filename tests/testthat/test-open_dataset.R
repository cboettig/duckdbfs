
test_that("local csv files", {
  cars <- tempfile()
  write.csv(mtcars, cars)
  df <- open_dataset(cars, format = "csv")
  expect_true(inherits(df, "tbl_duckdb_connection"))
  unlink(cars)

})





test_that("We can open remote parquet datasets over https", {

  skip_on_os("windows")
  skip_if_offline()
  skip_on_cran()

  base <- paste0("https://github.com/duckdb/duckdb/raw/master/",
                 "data/parquet-testing/hive-partitioning/union_by_name/")
  f1 <- paste0(base, "x=1/f1.parquet")
  f2 <- paste0(base, "x=1/f2.parquet")
  f3 <- paste0(base, "x=2/f2.parquet")

  conn <- cached_connection()
  ds <- open_dataset( c(f1,f2,f3), conn = conn, unify_schemas = TRUE)
  expect_s3_class(ds, "tbl")

  df <- dplyr::collect(ds)
  expect_s3_class(df, "data.frame")
  close_connection(conn)
})


test_that("We can close connections", {
  close_connection()
  close_connection()
  expect_true(TRUE)
})



test_that("We can open remote parquet datasets over s3", {

  skip_on_os("windows")
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("minioclient")

  # Put some parquet the MINIO test server:
  base <- paste0("https://github.com/duckdb/duckdb/raw/master/",
                 "data/parquet-testing/hive-partitioning/union_by_name/")
  f1 <- paste0(base, "x=1/f1.parquet")
  tmp <- tempfile(fileext = ".parquet")
  download.file(f1, tmp, quiet = TRUE)


  minioclient::mc("mb -p play/duckdbfs", verbose = FALSE)
  minioclient::mc("anonymous set download play/duckdbfs", verbose=FALSE)
  minioclient::mc_cp(tmp, "play/duckdbfs")
  f <- basename(tmp)

  #Sys.setenv("AWS_ACCESS_KEY_ID"="")
  #Sys.setenv("AWS_SECRET_ACCESS_KEY"="")

  endpoint <- "play.min.io"
  parquet <- "s3://duckdbfs/*.parquet"


  duckdb_s3_config(s3_endpoint=endpoint)
  df <- open_dataset(parquet)


  minioclient::mc_rb("play/duckdbfs")


})
