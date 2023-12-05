

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


test_that("spatial_join", {


  skip_if_not_installed("sf")
  skip_on_os("windows") # come on duckdb, support extensions on windows
  skip_if_offline() # needs to be able to load the spatial module
  skip_on_cran()

  countries <-
  paste0("/vsicurl/",
         "https://github.com/cboettig/duckdbfs/",
         "raw/spatial-read/inst/extdata/world.gpkg") |>
  open_dataset()

  cities <-
   paste0("/vsicurl/https://github.com/cboettig/duckdbfs/raw/",
          "spatial-read/inst/extdata/metro.fgb") |>
   open_dataset()

  out <-
    countries |>
    dplyr::filter(iso_a3 == "AUS") |>
    spatial_join(cities)

  expect_s3_class(out, "tbl_lazy")

  local <- to_sf(out)
  expect_s3_class(local, "sf")
  expect_true(all(local$iso_a3 == "AUS"))

  ## add examples of other types of spatial joins
})

