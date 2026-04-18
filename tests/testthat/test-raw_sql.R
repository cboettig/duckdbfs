test_that("raw_sql returns a lazy tbl from an inline subquery", {
  cars <- tempfile(fileext = ".csv")
  write.csv(mtcars, cars, row.names = FALSE)
  open_dataset(cars, format = "csv", tblname = "cars_view")

  df <- raw_sql("SELECT mpg, cyl FROM cars_view WHERE cyl = 4")
  expect_s3_class(df, "tbl")
  out <- dplyr::collect(df)
  expect_named(out, c("mpg", "cyl"))
  expect_true(all(out$cyl == 4))

  unlink(cars)
  close_connection()
})

test_that("raw_sql with tblname creates a reusable temporary view", {
  cars <- tempfile(fileext = ".csv")
  write.csv(mtcars, cars, row.names = FALSE)
  open_dataset(cars, format = "csv", tblname = "cars_view")

  view <- raw_sql("SELECT mpg, cyl FROM cars_view", tblname = "small_cars")
  expect_s3_class(view, "tbl")

  again <- dplyr::tbl(cached_connection(), "small_cars")
  expect_equal(dplyr::collect(view), dplyr::collect(again))

  unlink(cars)
  close_connection()
})

test_that("raw_sql supports UNION ALL BY NAME across differing schemas", {
  conn <- cached_connection()
  DBI::dbExecute(conn, "CREATE OR REPLACE TEMPORARY VIEW a AS SELECT 1 AS x, 2 AS y")
  DBI::dbExecute(conn, "CREATE OR REPLACE TEMPORARY VIEW b AS SELECT 3 AS x, 4 AS z")

  df <- raw_sql("SELECT * FROM a UNION ALL BY NAME SELECT * FROM b")
  out <- dplyr::collect(df)
  expect_setequal(names(out), c("x", "y", "z"))
  expect_equal(nrow(out), 2)

  close_connection()
})
