
# consider deprecating

test_that("s3 uri parsing", {

  skip_on_cran()

  url <- "s3://neon4cast-scores/parquet/aquatics"
  parts <- url_parse(url)
  expect_true(parts$scheme == "s3")
  expect_null(parts$username)
  expect_equal(parts$path, "/parquet/aquatics")

  url <- "s3://neon4cast-scores/parquet/aquatics?endpoint_url=data.ecoforecast.org"
  parts <- url_parse(url)
  expect_true(parts$scheme == "s3")
  expect_null(parts$username)
  expect_equal(parts$path, "/parquet/aquatics")
  expect_equal(parts$query[["endpoint_url"]], "data.ecoforecast.org")


  url <- "s3://user:password:token@neon4cast-scores/parquet/aquatics?endpoint_url=data.ecoforecast.org"
  parts <- url_parse(url)
  expect_true(parts$scheme == "s3")
  expect_equal(parts$username, "user")
  expect_equal(parts$password, "password")
  expect_equal(parts$token, "token")
  expect_equal(parts$path, "/parquet/aquatics")
  expect_equal(parts$query[["endpoint_url"]], "data.ecoforecast.org")

  url <- "s3://anonymous@neon4cast-scores/parquet/aquatics?endpoint_url=data.ecoforecast.org"
  parts <- url_parse(url)
  expect_equal(parts$username, "anonymous")

})
