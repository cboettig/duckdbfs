

test_that("spatial", {

  # what's going on with curl?
  #print(curl::nslookup("r-project.org", error = FALSE))
  # skip_if_offline() # needs to be able to load the spatial module

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
