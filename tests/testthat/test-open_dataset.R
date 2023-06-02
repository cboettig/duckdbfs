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
  ds <- open_dataset( c(f1,f2,f3), conn = conn)
  expect_s3_class(ds, "tbl")

  df <- dplyr::collect(ds)
  expect_s3_class(df, "data.frame")

})
