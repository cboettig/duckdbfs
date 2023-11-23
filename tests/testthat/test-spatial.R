

test_that("spatial", {
  skip_on_os("windows") # come on duckdb, support extensions on windows
  skip_if_offline() # needs to be able to load the spatial module
  skip_if_not_installed("sf")
  skip_on_cran()

  library(dplyr)
  library(sf)
  ex <- system.file("extdata/spatial-test.csv", package="duckdbfs") |>
  open_dataset(format = "csv") |>
  dplyr::mutate(geometry = ST_Point(longitude, latitude)) |>
  to_sf()

  expect_true(TRUE)

})

test_that("spatial vector read", {

  skip_if_not_installed("sf")
  skip_on_os("windows") # come on duckdb, support extensions on windows
  skip_if_offline() # needs to be able to load the spatial module
  skip_on_cran()

  # lazy-read external data (/vsicurl/ urls work too!)
  path <- system.file("extdata/world.gpkg", package = "duckdbfs")
  x <- open_dataset(path, format = "sf")

  # read into R
  y <- x |> to_sf()

  expect_s3_class(x, "tbl_lazy")
  expect_s3_class(x, "tbl")
  expect_s3_class(y, "sf")

})

